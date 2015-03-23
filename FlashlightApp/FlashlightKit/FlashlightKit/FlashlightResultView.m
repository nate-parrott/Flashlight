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

@interface FlashlightResultView ()

@property (nonatomic) NSProgressIndicator *loader;
@property (nonatomic) WebView *webView;

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
    self.webView = nil;
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

@end
