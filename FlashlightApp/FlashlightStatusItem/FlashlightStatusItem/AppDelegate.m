//
//  AppDelegate.m
//  FlashlightStatusItem
//
//  Created by Nate Parrott on 10/12/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "AppDelegate.h"
@class UIManager;
#import "PopoverViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) IBOutlet UIManager *uiManager;
@property (weak) IBOutlet PopoverViewController *popoverVC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openTargetResultWithOptions:(NSInteger)options {
    [self.popoverVC enterPressed:nil];
}

@end
