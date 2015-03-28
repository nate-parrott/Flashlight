//
//  PluginDirectoryAPI.h
//  Flashlight
//
//  Created by Nate Parrott on 11/21/14.
//
//

#import <Foundation/Foundation.h>

@interface PluginDirectoryAPI : NSObject

+ (PluginDirectoryAPI *)shared;

- (void)loadCategoriesWithCallback:(void (^)(NSArray *categories, NSError *error))callback;
- (NSURL *)URLForCategory:(NSString *)category;
- (NSURL *)URLForSearchQuery:(NSString *)query;
- (NSURL *)URLForPluginNamed:(NSString *)name;
- (void)logPluginInstall:(NSString *)name isUpdate:(BOOL)update;
- (void)getPluginsNeedingUpdatesWithExistingVersions:(NSDictionary *)pluginsByVersion callback:(void(^)(NSArray *pluginsNeedingUpdate))callback;
+ (NSString *)APIRoot;

@end
