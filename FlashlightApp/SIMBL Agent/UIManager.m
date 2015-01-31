//
//  UIManager.m
//  SIMBL
//
//  Created by Nate Parrott on 1/30/15.
//
//

#import "UIManager.h"
#import <ServiceManagement/ServiceManagement.h>

@interface UIManager ()

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) IBOutlet NSMenu *statusMenu;

@end

@implementation UIManager

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    NSImage *image = [NSImage imageNamed:@"StatusItemOn"];
    [image setTemplate:YES];
    self.statusItem.image = image;
    self.statusItem.menu = self.statusMenu;
}

- (IBAction)managePlugins:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"flashlight://category/Installed"]];
}

- (IBAction)getNewPlugins:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"flashlight://category/Featured"]];
}

@end
