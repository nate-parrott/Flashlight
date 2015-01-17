//
//  PSTaggedText+ToNestedDictionaries.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText+ToNestedDictionaries.h"
#import "PSHelpers.h"
#import "PSSpecialField.h"

@implementation PSTaggedText (ToNestedDictionaries)

- (NSDictionary *)toNestedDictionary {
    NSMutableDictionary *d = [NSMutableDictionary new];
    for (id child in self.contents) {
        if ([child isKindOfClass:[PSTaggedText class]]) {
            NSString *tag = [child tag];
            id val = nil;
            if ([tag characterAtIndex:0] == '@') {
                // it's a special field:
                Class fieldClass = [PSSpecialField specialFieldClassesForNames][tag];
                val = [fieldClass performSelector:@selector(getJsonObjectFromText:) withObject:[child _getText]];
            } else {
                NSDictionary *nestedDict = [child toNestedDictionary];
                val = nestedDict.count > 0 ? nestedDict : [child _getText];
            }
            if (val) {
                BOOL alreadyHadItemWithSameTag = !!d[tag];
                if (alreadyHadItemWithSameTag) {
                    NSString *tagAll = [NSString stringWithFormat:@"%@_all", tag];
                    NSArray *array = d[tagAll] ? : @[d[tag]];
                    d[tagAll] = [array arrayByAddingObject:val];
                }
                d[tag] = val;
            }
        }
    }
    return d;
}

- (NSString *)_getText {
    return [[self.contents mapFilter:^id(id obj) {
        return [obj isKindOfClass:[NSString class]] ? obj : nil;
    }] componentsJoinedByString:@" "];
}

@end
