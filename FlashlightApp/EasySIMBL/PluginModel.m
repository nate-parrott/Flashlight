//
//  PluginModel.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginModel.h"

@implementation PluginModel

- (id)copyWithZone:(NSZone *)zone {
    PluginModel *p = [PluginModel new];
    p.name = self.name;
    p.pluginDescription = self.pluginDescription;
    p.installed = self.installed;
    p.installing = self.installing;
    return p;
}

@end
