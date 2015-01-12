//
//  PrefEditorWindow.h
//  PrefEditor
//
//  Created by Nate Parrott on 1/10/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PluginModel;
@interface PrefEditorWindow : NSWindowController

@property (nonatomic) PluginModel *plugin;

- (void)save;

@end
