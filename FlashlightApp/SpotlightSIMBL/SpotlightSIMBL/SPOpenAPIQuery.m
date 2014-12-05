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
#import "_SS_PluginRunner.h"


// define initWithDisplayName: as selector so that we can call it on `id`
@interface DummyInterface : NSObject
- (id)initWithQuery:(NSString *)query json:(id)json sourcePlugin:(NSString *)sourcePlugin;
@end
@implementation DummyInterface
- (id)initWithQuery:(NSString *)query json:(id)json sourcePlugin:(NSString *)sourcePlugin {
    return nil;
}
@end

@class SPResponse, SPResult;

// + (BOOL)isQuerySupported:(unsigned long long)arg1;
BOOL __SS_isQuerySupported(id self, SEL cmd, unsigned long long arg1) {
    return YES;
}

void __SS_Start(SPQuery* self, SEL cmd) {
    SPQueryResponseHandler responseHandler = ((SPQuery*)self).responseHandler;
    NSString *query = self.userQueryString;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *resultsByPlugin = [_SS_PluginRunner resultDictionariesFromPluginsForQuery:query];
        NSMutableArray *resultItems = [NSMutableArray new];
        for (NSString *pluginName in resultsByPlugin) {
            for (NSDictionary *resultInfo in resultsByPlugin[pluginName]) {
                id result = [[__SS_SPOpenAPIResultClass() alloc] initWithQuery:query json:resultInfo sourcePlugin:pluginName];
                if (result) {
                    [resultItems addObject:result];
                }
            }
        }
        [resultItems sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES]]];
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
    NSLog(@"Create class: %@", c);
    return c;
}

