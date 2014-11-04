//
//  ZZChannel.h
//  zipzap
//
//  Created by Glen Low on 12/01/13.
//
//

#import <Foundation/Foundation.h>

@protocol ZZChannelOutput;

@protocol ZZChannel

@property (readonly, nonatomic) NSURL* URL;

- (instancetype)temporaryChannel:(out NSError**)error;
- (BOOL)replaceWithChannel:(id<ZZChannel>)channel
					 error:(out NSError**)error;
- (void)removeAsTemporary;

- (NSData*)newInput:(out NSError**)error;
- (id<ZZChannelOutput>)newOutput:(out NSError**)error;

@end
