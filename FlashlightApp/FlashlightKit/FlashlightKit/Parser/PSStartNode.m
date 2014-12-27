//
//  PSStartNode.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSStartNode.h"

@implementation PSStartNode

- (NSString *)tag {
    return @"$START";
}

+ (BOOL)isNameOfStartNode:(NSString *)name {
    return [name isEqualToString:@"$START"];
}

@end
