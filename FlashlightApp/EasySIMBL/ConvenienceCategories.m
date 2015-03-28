//
//  NSObject+ConvenienceCategories.m
//  Calculator
//
//  Created by Nate Parrott on 3/16/13.
//  Copyright (c) 2013 Nate Parrott. All rights reserved.
//

#import "ConvenienceCategories.h"

@implementation NSArray (ConvenienceCategories)

-(NSArray*)map:(NSArrayMapFunction)fn {
    NSMutableArray* result = [NSMutableArray array];
    for (id item in self) {
        id mapping = fn(item);
        if (mapping) {
            [result addObject:mapping];
        }
    }
    return result;
}
-(NSArray*)reversed {
    NSMutableArray* rev = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self.reverseObjectEnumerator) {
        [rev addObject:item];
    }
    return rev;
}
-(id)fold:(NSArrayFoldFunction)fn {
    if (self.count==0) return nil;
    id obj = self[0];
    for (int i=1; i<self.count; i++) {
        obj = fn(obj, self[i]);
    }
    return obj;
}
+(NSArray*)rangeFrom:(int)start until:(int)end {
    NSMutableArray* range = [NSMutableArray arrayWithCapacity:end-start];
    for (int i=start; i<end; i++) {
        [range addObject:@(i)];
    }
    return range;
}
-(double)sum {
    return [[self fold:^id(id obj1, id obj2) {
        return @([obj1 doubleValue] + [obj2 doubleValue]);
    }] doubleValue];
}

@end

@implementation NSDictionary (ConvenienceCategories)

-(BOOL)conflictsWithDictionary:(NSDictionary*)otherDict {
    for (id key in otherDict.keyEnumerator) {
        if (self[key] && ![self[key] isEqual:otherDict[key]]) {
            return YES;
        }
    }
    return NO;
}
-(NSDictionary*)map:(NSDictionaryMapFunction)fn {
    NSMutableDictionary* d = [NSMutableDictionary new];
    for (id key in self.keyEnumerator) {
        NSArray* kvpair = fn(key, self[key]);
        if (kvpair) d[kvpair[0]] = kvpair[1];
    }
    return d;
}

@end

@implementation NSMutableDictionary (ConvenienceCategories)

-(void)mergeKeysFromDictionary:(NSDictionary*)otherDict {
    for (id key in otherDict.keyEnumerator) {
        self[key] = otherDict[key];
    }
}

@end

void PerformOnMainThread(dispatch_block_t block) {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
