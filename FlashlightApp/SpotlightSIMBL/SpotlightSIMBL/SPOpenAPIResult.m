//
//  SPOpenAPIResult.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/2/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "SPOpenAPIResult.h"
#import "SPOpenAPIQuery.h"
#import "MARTNSObject.h"
#import "RTMethod.h"
#import "SPQuery.h"
#import "SPResult.h"
#import "SPResponse.h"
#import "SPDictionaryResult.h"
#import "MethodOverride.h"
#import "SPPreviewController.h"
#import <WebKit/WebKit.h>
#import "_SS_PluginRunner.h"
#import "_SS_InlineWebViewContainer.h"
#import "_Flashlight_Bootstrap.h"

id __SS_SSOpenAPIResult_initWithQuery_json_sourcePlugin(SPResult *self, SEL cmd, NSString *query, id json, NSString *sourcePlugin) {
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (!json[@"title"]) {
        return nil;
    }
    Class superclass = NSClassFromString(@"SPResult") ? : NSClassFromString(@"PRSResult");
    void (*superIMP)(id, SEL, NSString*, NSString*) = (void *)[superclass instanceMethodForSelector: @selector(initWithContentType:displayName:)];
    superIMP(self, cmd, nil, json[@"title"]); // TODO: what does contentType actually do? it probably isn't a mime type
    self.title = json[@"title"];
    objc_setAssociatedObject(self, @selector(jsonAssociatedObject), json, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(sourcePluginAssociatedObject), sourcePlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return self;
}

id __SS_SSOpenAPIResult_category(SPResult *self, SEL cmd) {
    return @"MENU_EXPRESSION";
}

id __SS_SSOpenAPIResult_customPreviewController(SPResult *self, SEL cmd) {
    Class cls = NSClassFromString(@"SPPreviewController") ? : NSClassFromString(@"PRSPreviewController");
    SPPreviewController *vc = [[cls alloc] initWithNibName:@"SPOpenAPIPreviewViewController" bundle:[NSBundle bundleWithIdentifier:@"com.nateparrott.SpotlightSIMBL"]];
    _SS_InlineWebViewContainer *container = (id)vc.view;
    container.result = self;
    if (!_Flashlight_Is_10_10_2_Spotlight()) {
        vc.internalPreviewResult = self;
    }
    return vc;
}

unsigned long long __SS_SSOpenAPIResult_rank(SPResult *self, SEL cmd) {
    id json = objc_getAssociatedObject(self, @selector(jsonAssociatedObject));
    if ([json[@"dont_force_top_hit"] boolValue]) {
        return 1;
    } else {
        return 0xffffffffffffffff; // for top hit
    }
}

BOOL __SS_SSOpenAPIResult_shouldNotBeTopHit(SPResult *self, SEL cmd) {
    id json = objc_getAssociatedObject(self, @selector(jsonAssociatedObject));
    return [json[@"dont_force_top_hit"] boolValue];
}

id __SS_SSOpenAPIResult_iconImage(SPResult *self, SEL cmd) {
    NSString *sourcePlugin = objc_getAssociatedObject(self, @selector(sourcePluginAssociatedObject));
    NSString *iconPath = [[_SS_PluginRunner pathForPlugin:sourcePlugin] stringByAppendingPathComponent:@"icon.png"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSData *infoJsonData = [NSData dataWithContentsOfFile:[[_SS_PluginRunner pathForPlugin:sourcePlugin] stringByAppendingPathComponent:@"info.json"]];
        if (infoJsonData) {
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:infoJsonData options:0 error:nil];
            if (info[@"iconPath"]) {
                iconPath = info[@"iconPath"];
            }
        }
    }
    return [[NSImage alloc] initByReferencingFile:iconPath];
}

// - (BOOL)openWithSearchString:(id)arg1 block:(CDUnknownBlockType)arg2;
BOOL __SS_SSOpenWithSearchString_block(SPResult *self, SEL cmd, NSString *searchString, void (^block)()) {
    id json = objc_getAssociatedObject(self, @selector(jsonAssociatedObject));
    NSString *sourcePlugin = objc_getAssociatedObject(self, @selector(sourcePluginAssociatedObject));
    if (json[@"run_args"]) {
        [_SS_PluginRunner runQueryResultWithArgs:json[@"run_args"] sourcePlugin:sourcePlugin];
        return YES;
    } else {
        return NO;
    }
}

Class __SS_SPOpenAPIResultClass() {
    Class c = NSClassFromString(@"SPOpenAPIResult");
    if (c) return c;
    Class superclass = NSClassFromString(@"SPResult") ? : NSClassFromString(@"PRSResult");
    c = [superclass rt_createSubclassNamed:@"SPOpenAPIResult"];
    __SS_Override(c, NSSelectorFromString(@"initWithQuery:json:sourcePlugin:"), __SS_SSOpenAPIResult_initWithQuery_json_sourcePlugin);
    __SS_Override(c, NSSelectorFromString(@"category"), __SS_SSOpenAPIResult_category);
    __SS_Override(c, NSSelectorFromString(@"rank"), __SS_SSOpenAPIResult_rank);
    if (_Flashlight_Is_10_10_2_Spotlight()) {
        __SS_Override(c, NSSelectorFromString(@"sharedCustomPreviewController"), __SS_SSOpenAPIResult_customPreviewController);
    } else {
        __SS_Override(c, NSSelectorFromString(@"customPreviewController"), __SS_SSOpenAPIResult_customPreviewController);
    }
    __SS_Override(c, NSSelectorFromString(@"iconImage"), __SS_SSOpenAPIResult_iconImage);
    __SS_Override(c, NSSelectorFromString(@"iconImageForApplication"), __SS_SSOpenAPIResult_iconImage);
    __SS_Override(c, NSSelectorFromString(@"openWithSearchString:block:"), __SS_SSOpenWithSearchString_block);
    __SS_Override(c, NSSelectorFromString(@"shouldNotBeTopHit"), __SS_SSOpenAPIResult_shouldNotBeTopHit);
    return c;
}
