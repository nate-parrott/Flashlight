//
//  PluginListRenderer.m
//  Flashlight
//
//  Created by Nate Parrott on 4/6/15.
//
//

#import "PluginListRenderer.h"
#import <GRMustache.h>
#import "ConvenienceCategories.h"
#import "PluginModel.h"
#import "FlashlightIconResolution.h"

@implementation PluginListRenderer

+ (GRMustacheTemplate *)template {
    static GRMustacheTemplate *template = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        template = [GRMustacheTemplate templateFromResource:@"PluginList" bundle:nil error:&error];
        if (error) NSLog(@"%@", error);
    });
    return template;
}

- (NSString *)renderPluginListHTMLForInstalled:(NSArray *)installedPlugins {
    NSError *err = nil;
    NSString *html = [[[self class] template] renderObject:[self templateArgsForInstalled:installedPlugins] error:&err];
    if (err) NSLog(@"%@", err);
    return html;
}

- (NSDictionary *)templateArgsForInstalled:(NSArray *)installedPlugins {
    return @{
             @"plugins": [installedPlugins map:^id(id obj) {
                 return [self templateArgsForPlugin:obj];
             }]
             };
}

- (NSDictionary *)templateArgsForPlugin:(PluginModel *)plugin {
    NSMutableDictionary *d = @{
                               @"name": plugin.name,
                               @"displayName": plugin.displayName ? : @"",
                               @"examples": plugin.examples ? : @[]
                               }.mutableCopy;
    if (plugin.description) d[@"description"] = plugin.description;
    NSString *iconPath = [FlashlightIconResolution pathForIconForPluginAtPath:plugin.path];
    if (iconPath) d[@"icon"] = iconPath;
    
    NSMutableArray *buttons = [NSMutableArray new];
    if (plugin.hasOptions) {
        [buttons addObject:@{
                             @"title": NSLocalizedString(@"Settings", @""),
                             @"url": [NSString stringWithFormat:@"flashlight://plugin/%@/preferences", plugin.name]
                             }];
    }
    [buttons addObject:@{
                         @"title": NSLocalizedString(@"Uninstall", @""),
                         @"url": [NSString stringWithFormat:@"uninstall://%@", plugin.name]
                         }];
    d[@"buttons"] = buttons;
    
    return d;
}

@end
