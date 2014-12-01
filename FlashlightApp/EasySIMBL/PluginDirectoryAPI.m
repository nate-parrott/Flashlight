//
//  PluginDirectoryAPI.m
//  Flashlight
//
//  Created by Nate Parrott on 11/21/14.
//
//

#import "PluginDirectoryAPI.h"

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
    return @"https://flashlightplugins.appspot.com";
}
- (void)loadCategoriesWithCallback:(void (^)(NSArray *categories, NSError *error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/categories", [[self class] APIRoot]]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSArray *categories = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (categories && [categories isKindOfClass:[NSArray class]]) {
                callback(categories, nil);
                return;
            }
        }
        callback(nil, error);
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
- (void)logPluginInstall:(NSString *)name {
    NSString *endpoint = [NSString stringWithFormat:@"%@/log_install", [[self class] APIRoot]];
    NSURLComponents *comps = [NSURLComponents componentsWithString:endpoint];
    comps.queryItems = @[[NSURLQueryItem queryItemWithName:@"name" value:name]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:comps.URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // disregard result
    }] resume];
}

@end
