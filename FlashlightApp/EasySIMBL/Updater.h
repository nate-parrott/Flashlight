//
//  InPlaceUpdater.h
//  Flashlight
//
//  Created by Nate Parrott on 11/10/14.
//
//

#import <Foundation/Foundation.h>

@interface Updater : NSObject

- (void)checkForUpdates:(void(^)())callback;
@property (nonatomic,strong) NSString *updatedVersionName;
@property (nonatomic,strong) NSString *updateURL;

@end
