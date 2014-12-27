//
//  PSNonterminalNode.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSNonterminalNode.h"
#import "PSHelpers.h"
#import "PSEndNode.h"

@implementation PSNonterminalNode

- (NSString *)externalTag {
    return [[self class] convertTagToExternal:self.tag];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", self.tag, [[self.children mapFilter:^id(id obj) {
        return [obj description];
    }] componentsJoinedByString:@" "]];
}

+ (NSString *)convertTagToExternal:(NSString *)tag {
    return [tag componentsSeparatedByString:@"/"].firstObject;
}

- (void)enumerateAllTransitions:(void(^)(NSString *insideState, NSString *fromExternalState, NSString *toExternalState))callback {
    for (NSInteger i=1; i<self.children.count; i++) {
        id<PSNode> prev = self.children[i-1];
        id<PSNode> cur = self.children[i];
        callback(self.tag, [prev externalTag], [cur externalTag]);
    }
    for (id<PSNode> node in self.children) {
        if ([node isKindOfClass:[PSNonterminalNode class]]) {
            [(PSNonterminalNode *)node enumerateAllTransitions:callback];
        }
    }
}

- (BOOL)isClosed {
    return [self.children.lastObject isKindOfClass:[PSEndNode class]];
}

- (NSArray *)nodeStackAtEnd {
    NSMutableArray *stack = [NSMutableArray new];
    id<PSNode> node = self;
    while (1) {
        [stack addObject:node];
        if ([node isKindOfClass:[PSNonterminalNode class]]) {
            node = [(PSNonterminalNode *)node children].lastObject;
        } else {
            break;
        }
    }
    return stack;
}

- (PSNonterminalNode *)currentNonterminal {
    NSArray *stack = [self nodeStackAtEnd];
    for (id<PSNode> node in [stack reverseObjectEnumerator]) {
        if ([node isKindOfClass:[PSNonterminalNode class]] && ![(PSNonterminalNode *)node isClosed]) {
            return (id)node;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (id)copy {
    PSNonterminalNode *copy = [PSNonterminalNode new];
    copy.tag = self.tag;
    copy.children = [self.children mapFilter:^id(id obj) {
        return [obj copy];
    }];
    return copy;
}

@end
