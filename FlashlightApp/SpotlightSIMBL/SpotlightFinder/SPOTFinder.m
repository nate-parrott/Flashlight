//
//  SPFinder.m
//  SpotlightFinder
//
//  Created by Josip Cavar on 09/12/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

#import "SPOTFinder.h"
#import <objc/runtime.h>

@implementation SPOTFinder

+ (instancetype)sharedInstance {
    
    static id plugin = nil;
    if (plugin == nil) {
        plugin = [[self alloc] init];
    }
    return plugin;
}

+ (void)load {
    
    NSLog(@"SPOTFinder loaded");
    id plugin = [self sharedInstance];
    if (plugin) {
        SPAppDelegate *appDelegate = [NSApp delegate];
        NSView *view = appDelegate.window.topView;
        NSButton *button = [[NSButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(appDelegate.window.searchField.frame) - CGRectGetHeight(appDelegate.window.searchField.frame), CGRectGetMinY(appDelegate.window.searchField.frame), CGRectGetHeight(appDelegate.window.searchField.frame), CGRectGetHeight(appDelegate.window.searchField.frame))];
        [button setButtonType:NSMomentaryPushInButton];
        [button setBezelStyle: NSRoundedDisclosureBezelStyle];
        [button setImagePosition:NSImageOnly];
        button.transparent = YES;
        [button setImage:[NSImage imageNamed:NSImageNameRevealFreestandingTemplate]];
        button.autoresizingMask = NSViewNotSizable | NSViewMaxYMargin | NSViewMaxYMargin;
        [button setTarget:[self sharedInstance]];
        [button setAction:@selector(buttonShowInFinderOnClick)];
        [view addSubview:button];
        
        [SPOTFinder sharedInstance].buttonShowInFinder = button;
        
        Class workspaceTabController = NSClassFromString(@"SPAppDelegate");
        Method buildMethod = class_getInstanceMethod(workspaceTabController, NSSelectorFromString(@"didShowPreviewItem:"));
        Method buildReplaceMethod = class_getInstanceMethod(workspaceTabController, NSSelectorFromString(@"didShowPreviewItemReplace:"));
        method_exchangeImplementations(buildMethod, buildReplaceMethod);
    }
}

- (void)buttonShowInFinderOnClick {
    
    SPAppDelegate *appDelegate = [NSApp delegate];
    if ([[appDelegate selectedResult] respondsToSelector:@selector(filePath)]) {
        id result = [[appDelegate selectedResult] filePath];
        if ([result isKindOfClass:NSString.class]) {
            NSLog(@"SPOTFinder opening path %@", result);
            [[NSWorkspace sharedWorkspace] selectFile:result inFileViewerRootedAtPath:@""];
        }
    }
}

@end

@implementation NSObject (SPOTAdditions)

- (void)didShowPreviewItemReplace:(id)arg {
    
    NSLog(@"SPOTFinder called show preview");
    [SPOTFinder sharedInstance].buttonShowInFinder.hidden = YES;
    SPAppDelegate *appDelegate = [NSApp delegate];
    if ([[appDelegate selectedResult] respondsToSelector:@selector(filePath)]) {
        id result = [[appDelegate selectedResult] filePath];
        if ([result isKindOfClass:NSString.class]) {
            NSLog(@"SPOTFinder selected path %@", result);
            [SPOTFinder sharedInstance].buttonShowInFinder.hidden = NO;
        }
    }
    [self didShowPreviewItemReplace:arg];
}

@end
