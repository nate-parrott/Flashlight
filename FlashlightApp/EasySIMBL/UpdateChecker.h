//
//  UpdateChecker.h
//  Flashlight
//
//  Created by Nate Parrott on 1/14/15.
//
//

#import <Foundation/Foundation.h>

NSString * const UpdateCheckerPluginsNeedingUpdatesDidChangeNotification;

@interface UpdateChecker : NSObject

+ (UpdateChecker *)shared;
@property (nonatomic) NSArray *pluginsNeedingUpdates;
- (void)justInstalledPlugin:(NSString *)plugin;

@end
