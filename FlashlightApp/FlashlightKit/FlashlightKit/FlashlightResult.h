//
//  FlashlightResult.h
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;

@interface FlashlightResult : NSObject

@property (nonatomic) NSDictionary *json;

- (NSString *)title;
- (BOOL)supportsWebview;
- (void)configureWebview:(WebView *)webView;
- (BOOL)pressEnter;

- (id)initWithJson:(id)json;

@end
