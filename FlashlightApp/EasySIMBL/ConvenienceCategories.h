//
//  NSObject+ConvenienceCategories.h
//  Calculator
//
//  Created by Nate Parrott on 3/16/13.
//  Copyright (c) 2013 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^NSArrayMapFunction)(id obj);
typedef id (^NSArrayFoldFunction)(id obj1, id obj2);
@interface NSArray (ConvenienceCategories)
-(NSArray*)map:(NSArrayMapFunction)fn;
-(NSArray*)reversed;
-(id)fold:(NSArrayFoldFunction)fn;
+(NSArray*)rangeFrom:(int)start until:(int)end;
-(double)sum;
@end

typedef NSArray* (^NSDictionaryMapFunction)(id key, id val);
@interface NSDictionary (ConvenienceCategories)
-(BOOL)conflictsWithDictionary:(NSDictionary*)otherDict;
-(NSDictionary*)map:(NSDictionaryMapFunction)fn;
@end

@interface NSMutableDictionary (ConvenienceCategories)
-(void)mergeKeysFromDictionary:(NSDictionary*)otherDict;

@end

void PerformOnMainThread(dispatch_block_t block);
