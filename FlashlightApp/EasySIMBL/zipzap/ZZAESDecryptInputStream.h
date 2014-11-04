//
//  ZZAESDecryptInputStream.h
//  zipzap
//
//  Created by Daniel Cohen Gindi on 1/6/14.
//
//

#import <Foundation/Foundation.h>

#import "ZZConstants.h"

@interface ZZAESDecryptInputStream : NSInputStream

- (id)initWithStream:(NSInputStream*)upstream
			password:(NSString*)password
			  header:(uint8_t*)header
			strength:(ZZAESEncryptionStrength)strength
			   error:(out NSError**)error;

- (void)open;
- (void)close;

- (NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len;
- (BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger*)len;
- (BOOL)hasBytesAvailable;

- (void)dealloc;

@end
