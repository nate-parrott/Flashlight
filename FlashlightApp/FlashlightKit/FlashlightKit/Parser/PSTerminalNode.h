//
//  PSTerminalNode.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSNode.h"
@class PSToken;

@interface PSTerminalNode : NSObject <PSNode>

@property (nonatomic) NSString *tag;
@property (nonatomic) PSToken *token;

+ (NSString *)terminalNodeNameFromParentTag:(NSString *)parent prev:(NSString *)prevTag next:(NSString *)nextTag;
+ (BOOL)isNameOfTerminalNode:(NSString *)node;
+ (BOOL)isNameOfFreeTextNode:(NSString *)node;

@end
