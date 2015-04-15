//
//  PluginDirectoryAPI.m
//  Flashlight
//
//  Created by Nate Parrott on 11/21/14.
//
//

#import "PluginDirectoryAPI.h"
#import "ConvenienceCategories.h"

@interface PluginDirectoryAPI ()

@end

@implementation PluginDirectoryAPI

+ (PluginDirectoryAPI *)shared {
    static PluginDirectoryAPI *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [PluginDirectoryAPI new];
    });
    return shared;
}
+ (NSString *)APIRoot {
    // return @"http://localhost:24080";
    return @"https://flashlightplugins.appspot.com";
}
- (void)loadCategoriesWithCallback:(void (^)(NSArray *categories, NSError *error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/categories", [[self class] APIRoot]]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSArray *categories = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (categories && [categories isKindOfClass:[NSArray class]]) {
                PerformOnMainThread(^{
                    callback(categories, nil);
                });
                return;
            }
        }
        PerformOnMainThread(^{
            callback(nil, error);
        });
    }] resume];
}
- (NSURL *)URLForCategory:(NSString *)category {
    NSURLComponents *comps = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@/directory", [[self class] APIRoot]]];
    comps.queryItems = @[
                         [NSURLQueryItem queryItemWithName:@"category" value:category],
                         [NSURLQueryItem queryItemWithName:@"languages" value:[[NSLocale preferredLanguages] componentsJoinedByString:@","]]
                         ];
    return [comps URL];
}
- (NSURL *)URLForSearchQuery:(NSString *)query {
    NSURLComponents *comps = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@/directory", [[self class] APIRoot]]];
    comps.queryItems = @[
                         [NSURLQueryItem queryItemWithName:@"search" value:query],
                         [NSURLQueryItem queryItemWithName:@"languages" value:[[NSLocale preferredLanguages] componentsJoinedByString:@","]]
                         ];
    return [comps URL];
}
- (NSURL *)URLForPluginNamed:(NSString *)name {
    NSURLComponents *comps = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@/directory", [[self class] APIRoot]]];
    comps.queryItems = @[
                         [NSURLQueryItem queryItemWithName:@"name" value:name],
                         [NSURLQueryItem queryItemWithName:@"languages" value:[[NSLocale preferredLanguages] componentsJoinedByString:@","]]
                         ];
    return [comps URL];
}
- (void)logPluginInstall:(NSString *)name isUpdate:(BOOL)update {
    NSString *endpoint = [NSString stringWithFormat:@"%@/log_install", [[self class] APIRoot]];
    NSURLComponents *comps = [NSURLComponents componentsWithString:endpoint];
    comps.queryItems = @[
                         [NSURLQueryItem queryItemWithName:@"name" value:name],
                         [NSURLQueryItem queryItemWithName:@"update" value:(update ? @"1" : @"0")]
                         ];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:comps.URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // disregard result
    }] resume];
}

- (void)getPluginsNeedingUpdatesWithExistingVersions:(NSDictionary *)pluginsByVersion callback:(void(^)(NSArray *pluginsNeedingUpdate))callback {
    NSURL *url = [NSURL URLWithString:[[self.class APIRoot] stringByAppendingString:@"/query_updates"]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:pluginsByVersion options:0 error:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *plugins = nil;
        if (data) {
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            plugins = info[@"plugins"];
        }
        callback(plugins);
    }] resume];
}

@end
