//
//  PSParsnipSource.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSParsnipSource.h"

NSString * const PSParsnipSourceDataParsnipKey = @"PSParsnipSourceDataParsnipKey";
NSString * const PSParsnipSourceFieldProcessorsDictionaryKey = @"PSParsnipSourceFieldProcessorsDictionaryKey";

@interface PSParsnipSource ()

@property (nonatomic) NSString *identifier;

@end

@implementation PSParsnipSource

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback {
    self = [super init];
    self.identifier = identifier;
    return self;
}

@end
