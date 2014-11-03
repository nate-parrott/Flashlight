//
//  NSObject+LogProperties.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/2/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//


//NSObject+logProperties.m
#import "NSObject+LogProperties.h"
#import <objc/runtime.h>

@implementation NSObject (logProperties)

- (void) logProperties {
    
    NSLog(@"----------------------------------------------- Properties for object %@", self);
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        
        if (strncmp(type, "i", 1) == 0) {
            int intValue = *(int*)((uintptr_t)self + offset);
            NSLog(@"%s = %i", name, intValue);
        } else if (strncmp(type, "f", 1) == 0) {
            float floatValue = *(float*)((uintptr_t)self + offset);
            NSLog(@"%s = %f", name, floatValue);
        } else if (strncmp(type, "@", 1) == 0) {
            id value = object_getIvar(self, ivar);
            NSLog(@"%s = %@", name, value);
        }
        // And the rest for other type encodings
    }
    free(ivars);
    
    NSLog(@"-----------------------------------------------");
}

@end
