//
//  TestPlugin.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_Flashlight_Bootstrap.h"
#import "RSSwizzle.h"
#import "CTBlockDescription.h"
#import "SPOpenAPIQuery.h"
#import "SPSpotQuery.h"
#import "NSObject+LogProperties.h"
#import "SPParsecSimpleResult.h"

@class SPQuery;

@implementation _Flashlight_Bootstrap

+ (void)load {
    __SS_SPOpenAPIQueryClass();
    
    /*RSSwizzleClassMethod(NSClassFromString(@"SPDictionaryQuery"), @selector(alloc), RSSWReturnType(id), RSSWArguments(), {
        RSSWCallOriginal();
        return [NSClassFromString(@"SPCalculatorQuery") alloc];
    });*/
    
    /*RSSwizzleInstanceMethod(NSClassFromString(@"SPParsecSimpleResult"), NSSelectorFromString(@"dealloc"), RSSWReturnType(void), RSSWArguments(), RSSWReplacement({
        [self logProperties];
        RSSWCallOriginal();
    }), 0, NULL);*/
    
    /*RSSwizzleInstanceMethod(NSClassFromString(@"SPParsecSimpleResult"), NSSelectorFromString(@"setCategory:"), RSSWReturnType(void), RSSWArguments(NSString *cat), RSSWReplacement({
        NSLog(@"[setCategory:%@]", cat);
        RSSWCallOriginal(cat);
    }), 0, NULL);*/
    
    /*RSSwizzleInstanceMethod(NSClassFromString(@"SPMetadataResult"), NSSelectorFromString(@"displayName"), RSSWReturnType(NSString*), RSSWArguments(), RSSWReplacement({
        NSString *original = RSSWCallOriginal();
        return [original stringByAppendingString:@" fuck fuck fuck"];
    }), 0, NULL);*/
    
    /*
    // determine type of SPQuery response callbacks at runtime:
    RSSwizzleInstanceMethod(NSClassFromString(@"SPQuery"), NSSelectorFromString(@"startWithResponseHandler:"), RSSWReturnType(void), RSSWArguments(id block), RSSWReplacement({
        NSLog(@"SIGNATURE is:");
        PrintMethodSignature([[CTBlockDescription alloc] initWithBlock:block].blockSignature);
        RSSWCallOriginal(block);
    }), 0, NULL);
     */
    
    /*RSSwizzleInstanceMethod(NSClassFromString(@"SPQuery"), NSSelectorFromString(@"initWithUserQuery:"), RSSWReturnType(id), RSSWArguments(NSString* query), RSSWReplacement({
        NSLog(@"-[%@ initWithUserQuery:%@", NSStringFromClass([self class]), query);
        return RSSWCallOriginal(query);
    }), 0, NULL);
    
    RSSwizzleInstanceMethod(NSClassFromString(@"SPQuery"), NSSelectorFromString(@"initWithUserQuery:options:"), RSSWReturnType(id), RSSWArguments(NSString* query, unsigned long long options), RSSWReplacement({
        NSLog(@"-[%@ initWithUserQuery:%@ options:%llu", NSStringFromClass([self class]), query, options);
        self = RSSWCallOriginal(query, options);
        if ([NSStringFromClass([self class]) isEqualToString:@"SPSpotQuery"]) {
            NSLog(@"ADD CHILD QUERY 2");
            [((SPSpotQuery*)self) addChildQuery:[[__SS_SPOpenAPIQueryClass() alloc] initWithUserQuery:query]];
        }
        return self;
    }), 0, NULL);
    
    RSSwizzleInstanceMethod(NSClassFromString(@"SPSpotQuery"), NSSelectorFromString(@"updateUserQueryString:"), RSSWReturnType(BOOL), RSSWArguments(NSString* query), RSSWReplacement({
        NSLog(@"-[%@ updateUserQueryString:%@]", NSStringFromClass([self class]), query);
        BOOL result = RSSWCallOriginal(query);
        if (1 || result) {
            NSLog(@"ADD CHILD QUERY");
            [((SPSpotQuery*)self) addChildQuery:[[__SS_SPOpenAPIQueryClass() alloc] initWithUserQuery:query]];
        }
        return result;
    }), 0, NULL);
    
    RSSwizzleInstanceMethod(NSClassFromString(@"SPCalculatorResult"), NSSelectorFromString(@"category"), RSSWReturnType(NSString*), RSSWArguments(), RSSWReplacement({
        
        NSLog(@"-[%@ category] = %@", NSStringFromClass([self class]), RSSWCallOriginal());
        return RSSWCallOriginal();
    }), 0, NULL);
     */
    
    RSSwizzleClassMethod(NSClassFromString(@"SPSpotQuery"), NSSelectorFromString(@"queryClasses"), id, RSSWArguments(), {
        return [RSSWCallOriginal() arrayByAddingObject:__SS_SPOpenAPIQueryClass()];
    });
    
    NSLog(@"Hello from Flashlight 0.21!");
}

@end
