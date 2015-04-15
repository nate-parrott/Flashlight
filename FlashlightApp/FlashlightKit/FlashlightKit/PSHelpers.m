//
//  PSHelpers.m
//  Parsnip
//
//  Created by Nate Parrott on 12/20/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSArray (PS)

- (NSArray *)mapFilter:(id(^)(id obj))mapper {
    NSMutableArray *mapped = [NSMutableArray new];
    for (id obj in self){
        id result = mapper(obj);
        if (result) {
            [mapped addObject:result];
        }
    }
    return mapped;
}

- (NSString *)toJson {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray *)flatMap:(NSArray*(^)(id obj))mapper {
    NSMutableArray *mapped = [NSMutableArray new];
    for (id obj in self) {
        NSArray *result = mapper(obj);
        if (result) {
            [mapped addObjectsFromArray:result];
        }
    }
    return mapped;
}

- (id)smartIndex:(NSInteger)i {
    if (i < 0) {
        return self[self.count-i];
    }
    return self[i];
}

- (id)reduce:(id(^)(id obj1, id obj2))reduceBlock initialVal:(id)initialVal {
    id val = initialVal;
    for (id item in self) {
        val = reduceBlock(val, item);
    }
    return val;
}

- (NSDictionary *)mapToDict:(id(^)(id *key))mapper {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id obj in self) {
        id key = obj;
        id val = mapper(&key);
        d[key] = val;
    }
    return d;
}

@end

double PSLogProb(double prob) {
    return log(prob);
}

const double PSMinimalProbability = 0.0001;
const double PSFreeTextProbability = 0.001;

double PSSmoothLogProb(double logProb) {
    double prob = exp(logProb);
    return PSLogProb(prob * (1-PSMinimalProbability) + PSMinimalProbability);
}

@implementation NSMutableDictionary (PS)

- (id)objectForKey:(id)aKey settingDefaultToValue:(id(^)())defaultFunction {
    id item = self[aKey];
    if (!item) {
        item = defaultFunction();
        self[aKey] = item;
    }
    return item;
}

@end

@implementation NSString (PS)

- (BOOL)startsWith:(NSString *)string {
    return self.length >= string.length && [[self substringToIndex:string.length] isEqualToString:string];
}

@end

@implementation NSDictionary (PS)

- (NSString *)toJson {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:0 error:nil] encoding:NSUTF8StringEncoding];
}

@end


