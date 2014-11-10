//
//  _SS_InlineWebView.h
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface _SS_InlineWebViewContainer : NSView

@property (nonatomic) IBOutlet NSProgressIndicator *loader;
@property (nonatomic) IBOutlet WebView *webView;

@end
