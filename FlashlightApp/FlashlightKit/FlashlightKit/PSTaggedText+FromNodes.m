//
//  PSTaggedText+FromNodes.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText+FromNodes.h"
#import "PSNonterminalNode.h"
#import "PSTerminalNode.h"
#import "PSSpecialNode.h"
#import "PSHelpers.h"
#import "NSString+PSTokenize.h"

@implementation PSTaggedText (FromNodes)

+ (PSTaggedText *)withNode:(PSNonterminalNode *)node {
    PSTaggedText *text = [PSTaggedText new];
    text.tag = node.tag;
    NSMutableArray *contents = [NSMutableArray new];
    for (id<PSNode> child in node.children) {
        if ([child isKindOfClass:[PSNonterminalNode class]]) {
            [contents addObject:[PSTaggedText withNode:child]];
        } else if ([child isKindOfClass:[PSTerminalNode class]]) {
            PSToken *token = [(PSTerminalNode *)child token];
            NSString *text = token.original;
            if (token.boundaryAfter) {
                text = [text stringByAppendingString:token.boundaryAfter];
            }
            if ([[contents lastObject] isKindOfClass:[NSString class]]) {
                NSString *last = [contents lastObject];
                [contents removeLastObject];
                [contents addObject:[last stringByAppendingString:text]];
            } else {
                [contents addObject:text];
            }
        } // } else { // drop PSSpecialNodes }
    }
    text.contents = [contents mapFilter:^id(NSString *obj) {
        if ([obj isKindOfClass:[NSString class]]) {
            return [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else {
            return obj;
        }
    }];
    return text;
}

@end
