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

@interface FlashlightResult ()

@end

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

- (BOOL)canBeTopHit {
    return ![self.json[@"dont_force_top_hit"] boolValue];
}

- (void)configureWebview:(WebView *)webView {
    NSString *pluginPath = [self.pluginPath stringByAppendingPathComponent:@"index.html"];
    [webView.mainFrame loadHTMLString:self.json[@"html"] baseURL:[NSURL fileURLWithPath:pluginPath]];
    if (self.json[@"webview_user_agent"]) {
        [webView setCustomUserAgent:self.json[@"webview_user_agent"]];
    }
    webView.drawsBackground = ![self.json[@"webview_transparent_background"] boolValue];
}

- (BOOL)pressEnter:(FlashlightResultView *)resultView errorCallback:(void(^)(NSString *error))errorCallback {
    NSMutableArray *runArgs = [self.json[@"run_args"] mutableCopy];
    if (runArgs) {
        if ([self.json[@"pass_result_of_output_function_as_first_run_arg"] boolValue]) {
            [runArgs insertObject:[resultView resultOfOutputFunction] atIndex:0];
        }
        
        NSTask* task = [NSTask withPathMarkedAsExecutableIfNecessary:[[NSBundle bundleForClass:[self class]] pathForResource:@"run_plugin" ofType:@"py"]];
        NSDictionary *input = @{
                                @"runArgs": runArgs,
                                @"builtinModulesPath": [FlashlightQueryEngine builtinModulesPath],
                                @"pluginPath": self.pluginPath
                                };
        task.arguments = @[input.toJson];
        [task launchWithTimeout:20 callback:^(NSData *stdoutData, NSData *stderrData) {
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

@end
