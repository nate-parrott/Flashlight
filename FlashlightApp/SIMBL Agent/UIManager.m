//
//  UIManager.m
//  SIMBL
//
//  Created by Nate Parrott on 1/30/15.
//
//

#import "UIManager.h"
#import <ServiceManagement/ServiceManagement.h>
#import "NSObject+InternationalizedValueForKey.h"

@interface UIManager () <NSMenuDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) IBOutlet NSMenu *statusMenu;
@property (nonatomic) IBOutlet NSMenu *pluginExamples;

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

#pragma mark Plugin examples
- (void)menuNeedsUpdate:(NSMenu *)menu {
    if (menu == self.pluginExamples) {
        [menu removeAllItems];
        NSString *pluginsDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"FlashlightPlugins"];
        for (NSString *plugin in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsDir error:nil]) {
            NSString *pluginPath = [pluginsDir stringByAppendingPathComponent:plugin];
            if ([pluginPath.pathExtension.lowercaseString isEqualToString:@"bundle"]) {
                NSData *infoJsonData = [NSData dataWithContentsOfFile:[pluginPath stringByAppendingPathComponent:@"info.json"]];
                if (infoJsonData) {
                    NSDictionary *infoJson = [NSJSONSerialization JSONObjectWithData:infoJsonData options:0 error:nil];
                    if ([infoJson isKindOfClass:[NSDictionary class]]) {
                        NSArray *examples = [infoJson internationalizedValueForKey:@"examples"];
                        if ([examples isKindOfClass:[NSArray class]] && examples.count > 0) {
                            if (menu.itemArray.count > 0) {
                                // append divider:
                                [menu addItem:[NSMenuItem separatorItem]];
                            }
                            for (NSString *example in examples) {
                                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:example action:@selector(openExample:) keyEquivalent:@""];
                                item.target = self;
                                [menu addItem:item];
                            }
                        }
                    }
                }
            }
        }
        if (menu.itemArray.count == 0) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"No plugins installed", @"") action:nil keyEquivalent:@""];
            item.enabled = NO;
            [menu addItem:item];
        }
    }
}

- (void)openExample:(NSMenuItem *)sender {
    
}

@end
