//
//  AppDelegate.m
//  FlashlightTool
//
//  Created by Nate Parrott on 12/25/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightToolAppDelegate.h"
#import "PSPluginDispatcher.h"
#import "PSBackgroundProcessor.h"
#import "PSHelpers.h"
#import "PSPluginExampleSource.h"

@import WebKit;

@interface FlashlightToolAppDelegate () <NSWindowDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *matchingPlugin, *pluginInput;

@property (nonatomic) IBOutlet NSTextView *errors;
@property (nonatomic) NSDictionary *errorSections;

@property (weak) IBOutlet WebView *resultWebView;
@property (weak) IBOutlet NSTextField *resultTitle;

@property PSPluginDispatcher *ps;
@property (nonatomic) PSBackgroundProcessor *querier;

@end

@implementation FlashlightToolAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.ps = [PSPluginDispatcher new];
    __weak FlashlightToolAppDelegate *weakSelf = self;
    self.querier = [[PSBackgroundProcessor alloc] initWithProcessingBlock:^(id data, PSBackgroundProcessorResultBlock callback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *matchingPlugin;
            NSDictionary *pluginArgs;
            [self.ps parseCommand:data pluginPath:&matchingPlugin arguments:&pluginArgs];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.matchingPlugin.stringValue = matchingPlugin.lastPathComponent.stringByDeletingPathExtension ? : @"None";
                weakSelf.pluginInput.stringValue = pluginArgs ? [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:pluginArgs options:0 error:nil] encoding:NSUTF8StringEncoding] : @"";
                callback(nil);
            });
        });
    }];
    
    self.errorSections = @{};
    
    self.ps.exampleSource.parserOutputChangedBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *d = self.errorSections.mutableCopy;
            d[@"Examples.txt Errors"] = weakSelf.ps.exampleSource.parserInfoOutput;
            weakSelf.errorSections = d;
        });
    };
    self.ps.exampleSource.parserOutputChangedBlock();
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)search:(NSSearchField *)sender {
    [self.querier gotNewData:sender.stringValue];
}

- (void)setErrorSections:(NSDictionary *)errorSections {
    _errorSections = errorSections;
    NSAttributedString *errors = [[[_errorSections allKeys] mapFilter:^id(id header) {
        NSAttributedString *headerText = [[NSAttributedString alloc] initWithString:[header stringByAppendingString:@"\n"] attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]}];
        NSString *errorText = [_errorSections[header] length] > 0 ? _errorSections[header] : @"(None)";
        NSAttributedString *error = [[NSAttributedString alloc] initWithString:errorText attributes:@{NSFontAttributeName: [NSFont fontWithName:@"Monaco" size:12]}];
        NSMutableAttributedString *str = [NSMutableAttributedString new];
        [str appendAttributedString:headerText];
        [str appendAttributedString:error];
        return str;
    }] reduce:^id(NSAttributedString* obj1, NSAttributedString* obj2) {
        NSMutableAttributedString *str = [NSMutableAttributedString new];
        [str appendAttributedString:obj1];
        [str appendAttributedString:obj2];
        return str;
    } initialVal:[NSAttributedString new]];
    [self.errors.textStorage setAttributedString:errors];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self.ps.exampleSource reload];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
