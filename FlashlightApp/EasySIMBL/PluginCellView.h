//
//  PluginCellView.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Cocoa/Cocoa.h>
#import "ITSwitch.h"

@interface PluginCellView : NSTableCellView

@property (nonatomic,weak) IBOutlet ITSwitch *switchControl;

@end
