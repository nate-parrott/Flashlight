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

+ (void)initialize {
    [super initialize];
    NSLog(@"testing stemming");
    for (NSString *word in @[@"test", @"testing", @"tested", @"untested"]) {
        NSLog(@"Stem of %@: %@", word, [word stem]);
    }
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
            NSArray *features = @[token.original, bigram];
            token.features = [features mapFilter:^id(id obj) {
                return [obj lowercaseString];
            }];
            [tokens addObject:token];
        }
    }];
    return tokens;
}

- (NSString *)stem {
    // TODO: use a thread-local tagger
    static NSLinguisticTagger *tagger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeLemma] options:NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerOmitWhitespace];
    });
    __block NSString *stem = self;
    @synchronized(tagger) {
        tagger.string = self;
        [tagger enumerateTagsInRange:NSMakeRange(0, self.length) scheme:NSLinguisticTagSchemeLemma options:NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
            if (tag) {
                stem = tag;
                // *stop = YES;
            }
        }];
    }
    return stem;
}

@end
