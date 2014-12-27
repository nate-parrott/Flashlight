//
//  PSTaggedText+PreprocessedForLearning.m
//  Parsnip
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText+PreprocessedForLearning.h"
#import "PSHelpers.h"

@implementation PSTaggedText (PreprocessedForLearning)

- (PSTaggedText *)preprocessedForLearning {
    PSTaggedText *processed = [PSTaggedText new];
    processed.tag = self.tag;
    if ([self.tag startsWith:@"~"]) {
        // it's a free-text tag; use the same sample text for both:
        processed.contents = @[@"abc def"];
    } else {
        processed.contents = [self.contents mapFilter:^id(id obj) {
            if ([obj isKindOfClass:[PSTaggedText class]]) {
                return [obj preprocessedForLearning];
            } else {
                return obj;
            }
        }];
    }
    return processed;
}

@end
