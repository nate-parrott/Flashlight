//
//  FlashlightIconResolution.h
//  FlashlightKit
//
//  Created by Nate Parrott on 4/1/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface FlashlightIconResolution : NSObject

+ (NSString *)pathForIconForPluginAtPath:(NSString *)pluginPath;
+ (NSImage *)iconForPluginAtPath:(NSString *)pluginPath;

@end
