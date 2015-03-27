//
//  PluginInstallManager.h
//  Flashlight
//
//  Created by Nate Parrott on 3/24/15.
//
//

#import <Foundation/Foundation.h>
@class PluginModel;

extern NSString *PluginInstallManagerDidUpdatePluginStatusesNotification;
extern NSString *PluginInstallManagerSetOfInstalledPluginsChangedNotification;
// the implementation for PluginInstallManagerSetOfInstalledPluginsChangedNotification should also call the implementation of PluginInstallManagerDidUpdatePluginStatusesNotification

@interface PluginInstallManager : NSObject

@property (nonatomic,readonly) NSSet *installTasksInProgress;

+ (PluginInstallManager *)shared;

- (void)installPlugin:(PluginModel *)plugin;
- (void)updatePlugin:(PluginModel *)plugin;
- (void)installPlugin:(PluginModel *)plugin callback:(void(^)(BOOL success, NSError *error))callback;
- (void)installPlugin:(PluginModel *)plugin isUpdate:(BOOL)isUpdate callback:(void(^)(BOOL success, NSError *error))callback;
- (void)uninstallPlugin:(PluginModel *)plugin;
- (BOOL)isPluginCurrentlyBeingInstalled:(PluginModel *)plugin;

@end
