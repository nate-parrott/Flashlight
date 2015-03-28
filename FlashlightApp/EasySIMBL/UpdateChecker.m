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
#import "PluginInstallManager.h"
#import "ConvenienceCategories.h"

NSString * UpdateCheckerPluginsNeedingUpdatesDidChangeNotification = @"UpdateCheckerPluginsNeedingUpdatesDidChangeNotification";
NSString * UpdateCheckerAutoupdateStatusChangedNotification = @"UpdateCheckerAutoupdateStatusChangedNotification";

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
        PerformOnMainThread(^{
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
    PerformOnMainThread(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateCheckerPluginsNeedingUpdatesDidChangeNotification object:self];
    });
}

#pragma mark Autoupdates

- (void)setAutoupdating:(BOOL)autoupdating {
    if (autoupdating != _autoupdating) {
        _autoupdating = autoupdating;
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateCheckerAutoupdateStatusChangedNotification object:self];
        [self updateNextPluginOrFinishIfStillAutoupdating];
    }
}

- (void)updateNextPluginOrFinishIfStillAutoupdating {
    PerformOnMainThread(^{
        if (self.autoupdating) {
            if (self.pluginsNeedingUpdates.count > 0) {
                NSString *plugin = self.pluginsNeedingUpdates.firstObject;
                [[PluginInstallManager shared] installPlugin:[PluginModel installedPluginNamed:plugin] isUpdate:YES callback:^(BOOL success, NSError *error) {
                    if (success) {
                        
                        // HACK: work-around a condition where the local plugin's info.json name is (illegally) different from its directory name, and we get into an infinite plugin loop.
                        if ([self.pluginsNeedingUpdates containsObject:plugin]) {
                            [self justInstalledPlugin:plugin];
                        }
                        // /HACK
                        
                        [self updateNextPluginOrFinishIfStillAutoupdating];
                    } else {
                        self.autoupdating = NO;
                    }
                }];
            } else {
                self.autoupdating = NO;
            }
        }
    });
}

@end
