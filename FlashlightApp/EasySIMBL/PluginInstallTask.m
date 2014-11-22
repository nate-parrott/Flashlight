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
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSError *zipError = nil;
                    ZZArchive *archive = [ZZArchive archiveWithData:data error:&zipError];
                    if (archive && !zipError) {
                        for (ZZArchiveEntry *entry in archive.entries) {
                            zipError = nil;
                            NSData *entryData = [entry newDataWithError:&zipError];
                            if (entryData && !zipError) {
                                NSString *writeToPath = [directory stringByAppendingPathComponent:entry.fileName];
                                if (![[NSFileManager defaultManager] fileExistsAtPath:[writeToPath stringByDeletingLastPathComponent]]) {
                                    [[NSFileManager defaultManager] createDirectoryAtPath:[writeToPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NO];
                                }
                                [entryData writeToFile:writeToPath atomically:YES];
                            } else {
                                callback(NO, zipError);
                                return;
                            }
                        }
                        callback(YES, nil);
                    } else {
                        callback(NO, zipError);
                    }
                });
            } else {
                callback(NO, error);
            }
        }] resume];
    }
}

@end
