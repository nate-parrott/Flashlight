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
    return p;
}

+ (PluginModel *)fromPath:(NSString *)path {
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    PluginModel *model = [PluginModel new];
    model.name = [path lastPathComponent].stringByDeletingPathExtension;
    model.displayName = [bundle infoDictionary][@"CFBundleDisplayName"];
    model.pluginDescription = [bundle infoDictionary][@"Description"];
    model.installed = YES;
    return model;
}

+ (PluginModel *)fromJson:(NSDictionary *)json baseURL:(NSURL *)url {
    PluginModel *model = [PluginModel new];
    model.name = json[@"name"];
    model.displayName = json[@"CFBundleDisplayName"];
    model.pluginDescription = json[@"Description"];
    model.installed = NO;
    model.zipURL = [NSURL URLWithString:json[@"zip_url"] relativeToURL:url];
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
    NSMutableAttributedString* s = [NSMutableAttributedString new];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:[self.displayName stringByAppendingString:@"\n"] attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]}]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:self.pluginDescription attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]}]];
    return s;
}

@end
