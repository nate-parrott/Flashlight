//
//  SearchPluginEditorWindowController.m
//  Flashlight
//
//  Created by Nate Parrott on 12/14/14.
//
//

#import "SearchPluginEditorWindowController.h"
#import "PluginEditorWindowController.h"

@interface SearchPluginEditorWindowController () <NSTextFieldDelegate>

@property (nonatomic) IBOutlet NSTextField *nameField, *extraKeywordsField, *urlField, *mobileUrlField;
@property (nonatomic) NSTimer *saveTimer;
@property (nonatomic) BOOL pendingSave;

@end

@implementation SearchPluginEditorWindowController


#pragma mark Data
- (NSDictionary *)json {
    NSData *data = [NSData dataWithContentsOfFile:[self.pluginPath stringByAppendingPathComponent:@"info.json"]];
    if (!data) return nil; // TODO: show some sort of error
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}
- (NSDictionary *)textFieldsForJsonFields {
    return @{
             @"displayName": self.nameField,
             @"searchExtraKeywords": self.extraKeywordsField,
             @"urlTemplate": self.urlField,
             @"mobileUrlTemplate": self.mobileUrlField
             };
}
- (void)save {
    NSMutableDictionary *json = [self json].mutableCopy;
    json[@"displayName"] = self.nameField.stringValue;
    json[@"searchExtraKeywords"] = self.extraKeywordsField.stringValue;
    [[NSJSONSerialization dataWithJSONObject:json options:0 error:nil] writeToFile:[self.pluginPath stringByAppendingPathComponent:@"info.json"] atomically:YES];
    
    NSMutableArray *examples = [NSMutableArray new];
    if (self.nameField.stringValue.length) {
        [examples addObject:[NSString stringWithFormat:@"%@ ~query(search string)", self.nameField.stringValue]];
    }
    for (NSString *extraKeyword in [self.extraKeywordsField.stringValue componentsSeparatedByString:@","]) {
        NSString *keyword = [extraKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword.length) {
            [examples addObject:[NSString stringWithFormat:@"%@ ~query(search)", keyword]];
        }
    }
    
    [[examples componentsJoinedByString:@"\n"] writeToFile:[self.pluginPath stringByAppendingPathComponent:@"examples.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *searchInfo = @{
                                 @"name": self.nameField.stringValue,
                                 @"urlTemplate": self.urlField.stringValue,
                                 @"mobileUrlField": self.mobileUrlField.stringValue
                                 };
    NSData *searchInfoJson = [NSJSONSerialization dataWithJSONObject:searchInfo options:0 error:nil];
    [searchInfoJson writeToFile:[self.pluginPath stringByAppendingPathComponent:@"searchInfo.json"] atomically:YES];
    
    self.saveTimer = nil;
    self.pendingSave = NO;
}
#pragma mark Window
- (void)windowDidLoad {
    [super windowDidLoad];
    [[PluginEditorWindowController globalOpenWindows] addObject:self];

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

#pragma mark NSTextFieldDelegate:
- (void)controlTextDidChange:(NSNotification *)obj {
    [self edited:nil];
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
- (IBAction)deletePlugin:(id)sender {
    [[NSFileManager defaultManager] removeItemAtPath:[self pluginPath] error:nil];
    self.pendingSave = NO;
    [self.saveTimer invalidate];
    self.saveTimer = nil;
    [self close];
}

@end
