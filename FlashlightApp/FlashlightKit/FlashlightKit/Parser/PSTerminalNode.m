//
//  PSTerminalNode.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTerminalNode.h"
#import "PSHelpers.h"
#import "NSString+PSTokenize.h"

@implementation PSTerminalNode

+ (NSString *)terminalNodeNameFromParentTag:(NSString *)parent prev:(NSString *)prevTag next:(NSString *)nextTag {
    return [NSString stringWithFormat:@"__%@:%@-%@", parent, prevTag, nextTag];
}

- (NSString *)externalTag {
    return self.tag;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", self.tag, self.token];
}

+ (BOOL)isNameOfTerminalNode:(NSString *)node {
    return [node startsWith:@"__"];
}

+ (BOOL)isNameOfFreeTextNode:(NSString *)node {
    return [node startsWith:@"__~"];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

- (id)copy {
    PSTerminalNode *copy = [PSTerminalNode new];
    copy.tag = self.tag;
    copy.token = self.token;
    return copy;
}

@end
