//
//  ZZStandardDecryptInputStream.h
//  zipzap
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//
//

#import <Foundation/Foundation.h>

@interface ZZStandardDecryptInputStream : NSInputStream

- (id)initWithStream:(NSInputStream*)upstream
			password:(NSString*)password
			  header:(uint8_t*)header
			   check:(uint16_t)check
			 version:(uint8_t)version
			   error:(out NSError**)error;

- (void)open;
- (void)close;

- (NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len;
- (BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger*)len;
- (BOOL)hasBytesAvailable;

@end
