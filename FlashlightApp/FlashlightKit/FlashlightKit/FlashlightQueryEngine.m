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
                NSMutableDictionary *pluginsToLaunchMappedToArgumentsDictionaries = [NSMutableDictionary new];
                // pluginPath -> @{} | NSNull
                NSString *path = nil;
                NSDictionary *args = nil;
                [weakSelf.dispatcher parseCommand:data pluginPath:&path arguments:&args];
                if (path && args) {
                    if (weakSelf.debugDataChangeBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.matchedPlugin = path.lastPathComponent.stringByDeletingPathExtension;
                            weakSelf.pluginArgs = args;
                            weakSelf.debugDataChangeBlock();
                        });
                    }
                    pluginsToLaunchMappedToArgumentsDictionaries[path] = args;
                }
                for (NSString *path in weakSelf.dispatcher.exampleSource.pathsOfPluginsToAlwaysInvoke) {
                    if (!pluginsToLaunchMappedToArgumentsDictionaries[path]) {
                        pluginsToLaunchMappedToArgumentsDictionaries[path] = [NSNull null];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf runPluginsWithArguments:pluginsToLaunchMappedToArgumentsDictionaries ifQueryIsStill:data];
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

- (void)runPluginsWithArguments:(NSDictionary *)pathsToArgumentsMap ifQueryIsStill:(NSString *)query {
    __weak FlashlightQueryEngine *weakSelf = self;
    if ([query isEqualToString:self.query]) {
        for (NSString *pluginPath in pathsToArgumentsMap) {
            id args = pathsToArgumentsMap[pluginPath];
            NSTask *task = [[NSTask alloc] init];
            task.currentDirectoryPath = pluginPath;
            task.launchPath = @"/usr/bin/python";
            NSString *builtinModulesPath = [[NSBundle bundleWithIdentifier:@"com.nateparrott.FlashlightKit"] pathForResource:@"BuiltinModules" ofType:@""];
            NSString *command = @"import sys, json\n"
            @"input = json.loads(sys.argv[1])\n"
            @"sys.path.append(input['builtinModulesPath'])\n"
            @"import plugin\n"
            @"results = plugin.results(input['args'], input['query'])\n"
            @"if not results: quit()\n"
            @"if type(results) != list: results = [results]\n"
            @"print json.dumps(results)\n";
            command = [NSString stringWithFormat:command, [@[builtinModulesPath] toJson]];
            NSDictionary *input = @{
                                    @"args": args,
                                    @"query": query,
                                    @"builtinModulesPath": builtinModulesPath
                                    };
            task.arguments = @[@"-c", command, input.toJson];
            [weakSelf.tasksInProgress addObject:task];
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
                                weakSelf.results = [weakSelf.results arrayByAddingObjectsFromArray:resultsObjs];
                                weakSelf.resultsDidChangeBlock();
                            }
                        });
                    }
                }
            }];
        }
    }
}

- (void)cancelAllTasks {
    for (NSTask *task in self.tasksInProgress) {
        [task safeTerminate];
    }
    [self.tasksInProgress removeAllObjects];
}

@end
