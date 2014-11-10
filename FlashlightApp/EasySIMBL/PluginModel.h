//
//  PluginModel.h
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import <Foundation/Foundation.h>

@interface PluginModel : NSObject <NSCopying>

@property (nonatomic) NSString *name, *displayName, *pluginDescription;
@property (nonatomic) NSArray *examples;
@property (nonatomic) BOOL installed;
@property (nonatomic) BOOL installing;
@property (nonatomic) NSURL *zipURL;

+ (PluginModel *)fromJson:(NSDictionary *)json baseURL:(NSURL *)url;

+ (NSArray *)mergeDuplicates:(NSArray *)models;

@property (nonatomic,readonly) NSAttributedString *attributedString;

@end
