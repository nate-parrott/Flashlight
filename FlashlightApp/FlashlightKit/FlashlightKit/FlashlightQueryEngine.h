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
 3-arg results() functions
 @date
 (regex examples?)
 
 */

#import <Foundation/Foundation.h>
#import "PSHelpers.h"
@class PSPluginDispatcher;

@interface FlashlightQueryEngine : NSObject

- (void)updateQuery:(NSString *)query;
@property (nonatomic, readonly) NSArray *results;
@property (nonatomic, copy) PSVoidBlock resultsDidChangeBlock;

// for debugging:
@property (nonatomic) NSString *matchedPlugin;
@property (nonatomic) NSDictionary *pluginArgs;
@property (nonatomic, copy) PSVoidBlock debugDataChangeBlock;
- (PSPluginDispatcher *)dispatcher;
@property (nonatomic) NSString *errorString;

@end
