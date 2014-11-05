//
//  _SS_PluginRunner.h
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _SS_PluginRunner : NSObject

+ (NSDictionary *)resultDictionariesFromPluginsForQuery:(NSString *)query;
+ (void)runQueryResultWithArgs:(id)runArgs sourcePlugin:(NSString *)pluginName;

@end
