//
//  ZZDataChannel.m
//  zipzap
//
//  Created by Glen Low on 12/01/13.
//
//

#import "ZZDataChannel.h"
#import "ZZDataChannelOutput.h"

@implementation ZZDataChannel
{
	NSData* _allData;
}

- (id)initWithData:(NSData*)data
{
	if ((self = [super init]))
		_allData = data;
	return self;
}

- (NSURL*)URL
{
	return nil;
}

- (instancetype)temporaryChannel:(out NSError**)error
{
	return [[ZZDataChannel alloc] initWithData:[NSMutableData data]];
}

- (BOOL)replaceWithChannel:(id<ZZChannel>)channel
					 error:(out NSError**)error
{
	[(NSMutableData*)_allData setData:((ZZDataChannel*)channel)->_allData];
	return YES;
}

- (void)removeAsTemporary
{
	_allData = nil;
}

- (NSData*)newInput:(out NSError**)error
{
	if (_allData.length == 0)
	{
		// no data available: consider it as file not found
		if (error)
			*error = [NSError errorWithDomain:NSCocoaErrorDomain
										 code:NSFileReadNoSuchFileError
									 userInfo:@{}];
		return nil;
	}
	return _allData;
}

- (id<ZZChannelOutput>)newOutput:(out NSError**)error
{
	return [[ZZDataChannelOutput alloc] initWithData:(NSMutableData*)_allData];
}

@end
