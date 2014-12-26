//
//  PSSpecialNode.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSSpecialNode.h"

@implementation PSSpecialNode

- (NSString *)tag {
    return nil;
}

- (NSString *)externalTag {
    return self.tag;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (id)copy {
    return [[self class] new];
}

- (NSString *)description {
    return self.tag;
}

@end
