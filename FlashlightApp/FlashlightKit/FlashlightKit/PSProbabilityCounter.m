//
//  PSProbabilityCounter.m
//  Parsnip
//
//  Created by Nate Parrott on 12/20/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSProbabilityCounter.h"
#import "PSHelpers.h"

@interface PSProbabilityCounter ()

@property (nonatomic) NSInteger count;
@property (nonatomic) NSMutableDictionary *countsForItems;

@end

@implementation PSProbabilityCounter

- (id)init {
    self = [super init];
    self.countsForItems = [NSMutableDictionary new];
    return self;
}

- (void)addItem:(id)item {
    self.countsForItems[item] = @([self.countsForItems[item] longValue] + 1);
    self.count++;
}

- (NSEnumerator *)allItems {
    return self.countsForItems.keyEnumerator;
}

- (double)smoothedLogProbForItem:(id)item {
    return PSLogProb([self.countsForItems[item] doubleValue] / self.count * (1 - PSMinimalProbability) + PSMinimalProbability);
}

- (NSString *)description {
    NSArray *pairs = [self.allItems.allObjects mapFilter:^id(id obj) {
        return [NSString stringWithFormat:@"(%@: %@)", obj, self.countsForItems[obj]];
    }];
    return [NSString stringWithFormat:@"[PSProbabilityCounter: %@]", [pairs componentsJoinedByString:@", "]];
}

- (void)ps_mergeWith:(PSProbabilityCounter *)other allowUnmergeableTypes:(BOOL)allowUnmergeableTypes {
    self.count += other.count;
    for (id item in other.countsForItems) {
        self.countsForItems[item] = @([self.countsForItems[item] longValue] + [other.countsForItems[item] longValue]);
    }
}

- (double)specialTextProbabilityForItem:(id)item {
    double count = [self.countsForItems[item] doubleValue];
    double p = 1 - 1.0 / (count + 1);
    return PSLogProb(PSMinimalProbability + p * (1 - PSMinimalProbability));
}

@end
