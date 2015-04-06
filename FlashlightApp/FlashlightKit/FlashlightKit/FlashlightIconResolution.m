//
//  FlashlightIconResolution.m
//  FlashlightKit
//
//  Created by Nate Parrott on 4/1/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "FlashlightIconResolution.h"

@implementation FlashlightIconResolution

+ (NSString *)pathForIconForPluginAtPath:(NSString *)pluginPath {
    BOOL darkMode = [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain] objectForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];
    
    NSMutableArray *iconSearchPaths = [NSMutableArray new];
    if (darkMode) {
        [iconSearchPaths addObject:[pluginPath stringByAppendingPathComponent:@"icon-dark.png"]];
    }
    [iconSearchPaths addObject:[pluginPath stringByAppendingPathComponent:@"Icon.png"]];
    [iconSearchPaths addObject:[pluginPath stringByAppendingPathComponent:@"icon.png"]];
    for (NSString *path in iconSearchPaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return path;
        }
    }
    
    // if we still don't have an image, see if there's one referenced in `info.json` (this is an undocumented API supported for compatibility)
    NSData *infoJsonData = [NSData dataWithContentsOfFile:[pluginPath stringByAppendingPathComponent:@"info.json"]];
    if (infoJsonData) {
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:infoJsonData options:0 error:nil];
        if (info[@"iconPath"]) {
            NSString *iconPath = info[@"iconPath"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
                return iconPath;
            }
        }
    }
    return nil;
}

+ (NSImage *)iconForPluginAtPath:(NSString *)pluginPath {
    NSString *path = [self pathForIconForPluginAtPath:pluginPath];
    return path ? [[NSImage alloc] initByReferencingFile:path] : nil;
}

@end
