//
//  PluginInstallTask.m
//  Flashlight
//
//  Created by Nate Parrott on 11/4/14.
//
//

#import "PluginInstallTask.h"
#import "PluginModel.h"
#import "zipzap.h"
#import "PluginDirectoryAPI.h"
#import "AppDelegate.h"
#import "UpdateChecker.h"

@implementation PluginInstallTask


- (id)initWithPlugin:(PluginModel *)plugin {
    self = [super init];
    _plugin = plugin;
    return self;
}
- (void)startInstallationIntoPluginsDirectory:(NSString *)directory withCallback:(void(^)(BOOL success, NSError *error))callback {
    [[PluginDirectoryAPI shared] logPluginInstall:self.plugin.name];
    if (self.plugin.zipURL) {
        [[[NSURLSession sharedSession] dataTaskWithURL:self.plugin.zipURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                [self installPluginData:data intoPluginsDirectory:directory callback:callback];
            } else {
                callback(NO, error);
            }
        }] resume];
    } else {
        NSLog(@"Can't install plugin with unknown zip url: %@", self.plugin.name);
    }
}

- (NSString *)nameForPluginContainingPath:(NSString *)path {
    for (NSString *comp in path.pathComponents.reverseObjectEnumerator) {
        if ([comp.pathExtension isEqualToString:@"bundle"]) {
            return comp.stringByDeletingPathExtension;
        }
    }
    return nil;
}

- (void)installPluginData:(NSData *)data intoPluginsDirectory:(NSString *)pluginsDirectory callback:(void(^)(BOOL success, NSError *error))callback {
    if (!data) {
        callback(NO, nil);
        return;
    }
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:tempDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pluginName = nil;
        NSError *zipError = nil;
        ZZArchive *archive = [ZZArchive archiveWithData:data error:&zipError];
        if (archive && !zipError) {
            for (ZZArchiveEntry *entry in archive.entries) {
                zipError = nil;
                NSData *entryData = [entry newDataWithError:&zipError];
                if (entryData && !zipError) {
                    NSString *writeToPath = [tempDirectory.path stringByAppendingPathComponent:entry.fileName];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:[writeToPath stringByDeletingLastPathComponent]]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:[writeToPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NO];
                    }
                    if ([[writeToPath pathExtension] isEqualToString:@"bundle"]) {
                        continue;
                    }
                    if (!pluginName && [self nameForPluginContainingPath:writeToPath]) {
                        pluginName = [self nameForPluginContainingPath:writeToPath];
                    }
                    [entryData writeToFile:writeToPath atomically:YES];
                } else {
                    callback(NO, zipError);
                    return;
                }
            }
            if (!pluginName) {
                callback(NO, nil);
                return;
            }
            
            // once we're done zipping, move from the temporary directory to the main directory (triggering a reload of the `examples.txt` index)
            NSString *bundleFilename = [pluginName stringByAppendingPathExtension:@"bundle"];
            NSString *destPath = [pluginsDirectory stringByAppendingPathComponent:bundleFilename];
            if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
            }
            [[NSFileManager defaultManager] moveItemAtPath:[tempDirectory.path stringByAppendingPathComponent:bundleFilename] toPath:destPath error:nil];
            
            _installedPluginName = pluginName;
            PluginModel *pluginModel = [PluginModel installedPluginNamed:pluginName];
            // done:
            if (pluginModel.openPreferencesOnInstall) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *d = (id)[NSApp delegate];
                    [pluginModel presentOptionsInWindow:d.window];
                });
            }
            [[UpdateChecker shared] justInstalledPlugin:self.plugin.name];
            callback(YES, nil);
        } else {
            callback(NO, zipError);
        }
    });
}

@end
