//
//  SearchPluginState.h
//  FlashlightKit
//
//  Created by Nate Parrott on 2/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FlashlightResult;
#import <FlashlightKit/PSHelpers.h>

@interface SearchPluginState : NSObject

- (instancetype)initWithPluginPath:(NSString *)pluginPath;
@property (nonatomic,readonly) NSArray *results;
@property (nonatomic,copy) PSVoidBlock resultsUpdate;
- (NSArray *)setQueryAndGetResults:(NSString *)search;

@end
