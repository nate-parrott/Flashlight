//
//  _SS_MetadataResponseDelayer.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 12/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_SS_MetadataResponseDelayer.h"
#import "RSSwizzle.h"
#import "SPQuery.h"

@interface _SS_MetadataQueryTracker : NSObject

@property (nonatomic) BOOL alreadySentPluginResponse;
@property (nonatomic, copy) void (^callbackForWhenPluginResponseArrives)();

@end

@implementation _SS_MetadataQueryTracker

@end



@interface _SS_MetadataResponseDelayer ()

@property (nonatomic) NSMutableDictionary *queryTrackers;

@end

@implementation _SS_MetadataResponseDelayer

+ (_SS_MetadataResponseDelayer *)shared {
    static _SS_MetadataResponseDelayer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [_SS_MetadataResponseDelayer new];
    });
    return shared;
}

- (void)setup {
    self.queryTrackers = [NSMutableDictionary new];
    
    Class spMetadataQuery = NSClassFromString(@"SPMetadataQuery");
    RSSwizzleInstanceMethod(spMetadataQuery, @selector(responseHandler), SPQueryResponseHandler, RSSWArguments(), RSSWReplacement({
        SPQueryResponseHandler originalHandler = RSSWCallOriginal();
        // NSString *query = [@([[self parentQuery] queryId]) stringValue];
        NSString *query = [self userQueryString];
        return ^(SPResponse *resp){
            [[_SS_MetadataResponseDelayer shared] registerCallback:^{
                originalHandler(resp);
            } forQuery:query];
        };
    }), 0, 0);
}

- (void)registerCallback:(void(^)())handler forQuery:(NSString *)query {
    @synchronized(self) {
        _SS_MetadataQueryTracker *tracker = self.queryTrackers[query];
        if (tracker && tracker.alreadySentPluginResponse) {
            handler();
            [self.queryTrackers removeObjectForKey:query];
        } else {
            if (!tracker) {
                self.queryTrackers[query] = [_SS_MetadataQueryTracker new];
            }
            [self.queryTrackers[query] setCallbackForWhenPluginResponseArrives:handler];
        }
    }
}

- (void)sentPluginResponseForQuery:(NSString *)query {
    @synchronized(self) {
        _SS_MetadataQueryTracker *tracker = self.queryTrackers[query];
        if (!tracker) {
            tracker = [_SS_MetadataQueryTracker new];
            tracker.alreadySentPluginResponse = YES;
            self.queryTrackers[query] = tracker;
        }
        if (tracker.callbackForWhenPluginResponseArrives) {
            tracker.callbackForWhenPluginResponseArrives();
            [self.queryTrackers removeObjectForKey:query];
        }
    }
}

@end
