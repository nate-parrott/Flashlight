//
//  PSSpecialField.h
//  FlashlightKit
//
//  Created by Nate Parrott on 1/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSTaggedText;

@interface PSSpecialField : NSObject

+ (NSMutableDictionary *)specialFieldClassesForNames;
+ (id)getJsonObjectFromTaggedText:(PSTaggedText *)taggedText;
+ (NSArray *)getExamples;
+ (NSArray *)getParsedExamples; // by default, calls -getExamples and parses them
+ (NSString *)name;

@end
