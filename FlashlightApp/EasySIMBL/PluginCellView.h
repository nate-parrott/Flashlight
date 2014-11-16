//
//  PluginCellView.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Cocoa/Cocoa.h>
#import "ITSwitch.h"
@class PluginListController, PluginModel;

@interface PluginCellView : NSTableCellView

@property (nonatomic,weak) IBOutlet ITSwitch *switchControl;
@property (nonatomic,weak) IBOutlet PluginListController *listController;

- (PluginModel *)plugin;

@end
