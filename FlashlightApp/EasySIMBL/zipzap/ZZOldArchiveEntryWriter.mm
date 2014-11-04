//
//  ZZZipEntryWriter.m
//  zipzap
//
//  Created by Glen Low on 9/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#import "ZZChannelOutput.h"
#import "ZZOldArchiveEntryWriter.h"
#import "ZZHeaders.h"

@implementation ZZOldArchiveEntryWriter
{
	NSData* _centralFileHeader;
	uint32_t _localFileLength;
	NSData* _localFile;
}

- (id)initWithCentralFileHeader:(struct ZZCentralFileHeader*)centralFileHeader
				localFileHeader:(struct ZZLocalFileHeader*)localFileHeader
			shouldSkipLocalFile:(BOOL)shouldSkipLocalFile
{
	if ((self = [super init]))
	{
		size_t centralFileLength = (uint8_t*)centralFileHeader->nextCentralFileHeader() - (uint8_t*)centralFileHeader;
		
		_localFileLength = (uint32_t)((const uint8_t*)localFileHeader->nextLocalFileHeader(centralFileHeader->compressedSize) - (const uint8_t*)localFileHeader);

		if (shouldSkipLocalFile)
		{
			// reference the central header bytes: original memory map will be intact when writing, we're not changing the header
			// don't reference the local file: since we skip the local file, don't need to reference it
			_centralFileHeader = [NSData dataWithBytesNoCopy:centralFileHeader
													  length:centralFileLength
												freeWhenDone:NO];
			_localFile = nil;
		}
		else
		{
			// copy the central header bytes: we change the header so we need to make a copy first
			// reference the local file: original memory map will be intact when writing
			_centralFileHeader = [[NSMutableData alloc] initWithBytes:centralFileHeader
															   length:centralFileLength];
		
			_localFile = [NSData dataWithBytesNoCopy:localFileHeader
											  length:_localFileLength
										freeWhenDone:NO];
		}
	}
	return self;
}

- (uint32_t)offsetToLocalFileEnd
{
	if (_localFile)
		return 0;
	else
		return ((const ZZCentralFileHeader*)_centralFileHeader.bytes)->relativeOffsetOfLocalHeader + _localFileLength;
}

- (BOOL)writeLocalFileToChannelOutput:(id<ZZChannelOutput>)channelOutput
					  withInitialSkip:(uint32_t)initialSkip
								error:(out NSError**)error
{
	if (_localFile)
	{
		// can't skip: save the offset, then write out the local file bytes
		((ZZCentralFileHeader*)((NSMutableData*)_centralFileHeader).mutableBytes)->relativeOffsetOfLocalHeader = [channelOutput offset] + initialSkip;
		return [channelOutput writeData:_localFile
								  error:error];
	}
	else
		return YES;
}

- (BOOL)writeCentralFileHeaderToChannelOutput:(id<ZZChannelOutput>)channelOutput
										error:(out NSError**)error
{
	return [channelOutput writeData:_centralFileHeader
							  error:error];
}

@end
