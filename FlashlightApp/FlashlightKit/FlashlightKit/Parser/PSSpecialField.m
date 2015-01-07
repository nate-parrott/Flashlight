//
//  PSSpecialField.m
//  FlashlightKit
//
//  Created by Nate Parrott on 1/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PSSpecialField.h"

@implementation PSSpecialField

+ (NSMutableDictionary *)specialFieldClassesForNames {
    static NSMutableDictionary *fields = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fields = [NSMutableDictionary new];
    });
    return fields;
}

+ (void)initialize {
    [super initialize];
    if ([self name]) {
        [PSSpecialField specialFieldClassesForNames][[self name]] = [self class];
    }
}

+ (id)getJsonObjectFromText:(NSString *)text {
    return nil;
}

+ (NSArray *)getExamples {
    return @[];
}

+ (NSString *)name {
    return nil;
}

@end
