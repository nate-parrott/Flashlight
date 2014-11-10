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

id __SS_SSOpenAPIResult_initWithQuery_json_sourcePlugin(SPResult *self, SEL cmd, NSString *query, id json, NSString *sourcePlugin) {
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (!json[@"title"]) {
        return nil;
    }
    Class superclass = NSClassFromString(@"SPResult");
    void (*superIMP)(id, SEL, NSString*, NSString*) = (void *)[superclass instanceMethodForSelector: @selector(initWithContentType:displayName:)];
    superIMP(self, cmd, @"text/html", json[@"title"]); // TODO: what does contentType actually do? it probably isn't a mime type
    self.title = json[@"title"];
    // self.isParsecTopHit = YES;
    // [self setType:@"Type"]; // TODO: what does *this* do?
    [self setCategoryForCP:@"MENU_EXPRESSION"];
    objc_setAssociatedObject(self, @selector(jsonAssociatedObject), json, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(sourcePluginAssociatedObject), sourcePlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return self;
}

id __SS_SSOpenAPIResult_category(SPResult *self, SEL cmd) {
    return @"MENU_EXPRESSION";
}

id __SS_SSOpenAPIResult_customPreviewController(SPResult *self, SEL cmd) {
    SPPreviewController *vc = [[NSClassFromString(@"SPPreviewController") alloc] initWithNibName:@"SPOpenAPIPreviewViewController" bundle:[NSBundle bundleWithIdentifier:@"com.nateparrott.SpotlightSIMBL"]];
    _SS_InlineWebViewContainer *container = (id)vc.view;
    container.result = self;
    vc.internalPreviewResult = self;
    return vc;
}

unsigned long long __SS_SSOpenAPIResult_rank(SPResult *self, SEL cmd) {
    id json = objc_getAssociatedObject(self, @selector(jsonAssociatedObject));
    if (json[@"rank"]) {
        return json[@"rank"];
    } else if ([json[@"dont_force_top_hit"] boolValue]) {
        return 2;
    } else {
        return 1;
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
        NSBundle *appBundle = [NSBundle bundleWithPath:[_SS_PluginRunner pathForPlugin:sourcePlugin]];
        if (appBundle.infoDictionary[@"IconPath"]) {
            iconPath = appBundle.infoDictionary[@"IconPath"];
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
    c = [(Class)NSClassFromString(@"SPResult") rt_createSubclassNamed:@"SPOpenAPIResult"];
    __SS_Override(c, NSSelectorFromString(@"initWithQuery:json:sourcePlugin:"), __SS_SSOpenAPIResult_initWithQuery_json_sourcePlugin);
    __SS_Override(c, NSSelectorFromString(@"category"), __SS_SSOpenAPIResult_category);
    __SS_Override(c, NSSelectorFromString(@"rank"), __SS_SSOpenAPIResult_rank);
    __SS_Override(c, NSSelectorFromString(@"customPreviewController"), __SS_SSOpenAPIResult_customPreviewController);
    __SS_Override(c, NSSelectorFromString(@"iconImage"), __SS_SSOpenAPIResult_iconImage);
    __SS_Override(c, NSSelectorFromString(@"iconImageForApplication"), __SS_SSOpenAPIResult_iconImage);
    __SS_Override(c, NSSelectorFromString(@"openWithSearchString:block:"), __SS_SSOpenWithSearchString_block);
    __SS_Override(c, NSSelectorFromString(@"shouldNotBeTopHit"), __SS_SSOpenAPIResult_shouldNotBeTopHit);
    return c;
}
