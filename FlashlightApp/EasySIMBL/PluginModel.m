//
//  PluginModel.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginModel.h"
#import "ConvenienceCategories.h"
#import "NSObject+InternationalizedValueForKey.h"
#import "PrefEditorWindow.h"
#import "PluginDirectoryAPI.h"

@implementation PluginModel

- (id)copyWithZone:(NSZone *)zone {
    PluginModel *p = [PluginModel new];
    p.name = self.name;
    p.displayName = self.displayName;
    p.pluginDescription = self.pluginDescription;
    p.installed = self.installed;
    p.installing = self.installing;
    p.examples = self.examples;
    p.categories = self.categories;
    p.isAutomatorWorkflow = self.isAutomatorWorkflow;
    p.isSearchPlugin = self.isSearchPlugin;
    p.openPreferencesOnInstall = self.openPreferencesOnInstall;
    return p;
}

+ (PluginModel *)fromJson:(NSDictionary *)json baseURL:(NSURL *)url {
    PluginModel *model = [PluginModel new];
    model.name = json[@"name"];
    model.displayName = [json internationalizedValueForKey:@"displayName"] ? : @"";
    model.pluginDescription = [json internationalizedValueForKey:@"description"] ? : @"";
    model.examples = [json internationalizedValueForKey:@"examples"];
    model.installed = NO;
    model.categories = json[@"categories"] ? : @[@"Unknown"];
    model.isAutomatorWorkflow = [json[@"isAutomatorWorkflow"] boolValue];
    model.isSearchPlugin = [json[@"isSearchPlugin"] boolValue];
    model.openPreferencesOnInstall = [json[@"openPreferencesOnInstall"] boolValue];
    return model;
}

- (NSAttributedString *)attributedString {
    NSMutableArray *stringsToJoin = [NSMutableArray new];
    [stringsToJoin addObject:[[NSAttributedString alloc] initWithString:self.displayName attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]}]];
    if (self.pluginDescription.length) {
        [stringsToJoin addObject:[[NSAttributedString alloc] initWithString:self.pluginDescription attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]}]];
    }
    if (self.examples.count) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        //NSFont *font = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] toHaveTrait:NSItalicFontMask];
        NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
        NSColor *color = [NSColor grayColor];
        NSDictionary *attrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: para};
        NSString *unattributed = [[[self.examples subarrayWithRange:NSMakeRange(0, MIN(self.examples.count, 4))] map:^id(id obj) {
            obj = [obj stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"]; // ' ' -> '&nbsp'
            return [NSString stringWithFormat:@"“%@”", obj];
        }] componentsJoinedByString:@"    "];
        NSAttributedString *s = [[NSAttributedString alloc] initWithString:unattributed attributes:attrs];
        [stringsToJoin addObject:s];
    }
    
    NSMutableAttributedString *s = [NSMutableAttributedString new];
    for (NSAttributedString *a  in stringsToJoin) {
        [s appendAttributedString:a];
        if (a != stringsToJoin.lastObject) {
            [s appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }
    return s;
}

- (NSArray *)allCategories {
    NSMutableArray *cats = [self.categories mutableCopy];
    if (self.installed) {
        [cats addObject:@"Installed"];
    }
    return cats;
}

+ (NSString *)pluginsDir {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"FlashlightPlugins"];
}

- (NSString *)path {
    return [[[[self class] pluginsDir] stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:@"bundle"];
}

- (BOOL)hasOptions {
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self path] stringByAppendingPathComponent:@"options.json"]];
}

- (void)presentOptionsInWindow:(NSWindow *)window {
    PrefEditorWindow *win = [[PrefEditorWindow alloc] initWithWindowNibName:@"PrefEditorWindow"];
    win.plugin = self;
    [window beginSheet:win.window completionHandler:^(NSModalResponse returnCode) {
        [win save]; // it's important that we hold a reference to win
    }];
}

+ (PluginModel *)installedPluginNamed:(NSString *)name {
    NSString *infoPath = [[[[[self class] pluginsDir] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"] stringByAppendingPathComponent:@"info.json"];
    NSData *infoData = [NSData dataWithContentsOfFile:infoPath];
    if (infoPath) {
        return [PluginModel fromJson:[NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil] baseURL:nil];
    } else {
        return nil;
    }
}

+ (NSInteger)versionForPluginAtPath:(NSString *)path {
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]) {
        if ([file.pathExtension isEqualToString:@"version"]) {
            return file.stringByDeletingPathExtension.integerValue;
        }
    }
    return 1; // fallback to version 1
}

- (NSURL *)zipURL {
    NSString *u = [NSString stringWithFormat:@"%@/plugin/%@/latest.zip", [PluginDirectoryAPI APIRoot], self.name];
    return [NSURL URLWithString:u];
}

@end
