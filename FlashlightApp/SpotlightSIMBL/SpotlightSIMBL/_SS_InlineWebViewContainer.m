//
//  _SS_InlineWebView.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_SS_InlineWebViewContainer.h"
#import <objc/runtime.h>
#import "_SS_PluginRunner.h"

@interface _SS_InlineWebViewContainer ()

@property (nonatomic) BOOL linksOpenInBrowser;

@end

@implementation _SS_InlineWebViewContainer

#pragma mark Window Scripting Layer

- (NSString *)bash:(NSString*) args {
    NSPipe *pipeIn = [NSPipe pipe];
    NSPipe *pipeOut = [NSPipe pipe];
    NSFileHandle *file = pipeOut.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = [NSArray arrayWithObjects:@"-l", @"-c", args, nil];
    task.standardInput = pipeIn;
    task.standardOutput = pipeOut;
    
    [task waitUntilExit];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return grepOutput;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
    if(sel == @selector(bash:))
        return NO;
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
    if(sel == @selector(bash:))
        return @"bash";
    return nil;
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    if (frame.DOMDocument.domain.length == 0) {
        // only insert on non-remote pages:
        [windowScriptObject setValue:self forKey:@"flashlight"];
    }
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
    [self.webView.windowScriptObject removeWebScriptKey:@"flashlight"];
    self.webView.frameLoadDelegate = nil;
    self.webView.policyDelegate = nil;
    // [self.webView.mainFrame loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading:nil];
}

#pragma mark Result
- (void)setResult:(SPResult *)result {
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

@end
