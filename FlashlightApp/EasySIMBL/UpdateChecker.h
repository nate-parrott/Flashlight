//
//  UpdateChecker.h
//  Flashlight
//
//  Created by Nate Parrott on 1/14/15.
//
//

#import <Foundation/Foundation.h>

extern NSString * UpdateCheckerPluginsNeedingUpdatesDidChangeNotification;
extern NSString * UpdateCheckerAutoupdateStatusChangedNotification;

@interface UpdateChecker : NSObject

+ (UpdateChecker *)shared;
@property (nonatomic) NSArray *pluginsNeedingUpdates;
- (void)justInstalledPlugin:(NSString *)plugin;

@property (nonatomic) BOOL autoupdating;

@end
