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
#import "FlashlightResult.h"
#import <FlashlightKit.h>

@interface FlashlightResultView ()

@property (nonatomic) NSProgressIndicator *loader;
@property (nonatomic) WebView *webView;

@property (nonatomic) NSTimer *visibilityLoggingTimer;

@end

@implementation FlashlightResultView

#pragma mark View loading
- (void)setup {
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setup];
    return self;
}

#pragma mark Lifecycle
- (void)dealloc {
    self.result = nil;
}

#pragma mark Result
- (void)setResult:(FlashlightResult *)result {
    [_result cleanUpWebviewIfNeeded];
    
    _result = result;
    
    self.webView = result.webView;
}

- (void)setWebView:(WebView *)webView {
    [_webView removeFromSuperview];
    _webView = webView;
    if (webView) {
        [self addSubview:_webView];
        _webView.frame = self.bounds;
        _webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
}

#pragma mark Output function

- (id)resultOfOutputFunction {
    return [self.result resultOfOutputFunction];
}

#pragma mark Visibility
- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    if (newWindow && !self.visibilityLoggingTimer) {
        self.visibilityLoggingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(viewedFor1Sec) userInfo:nil repeats:NO];
    } else if (!newWindow && self.visibilityLoggingTimer) {
        [self.visibilityLoggingTimer invalidate];
        self.visibilityLoggingTimer = nil;
    }
}

- (void)viewedFor1Sec {
    [DAU logDailyAction:@"viewResultFor1Sec"];
    self.visibilityLoggingTimer = nil;
}

@end
