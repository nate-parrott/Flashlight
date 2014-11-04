//
//  PluginModel.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Foundation/Foundation.h>

@interface PluginModel : NSObject <NSCopying>

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *pluginDescription;
@property (nonatomic) BOOL installed;
@property (nonatomic) BOOL installing;

@end
