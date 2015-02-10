//
//  SearchPluginState.m
//  FlashlightKit
//
//  Created by Nate Parrott on 2/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "SearchPluginState.h"
#import "PSBackgroundProcessor.h"
#import "FlashlightResult.h"

@interface SearchPluginState ()

@property (nonatomic) NSString *pluginPath, *name, *mobileUrlTemplate, *desktopUrlTemplate, *autocompleteUrlTemplate;
@property (nonatomic) PSBackgroundProcessor *autocompleter;
@property (nonatomic) NSArray *autocompleteStrings;
@property (nonatomic) NSArray *results;

@end

@implementation SearchPluginState

- (instancetype)initWithPluginPath:(NSString *)pluginPath {
    self = [super init];
    self.pluginPath = pluginPath;
    NSData *data = [NSData dataWithContentsOfFile:[pluginPath stringByAppendingPathComponent:@"search.json"]];
    NSDictionary *dict = data? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    for (NSString *key in @[@"name", @"mobileUrlTemplate", @"desktopUrlTemplate", @"autocompleteUrlTemplate"]) {
        [self setValue:dict[key] forKey:key];
    }
    __weak SearchPluginState *weakSelf = self;
    self.autocompleter = [[PSBackgroundProcessor alloc] initWithProcessingBlock:^(id data, PSBackgroundProcessorResultBlock callback) {
        NSArray *autocompletes = @[@"brown university", @"brown university bears", @"brown colors", @"brown hackathon", @"jesus christ", @"flashlight app", @"nate parrott"];
        NSArray *items = [autocompletes mapFilter:^id(NSString *obj) {
            return [obj startsWith:data] ? obj : nil;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
            weakSelf.autocompleteStrings = items;
            if (weakSelf.resultsUpdate) weakSelf.resultsUpdate();
            callback(items);
        });
    }];
    return self;
}

- (void)setAutocompleteStrings:(NSArray *)autocompleteStrings {
    _autocompleteStrings = autocompleteStrings;
    [self updateResults];
}

- (NSArray *)setQueryAndGetResults:(NSString *)search {
    [self.autocompleter gotNewData:search];
    [self updateResults];
    return self.results;
}

- (void)updateResults {
    NSMutableArray *matchingQueries = [NSMutableArray new];
    NSString *currentQuery = self.autocompleter.latestData;
    if (currentQuery) {
        [matchingQueries addObject:currentQuery];
    }
    for (NSString *autocomplete in self.autocompleteStrings) {
        if (currentQuery && [autocomplete startsWith:currentQuery]) {
            [matchingQueries addObject:autocomplete];
        }
    }
    self.results = [matchingQueries mapFilter:^id(id obj) {
        return [self flashlightResultItemForQuery:obj];
    }];
}

- (FlashlightResult *)flashlightResultItemForQuery:(NSString *)query {
    FlashlightResult *res = [FlashlightResult new];
    res.pluginPath = self.pluginPath;
    NSString *mobileSearchPath = [self.mobileUrlTemplate stringByReplacingOccurrencesOfString:@"QUERY" withString:[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    res.uniqueIdentifier = [NSString stringWithFormat:@"%@: %@", self.pluginPath, query];
    res.json = @{
                 @"title": [NSString stringWithFormat:@"%@ — %@", query, self.name],
                 @"html": [NSString stringWithFormat:@"<script>setTimeout(function() {window.location = '%@'}, 500)</script>", mobileSearchPath],
                 @"webview_user_agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
                 @"webview_links_open_in_browser": @YES
                 };
    return res;
}

@end
