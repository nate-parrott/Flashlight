//
//  PSTaggedText+ToNestedDictionaries.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText+ToNestedDictionaries.h"
#import "PSHelpers.h"
#import "PSNonterminalNode.h"
#import "PSPluginExampleSource.h"
#import "PSPluginDispatcher.h"

@implementation PSTaggedText (ToNestedDictionaries)

- (NSDictionary *)toNestedDictionary {
    NSMutableDictionary *d = [NSMutableDictionary new];
    for (id child in self.contents) {
        if ([child isKindOfClass:[PSTaggedText class]]) {
            NSString *tag = [child tag];
            id val = nil;
            if ([tag characterAtIndex:0] == '@') {
                // it's a special field:
                PSParsnipFieldProcessor processor = [PSPluginDispatcher fieldProcessorForTag:tag];
                if (processor) {
                    val = processor(child);
                }
            } else {
                NSDictionary *nestedDict = [child toNestedDictionary];
                val = nestedDict.count > 0 ? nestedDict : [child getText];
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

@end
