//
//  _SS_InlineWebView.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_SS_InlineWebViewContainer.h"

@implementation _SS_InlineWebViewContainer

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (frame == sender.mainFrame) {
            [self.loader startAnimation:nil];
        }
    });
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (frame == sender.mainFrame) {
            [self.loader stopAnimation:nil];
        }
    });
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSLog(@"Decide window policy: %@", actionInformation);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSWorkspace sharedWorkspace] openURL:request.URL];
    });
    [listener ignore];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSLog(@"Decide policy: %@", actionInformation);
    if ([actionInformation[WebActionNavigationTypeKey] isEqualToString:WebNavigationTypeLinkClicked]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:request.URL];
        });
        [listener ignore];
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    [listener use];
}

- (void)dealloc {
    self.webView.policyDelegate = nil;
    self.webView.frameLoadDelegate = nil;
    [self.webView stopLoading:nil];
}

@end
