//
//  FlashlightResult.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightResult.h"

@implementation FlashlightResult

- (NSString *)title {
    return self.json[@"title"];
}

- (BOOL)supportsWebview {
    return !!self.json[@"html"];
}

- (BOOL)linksOpenInBrowser {
    return [self.json[@"webview_links_open_in_browser"] boolValue];
}

- (void)configureWebview:(WebView *)webView {
    NSString *pluginPath = [self.pluginPath stringByAppendingPathComponent:@"index.html"];
    [webView.mainFrame loadHTMLString:self.json[@"html"] baseURL:[NSURL fileURLWithPath:pluginPath]];
    if (self.json[@"webview_user_agent"]) {
        [webView setCustomUserAgent:self.json[@"webview_user_agent"]];
    }
    webView.drawsBackground = ![self.json[@"webview_transparent_background"] boolValue];
}

- (BOOL)pressEnter {
    return NO; // TODO
}

@end
