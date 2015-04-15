//
//  StarterPack.m
//  Flashlight
//
//  Created by Nate Parrott on 4/7/15.
//
//

#import "StarterPack.h"
#import "PluginModel.h"

@implementation StarterPack

+ (void)unpack {
    NSFileManager *manager = [NSFileManager new];
    NSString *pluginPath = [PluginModel pluginsDir];
    NSString *starterPackPath = [[NSBundle mainBundle] pathForResource:@"StarterPackPlugins" ofType:nil];
    if (![manager fileExistsAtPath:pluginPath]) {
        [manager createDirectoryAtPath:pluginPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    for (NSString *item in [manager contentsOfDirectoryAtPath:starterPackPath error:nil]) {
        if ([item.pathExtension isEqualToString:@"bundle"]) {
            NSString *pluginSource = [starterPackPath stringByAppendingPathComponent:item];
            NSString *pluginDest = [pluginPath stringByAppendingPathComponent:item];
            [manager copyItemAtPath:pluginSource toPath:pluginDest error:nil];
        }
    }
}

@end
