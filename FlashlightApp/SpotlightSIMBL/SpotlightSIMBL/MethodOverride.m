//
//  MethodOverride.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/2/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MARTNSObject.h"
#import "RTMethod.h"
#import "SPQuery.h"
#import "SPResult.h"
#import "SPResponse.h"
#import "SPDictionaryResult.h"
#import "SPOpenAPIResult.h"

void __SS_Override(Class c, SEL sel, void *fptr)
{
    RTMethod *superMethod = [[c superclass] rt_methodForSelector: sel];
    RTMethod *newMethod = [RTMethod methodWithSelector: sel implementation: fptr signature: [superMethod signature]];
    [c rt_addMethod: newMethod];
}
