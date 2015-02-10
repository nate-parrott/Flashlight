//
//  FlashlightQueryEngine.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightQueryEngine.h"
#import "PSBackgroundProcessor.h"
#import "PSPluginDispatcher.h"
#import "PSPluginExampleSource.h"
#import "NSTask+FlashlightExtensions.h"
#import "FlashlightResult.h"
#import "PSHelpers.h"
#import "PSTaggedText+ToJSON.h"
#import "PSTaggedText+ToNestedDictionaries.h"
#import "SearchPluginState.h"

@interface FlashlightQueryEngine ()

@property (nonatomic) NSString *query;
@property (nonatomic) PSBackgroundProcessor *parserRunner;
@property (nonatomic) PSPluginDispatcher *dispatcher;
@property (nonatomic) NSMutableArray *tasksInProgress;
@property (nonatomic) NSArray *results;
@property (nonatomic) NSMutableDictionary *searchPluginStates;

@end

@implementation FlashlightQueryEngine

- (id)init {
    self = [super init];
    __weak FlashlightQueryEngine *weakSelf = self;
    self.dispatcher = [PSPluginDispatcher new];
    self.parserRunner = [[PSBackgroundProcessor alloc] initWithProcessingBlock:^(id data, PSBackgroundProcessorResultBlock callback) {
        if ([data length] == 0) {
            callback(nil);
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableDictionary *pluginsToLaunchMappedToParseTrees = [NSMutableDictionary new];
                // pluginPath -> @{} | NSNull
                NSString *path = nil;
                NSDictionary *args = nil;
                PSTaggedText *parseTree = nil;
                [weakSelf.dispatcher parseCommand:data pluginPath:&path arguments:&args parseTree:&parseTree];
                if (path && args) {
                    if (weakSelf.debugDataChangeBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.matchedPlugin = path.lastPathComponent.stringByDeletingPathExtension;
                            weakSelf.pluginArgs = args;
                            weakSelf.debugDataChangeBlock();
                        });
                    }
                    pluginsToLaunchMappedToParseTrees[path] = parseTree;
                }
                for (NSString *path in weakSelf.dispatcher.exampleSource.pathsOfPluginsToAlwaysInvoke) {
                    if (!pluginsToLaunchMappedToParseTrees[path]) {
                        pluginsToLaunchMappedToParseTrees[path] = [NSNull null];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf runPluginsWithParseTrees:pluginsToLaunchMappedToParseTrees ifQueryIsStill:data];
                });
                callback(nil);
            });
        }
    }];
    self.tasksInProgress = [NSMutableArray new];
    self.searchPluginStates = [NSMutableDictionary new];
    return self;
}

- (void)updateQuery:(NSString *)query {
    // clear debug data:
    self.matchedPlugin = nil;
    self.pluginArgs = nil;
    self.errorString = nil;
    if (self.debugDataChangeBlock) self.debugDataChangeBlock();
    
    [self cancelAllTasks];
    self.query = query;
    self.results = @[];
    [self.parserRunner gotNewData:query];
}

- (void)runPluginsWithParseTrees:(NSDictionary *)pluginPathsToParseTreesMap ifQueryIsStill:(NSString *)query {
    if ([query isEqualToString:self.query]) {
        for (NSString *pluginPath in pluginPathsToParseTreesMap) {
            PSTaggedText *parseTree = pluginPathsToParseTreesMap[pluginPath];
            if ([parseTree isEqual:[NSNull null]]) parseTree = nil;
            [self handlePluginAtPath:pluginPath parseTree:parseTree query:query];
        }
    }
}

- (void)handlePluginAtPath:(NSString *)pluginPath parseTree:(PSTaggedText *)parseTree query:(NSString *)query {
    SearchPluginState *searchPluginState = [self searchPluginStateForPlugin:pluginPath];
    if (searchPluginState) {
        NSString *searchQuery = [[parseTree findChild:@"~query"] getText];
        [self addResults:[searchPluginState setQueryAndGetResults:searchQuery] forQuery:query];
        __weak FlashlightQueryEngine *weakSelf = self;
        __weak SearchPluginState *weakSearchPluginState = searchPluginState;
        searchPluginState.resultsUpdate = ^{
            if ([weakSelf.query isEqualToString:query]) {
                [weakSelf addResults:weakSearchPluginState.results forQuery:query];
            }
        };
    } else {
        [self executePluginAtPath:pluginPath parseTree:parseTree query:query];
    }
}

- (void)executePluginAtPath:(NSString *)pluginPath parseTree:(PSTaggedText *)parseTree query:(NSString *)query {
    __weak FlashlightQueryEngine *weakSelf = self;
    NSTask *task = [NSTask withPathMarkedAsExecutableIfNecessary:[[NSBundle bundleForClass:[self class]] pathForResource:@"invoke_plugin" ofType:@"py"]];
    NSDictionary *input = @{
                            @"args": [parseTree toNestedDictionary] ? : [NSNull null],
                            @"query": query,
                            @"builtinModulesPath": [[self class] builtinModulesPath],
                            @"parseTree": [parseTree toJsonObject] ? : [NSNull null],
                            @"pluginPath": pluginPath
                            };
    task.arguments = @[input.toJson];
    @synchronized(weakSelf.tasksInProgress) {
        [weakSelf.tasksInProgress addObject:task];
    }
    [task launchWithTimeout:2 callback:^(NSData *stdoutData, NSData *stderrData) {
        // only act on the result data if we're still part of the tasksInProgress
        BOOL wasInProgress = NO;
        @synchronized(weakSelf.tasksInProgress) {
            wasInProgress = [weakSelf.tasksInProgress containsObject:task];
            if (wasInProgress) [weakSelf.tasksInProgress removeObject:task];
        }
        if (wasInProgress) {
            if (weakSelf.debugDataChangeBlock) {
                // report the error:
                if (stderrData) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.errorString = [weakSelf.errorString ? : @"" stringByAppendingString:[[NSString alloc] initWithData:stderrData encoding:NSUTF8StringEncoding]];
                        weakSelf.debugDataChangeBlock();
                    });
                }
            }
            if (stdoutData) {
                NSArray *results = [NSJSONSerialization JSONObjectWithData:stdoutData options:0 error:nil];
                NSArray *resultsObjs = [results mapFilter:^id(id obj) {
                    FlashlightResult *res = [FlashlightResult new];
                    res.json = obj;
                    res.pluginPath = pluginPath;
                    return res;
                }];
                [self addResults:resultsObjs forQuery:query];
            }
        }
    }];
}

- (void)addResults:(NSArray *)resultObjs forQuery:(NSString *)query {
    dispatch_async(dispatch_get_main_queue(), ^{
        // don't replace old results with same unique ID
        if ([self.query isEqualToString:query]) {
            NSSet *uniqueIdsForOldResults = [NSSet setWithArray:[self.results mapFilter:^id(id obj) {
                return [obj uniqueIdentifier];
            }]];
            NSArray *newResults = [resultObjs mapFilter:^id(id obj) {
                NSString *objId = [obj uniqueIdentifier];
                if (objId && [uniqueIdsForOldResults containsObject:objId]) {
                    return nil;
                } else {
                    return obj;
                }
            }];
            self.results = [[self.results arrayByAddingObjectsFromArray:newResults] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"canBeTopHit" ascending:NO]]];
            self.resultsDidChangeBlock(query, self.results);
        }
    });
}

- (void)cancelAllTasks {
    @synchronized(self.tasksInProgress) {
        for (NSTask *task in self.tasksInProgress) {
            [task safeTerminate];
        }
        [self.tasksInProgress removeAllObjects];
    }
}

+ (NSString *)pythonPath {
    return @"/usr/bin/python";
}

+ (NSString *)builtinModulesPath {
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"BuiltinModules" ofType:@""];
}

#pragma mark Search Plugins
- (SearchPluginState *)searchPluginStateForPlugin:(NSString *)pluginPath {
    return nil; // block this off for now
    if ([[NSFileManager defaultManager] fileExistsAtPath:[pluginPath stringByAppendingPathComponent:@"search.json"]]) {
        SearchPluginState *s = self.searchPluginStates[pluginPath];
        if (!s) {
            s = [[SearchPluginState alloc] initWithPluginPath:pluginPath];
            self.searchPluginStates[pluginPath] = s;
        }
        return s;
    } else {
        return nil;
    }
}

@end
