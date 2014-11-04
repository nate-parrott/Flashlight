//
//  PluginListController.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Foundation/Foundation.h>

@interface PluginListController : NSObject

@property (nonatomic,weak) IBOutlet NSArrayController *arrayController;
@property (nonatomic,weak) IBOutlet NSTableView *tableView;

- (IBAction)reloadPluginsFromWeb:(id)sender;

@end
