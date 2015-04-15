//
//  PSTaggedText.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText.h"
#import "PSNonterminalNode.h"
#import "PSTerminalNode.h"
#import "PSHelpers.h"
#import "PSStartNode.h"
#import "PSEndNode.h"
#import "NSString+PSTokenize.h"

@implementation PSTaggedText

- (PSNonterminalNode *)toNode {
    PSNonterminalNode *node = [PSNonterminalNode new];
    node.tag = self.tag;
    __block NSInteger i = 0;
    __block id prevTagName = [[PSStartNode new] externalTag];
    NSMutableArray *children = [self.contents flatMap:^NSArray*(id obj) {
        i++;
        if ([obj isKindOfClass:[PSTaggedText class]]) {
            PSNonterminalNode *child = [obj toNode];
            prevTagName = child.externalTag;
            return @[child];
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSArray *contentsAfter = [self.contents subarrayWithRange:NSMakeRange(i, self.contents.count-i)];
            NSString *nextTagName = [[self class] _externalNameOfFirstTaggedTextInstance:contentsAfter] ? : [PSEndNode new].externalTag;
            NSString *tag = [PSTerminalNode terminalNodeNameFromParentTag:node.tag prev:prevTagName next:nextTagName];
            return [[obj ps_tokenize] mapFilter:^id(id obj) {
                PSTerminalNode *terminal = [PSTerminalNode new];
                terminal.tag = tag;
                terminal.token = obj;
                return terminal;
            }];
        } else {
            assert(0);
            return nil; // should not happen
        }
    }].mutableCopy;
    [children insertObject:[PSStartNode new] atIndex:0];
    [children addObject:[PSEndNode new]];
    node.children = children;
    return node;
}

+ (NSString *)_externalNameOfFirstTaggedTextInstance:(NSArray *)contents {
    for (id item in contents) {
        if ([item isKindOfClass:[PSTaggedText class]]) {
            return [PSNonterminalNode convertTagToExternal:[item tag]];
        }
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", self.tag, [[self.contents mapFilter:^id(id obj) {
        return [obj description];
    }] componentsJoinedByString:@" "]];
}

- (NSString *)getText {
    return [[self.contents mapFilter:^id(id obj) {
        if ([obj isKindOfClass:[NSString class]]) {
            return obj;
        } else if ([obj isKindOfClass:[PSTaggedText class]]) {
            return [obj getText];
        } else {
            return nil;
        }
    }] componentsJoinedByString:@" "];
}

- (PSTaggedText *)findChild:(NSString *)childTag {
    for (id item in self.contents) {
        if ([item isKindOfClass:[PSTaggedText class]]) {
            NSString *externalTag = [PSNonterminalNode convertTagToExternal:[item tag]];
            if ([[item tag] isEqualToString:childTag] || [externalTag isEqualToString:childTag]) {
                return item;
            }
            id found = [item findChild:childTag];
            if (found) {
                return found;
            }
        }
    }
    return nil;
}

@end

PSTaggedText *Tagged(NSString *tag, NSArray *contents) {
    PSTaggedText *t = [PSTaggedText new];
    t.tag = tag;
    t.contents = contents;
    return t;
}
