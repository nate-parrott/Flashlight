//
//  PSTaggedText+ParseExample.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText+ParseExample.h"

@implementation PSTaggedText (ParseExample)

+ (PSTaggedText *)withExampleString:(NSString *)example rootTag:(NSString *)rootTag {
    static NSRegularExpression *openOrCloseRegex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        openOrCloseRegex = [NSRegularExpression regularExpressionWithPattern:@"(([a-zA-Z_~@\\*\\/]+)\\(+|\\))" options:0 error:nil];
    });
    
    NSMutableArray *rootContents = [NSMutableArray new];
    PSTaggedText *root = [PSTaggedText new];
    root.contents = rootContents;
    root.tag = rootTag;
    
    NSMutableArray *stack = [NSMutableArray arrayWithObject:rootContents];
    __block NSInteger lastIndex = 0;
    
    void (^gotText)(NSString *) = ^(NSString *text){
        NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmed.length > 0) {
            [stack.lastObject addObject:trimmed];
        }
    };
    
    __block BOOL errored = NO;
    
    [openOrCloseRegex enumerateMatchesInString:example options:0 range:NSMakeRange(0, example.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *previousText = [example substringWithRange:NSMakeRange(lastIndex, result.range.location - lastIndex)];
        gotText(previousText);
        NSRange nameOfOpenedTag = [result rangeAtIndex:2];
        if (nameOfOpenedTag.location != NSNotFound) {
            // open paren:
            PSTaggedText *nestedTag = [PSTaggedText new];
            nestedTag.tag = [example substringWithRange:nameOfOpenedTag];
            NSMutableArray *nestedContents = [NSMutableArray new];
            nestedTag.contents = nestedContents;
            [stack.lastObject addObject:nestedTag];
            [stack addObject:nestedContents];
        } else {
            // this is a closing tag:
            if (stack.count == 1) {
                // the stack can't be empty, so fail:
                errored = YES;
                *stop = YES;
            } else {
                // it's valid
                [stack removeLastObject];
            }
        }
        lastIndex = result.range.location + result.range.length;
    }];
    
    gotText([example substringWithRange:NSMakeRange(lastIndex, example.length - lastIndex)]);
    
    return errored ? nil : root;
}

@end
