//
//  PluginEditorWindowController.h
//  Flashlight
//
//  Created by Nate Parrott on 11/16/14.
//
//

#import <Cocoa/Cocoa.h>

NSString * const PluginDidChangeOnDiskNotification;

@interface PluginEditorWindowController : NSWindowController

@property (nonatomic) NSString *pluginPath;

+ (NSMutableSet *)globalOpenWindows;

@end
