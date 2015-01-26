//
//  PSTaggedText+ToJSON.h
//  FlashlightKit
//
//  Created by Nate Parrott on 12/31/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PSTaggedText.h"

@interface PSTaggedText (ToJSON)

- (NSString *)toJson;
- (id)toJsonObject;

@end
