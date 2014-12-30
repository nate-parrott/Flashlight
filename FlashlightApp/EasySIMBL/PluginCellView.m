//
//  PluginCellView.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginCellView.h"
#import "PluginModel.h"
#import "PluginListController.h"
#import <QuartzCore/QuartzCore.h>
#import "ITSwitch+Additions.h"

@implementation PluginCellView

- (PluginModel *)plugin {
    return self.objectValue;
}

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    self.removeButton.enabled = ![self plugin].installing;
    if ([[self plugin] installing]) {
        [self.loader startAnimation:nil];
    } else {
        [self.loader stopAnimation:nil];
    }
}

- (IBAction)remove:(id)sender {
    [self.listController uninstallPlugin:[self plugin]];
}

@end
