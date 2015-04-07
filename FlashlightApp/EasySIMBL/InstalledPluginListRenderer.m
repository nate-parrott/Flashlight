//
//  PluginListRenderer.m
//  Flashlight
//
//  Created by Nate Parrott on 4/6/15.
//
//

#import "InstalledPluginListRenderer.h"
#import <GRMustache.h>
#import "ConvenienceCategories.h"
#import "PluginModel.h"
#import "FlashlightIconResolution.h"

@implementation InstalledPluginListRenderer

+ (GRMustacheTemplate *)template {
    static GRMustacheTemplate *template = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        template = [GRMustacheTemplate templateFromContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PluginListContent" ofType:@"html"] error:&error];
        if (error) NSLog(@"%@", error);
    });
    return template;
}

+ (NSString *)contentWrapper {
    static NSString *wrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PluginList" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    });
    return wrapper;
}

- (NSString *)renderPluginListContentForInstalled:(NSArray *)installedPlugins {
    installedPlugins = [self orderPlugins:installedPlugins];
    NSError *err = nil;
    NSString *html = [[[self class] template] renderObject:[self templateArgsForInstalled:installedPlugins] error:&err];
    if (err) NSLog(@"%@", err);
    return html;
}

- (NSArray *)orderPlugins:(NSArray *)plugins {
    NSMutableDictionary *modDates = [NSMutableDictionary new];
    for (PluginModel *plugin in plugins) {
        modDates[plugin.name] = [[NSFileManager defaultManager] attributesOfItemAtPath:plugin.path error:nil][NSFileModificationDate] ? : [NSDate distantPast];
    }
    return [plugins sortedArrayUsingComparator:^NSComparisonResult(PluginModel *obj1, PluginModel *obj2) {
        NSDate *date1 = modDates[[obj1 name]];
        NSDate *date2 = modDates[[obj2 name]];
        return [date2 compare:date1];
    }];
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
    if (plugin.pluginDescription) d[@"description"] = plugin.pluginDescription;
    NSString *iconPath = [FlashlightIconResolution pathForIconForPluginAtPath:plugin.path];
    if (iconPath) d[@"icon"] = [NSURL fileURLWithPath:iconPath].absoluteString;
    
    NSMutableArray *buttons = [NSMutableArray new];
    if (plugin.hasOptions) {
        [buttons addObject:@{
                             @"title": NSLocalizedString(@"Settings", @""),
                             @"url": [NSString stringWithFormat:@"flashlight://plugin/%@/preferences", plugin.name]
                             }];
    }
    if (plugin.isAutomatorWorkflow) {
        NSURLComponents *comps = [NSURLComponents componentsWithString:@"edit://plugin"];
        comps.host = plugin.name;
        [buttons addObject:@{
                             @"title": NSLocalizedString(@"Edit", nil),
                             @"url": comps.URL.absoluteString
                             }];
    }
    if (plugin.installing) {
        [buttons addObject:@{
                             @"title": NSLocalizedString(@"Installing...", @""),
                             @"url": @"about:blank"
                             }];
    } else if (plugin.installed) {
        [buttons addObject:@{
                             @"title": NSLocalizedString(@"Uninstall", @""),
                             @"url": [NSString stringWithFormat:@"uninstall://%@", plugin.name]
                             }];
    }
    d[@"buttons"] = buttons;
    
    return d;
}

- (void)populateWebview:(WebView *)webview withInstalledPlugins:(NSArray *)installedPlugins {
    NSString *contentHTML = [self renderPluginListContentForInstalled:installedPlugins];
    if ([self isWebviewShowingInstalledPluginList:webview]) {
        [self injectContentHTML:contentHTML intoWebviewAlreadyShowingPluginList:webview];
    } else {
        NSString *fullHTML = [[[self class] contentWrapper] stringByReplacingOccurrencesOfString:@"<!--CONTENT-->" withString:contentHTML];
        [webview.mainFrame loadHTMLString:fullHTML baseURL:nil];
    }
}

- (BOOL)isWebviewShowingInstalledPluginList:(WebView *)webview {
    return [[webview stringByEvaluatingJavaScriptFromString:@"__flashlight_is_installed_plugin_list"] isEqualToString:@"true"];
}

- (void)injectContentHTML:(NSString *)html intoWebviewAlreadyShowingPluginList:(WebView *)webview {
    NSString *escapedString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[html] options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *js = [NSString stringWithFormat:@"replaceContent(%@[0])", escapedString];
    [webview stringByEvaluatingJavaScriptFromString:js];
}

@end
