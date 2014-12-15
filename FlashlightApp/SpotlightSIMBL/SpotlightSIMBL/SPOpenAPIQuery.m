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
#import "_SS_MetadataResponseDelayer.h"
#import "_Flashlight_Bootstrap.h"

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
        BOOL sortAscending = !_Flashlight_Is_10_10_2_Spotlight();
        [resultItems sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:sortAscending]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            Class cls = NSClassFromString(@"SPResponse")? : NSClassFromString(@"SPKResponse");
            SPResponse *resp = [[cls alloc] initWithResults:resultItems];
            resp.userQueryString = query;
            responseHandler(resp);
            if (_Flashlight_Is_10_10_2_Spotlight()) {
                [[_SS_MetadataResponseDelayer shared] sentPluginResponseForQuery:query];
            }
        });
    });
}

// dynamically subclass SPQuery:
Class __SS_SPOpenAPIQueryClass() {
    Class c = NSClassFromString(@"SPOpenAPIQuery");
    if (c) return c;
    Class superclass = NSClassFromString(@"SPQuery") ? : NSClassFromString(@"SPKQuery");
    c = [superclass rt_createSubclassNamed:@"SPOpenAPIQuery"];
    __SS_Override(c, NSSelectorFromString(@"start"), __SS_Start);
    __SS_Override(objc_getMetaClass("SPOpenAPIQuery"), NSSelectorFromString(@"isQuerySupported:"), __SS_isQuerySupported);
    NSLog(@"Create class: %@", c);
    return c;
}

