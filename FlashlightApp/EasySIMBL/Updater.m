//
//  InPlaceUpdater.m
//  Flashlight
//
//  Created by Nate Parrott on 11/10/14.
//
//

#import "Updater.h"

@interface Updater ()

@property (nonatomic) NSDictionary *updateJson;

@end


@implementation Updater

- (void)checkForUpdates:(void(^)())callback {
    NSURL *updateURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/nate-parrott/flashlight/master/UpdateInfo.json"];
    double currentBuild = [[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] doubleValue];
    [[[NSURLSession sharedSession] dataTaskWithURL:updateURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.updatedVersionName = nil;
            self.updateURL = nil;
            if (data) {
                self.updateJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([self.updateJson[@"build"] doubleValue] > currentBuild) {
                    self.updatedVersionName = self.updateJson[@"name"];
                    self.updateURL = self.updateJson[@"updateURL"];
                }
            }
            callback();
        });
    }] resume];
}

@end
