//
//  FlashlightQueryEngine.h
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

/*
 BEHAVIORS TO REPLICATE:
 
 run()
 @date
 (regex examples?)
 
 */

#import <Foundation/Foundation.h>
#import <FlashlightKit/PSHelpers.h>
@class PSPluginDispatcher;

typedef void (^PSResultsChangedCallback)(NSString *query, NSArray *results);

@interface FlashlightQueryEngine : NSObject

- (void)updateQuery:(NSString *)query;
@property (nonatomic, readonly) NSArray *results;
@property (nonatomic, copy) PSResultsChangedCallback resultsDidChangeBlock;

// for debugging:
@property (nonatomic) NSString *matchedPlugin;
@property (nonatomic) NSDictionary *pluginArgs;
@property (nonatomic, copy) PSVoidBlock debugDataChangeBlock;
- (PSPluginDispatcher *)dispatcher;
@property (nonatomic) NSString *errorString;

+ (NSString *)builtinModulesPath;
+ (NSString *)pythonPath;

@end
