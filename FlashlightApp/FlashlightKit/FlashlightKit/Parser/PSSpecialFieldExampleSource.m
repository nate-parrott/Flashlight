//
//  PSSpecialFieldExampleSource.m
//  FlashlightKit
//
//  Created by Nate Parrott on 1/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PSSpecialFieldExampleSource.h"
#import "Parsnip.h"
#import "PSHelpers.h"
#import "PSSpecialField.h"
#import "PSTaggedText+ParseExample.h"

@implementation PSSpecialFieldExampleSource

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback {
    self = [super initWithIdentifier:identifier callback:callback];
    Parsnip *parsnip = [Parsnip new];
    NSArray *examples = [[[PSSpecialField specialFieldClassesForNames] allKeys] flatMap:^NSArray *(NSString *fieldName) {
        Class cls = [PSSpecialField specialFieldClassesForNames][fieldName];
        return [cls performSelector:@selector(getParsedExamples)];
    }];
    [parsnip learnExamples:examples];
    callback(identifier, @{PSParsnipSourceDataParsnipKey: parsnip});
    return self;
}

@end
