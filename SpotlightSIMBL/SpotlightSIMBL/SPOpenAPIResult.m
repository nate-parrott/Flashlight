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

id __SS_SSOpenAPIResult_initWithQuery_json(SPResult *self, SEL cmd, NSString *displayName, id json) {
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
    [self setType:@"Type"]; // TODO: what does *this* do?
    [self setCategoryForCP:@"MENU_EXPRESSION"];
    objc_setAssociatedObject(self, @selector(jsonAssociatedObject), json, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return self;
}

id __SS_SSOpenAPIResult_category(SPResult *self, SEL cmd) {
    return @"MENU_EXPRESSION";
}

id __SS_SSOpenAPIResult_customPreviewController(SPResult *self, SEL cmd) {
    id json = objc_getAssociatedObject(self, @selector(jsonAssociatedObject));
    SPPreviewController *vc = [[NSClassFromString(@"SPPreviewController") alloc] initWithNibName:@"SPOpenAPIPreviewViewController" bundle:[NSBundle bundleWithIdentifier:@"com.nateparrott.SpotlightSIMBL"]];
    WebView *webView = vc.view.subviews.firstObject;
    if ([webView isKindOfClass:[WebView class]]) {
        if (json[@"html"]) {
            [[webView mainFrame] loadHTMLString:json[@"html"] baseURL:[NSURL fileURLWithPath:json[@"pluginPath"]]];
        } else {
            webView.hidden = YES;
        }
    } else {
        // TODO: log it
    }
    vc.internalPreviewResult = self;
    return vc;
}

unsigned long long __SS_SSOpenAPIResult_rank(SPResult *self, SEL cmd) {
    return 1;
}

// - (BOOL)openWithSearchString:(id)arg1 block:(CDUnknownBlockType)arg2;
BOOL __SS_SSOpenWithSearchString_block(SPResult *self, SEL cmd, NSString *searchString, void (^block)()) {
    id json = objc_getAssociatedObject(self, @selector(jsonAssociatedObject));
    if (json[@"execute"]) {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:@[ @"-c", json[@"execute"] ]];
        [task launch];
        return YES;
    } else {
        return NO;
    }
}

Class __SS_SPOpenAPIResultClass() {
    Class c = NSClassFromString(@"SPOpenAPIResult");
    if (c) return c;
    c = [(Class)NSClassFromString(@"SPResult") rt_createSubclassNamed:@"SPOpenAPIResult"];
    __SS_Override(c, NSSelectorFromString(@"initWithQuery:json:"), __SS_SSOpenAPIResult_initWithQuery_json);
    __SS_Override(c, NSSelectorFromString(@"category"), __SS_SSOpenAPIResult_category);
    __SS_Override(c, NSSelectorFromString(@"rank"), __SS_SSOpenAPIResult_rank);
    __SS_Override(c, NSSelectorFromString(@"customPreviewController"), __SS_SSOpenAPIResult_customPreviewController);
    __SS_Override(c, NSSelectorFromString(@"openWithSearchString:block:"), __SS_SSOpenWithSearchString_block);
    return c;
}
