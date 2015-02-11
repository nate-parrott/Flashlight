//
//  PluginListController.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class PluginModel;

@interface PluginListController : NSObject

@property (nonatomic) IBOutlet NSView *rightPaneContainer;
@property (nonatomic,weak) IBOutlet NSArrayController *arrayController;
@property (nonatomic) IBOutlet NSView *view;

@property (nonatomic) IBOutlet NSView *tableContainer;
@property (nonatomic) IBOutlet NSTableView *tableView;

@property (nonatomic) IBOutlet NSVisualEffectView *webViewEffectView;
@property (nonatomic) IBOutlet WebView *webView;

- (void)installPlugin:(PluginModel *)plugin;
- (void)uninstallPlugin:(PluginModel *)plugin;

@property (nonatomic,weak) IBOutlet NSView *errorBanner;
@property (nonatomic,weak) IBOutlet NSTextField *errorText;
@property (nonatomic,weak) IBOutlet NSButton *errorButton;
@property (nonatomic,strong) void (^errorButtonAction)();

@property (nonatomic) IBOutlet NSToolbarItem *toolbarItem;
@property (nonatomic) IBOutlet NSView *toggleView;

@property (nonatomic) IBOutlet NSOutlineView *sourceList;

- (void)showPluginWithName:(NSString *)name;
- (void)showInstalledPluginWithName:(NSString *)name;
- (void)showCategory:(NSString *)category;
- (void)showSearch:(NSString *)search;

@property (nonatomic) BOOL enabled;

- (void)editAutomatorPluginNamed:(NSString *)name;

@end
