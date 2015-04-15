//
//  Parsnip.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "Parsnip.h"
#import "PSTaggedText.h"
#import "PSTerminalNode.h"
#import "PSNonterminalNode.h"
#import "PSHelpers.h"
#import "PSProbabilityCounter.h"
#import "PSParseCandidate.h"
#import "PSStartNode.h"
#import "PSEndNode.h"
#import "NSString+PSTokenize.h"
#import "PSMerging.h"
#import "PSTaggedText+FromNodes.h"
#import "PSTaggedText+PreprocessedForLearning.h"

const NSInteger PSMaxDepth = 10;
const NSInteger PSMaxRecursion = 6;
const NSInteger PSMaxCandidatesPerRound = 50;

@interface Parsnip ()

@property (nonatomic) NSMutableDictionary *tagsForExternalTags, *emissionProbs, *transitionProbsForTags, *probBoosts;
// transitionProbsForStates: [tag: [previous external tag: <probability counter>]]
// emissionProbs: [terminalTagName: [feature: <probability counter>]]

@property (nonatomic) NSArray *boostsForEarlyTokens;

@end

@implementation Parsnip

- (id)init {
    self = [super init];
    self.tagsForExternalTags = [NSMutableDictionary new];
    self.emissionProbs = [NSMutableDictionary new];
    self.transitionProbsForTags = [NSMutableDictionary new];
    self.probBoosts = [NSMutableDictionary new];
    self.boostsForEarlyTokens = @[@1.25, @1.125];
    return self;
}

#pragma mark Learning
- (void)learnExamples:(NSArray *)examples {
    for (PSTaggedText *example in examples) {
        [self learnExample:[example preprocessedForLearning]];
    }
}

- (void)learnExample:(PSTaggedText *)example {
    PSNonterminalNode *node = example.toNode;
    [self learnExampleFromNode:node];
    [node enumerateAllTransitions:^(NSString *insideState, NSString *fromExternalState, NSString *toExternalState) {
        NSMutableDictionary *probsForPreviousTagsInsideThisTag = [self.transitionProbsForTags objectForKey:insideState settingDefaultToValue:^id{
            return [NSMutableDictionary new];
        }];
        PSProbabilityCounter *probCounter = [probsForPreviousTagsInsideThisTag objectForKey:fromExternalState settingDefaultToValue:^id{
            return [PSProbabilityCounter new];
        }];
        [probCounter addItem:toExternalState];
    }];
}

- (void)learnExampleFromNode:(id<PSNode>)node {
    [self learnTagsForExternalTagsFromNode:node];
    if ([node isKindOfClass:[PSNonterminalNode class]]) {
        PSNonterminalNode *nonTerm = node;
        for (id<PSNode> child in nonTerm.children) {
            [self learnExampleFromNode:child];
        }
    } else if ([node isKindOfClass:[PSTerminalNode class]]) {
        // add to emission probs:
        PSTerminalNode *terminal = node;
        PSProbabilityCounter *probCounter = [self.emissionProbs objectForKey:terminal.tag settingDefaultToValue:^id{
            return [PSProbabilityCounter new];
        }];
        if (![terminal.token.original isEqualToString:@"___"]) {
            // ignore examples that are just ___ (three _'s)
            for (id feature in terminal.token.features) {
                [probCounter addItem:feature];
            }
        }
    }
}

- (void)learnTagsForExternalTagsFromNode:(id<PSNode>)node {
    NSMutableSet *set = [self.tagsForExternalTags objectForKey:[node externalTag] settingDefaultToValue:^id{
        return [NSMutableSet new];
    }];
    [set addObject:[node tag]];
}

#pragma mark Parsing
- (PSParseCandidate *)parseText:(NSString *)text intoTag:(NSString *)rootTag {
    return [self parseText:text intoCandidatesForTag:rootTag].firstObject;
}

- (NSArray *)parseText:(NSString *)text intoCandidatesForTag:(NSString *)rootTag {
    NSArray *candidates = [self initialCandidatesForRootTag:rootTag];
    NSInteger i = 0;
    for (PSToken *token in [text ps_tokenize]) {
        double tokenBoostBasedOnIndex = i < self.boostsForEarlyTokens.count ? [self.boostsForEarlyTokens[i] doubleValue] : 1;
        NSMutableDictionary *newCandidates = [NSMutableDictionary new];
        for (PSParseCandidate *candidate in candidates) {
            [self addNewCandidatesToDictionary:newCandidates withCandidate:candidate addingToken:token remainingRecursions:PSMaxRecursion boost:tokenBoostBasedOnIndex];
        }
        candidates = [self trimCandidateSet:newCandidates.allValues];
        i++;
    }
    for (PSParseCandidate *candidate in candidates) {
        candidate.logProb += [self probabilityOfCandidateEnding:candidate];
    }
    candidates = [candidates sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"logProb" ascending:NO]]];
    /*for (PSParseCandidate *c in candidates) {
        NSLog(@"Candidate: %f, %@", c.logProb, [PSTaggedText withNode:c.node]);
    }*/
    return candidates;
}

- (void)addNewCandidatesToDictionary:(NSMutableDictionary *)dict withCandidate:(PSParseCandidate *)candidate addingToken:(PSToken *)token remainingRecursions:(NSInteger)recursions boost:(double)boostFactor {
    if (recursions == 0) return;
    PSNonterminalNode *curNode = [candidate.node currentNonterminal];
    if (!curNode) {
        return; // all nodes have closed already; this candidate finished prematurely
    }
    PSProbabilityCounter *transitions = self.transitionProbsForTags[curNode.tag][[curNode.children.lastObject externalTag]];
    for (NSString *externalNextTag in transitions.allItems) {
        double logProb = [transitions smoothedLogProbForItem:externalNextTag];
        for (NSString *nextTag in self.tagsForExternalTags[externalNextTag]) {
            if ([PSTerminalNode isNameOfTerminalNode:nextTag]) {
                // okay, consume this token and finish:
                double emissionProb = [self logProbOfEmissionOfToken:token fromTerminalNodeNamed:nextTag] * boostFactor;
                PSTerminalNode *newTerminal = [PSTerminalNode new];
                newTerminal.tag = nextTag;
                newTerminal.token = token;
                PSParseCandidate *newCandidate = [candidate copy];
                [newCandidate.node currentNonterminal].children = [newCandidate.node.currentNonterminal.children arrayByAddingObject:newTerminal];
                newCandidate.logProb += emissionProb + logProb;
                [self addCandidate:newCandidate toDictionary:dict];
            } else {
                // not adding a new terminal node yet; create a new candidate and recur:
                PSParseCandidate *newCandidate = [candidate copy];
                newCandidate.logProb += logProb - PSMinimalProbability; // deduct a little bit during every recursion as a complexity penality
                newCandidate.logProb += [self.probBoosts[nextTag] doubleValue];
                id<PSNode> nodeToAdd = nil;
                if ([PSEndNode isNameOfEndNode:nextTag]) {
                    nodeToAdd = [PSEndNode new];
                } else {
                    PSNonterminalNode *newNonterminal = [PSNonterminalNode new];
                    newNonterminal.tag = nextTag;
                    newNonterminal.children = @[[PSStartNode new]];
                    nodeToAdd = newNonterminal;
                }
                newCandidate.node.currentNonterminal.children = [newCandidate.node.currentNonterminal.children arrayByAddingObject:nodeToAdd];
                // recur:
                [self addNewCandidatesToDictionary:dict withCandidate:newCandidate addingToken:token remainingRecursions:recursions-1 boost:boostFactor];
            }
        }
    }
}

- (double)logProbOfEmissionOfToken:(PSToken *)token fromTerminalNodeNamed:(NSString *)tagName {
    if ([PSTerminalNode isNameOfFreeTextNode:tagName]) {
        return PSSmoothLogProb(PSLogProb(PSFreeTextProbability)) * token.features.count;
    } else {
        PSProbabilityCounter *counter = self.emissionProbs[tagName];
        double logProb = 0;
        for (id feature in token.features) {
            logProb += [counter specialTextProbabilityForItem:feature];
        }
        return logProb;
    }
}

- (double)probabilityOfCandidateEnding:(PSParseCandidate *)candidate {
    double logProb = 0;
    for (id<PSNode> node in [candidate.node nodeStackAtEnd]) {
        if ([node isKindOfClass:[PSNonterminalNode class]]) {
            PSNonterminalNode *nonterminal = node;
            if (![nonterminal isClosed]) {
                PSProbabilityCounter *probCounter = self.transitionProbsForTags[nonterminal.tag][[nonterminal.children.lastObject externalTag]];
                logProb += probCounter ? [probCounter smoothedLogProbForItem:[[PSEndNode new] externalTag]] : PSLogProb(PSMinimalProbability);
            }
        }
    }
    return logProb;
}

- (void)addCandidate:(PSParseCandidate *)candidate toDictionary:(NSMutableDictionary *)dictionary {
    NSString *identifier = candidate.identifier;
    if (dictionary[identifier]==nil || candidate.logProb > [dictionary[identifier] logProb]) {
        dictionary[identifier] = candidate;
    }
}

- (NSArray *)trimCandidateSet:(NSArray *)candidates {
    NSArray *filtered = [candidates mapFilter:^id(id obj) {
        NSInteger depth = [[[obj node] nodeStackAtEnd] count];
        return depth <= PSMaxDepth ? obj : nil;
    }];
    NSArray *sorted = [filtered sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"logProb" ascending:NO]]];
    return [sorted subarrayWithRange:NSMakeRange(0, MIN(sorted.count, PSMaxCandidatesPerRound))];
}

- (NSArray *)initialCandidatesForRootTag:(NSString *)rootTag {
    return [[self.tagsForExternalTags[rootTag] allObjects] mapFilter:^id(id obj) {
        PSParseCandidate *c = [PSParseCandidate new];
        c.node = [PSNonterminalNode new];
        c.node.tag = obj;
        c.node.children = @[[PSStartNode new]];
        return c;
    }];
}

#pragma mark Debugging
- (void)printData {
    NSLog(@"TAGS FOR EXTERNAL TAGS: %@\n\n", self.tagsForExternalTags);
    NSLog(@"EMISSION PROBS: %@\n\n", self.emissionProbs);
    NSLog(@"TRANSITION PROBS: %@\n\n", self.transitionProbsForTags);
}

#pragma mark Merging

- (instancetype)initWithOtherParsnips:(NSArray *)parsnips {
    self = [self init];
    for (Parsnip *ps in parsnips) {
        [self.tagsForExternalTags ps_mergeWith:ps.tagsForExternalTags allowUnmergeableTypes:NO];
        [self.emissionProbs ps_mergeWith:ps.emissionProbs allowUnmergeableTypes:NO];
        [self.transitionProbsForTags ps_mergeWith:ps.transitionProbsForTags allowUnmergeableTypes:NO];
        [self.probBoosts ps_mergeWith:ps.probBoosts allowUnmergeableTypes:YES];
    }
    return self;
}

#pragma mark Boosts

- (void)setLogProbBoost:(double)boost forTag:(NSString *)tag {
    self.probBoosts[tag] = @(boost);
}

@end
