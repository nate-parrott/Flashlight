//
//  AppDelegate.m
//  FlashlightTool
//
//  Created by Nate Parrott on 12/25/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightToolAppDelegate.h"
#import <FlashlightKit/FlashlightKit.h>

@import WebKit;

@interface FlashlightToolAppDelegate () <NSWindowDelegate, NSTextFieldDelegate>

@property (nonatomic) FlashlightQueryEngine *queryEngine;

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *matchingPlugin, *pluginInput;

@property (nonatomic) IBOutlet NSTextView *errors;
@property (nonatomic) NSDictionary *errorSections;

@property (nonatomic) FlashlightResult *result;
@property (weak) IBOutlet FlashlightResultView *resultView;
@property (weak) IBOutlet NSTextField *resultTitle;

@property (nonatomic) NSString *lastQuery;

@property (nonatomic) IBOutlet NSTextField *updateInfoLabel;

@end

@implementation FlashlightToolAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {    
    __weak FlashlightToolAppDelegate *weakSelf = self;
    
    self.queryEngine = [FlashlightQueryEngine new];
    
    self.errorSections = @{};
    
    self.queryEngine.dispatcher.exampleSource.parserOutputChangedBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *d = self.errorSections.mutableCopy;
            d[@"Examples.txt Errors"] = weakSelf.queryEngine.dispatcher.exampleSource.parserInfoOutput;
            weakSelf.errorSections = d;
        });
    };
    self.queryEngine.dispatcher.exampleSource.parserOutputChangedBlock();
    
    self.queryEngine.debugDataChangeBlock = ^{
        weakSelf.matchingPlugin.stringValue = weakSelf.queryEngine.matchedPlugin ? : @"None";
        weakSelf.pluginInput.stringValue = weakSelf.queryEngine.pluginArgs ? [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:weakSelf.queryEngine.pluginArgs options:0 error:nil] encoding:NSUTF8StringEncoding] : @"None";
    };
    self.queryEngine.debugDataChangeBlock();
    
    self.queryEngine.resultsDidChangeBlock = ^(NSString *query, NSArray *results){
        weakSelf.resultTitle.stringValue = [weakSelf.queryEngine.results.firstObject json][@"title"] ? : @"None";
        weakSelf.result = weakSelf.queryEngine.results.firstObject;
        weakSelf.resultView.result = weakSelf.result;
        NSMutableDictionary *d = weakSelf.errorSections.mutableCopy;
        if (weakSelf.queryEngine.errorString) {
            d[@"Plugin.py Errors"] = weakSelf.queryEngine.errorString;
        } else {
            [d removeObjectForKey:@"Plugin.py Errors"];
        }
        [d removeObjectForKey:@"Plugin.py run() Errors"];
        weakSelf.errorSections = d;
    };
    
    self.updateInfoLabel.stringValue = [NSString stringWithFormat:@"FlashlightTool %@", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.window makeKeyAndOrderFront:nil];
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)search:(NSSearchField *)sender {
    if (![sender.stringValue isEqualToString:self.lastQuery]) {
        self.lastQuery = sender.stringValue;
        [self.queryEngine updateQuery:sender.stringValue];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self openTargetResultWithOptions:0];
        return YES;
    } else {
        return NO;
    }
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
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
        [str appendAttributedString:obj2];
        return str;
    } initialVal:[NSAttributedString new]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.errors.textStorage setAttributedString:errors];
    });
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self.queryEngine.dispatcher.exampleSource reload];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] terminate:nil];
}

#pragma mark Actions
- (IBAction)openPluginsDirectory:(id)sender {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"FlashlightPlugins"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
}

- (IBAction)openAPIDocs:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/nate-parrott/Flashlight/wiki/API-Reference"]];
}

- (IBAction)newPlugin:(id)sender {
    NSString *name = [self input:NSLocalizedString(@"Choose an internal name for your plugin: (no spaces or special characters, please)", nil) defaultValue:@"my-plugin"];
    if (name.length) {
        NSString *skeleton = [[NSBundle mainBundle] pathForResource:@"say" ofType:@"bundle"];
        NSString *pluginsDir = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"FlashlightPlugins"];
        NSString *destination = [[pluginsDir stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"];
        [[NSFileManager defaultManager] copyItemAtPath:skeleton toPath:destination error:nil];
        NSString *infoJsonPath = [destination stringByAppendingPathComponent:@"info.json"];
        NSMutableDictionary *dict = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:infoJsonPath] options:0 error:nil] mutableCopy];
        dict[@"name"] = name;
        [[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] writeToFile:infoJsonPath atomically:YES];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:destination]]];
        [[NSWorkspace sharedWorkspace] selectFile:infoJsonPath inFileViewerRootedAtPath:destination];
    }
}

/* TODO: actually invest time in building a reasonable UI
 rather than copying the simplest possible example of a modal
 prompt dialog from StackOverflow */
- (NSString *)input:(NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}

- (IBAction)checkForUpdate:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://flashlighttool.42pag.es"]];
}

- (void)openTargetResultWithOptions:(unsigned long long)options {
    __weak FlashlightToolAppDelegate *weakSelf = self;
    [self.resultView.result pressEnter:self.resultView errorCallback:^(NSString *error) {
        NSMutableDictionary *d = weakSelf.errorSections.mutableCopy;
        [d removeObjectForKey:@"Plugin.py run() Errors"];
        if (error) d[@"Plugin.py run() Errors"] = error;
        weakSelf.errorSections = d;
    }];
}

@end
