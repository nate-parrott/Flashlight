//
//  PluginEditorWindowController.m
//  Flashlight
//
//  Created by Nate Parrott on 11/16/14.
//
//

#import "PluginEditorWindowController.h"

NSString * const PluginDidChangeOnDiskNotification = @"PluginDidChangeOnDiskNotification";

@interface PluginEditorWindowController () <NSTextViewDelegate, NSTextFieldDelegate>

@property (nonatomic,weak) IBOutlet NSTextField *nameField, *descriptionField;
@property (nonatomic,assign) IBOutlet NSTextView *examples;
@property (nonatomic) NSTimer *saveTimer;
@property (nonatomic) BOOL pendingSave;

@end

@implementation PluginEditorWindowController

#pragma mark Data
- (NSDictionary *)json {
    NSData *data = [NSData dataWithContentsOfFile:[self.pluginPath stringByAppendingPathComponent:@"info.json"]];
    if (!data) return nil; // TODO: show some sort of error
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}
- (void)save {
    NSMutableDictionary *json = [self json].mutableCopy;
    json[@"displayName"] = self.nameField.stringValue;
    json[@"description"] = self.descriptionField.stringValue;
    json[@"examples"] = [self.examples.string componentsSeparatedByString:@"\n"];
    [[NSJSONSerialization dataWithJSONObject:json options:0 error:nil] writeToFile:[self.pluginPath stringByAppendingPathComponent:@"info.json"] atomically:YES];
    [self.examples.string writeToFile:[self.pluginPath stringByAppendingPathComponent:@"examples.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    self.saveTimer = nil;
    self.pendingSave = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PluginDidChangeOnDiskNotification object:self];
}
#pragma mark Actions
- (IBAction)edited:(id)sender {
    if (self.saveTimer) {
        [self.saveTimer invalidate];
        self.saveTimer = nil;
    }
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(save) userInfo:nil repeats:NO];
    self.pendingSave = YES;
}
- (IBAction)editWorkflow:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:[self.pluginPath stringByAppendingPathComponent:@"workflow.workflow"]];
}
- (IBAction)deletePlugin:(id)sender {
    [[NSFileManager defaultManager] removeItemAtPath:[self pluginPath] error:nil];
    self.pendingSave = NO;
    [self.saveTimer invalidate];
    self.saveTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PluginDidChangeOnDiskNotification object:self];
    [self close];
}
#pragma mark NSTextViewDelegate
- (void)textDidChange:(NSNotification *)notification {
    [self edited:nil];
}
#pragma mark NSTextFieldDelegate:
- (void)controlTextDidChange:(NSNotification *)obj {
    [self edited:nil];
}
#pragma mark UI
- (void)windowDidLoad {
    [super windowDidLoad];
    [[[self class] globalOpenWindows] addObject:self];
    
    NSDictionary *json = [self json];
    self.nameField.stringValue = json[@"displayName"];
    self.descriptionField.stringValue = json[@"description"];
    self.examples.string = [[NSString alloc] initWithContentsOfFile:[self.pluginPath stringByAppendingPathComponent:@"examples.txt"] encoding:NSUTF8StringEncoding error:nil];
    
    self.nameField.delegate = self;
    self.descriptionField.delegate = self;
    self.examples.delegate = self;
}
- (void)setPendingSave:(BOOL)pendingSave {
    _pendingSave = pendingSave;
}
- (void)close {
    if (self.pendingSave) {
        [self.saveTimer invalidate];
        self.saveTimer = nil;
        [self save];
    }
    [super close];
    [[[self class] globalOpenWindows] removeObject:self];
}
+ (NSMutableSet *)globalOpenWindows {
    static NSMutableSet *windows = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        windows = [NSMutableSet new];
    });
    return windows;
}

@end
