//
//  PSPluginDispatcher.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/23/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSPluginDispatcher.h"
#import "Parsnip.h"
#import "PSPluginExampleSource.h"
#import "PSBackgroundProcessor.h"
#import "PSHelpers.h"
#import "PSNonterminalNode.h"
#import "PSTaggedText+FromNodes.h"
#import "PSTaggedText+ToNestedDictionaries.h"
#import "PSParseCandidate.h"
#import "PSParsnipSource.h"

@interface PSPluginDispatcher ()

@property (nonatomic) NSMutableDictionary *latestResultsDictionariesForSourceIdentifiers;
@property (nonatomic) NSMutableArray *sources;
@property (nonatomic) PSBackgroundProcessor *parsnipCreator;

@end

@implementation PSPluginDispatcher

- (instancetype)init {
    self = [super init];
    
    self.parsnipCreator = [[PSBackgroundProcessor alloc] initWithProcessingBlock:^(NSDictionary *latestResultsDictionariesForSourceIdentifiers, PSBackgroundProcessorResultBlock callback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray *parsnips = [latestResultsDictionariesForSourceIdentifiers.allValues mapFilter:^id(NSDictionary *data) {
                return data[PSParsnipSourceDataParsnipKey];
            }];
            Parsnip *ps = [[Parsnip alloc] initWithOtherParsnips:parsnips];
            callback(ps);
        });
    }];
    self.latestResultsDictionariesForSourceIdentifiers = [NSMutableDictionary new];
    self.sources = [NSMutableArray new];
    [self addSourceWithClass:[PSPluginExampleSource class] identifier:@"plugins"];
    
    return self;
}

- (void)addSourceWithClass:(Class)class identifier:(NSString *)identifier {
    __weak PSPluginDispatcher *weakSelf = self;
    PSParsnipSource *source = [[class alloc] initWithIdentifier:identifier callback:^(NSString *identifier, NSDictionary *data) {
        @synchronized(weakSelf) {
            weakSelf.latestResultsDictionariesForSourceIdentifiers[identifier] = data;
            [weakSelf.parsnipCreator gotNewData:weakSelf.latestResultsDictionariesForSourceIdentifiers.copy];
        }
    }];
    [self.sources addObject:source];
}

- (void)parseCommand:(NSString *)command pluginPath:(NSString **)pluginPath arguments:(NSDictionary **)arguments {
    Parsnip *mainParsnip;
    NSDictionary *pluginPathsForIntents;
    @synchronized(self) {
        mainParsnip = self.parsnipCreator.latestResult;
        pluginPathsForIntents = self.latestResultsDictionariesForSourceIdentifiers[@"plugins"][PSParsnipSourceDataPluginPathForIntentDictionaryKey];
    }
    PSParseCandidate *result = [mainParsnip parseText:command intoTag:@"plugin_intent"];
    if (result) {
        *pluginPath = pluginPathsForIntents[result.node.tag];
        *arguments = [[PSTaggedText withNode:result.node] toNestedDictionary];
    } else {
        // no match:
        *pluginPath = nil;
        *arguments = nil;
    }
}

- (PSPluginExampleSource *)exampleSource {
    for (PSParsnipSource *source in self.sources) {
        if ([source.identifier isEqualToString:@"plugins"]) {
            return (id)source;
        }
    }
    return nil;
}

@end
