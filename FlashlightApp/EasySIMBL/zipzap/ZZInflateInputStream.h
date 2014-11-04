//
//  ZZInflateInputStream.h
//  zipzap
//
//  Created by Glen Low on 29/09/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZInflateInputStream : NSInputStream

+ (NSData*)decompressData:(NSData*)data
	 withUncompressedSize:(NSUInteger)uncompressedSize;

- (id)initWithStream:(NSInputStream*)upstream;

- (NSStreamStatus)streamStatus;
- (NSError*)streamError;

- (void)open;
- (void)close;

- (NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len;
- (BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger*)len;
- (BOOL)hasBytesAvailable;

@end
