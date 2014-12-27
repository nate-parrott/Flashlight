//
//  FlashlightCustomPreviewController.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightResultView.h"
#import <WebKit/WebKit.h>
#import "FlashlightWebScriptObject.h"
#import <objc/runtime.h>

@interface FlashlightResultView ()

@property (nonatomic) BOOL linksOpenInBrowser;
@property (nonatomic) NSProgressIndicator *loader;
@property (nonatomic) WebView *webView;

@end

@implementation FlashlightResultView

#pragma mark View loading
- (void)setup {
    [self ensureWebview];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setup];
    return self;
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

#pragma mark Navigation interception

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if (self.linksOpenInBrowser && [actionInformation[WebActionNavigationTypeKey] integerValue] == WebNavigationTypeLinkClicked) {
        [listener ignore];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:request.URL];
        });
    }
    [listener use];
}

#pragma mark Loading indicator
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    if (frame == sender.mainFrame) {
        [_loader startAnimation:nil];
    }
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if (frame == sender.mainFrame) {
        [_loader stopAnimation:nil];
    }
}
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if (frame == sender.mainFrame) {
        [_loader stopAnimation:nil];
    }
}

#pragma mark Lifecycle
- (void)dealloc {
    self.webView.frameLoadDelegate = nil;
    self.webView.policyDelegate = nil;
    // [self.webView.mainFrame loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading:nil];
}

#pragma mark Result
- (void)setResult:(FlashlightResult *)result {
    _result = result;
    
    id json = objc_getAssociatedObject(result, @selector(jsonAssociatedObject));
    NSString *sourcePlugin = objc_getAssociatedObject(result, @selector(sourcePluginAssociatedObject));
    
    if (json[@"html"]) {
        [self ensureWebview];
        NSString *pluginPath = [[_SS_PluginRunner pathForPlugin:sourcePlugin] stringByAppendingPathComponent:@"index.html"];
        [_webView.mainFrame loadHTMLString:json[@"html"] baseURL:[NSURL fileURLWithPath:pluginPath]];
        if (json[@"webview_user_agent"]) {
            [_webView setCustomUserAgent:json[@"webview_user_agent"]];
        }
        if ([json[@"webview_links_open_in_browser"] boolValue]) {
            self.linksOpenInBrowser = YES;
        }
        if ([json[@"webview_transparent_background"] boolValue]) {
            _webView.drawsBackground = NO;
        }
    } else {
        for (NSView *v in self.subviews) {
            v.hidden = YES;
        }
    }
}

- (void)ensureWebview {
    if (!_webView) {
        _webView = [WebView new];
        [self addSubview:_webView positioned:NSWindowBelow relativeTo:_loader];
        _webView.frameLoadDelegate = self;
        _webView.policyDelegate = self;
        _webView.frame = self.bounds;
        _webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
}

#pragma mark Output function

- (id)resultOfOutputFunction {
    if ([self isWebFrameShowingLocalData:self.webView.mainFrame]) {
        return [self.webView stringByEvaluatingJavaScriptFromString:@"output()"] ? : [NSNull null];
    }
    return [NSNull null];
}


@end
