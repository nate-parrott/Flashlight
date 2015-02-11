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

@interface PluginCellView ()

@property (nonatomic) IBOutlet NSButton *settingsButton, *editButton;

@end

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
    self.settingsButton.hidden = [self.plugin installing] || ![self.plugin hasOptions];
    self.editButton.hidden = !self.plugin.isAutomatorWorkflow;
}

- (IBAction)edit:(id)sender {
    [self.listController editAutomatorPluginNamed:self.plugin.name];
}

- (IBAction)remove:(id)sender {
    [self.listController uninstallPlugin:[self plugin]];
}

- (IBAction)openSettings:(id)sender {
    [self.plugin presentOptionsInWindow:self.window];
}

@end
