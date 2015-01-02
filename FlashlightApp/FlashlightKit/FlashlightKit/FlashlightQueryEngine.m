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

@interface FlashlightQueryEngine ()

@property (nonatomic) NSString *query;
@property (nonatomic) PSBackgroundProcessor *parserRunner;
@property (nonatomic) PSPluginDispatcher *dispatcher;
@property (nonatomic) NSMutableArray *tasksInProgress;
@property (nonatomic) NSArray *results;

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
    __weak FlashlightQueryEngine *weakSelf = self;
    if ([query isEqualToString:self.query]) {
        for (NSString *pluginPath in pluginPathsToParseTreesMap) {
            PSTaggedText *parseTree = pluginPathsToParseTreesMap[pluginPath];
            if ([parseTree isEqual:[NSNull null]]) parseTree = nil;
            NSTask *task = [[NSTask alloc] init];
            task.currentDirectoryPath = pluginPath;
            task.launchPath = [[self class] pythonPath];
            static NSString *command = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                command = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"invoke_plugin" ofType:@"py"] encoding:NSUTF8StringEncoding error:nil];
            });
            NSDictionary *input = @{
                                    @"args": [parseTree toNestedDictionary] ? : [NSNull null],
                                    @"query": query,
                                    @"builtinModulesPath": [[self class] builtinModulesPath],
                                    @"parseTree": [parseTree toJsonObject] ? : [NSNull null]
                                    };
            task.arguments = @[@"-c", command, input.toJson];
            @synchronized(weakSelf.tasksInProgress) {
                [weakSelf.tasksInProgress addObject:task];
            }
            [task launchWithTimeout:2 callback:^(NSData *stdoutData, NSData *stderrData) {
                // only act on the result data if we're still part of the tasksInProgress
                if ([weakSelf.tasksInProgress containsObject:task]) {
                    [weakSelf.tasksInProgress removeObject:self];
                    
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([weakSelf.query isEqualToString:query]) {
                                weakSelf.results = [[weakSelf.results arrayByAddingObjectsFromArray:resultsObjs] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"canBeTopHit" ascending:NO]]];
                                weakSelf.resultsDidChangeBlock(query, weakSelf.results);
                            }
                        });
                    }
                }
            }];
        }
    }
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

@end
