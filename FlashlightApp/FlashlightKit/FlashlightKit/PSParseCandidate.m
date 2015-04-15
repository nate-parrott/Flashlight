//
//  PSParseCandidate.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSParseCandidate.h"
#import "PSNonterminalNode.h"
#import "PSHelpers.h"

@implementation PSParseCandidate

- (NSString *)identifier {
    return [[[self.node nodeStackAtEnd] mapFilter:^id(id obj) {
        return [obj tag];
    }] componentsJoinedByString:@"->"];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (id)copy {
    PSParseCandidate *copy = [PSParseCandidate new];
    copy.logProb = self.logProb;
    copy.node = self.node.copy;
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[PSParseCandidate: %f; %@]", self.logProb, self.node];
}

@end
