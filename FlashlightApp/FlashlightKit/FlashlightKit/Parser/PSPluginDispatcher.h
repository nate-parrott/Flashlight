//
//  PSPluginDispatcher.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/23/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSPluginExampleSource;

@interface PSPluginDispatcher : NSObject

// can be called on a background thread
- (void)parseCommand:(NSString *)command pluginPath:(NSString **)pluginPath arguments:(NSDictionary **)arguments;

- (PSPluginExampleSource *)exampleSource;

@end
