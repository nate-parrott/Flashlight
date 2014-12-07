/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <Cocoa/Cocoa.h>
#import "ITSwitch.h"
#import <WebKit/WebKit.h>

@class PluginListController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) NSString *loginItemBundleIdentifier;
@property (nonatomic) NSString *loginItemPath;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) IBOutlet ITSwitch *useSIMBLSwitch;
@property (nonatomic) IBOutlet NSTableView *tableView;
@property (nonatomic) IBOutlet WebView *webView;
- (IBAction)toggleUseSIMBL:(id)sender;

@property (nonatomic) BOOL SIMBLOn;

@property (nonatomic,weak) IBOutlet PluginListController *pluginListController;

- (IBAction)openURLFromButton:(NSButton *)sender;

@end
