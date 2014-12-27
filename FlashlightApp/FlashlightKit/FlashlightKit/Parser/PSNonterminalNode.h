//
//  PSNonterminalNode.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSNode.h"
@class PSTransition;

@interface PSNonterminalNode : NSObject <PSNode>

@property (nonatomic) NSString *tag;
@property (nonatomic) NSArray *children;

+ (NSString *)convertTagToExternal:(NSString *)tag;

- (void)enumerateAllTransitions:(void(^)(NSString *insideState, NSString *fromExternalState, NSString *toExternalState))callback;

- (BOOL)isClosed;

- (NSArray *)nodeStackAtEnd; // all but the last item should be instances of PSNonterminalNode; the last should never be

- (PSNonterminalNode *)currentNonterminal;

@end
