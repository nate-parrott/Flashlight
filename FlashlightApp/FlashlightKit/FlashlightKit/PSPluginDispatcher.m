//
//  PSPluginDispatcher.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/23/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSPluginDispatcher.h"
#import "Parsnip.h"
#import "PSPluginExampleSource.h"
#import "PSBackgroundProcessor.h"
#import "PSHelpers.h"
#import "PSNonterminalNode.h"
#import "PSTaggedText+FromNodes.h"
#import "PSTaggedText+ToNestedDictionaries.h"
#import "PSParseCandidate.h"

#import "PSParsnipSource.h"
#import "PSDateSource.h"
#import "PSContactSource.h"
#import "PSFileSource.h"

@interface PSPluginDispatcher ()

@property (nonatomic) NSMutableDictionary *latestResultsDictionariesForSourceIdentifiers;
@property (nonatomic) NSMutableArray *sources;
@property (nonatomic) PSBackgroundProcessor *parsnipCreator;

@end

@implementation PSPluginDispatcher

- (instancetype)init {
    self = [super init];
    
    self.parsnipCreator = [[PSBackgroundProcessor alloc] initWithProcessingBlock:^(NSDictionary *latestResultsDictionariesForSourceIdentifiers, PSBackgroundProcessorResultBlock callback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray *parsnips = [latestResultsDictionariesForSourceIdentifiers.allValues mapFilter:^id(NSDictionary *data) {
                return data[PSParsnipSourceDataParsnipKey];
            }];
            Parsnip *ps = [[Parsnip alloc] initWithOtherParsnips:parsnips];
            callback(ps);
        });
    }];
    self.latestResultsDictionariesForSourceIdentifiers = [NSMutableDictionary new];
    self.sources = [NSMutableArray new];
    [self addSourceWithClass:[PSPluginExampleSource class] identifier:@"plugins"];
    [self addSourceWithClass:[PSDateSource class] identifier:@"date"];
    [self addSourceWithClass:[PSContactSource class] identifier:@"contact"];
    [self addSourceWithClass:[PSFileSource class] identifier:@"file"];
    
    return self;
}

- (void)addSourceWithClass:(Class)class identifier:(NSString *)identifier {
    __weak PSPluginDispatcher *weakSelf = self;
    PSParsnipSource *source = [[class alloc] initWithIdentifier:identifier callback:^(NSString *identifier, NSDictionary *data) {
        @synchronized(weakSelf) {
            weakSelf.latestResultsDictionariesForSourceIdentifiers[identifier] = data;
            [weakSelf.parsnipCreator gotNewData:weakSelf.latestResultsDictionariesForSourceIdentifiers.copy];
            
            NSDictionary *fieldProcessors = data[PSParsnipSourceFieldProcessorsDictionaryKey];
            if (fieldProcessors) {
                [[weakSelf class] updateFieldProcessorsDict:fieldProcessors];
            }
        }
    }];
    [self.sources addObject:source];
}

- (void)parseCommand:(NSString *)command pluginPath:(NSString **)pluginPath arguments:(NSDictionary **)arguments parseTree:(PSTaggedText **)tree {
    Parsnip *mainParsnip;
    NSDictionary *pluginPathsForIntents;
    @synchronized(self) {
        mainParsnip = self.parsnipCreator.latestResult;
        pluginPathsForIntents = self.latestResultsDictionariesForSourceIdentifiers[@"plugins"][PSParsnipSourceDataPluginPathForIntentDictionaryKey];
    }
    NSArray *results = [mainParsnip parseText:command intoCandidatesForTag:@"plugin_intent"];
    PSParseCandidate *result = [self outstandingResultFromResults:results];
    if (result) {
        *pluginPath = pluginPathsForIntents[result.node.tag];
        *arguments = [[PSTaggedText withNode:result.node] toNestedDictionary];
        *tree = [PSTaggedText withNode:result.node];
    } else {
        // no match:
        *pluginPath = nil;
        *arguments = nil;
        *tree = nil;
    }
}

- (PSParseCandidate *)outstandingResultFromResults:(NSArray *)results {
    /*
     The parser returns an array of candidates ordered by probability DESC.
     There are 3 types: 
     plugin_intent/plugin_name, (we've parsed the command as a plugin invocation)
     plugin_intent/<NOT>plugin_name, (we've parsed this as a counter example — if the counter-example's prob is greater than the plugin intent's prob, don't invoke the plugin)
     plugin_intent/<NULL> : the null example. don't match ANY plugin.
     */
    // plugin_intent/<NULL>
    // plugin_intent/<NOT>
    NSString * const nullIntent = @"plugin_intent/<NULL>";
    NSString * const counterexampleIntentPrefix = @"plugin_intent/<NOT>";
    NSString * const exampleIntentPrefix = @"plugin_intent/";
    NSMutableSet *intentsWhereCounterexamplesAlreadyMatched = [NSMutableSet new];
    for (PSParseCandidate *candidate in results) {
        NSString *tag = candidate.node.tag;
        if ([tag isEqualToString:nullIntent]) {
            return nil;
        } else if ([tag startsWith:counterexampleIntentPrefix]) {
            NSString *intent = [tag substringFromIndex:counterexampleIntentPrefix.length];
            [intentsWhereCounterexamplesAlreadyMatched addObject:intent];
        } else {
            NSAssert(tag.length > exampleIntentPrefix.length, @"Found result tag '%@' which doesn't start with 'exampleIntentPrefix'", tag);
            NSString *intent = [tag substringFromIndex:exampleIntentPrefix.length];
            if (![intentsWhereCounterexamplesAlreadyMatched containsObject:intent]) {
                return candidate; // this candidate is a plugin invocation, and we haven't already matched its counterexamples.
            }
        }
    }
    return nil;
}

- (PSPluginExampleSource *)exampleSource {
    for (PSParsnipSource *source in self.sources) {
        if ([source.identifier isEqualToString:@"plugins"]) {
            return (id)source;
        }
    }
    return nil;
}

#pragma mark Field Processors
+ (PSParsnipFieldProcessor)fieldProcessorForTag:(NSString *)tag {
    NSMutableDictionary *d = [self fieldProcessors];
    @synchronized(d) {
        PSParsnipFieldProcessor p = d[tag];
        if (p) return p;
        p = d[[PSNonterminalNode convertTagToExternal:tag]];
        return p;
    }
}

+ (void)updateFieldProcessorsDict:(NSDictionary *)procs {
    NSMutableDictionary *d = [self fieldProcessors];
    @synchronized(d) {
        [d addEntriesFromDictionary:procs];
    }
}

+ (NSMutableDictionary *)fieldProcessors {
    static NSMutableDictionary *fieldProcs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fieldProcs = [NSMutableDictionary new];
    });
    return fieldProcs;
}

@end
