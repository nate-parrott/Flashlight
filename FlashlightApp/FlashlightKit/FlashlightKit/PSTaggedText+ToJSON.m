//
//  PSTaggedText+ToJSON.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/31/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText+ToJSON.h"
#import "PSHelpers.h"

@implementation PSTaggedText (ToJSON)

- (NSString *)toJson {
    return [[self toJsonObject] toJson];
}

- (id)toJsonObject {
    return @{
             @"tag": self.tag,
             @"contents": [self.contents mapFilter:^id(id obj) {
                 if ([obj isKindOfClass:[PSTaggedText class]]) {
                     return [obj toJsonObject];
                 } else if ([obj isKindOfClass:[NSString class]]) {
                     return obj;
                 }
                 return nil;
             }]
             };
}

@end
