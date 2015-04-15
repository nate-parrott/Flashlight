//
//  PluginListRenderer.h
//  Flashlight
//
//  Created by Nate Parrott on 4/6/15.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@class PluginModel;

@interface InstalledPluginListRenderer : NSObject

- (void)populateWebview:(WebView *)webview withInstalledPlugins:(NSArray *)installedPlugins;

@end
