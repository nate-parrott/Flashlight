//
//  PSFileSource.m
//  FlashlightKit
//
//  Created by Nate Parrott on 1/23/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PSFileSource.h"
#import <CoreServices/CoreServices.h>
#import "PSTaggedText+ParseExample.h"
#import "Parsnip.h"

@interface PSFileSource ()

@property (nonatomic, copy) PSParsnipDataCallback callback;

@end

@implementation PSFileSource

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback {
    self = [super initWithIdentifier:identifier callback:callback];
    self.callback = callback;
    [self update];
    return self;
}

- (void)update {
    PSParsnipFieldProcessor fieldProcessor = [self fieldProcessor];
    Parsnip *parsnip = [Parsnip new];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"~fileSearch(anything)" rootTag:@"@file"]]];
    self.callback(self.identifier, @{PSParsnipSourceDataParsnipKey: parsnip, PSParsnipSourceFieldProcessorsDictionaryKey: @{@"@file": fieldProcessor}});
}

- (PSParsnipFieldProcessor)fieldProcessor {
    return ^id(PSTaggedText *tagged) {
        NSString *searchQuery = [[tagged findChild:@"~fileSearch"] getText] ? : [tagged getText];
        if (searchQuery) {
            MDQueryRef query = MDQueryCreate(kCFAllocatorDefault, (CFStringRef)[self MDQueryStringForSearch:searchQuery], nil, nil);
            MDQuerySetMaxCount(query, 10);
            MDQuerySetSearchScope(query, (CFArrayRef)@[(id)kMDQueryScopeComputerIndexed], 0);
            if (!MDQueryExecute(query, kMDQuerySynchronous)) {
                NSLog(@"Search failed.");
                return nil;
            }
            
            NSMutableArray *mdItems = [NSMutableArray new];
            for (NSInteger i=0; i<MDQueryGetResultCount(query); i++) {
                MDItemRef item = (MDItemRef)MDQueryGetResultAtIndex(query, i);
                [mdItems addObject:(__bridge id)item];
            }
            [mdItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *r1 = CFBridgingRelease(MDItemCopyAttribute((MDItemRef)obj1, kMDQueryResultContentRelevance));
                NSNumber *r2 = CFBridgingRelease(MDItemCopyAttribute((MDItemRef)obj2, kMDQueryResultContentRelevance));
                return [r2 compare:r1];
            }];
            NSArray *paths = [mdItems mapFilter:^id(id obj) {
                return CFBridgingRelease(MDItemCopyAttribute((MDItemRef)obj, kMDItemPath));
            }];
            return @{
                     @"query": searchQuery,
                     @"path": paths.firstObject ? : [NSNull null],
                     @"otherPaths": paths.count > 1 ? [paths subarrayWithRange:NSMakeRange(1, paths.count - 1)] : @[]
                     };
        }
        return nil;
    };
}

- (NSString *)MDQueryStringForSearch:(NSString *)search {
    NSString *escaped = [[[search stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"] stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
    return [NSString stringWithFormat:@"kMDItemDisplayName == '%@'cd", escaped];
}

@end
