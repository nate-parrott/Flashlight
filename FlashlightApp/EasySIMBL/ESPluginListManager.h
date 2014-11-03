/**
 * Copyright 2012, hetima
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <Foundation/Foundation.h>

// this class is tableview delegate so that receive action from inside of table cell view etc.

@interface ESPluginListManager : NSObject{
    FSEventStreamRef _eventStream;
}

@property (nonatomic) NSMutableArray* plugins;
@property (assign) IBOutlet NSPopover *removePopover;
@property (assign) IBOutlet NSTextField *removePopoverCaption;
@property (assign) IBOutlet NSTableView *listView;
@property (nonatomic) NSString *pluginsDirectory;
@property (nonatomic) NSString *disabledPluginsDirectory;


- (void)installPlugins:(NSArray*)plugins;
- (NSMenu*)menuForTableView:(NSTableView*)tableView row:(NSInteger)row;

@end
