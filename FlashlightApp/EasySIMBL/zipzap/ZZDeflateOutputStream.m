//
//  ZZDeflateOutputStream.m
//  zipzap
//
//  Created by Glen Low on 9/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#include <zlib.h>

#import "ZZChannelOutput.h"
#import "ZZDeflateOutputStream.h"

static const uInt _flushLength = 1024;

@implementation ZZDeflateOutputStream
{
	id<ZZChannelOutput> _channelOutput;
	NSUInteger _compressionLevel;
	NSStreamStatus _status;
	NSError* _error;
	uint32_t _crc32;
	z_stream _stream;
}

@synthesize crc32 = _crc32;

- (id)initWithChannelOutput:(id<ZZChannelOutput>)channelOutput compressionLevel:(NSUInteger)compressionLevel
{
	if ((self = [super init]))
	{
		_channelOutput = channelOutput;
		_compressionLevel = compressionLevel;
		
		_status = NSStreamStatusNotOpen;
		_error = nil;
		_crc32 = 0;
		_stream.zalloc = Z_NULL;
		_stream.zfree = Z_NULL;
		_stream.opaque = Z_NULL;
		_stream.next_in = Z_NULL;
		_stream.avail_in = 0;
	}
	return self;
}

- (uint32_t)compressedSize
{
	return (uint32_t)_stream.total_out;
}

- (uint32_t)uncompressedSize
{
	return (uint32_t)_stream.total_in;
}

- (NSStreamStatus)streamStatus
{
	return _status;
}

- (NSError*)streamError
{
	return _error;
}

- (void)open
{
	deflateInit2(&_stream,
				 _compressionLevel,
				 Z_DEFLATED,
				 -15,
				 8,
				 Z_DEFAULT_STRATEGY);
	_status = NSStreamStatusOpen;
}

- (void)close
{
	uint8_t flushBuffer[_flushLength];
	_stream.next_in = Z_NULL;
	_stream.avail_in = 0;
	
	// flush out all remaining deflated bytes, a bufferfull at a time
	BOOL flushing = YES;
	while (flushing)
	{
		_stream.next_out = flushBuffer;
		_stream.avail_out = _flushLength;
		
		flushing = deflate(&_stream, Z_FINISH) == Z_OK;
				
		if (_stream.avail_out < _flushLength)
		{
			NSError* __autoreleasing flushError;
			if (![_channelOutput writeData:[NSData dataWithBytesNoCopy:flushBuffer
																length:_flushLength - _stream.avail_out
														  freeWhenDone:NO]
									 error:&flushError])
			{
				_status = NSStreamStatusError;
				_error = flushError;
			}
		}
	}
	
	deflateEnd(&_stream);
	_status = NSStreamStatusClosed;
}

- (NSInteger)write:(const uint8_t*)buffer maxLength:(NSUInteger)length
{
	// allocate an output buffer large enough to fit deflated output
	// NOTE: we ensure that we can deflate at least one byte, since write:maxLength: need not deflate all bytes
	uLong maxLength = deflateBound(&_stream, length);
	NSMutableData* outputBuffer = [[NSMutableData alloc] initWithLength:maxLength];
	
	// deflate buffer to output buffer
	_stream.next_in = (Bytef*)buffer;
	_stream.avail_in = (uInt)length;
	_stream.next_out = (Bytef*)outputBuffer.mutableBytes;
	_stream.avail_out = (uInt)maxLength;
	deflate(&_stream, Z_NO_FLUSH);
	
	// write out deflated output if any
	outputBuffer.length = maxLength - _stream.avail_out;
	if (outputBuffer.length > 0)
	{
		NSError* __autoreleasing writeError;
		if (![_channelOutput writeData:outputBuffer
								 error:&writeError])
		{
			_status = NSStreamStatusError;
			_error = writeError;
			return -1;
		}
	}

	// accumulate checksum only on bytes that were deflated
	NSUInteger bytesWritten = length - _stream.avail_in;
	_crc32 = (uint32_t)crc32(_crc32, buffer, (uInt)bytesWritten);
	
	return bytesWritten;
}

- (BOOL)hasSpaceAvailable
{
	return YES;
}

@end
