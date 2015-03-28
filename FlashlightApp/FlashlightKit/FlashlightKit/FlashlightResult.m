//
//  FlashlightResult.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightResult.h"
#import "NSTask+FlashlightExtensions.h"
#import "PSHelpers.h"
#import "FlashlightResultView.h"
#import "FlashlightQueryEngine.h"
#import "FlashlightWebScriptObject.h"
#import "FlashlightSystemHelpers.h"
#import <FlashlightKit.h>

@interface FlashlightResult ()

@property (nonatomic) WebView *webView;
@property (nonatomic) BOOL webViewIsReady;

@end

@implementation FlashlightResult

- (NSString *)title {
    return self.json[@"title"];
}

- (BOOL)supportsWebview {
    return !!self.json[@"html"] || !!self.json[@"html_file"];
}

- (BOOL)linksOpenInBrowser {
    return [self.json[@"webview_links_open_in_browser"] boolValue];
}

- (BOOL)canBeTopHit {
    return ![self.json[@"dont_force_top_hit"] boolValue];
}

- (BOOL)pressEnter:(FlashlightResultView *)resultView errorCallback:(void(^)(NSString *error))errorCallback {
    [DAU logDailyAction:@"openedResult"];
    NSMutableArray *runArgs = [self.json[@"run_args"] mutableCopy];
    if (runArgs) {
        if ([self.json[@"pass_result_of_output_function_as_first_run_arg"] boolValue]) {
            [runArgs insertObject:[resultView resultOfOutputFunction] atIndex:0];
        }
        
        NSString *scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"run_plugin" ofType:@"pyc"];
        // NSTask* task = [NSTask withPathMarkedAsExecutableIfNecessary:[[NSBundle bundleForClass:[self class]] pathForResource:@"run_plugin" ofType:@"pyc"]];
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/python";
        NSDictionary *input = @{
                                @"runArgs": runArgs,
                                @"builtinModulesPath": [FlashlightQueryEngine builtinModulesPath],
                                @"pluginPath": self.pluginPath
                                };
        task.arguments = @[scriptPath, input.toJson];
        [task launchWithTimeout:30 callback:^(NSData *stdoutData, NSData *stderrData) {
            NSString *error = nil;
            if (stderrData) {
                error = [[NSString alloc] initWithData:stderrData encoding:NSUTF8StringEncoding];
            }
            errorCallback(error);
        }];
        return YES;
    } else {
        return NO;
    }
}

- (void)setCurrentInputForStaticPlugin:(NSDictionary *)currentInputForStaticPlugin {
    _currentInputForStaticPlugin = currentInputForStaticPlugin;
    if (self.webViewIsReady) {
        [self sendInput];
    }
}

#pragma mark Webview
- (WebView *)webView {
    if (![self supportsWebview]) {
        return nil;
    }
    
    if (!_webView) {
        _webView = [WebView new];
        _webView.frameLoadDelegate = self;
        _webView.policyDelegate = self;
        [self configureWebview:_webView];
    }
    return _webView;
}

- (NSString *)getHTML {
    if (self.json[@"html"]) {
        return self.json[@"html"];
    }
    if (self.json[@"html_file"]) {
        NSString *path = [self.pluginPath stringByAppendingPathComponent:self.json[@"html_file"]];
        NSMutableString *markup = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil].mutableCopy;
        [markup replaceOccurrencesOfString:@"<!--FLASHLIGHT_THEME_MODE-->" withString:(FlashlightIsDarkModeEnabled() ? @"dark" : @"light") options:0 range:NSMakeRange(0, markup.length)];
        return markup;
    }
    return nil;
}

- (void)configureWebview:(WebView *)webView {
    NSString *pluginPath = [self.pluginPath stringByAppendingPathComponent:@"index.html"];
    [webView.mainFrame loadHTMLString:[self getHTML] baseURL:[NSURL fileURLWithPath:pluginPath]];
    if (self.json[@"webview_user_agent"]) {
        [webView setCustomUserAgent:self.json[@"webview_user_agent"]];
    }
    webView.drawsBackground = ![self.json[@"webview_transparent_background"] boolValue];
}

- (void)cleanUpWebviewIfNeeded {
    if (!self.currentInputForStaticPlugin) {
        _webView.frameLoadDelegate = nil;
        self.webView.policyDelegate = nil;
        [self.webView stopLoading:nil];
        _webView = nil;
    }
}

- (void)webViewBecameReady {
    self.webViewIsReady = YES;
    if (self.currentInputForStaticPlugin) {
        [self sendInput];
    }
}

- (void)sendInput {
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"updateInput(%@)", self.currentInputForStaticPlugin.toJson]];
}

#pragma mark Window Scripting Layer

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    if ([self isWebFrameShowingLocalData:frame]) {
        // only insert on non-remote pages:
        [windowScriptObject setValue:[FlashlightWebScriptObject new] forKey:@"flashlight"];
    }
}

- (BOOL)isWebFrameShowingLocalData:(WebFrame *)frame {
    return frame.DOMDocument.domain.length == 0;
}

#pragma mark Output Function

- (id)resultOfOutputFunction {
    if ([self isWebFrameShowingLocalData:self.webView.mainFrame]) {
        return [self.webView stringByEvaluatingJavaScriptFromString:@"output()"] ? : [NSNull null];
    }
    return [NSNull null];
}

#pragma mark Navigation interception

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    BOOL shouldOpenExternally = [actionInformation[WebActionNavigationTypeKey] integerValue] == WebNavigationTypeLinkClicked && (self.linksOpenInBrowser || ![@[@"http", @"https"] containsObject:request.URL.scheme]);
    if (shouldOpenExternally) {
        [listener ignore];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:request.URL];
        });
    } else {
        [listener use];
    }
}

#pragma mark Loading indicator
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    if (frame == sender.mainFrame) {
        //[_loader startAnimation:nil];
    }
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if (frame == sender.mainFrame) {
        [self webViewBecameReady];
        //[_loader stopAnimation:nil];
    }
}
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if (frame == sender.mainFrame) {
        //[_loader stopAnimation:nil];
    }
}

- (void)dealloc {
    _webView.frameLoadDelegate = nil;
    _webView.policyDelegate = nil;
}

@end
