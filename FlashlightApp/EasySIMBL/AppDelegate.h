/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class PluginListController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) NSString *loginItemBundleIdentifier;
@property (nonatomic) NSString *loginItemPath;

@property (assign) IBOutlet NSWindow *window;

- (IBAction)toggleFlashlightEnabled:(id)sender;

@property (nonatomic) BOOL SIMBLOn;

@property (nonatomic,weak) IBOutlet PluginListController *pluginListController;

- (IBAction)openURLFromButton:(NSButton *)sender;

- (IBAction)openGithub:(id)sender;
- (IBAction)leaveFeedback:(id)sender;

@end
