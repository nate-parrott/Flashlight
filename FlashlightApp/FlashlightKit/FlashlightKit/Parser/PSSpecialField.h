//
//  PSSpecialField.h
//  FlashlightKit
//
//  Created by Nate Parrott on 1/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSSpecialField : NSObject

+ (NSMutableDictionary *)specialFieldClassesForNames;
+ (id)getJsonObjectFromText:(NSString *)text;
+ (NSArray *)getExamples;
+ (NSString *)name;

@end
