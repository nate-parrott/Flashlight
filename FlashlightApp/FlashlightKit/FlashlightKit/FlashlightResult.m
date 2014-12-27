//
//  FlashlightResult.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightResult.h"

@implementation FlashlightResult

- (id)initWithJson:(id)json {
    self = [super init];
    self.json = json;
    return self;
}

@end
