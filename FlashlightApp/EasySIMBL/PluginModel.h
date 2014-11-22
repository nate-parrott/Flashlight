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
@property (nonatomic) NSArray *categories;
@property (nonatomic) BOOL isAutomatorWorkflow;

+ (PluginModel *)fromJson:(NSDictionary *)json baseURL:(NSURL *)url;

@property (nonatomic,readonly) NSAttributedString *attributedString;

- (NSArray *)allCategories;

@end
