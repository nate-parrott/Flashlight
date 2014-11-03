//
//  SPOpenAPIQuery.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "SPOpenAPIQuery.h"
#import "MARTNSObject.h"
#import "RTMethod.h"
#import "SPQuery.h"
#import "SPResult.h"
#import "SPResponse.h"
#import "SPDictionaryResult.h"
#import "SPOpenAPIResult.h"
#import "MethodOverride.h"


// define initWithDisplayName: as selector so that we can use it in @selector()
@interface DummyInterface : NSObject
- (id)initWithQuery:(NSString *)query json:(id)json;
@end
@implementation DummyInterface
- (id)initWithQuery:(NSString *)query json:(id)json {
    return nil;
}
@end


@class SPResponse, SPResult;

// + (BOOL)isQuerySupported:(unsigned long long)arg1;
BOOL __SS_isQuerySupported(id self, SEL cmd, unsigned long long arg1) {
    return YES;
}

void __SS_Start(SPQuery* self, SEL cmd) {
    /*NSString *query = self.userQueryString;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SPQueryResponseHandler responseHandler = ((SPQuery*)self).responseHandler;
        //SPResult *res = [[NSClassFromString(@"SPDictionaryResult") alloc] initWithDisplayName:@"Open API?" dictionaryId:@"xyz" query:[self userQueryString]];
        NSString *displayName = [NSString stringWithFormat:@"Response to '%@'", query];
        SPResult *res = [[__SS_SPOpenAPIResultClass() alloc] initWithDisplayName:displayName];
        SPResponse *resp = [[NSClassFromString(@"SPResponse") alloc] initWithResults:@[res]];
        resp.userQueryString = query;
        responseHandler(resp);
    });*/
    
    SPQueryResponseHandler responseHandler = ((SPQuery*)self).responseHandler;
    NSString *query = self.userQueryString;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pluginsDir = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"FlashlightPlugins"];
        NSArray *plugins = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsDir error:nil];
        NSMutableArray *pluginTasks = [NSMutableArray new];
        for (NSString *name in plugins) {
            if ([name isEqualToString:@".DS_Store"]) continue;
            NSString *pluginDir = [pluginsDir stringByAppendingPathComponent:name];
            NSTask *task = nil;
            @try {
                task = [NSTask new];
                task.launchPath = [pluginDir stringByAppendingPathComponent:@"executable"];
                task.currentDirectoryPath = pluginDir;
                task.arguments = @[query];
                NSPipe *pipe = [NSPipe pipe];
                task.standardOutput = pipe;
                [task launch];
            }
            @catch (NSException *exception) {
                // NSLog(@"Failed to execute plugin at %@", [pluginsDir stringByAppendingPathComponent:name]);
            }
            if (task) {
                [pluginTasks addObject:task];
            }
        }
        NSMutableArray *resultItems = [NSMutableArray new];
        for (NSTask *task in pluginTasks) {
            [task waitUntilExit];
            NSData *data = [[task.standardOutput fileHandleForReading] readDataToEndOfFile];
            if (data) {
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json isKindOfClass:[NSDictionary class]]) {
                    json = [json mutableCopy];
                    json[@"pluginPath"] = task.currentDirectoryPath;
                    id result = [[__SS_SPOpenAPIResultClass() alloc] initWithQuery:query json:json];
                    if (result) {
                        [resultItems addObject:result];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            SPResponse *resp = [[NSClassFromString(@"SPResponse") alloc] initWithResults:resultItems];
            resp.userQueryString = query;
            responseHandler(resp);
        });
    });
}

// dynamically subclass SPQuery:
Class __SS_SPOpenAPIQueryClass() {
    Class c = NSClassFromString(@"SPOpenAPIQuery");
    if (c) return c;
    c = [(Class)NSClassFromString(@"SPQuery") rt_createSubclassNamed:@"SPOpenAPIQuery"];
    __SS_Override(c, NSSelectorFromString(@"start"), __SS_Start);
    __SS_Override(objc_getMetaClass("SPOpenAPIQuery"), NSSelectorFromString(@"isQuerySupported:"), __SS_isQuerySupported);
    return c;
}

