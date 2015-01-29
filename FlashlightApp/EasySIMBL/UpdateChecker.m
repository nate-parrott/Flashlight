//
//  UpdateChecker.m
//  Flashlight
//
//  Created by Nate Parrott on 1/14/15.
//
//

#import "UpdateChecker.h"
#import "PluginModel.h"
#import "PluginDirectoryAPI.h"

NSString * UpdateCheckerPluginsNeedingUpdatesDidChangeNotification = @"UpdateCheckerPluginsNeedingUpdatesDidChangeNotification";

@implementation UpdateChecker

+ (UpdateChecker *)shared {
    static UpdateChecker *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [UpdateChecker new];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    [self reload];
    return self;
}

- (void)reload {
    [[PluginDirectoryAPI shared] getPluginsNeedingUpdatesWithExistingVersions:[self pluginsByVersion] callback:^(NSArray *pluginsNeedingUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pluginsNeedingUpdates = pluginsNeedingUpdate;
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateCheckerPluginsNeedingUpdatesDidChangeNotification object:self];
        });
    }];
}

- (NSDictionary *)pluginsByVersion {
    NSMutableDictionary *pluginsByVersion = [NSMutableDictionary new];
    NSString *pluginsDir = [PluginModel pluginsDir];
    for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsDir error:nil]) {
        NSString *pluginPath = [pluginsDir stringByAppendingPathComponent:filename];
        NSString *pluginName = filename.stringByDeletingPathExtension;
        if ([filename.pathExtension isEqualToString:@"bundle"]) {
            pluginsByVersion[pluginName] = @([PluginModel versionForPluginAtPath:pluginPath]);
        }
    }
    return pluginsByVersion;
}

- (void)justInstalledPlugin:(NSString *)plugin {
    NSMutableArray *plugins = self.pluginsNeedingUpdates.mutableCopy;
    [plugins removeObject:plugin];
    self.pluginsNeedingUpdates = plugins;
}

@end
