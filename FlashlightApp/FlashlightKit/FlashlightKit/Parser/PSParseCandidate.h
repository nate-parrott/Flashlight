//
//  PSParseCandidate.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSNonterminalNode;

@interface PSParseCandidate : NSObject <NSCopying>

@property (nonatomic) double logProb;
@property (nonatomic) PSNonterminalNode *node;

- (NSString *)identifier;

@end
