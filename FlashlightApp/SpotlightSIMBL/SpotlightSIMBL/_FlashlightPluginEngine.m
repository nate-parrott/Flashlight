//
//  _FlashlightPluginEngine.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_FlashlightPluginEngine.h"
#import <AppKit/AppKit.h>
#import "SPResultViewController.h"
#import "SPOpenAPIResult.h"
#import "SPResult.h"
#import "SPGroupHeadingResult.h"
#import "SPSearchPanel.h"
#import "SPAppDelegate.h"
#import <FlashlightKit/FlashlightKit.h>

@interface _FlashlightPluginEngine ()

@property (nonatomic) NSArray *results;
@property (nonatomic) NSString *mostRecentQueryWithResults;
@property (nonatomic) FlashlightQueryEngine *queryEngine;

@end

@implementation _FlashlightPluginEngine

+ (_FlashlightPluginEngine *)shared {
    static _FlashlightPluginEngine *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [_FlashlightPluginEngine new];
    });
    return shared;
}

- (id)init {
    self = [super init];
    
    self.queryEngine = [FlashlightQueryEngine new];
    __weak _FlashlightPluginEngine *weakSelf = self;
    self.queryEngine.resultsDidChangeBlock = ^(NSString *query, NSArray *results){
        NSMutableArray *resultItems = [NSMutableArray new];
        for (FlashlightResult *result in weakSelf.queryEngine.results) {
            id spResult = [[__SS_SPOpenAPIResultClass() alloc] initWithQuery:query result:result];
            [resultItems addObject:spResult];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([query isEqualToString:weakSelf.query]) {
                weakSelf.results = resultItems;
                weakSelf.mostRecentQueryWithResults = query;
                if (weakSelf.results.count > 0) {
                    [weakSelf reloadResultsViews];
                }
            }
        });
    };
    return self;
}

- (void)setQuery:(NSString *)query {
    _query = query;
    self.results = nil;
    if (!query) {
        self.mostRecentQueryWithResults = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateWindowCollapsed];
    });
    if (!query) {
        return;
    }
    
    [self.queryEngine updateQuery:query];
}

- (void)reloadResultsViews {
    id appDelegate = [[NSApplication sharedApplication] delegate];
    SPResultViewController *resultVC = [appDelegate performSelector:NSSelectorFromString(@"currentViewController")];
    [resultVC setResults:resultVC.results];
    [resultVC reloadResultsSelectingTopResult:YES animate:NO];
    [self updateWindowCollapsed];
}

- (NSArray *)mergeFlashlightResultsWithSpotlightResults:(NSArray *)spotlightResults {
    NSMutableArray *pluginTopHits = [NSMutableArray new];
    NSMutableArray *pluginNonTopHits = [NSMutableArray new];
    for (id pluginHit in self.results) {
        if ([pluginHit shouldNotBeTopHit]) {
            [pluginNonTopHits addObject:pluginHit];
        } else {
            [pluginTopHits addObject:pluginHit];
        }
    }
    
    
    NSMutableArray *mainResults = [NSMutableArray new];
    NSMutableArray *showAllInFinderResults = [NSMutableArray new];
    NSMutableArray *topHitHeaders = [NSMutableArray new];
    NSMutableArray *topHitItems = [NSMutableArray new];
    BOOL lastHeaderWasTopHit = NO;
    
    for (id item in spotlightResults) {
        if ([item isKindOfClass:NSClassFromString(@"SPOpenAPIResult")]) {
            // do nothing
        } else if ([item isGroupHeading]) {
            if ([[item displayName] isEqualToString:@"FLASHLIGHT"]) {
                // do nothing
            } else if (topHitHeaders.count == 0) {
                // this is the top-hit header:
                lastHeaderWasTopHit = YES;
                [topHitHeaders addObject:item];
            } else {
                lastHeaderWasTopHit = NO;
                [mainResults addObject:item];
            }
        } else if (lastHeaderWasTopHit) {
            [topHitItems addObject:item];
        } else {
            [mainResults addObject:item];
        }
    }
    
    [topHitItems insertObjects:pluginTopHits atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, pluginTopHits.count)]];
    if (pluginNonTopHits.count) {
        [pluginNonTopHits insertObject:[[NSClassFromString(@"SPGroupHeadingResult") alloc] initWithDisplayName:@"FLASHLIGHT" focusString:nil] atIndex:0];
        [mainResults insertObjects:pluginNonTopHits atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, pluginNonTopHits.count)]];
    }
    
    NSMutableArray *toPrepend = [NSMutableArray new];
    [toPrepend addObjectsFromArray:topHitHeaders];
    [toPrepend addObjectsFromArray:topHitItems];
    [mainResults insertObjects:toPrepend atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, toPrepend.count)]];
    [mainResults addObjectsFromArray:showAllInFinderResults];
    return mainResults;
}

- (void)updateWindowCollapsed {
    SPAppDelegate *delegate = (id)[[NSApplication sharedApplication] delegate];
    SPSearchPanel *panel = delegate.window;
    
    if ([self shouldBeCollapsed] != [panel collapsedState]) {
        if ([self shouldBeCollapsed]) {
            [panel collapse];
        } else {
            [panel expand];
        }
    }
}

- (BOOL)shouldBeCollapsed {
    SPAppDelegate *delegate = (id)[[NSApplication sharedApplication] delegate];
    SPSearchPanel *panel = delegate.window;
    
    BOOL queryEmpty = self.query.length == 0;
    BOOL queryFinished = self.query == self.mostRecentQueryWithResults || [self.query isEqualToString:self.mostRecentQueryWithResults];
    BOOL noResults = self.results.count == 0;
    BOOL isCollapsedNow = [panel collapsedState];
    
    BOOL canCollapse = queryEmpty || (queryFinished && noResults) || (!queryFinished && noResults && isCollapsedNow);
    
    return self.spotlightWantsCollapsed && canCollapse;
}

@end
