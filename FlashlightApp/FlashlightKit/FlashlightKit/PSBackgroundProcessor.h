//
//  PSBackgroundProcessor.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PSBackgroundProcessorResultBlock)(id result);
typedef void (^PSBackgroundProcessorBlock)(id data, PSBackgroundProcessorResultBlock callback);

@interface PSBackgroundProcessor : NSObject

- (instancetype)initWithProcessingBlock:(PSBackgroundProcessorBlock)block;

// API is thread-safe:
- (void)gotNewData:(id)data;
@property (atomic) id latestResult;
@property (nonatomic, readonly) id latestData;

@end
