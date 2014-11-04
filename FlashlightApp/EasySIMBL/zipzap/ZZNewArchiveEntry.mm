//
//  ZZNewArchiveEntry.m
//  zipzap
//
//  Created by Glen Low on 8/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#import "ZZNewArchiveEntry.h"
#import "ZZNewArchiveEntryWriter.h"

@implementation ZZNewArchiveEntry
{
	NSString* _fileName;
	mode_t _fileMode;
	NSDate* _lastModified;
	NSInteger _compressionLevel;
	NSData* (^_dataBlock)(NSError** error);
	BOOL (^_streamBlock)(NSOutputStream* stream, NSError** error);
	BOOL (^_dataConsumerBlock)(CGDataConsumerRef dataConsumer, NSError** error);
}

- (id)initWithFileName:(NSString*)fileName
			  fileMode:(mode_t)fileMode
		  lastModified:(NSDate*)lastModified
	  compressionLevel:(NSInteger)compressionLevel
			 dataBlock:(NSData*(^)(NSError** error))dataBlock
		   streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock
	 dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;
{
	if ((self = [super init]))
	{
		_fileName = fileName;
		_fileMode = fileMode;
		_lastModified = lastModified;
		_compressionLevel = compressionLevel;
		_dataBlock = dataBlock;
		_streamBlock = streamBlock;
		_dataConsumerBlock = dataConsumerBlock;
	}
	return self;
}

- (BOOL)compressed
{
	return _compressionLevel != 0;
}

- (NSDate*)lastModified
{
	return _lastModified;
}

- (mode_t)fileMode
{
	return _fileMode;
}

- (NSString*)fileName
{
	return _fileName;
}

- (id<ZZArchiveEntryWriter>)newWriterCanSkipLocalFile:(BOOL)canSkipLocalFile
{
	return [[ZZNewArchiveEntryWriter alloc] initWithFileName:_fileName
												fileMode:_fileMode
											lastModified:_lastModified
										compressionLevel:_compressionLevel
											   dataBlock:_dataBlock
											 streamBlock:_streamBlock
									   dataConsumerBlock:_dataConsumerBlock];
}

@end

