//
//  PSBackgroundProcessor.m
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSBackgroundProcessor.h"

@interface PSBackgroundProcessor ()

@property (nonatomic,copy) PSBackgroundProcessorBlock block;

// @synchronized(self) access to all these:
@property (nonatomic) id latestData;
@property (nonatomic) BOOL workInProgress, needsWorkAfterwards;

@end

@implementation PSBackgroundProcessor

- (instancetype)initWithProcessingBlock:(PSBackgroundProcessorBlock)block {
    self = [super init];
    self.block = block;
    return self;
}

- (void)gotNewData:(id)data {
    id workNowOnData = nil;
    @synchronized(self) {
        self.latestData = data;
        if (self.workInProgress) {
            self.needsWorkAfterwards = YES;
        } else {
            // do work:
            self.workInProgress = YES;
            workNowOnData = self.latestData;
        }
    }
    if (workNowOnData) {
        [self workNowWithData:workNowOnData];
    }
}

- (void)workNowWithData:(id)data {
    self.block(data, ^(id result) {
        id workNowOnData = nil;
        @synchronized(self) {
            self.latestResult = result;
            if (self.needsWorkAfterwards) {
                workNowOnData = self.latestData;
                self.needsWorkAfterwards = NO;
            } else {
                self.workInProgress = NO;
            }
        }
        if (workNowOnData) {
            [self workNowWithData:workNowOnData];
        }
    });
}

@end
