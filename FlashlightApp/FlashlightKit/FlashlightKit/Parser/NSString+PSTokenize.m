//
//  NSString+PSTokenize.m
//  Parsnip
//
//  Created by Nate Parrott on 12/19/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "NSString+PSTokenize.h"
#import "PSHelpers.h"

@implementation PSToken

- (id)copy {
    PSToken *copy = [PSToken new];
    copy.features = self.features;
    copy.boundaryAfter = self.boundaryAfter;
    copy.original = self.original;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@>", self.original];
}

@end

@implementation NSString (PSTokenize)

- (NSArray *)ps_tokenize {
    NSMutableArray *tokens = [NSMutableArray new];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeTokenType] options:0];
    tagger.string = self;
    __block NSString *prevText = nil;
    [tagger enumerateTagsInRange:NSMakeRange(0, self.length) scheme:NSLinguisticTagSchemeTokenType options:0 usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *text = [self substringWithRange:tokenRange];
        if ([tag isEqualToString:NSLinguisticTagWhitespace]) {
            // append to last token as `boundaryAfter`
            [tokens.lastObject setBoundaryAfter:[([tokens.lastObject boundaryAfter] ? : @"") stringByAppendingString:text]];
        } else {
            PSToken *token = [PSToken new];
            token.original = text;
            NSString *bigram = [NSString stringWithFormat:@"%@-%@", prevText, text];
            prevText = text;
            token.features = @[token.original, bigram];
            [tokens addObject:token];
        }
    }];
    return tokens;
}

@end
