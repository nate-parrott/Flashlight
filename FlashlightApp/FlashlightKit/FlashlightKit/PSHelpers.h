//
//  PSHelpers.h
//  Parsnip
//
//  Created by Nate Parrott on 12/20/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PSVoidBlock)();

extern const double PSMinimalProbability;
extern const double PSFreeTextProbability;

@interface NSArray (PS)

- (NSArray *)mapFilter:(id(^)(id obj))mapper;
- (NSArray *)flatMap:(NSArray*(^)(id obj))mapper;
- (id)reduce:(id(^)(id obj1, id obj2))reduceBlock initialVal:(id)initialVal;

- (id)smartIndex:(NSInteger)i; // python-style indexing

- (NSString *)toJson;

- (NSDictionary *)mapToDict:(id(^)(id *key))mapper;

@end

double PSLogProb(double prob);
double PSSmoothLogProb(double logProb);

@interface NSMutableDictionary (PS)

- (id)objectForKey:(id)aKey settingDefaultToValue:(id(^)())defaultFunction;

@end

@interface NSString (PS)

- (BOOL)startsWith:(NSString *)string;

@end

@interface NSDictionary (PS)

- (NSString *)toJson;

@end
