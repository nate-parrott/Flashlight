//
//  Parsnip.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSNonterminalNode, PSParseCandidate;

@interface Parsnip : NSObject

- (void)learnExamples:(NSArray *)examples;
- (PSParseCandidate *)parseText:(NSString *)text intoTag:(NSString *)rootTag;
- (NSArray *)parseText:(NSString *)text intoCandidatesForTag:(NSString *)rootTag;

- (void)printData;

- (instancetype)initWithOtherParsnips:(NSArray *)parsnips;

- (void)setLogProbBoost:(double)boost forTag:(NSString *)tag;

@end
