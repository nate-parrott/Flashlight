//
//  PluginInstallTask.h
//  Flashlight
//
//  Created by Nate Parrott on 11/4/14.
//
//

#import <Foundation/Foundation.h>
@class PluginModel;

@interface PluginInstallTask : NSObject

- (id)initWithPlugin:(PluginModel *)plugin;
- (void)startInstallationIntoPluginsDirectory:(NSString *)directory withCallback:(void(^)(BOOL success, NSError *error))callback; // callback comes on arbitrary thread
@property (nonatomic,readonly) PluginModel *plugin;

@end
