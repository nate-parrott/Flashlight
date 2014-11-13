//
//  PluginModel.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginModel.h"

@implementation PluginModel

- (id)copyWithZone:(NSZone *)zone {
    PluginModel *p = [PluginModel new];
    p.name = self.name;
    p.displayName = self.displayName;
    p.pluginDescription = self.pluginDescription;
    p.installed = self.installed;
    p.installing = self.installing;
    p.examples = self.examples;
    p.disabledPluginPath = self.disabledPluginPath;
    p.categories = self.categories;
    return p;
}

+ (PluginModel *)fromJson:(NSDictionary *)json baseURL:(NSURL *)url {
    PluginModel *model = [PluginModel new];
    model.name = json[@"name"];
    model.displayName = json[@"displayName"];
    model.pluginDescription = json[@"description"];
    model.examples = json[@"examples"];
    model.installed = NO;
    model.zipURL = [NSURL URLWithString:json[@"zip_url"] relativeToURL:url];
    model.categories = json[@"categories"] ? : @[@"Unknown"];
    return model;
}

+ (NSArray *)mergeDuplicates:(NSArray *)models {
    NSMutableDictionary *pluginsByName = [NSMutableDictionary new];
    for (PluginModel *p in models) {
        if (pluginsByName[p.name]) {
            pluginsByName[p.name] = [p mergeWith:pluginsByName[p.name]];
        } else {
            pluginsByName[p.name] = p;
        }
    }
    return pluginsByName.allValues;
}

- (PluginModel *)mergeWith:(PluginModel *)other {
    if (self.installed) {
        return self;
    } else {
        return other;
    }
}

- (NSAttributedString *)attributedString {
    NSMutableArray *stringsToJoin = [NSMutableArray new];
    [stringsToJoin addObject:[[NSAttributedString alloc] initWithString:self.displayName attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]}]];
    if (self.pluginDescription.length) {
        [stringsToJoin addObject:[[NSAttributedString alloc] initWithString:self.pluginDescription attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]}]];
    }
    if (self.examples.count) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        NSFont *font = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] toHaveTrait:NSItalicFontMask];
        NSColor *color = [NSColor grayColor];
        NSDictionary *attrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: para};
        NSAttributedString *s = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\"", [self.examples componentsJoinedByString:@"\"    \""]] attributes:attrs];
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

@end
