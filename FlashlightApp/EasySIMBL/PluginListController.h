//
//  PluginListController.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Foundation/Foundation.h>

@class PluginModel;

@interface PluginListController : NSObject

@property (nonatomic,weak) IBOutlet NSArrayController *arrayController;
@property (nonatomic) IBOutlet NSView *view;
@property (nonatomic) IBOutlet NSTableView *tableView;

- (IBAction)reloadPluginsFromWeb:(id)sender;

- (void)installPlugin:(PluginModel *)plugin;
- (void)uninstallPlugin:(PluginModel *)plugin;

@property (nonatomic,weak) IBOutlet NSView *failedToLoadDirectoryBanner;

@end
