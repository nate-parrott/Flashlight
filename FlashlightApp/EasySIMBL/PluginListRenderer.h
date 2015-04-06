//
//  PluginListRenderer.h
//  Flashlight
//
//  Created by Nate Parrott on 4/6/15.
//
//

#import <Foundation/Foundation.h>

@interface PluginListRenderer : NSObject

- (NSString *)renderPluginListHTMLForInstalled:(NSArray *)installedPlugins;

@end
