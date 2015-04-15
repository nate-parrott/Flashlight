//
//  PSMerging.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSMerging.h"

@implementation NSMutableDictionary (PSMerging)

- (void)ps_mergeWith:(id)other allowUnmergeableTypes:(BOOL)allowUnmergeableTypes {
    for (id key in [other keyEnumerator]) {
        id selfVal = self[key];
        id otherVal = other[key];
        if (!allowUnmergeableTypes && otherVal) {
            NSAssert([otherVal conformsToProtocol:@protocol(PSMerging)], @"Tried to merge unmergeable object (%@), but unmergeable objects aren't allowed in this merge.", otherVal);
        }
        if (selfVal && otherVal && [selfVal conformsToProtocol:@protocol(PSMerging)]) {
            [(id<PSMerging>)selfVal ps_mergeWith:otherVal allowUnmergeableTypes:allowUnmergeableTypes];
        } else {
            self[key] = otherVal;
        }
    }
}

@end

@implementation NSMutableSet (PSMerging)

- (void)ps_mergeWith:(id)other allowUnmergeableTypes:(BOOL)allowUnmergeableTypes {
    [self addObjectsFromArray:[other allObjects]];
}

@end
