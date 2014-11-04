//
//  ZZStoreOutputStream.h
//  zipzap
//
//  Created by Glen Low on 13/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZZChannelOutput;

@interface ZZStoreOutputStream : NSOutputStream

@property (readonly, nonatomic) uint32_t crc32;
@property (readonly, nonatomic) uint32_t size;

- (id)initWithChannelOutput:(id<ZZChannelOutput>)channelOutput;

- (NSStreamStatus)streamStatus;
- (NSError*)streamError;

- (void)open;
- (void)close;

- (NSInteger)write:(const uint8_t*)buffer maxLength:(NSUInteger)length;
- (BOOL)hasSpaceAvailable;

@end
