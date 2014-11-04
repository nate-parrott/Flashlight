//
//  ZZArchive.mm
//  zipzap
//
//  Created by Glen Low on 25/09/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#include <algorithm>
#include <fcntl.h>

#import "ZZChannelOutput.h"
#import "ZZDataChannel.h"
#import "ZZError.h"
#import "ZZFileChannel.h"
#import "ZZScopeGuard.h"
#import "ZZArchiveEntryWriter.h"
#import "ZZArchive.h"
#import "ZZHeaders.h"
#import "ZZOldArchiveEntry.h"

static const size_t ENDOFCENTRALDIRECTORY_MAXSEARCH = sizeof(ZZEndOfCentralDirectory) + 0xFFFF;
static const size_t ENDOFCENTRALDIRECTORY_MINSEARCH = sizeof(ZZEndOfCentralDirectory) - sizeof(ZZEndOfCentralDirectory::signature);

@interface ZZArchive ()

- (id)initWithChannel:(id<ZZChannel>)channel
			  options:(NSDictionary*)options
				error:(out NSError**)error;

- (BOOL)loadCanMiss:(BOOL)canMiss error:(out NSError**)error;

@end

@implementation ZZArchive
{
	id<ZZChannel> _channel;
	NSStringEncoding _encoding;
}

+ (instancetype)archiveWithURL:(NSURL*)URL
						 error:(out NSError**)error
{
	return [[self alloc] initWithChannel:[[ZZFileChannel alloc] initWithURL:URL]
								 options:nil
								   error:error];
}

+ (instancetype)archiveWithData:(NSData*)data
						  error:(out NSError**)error
{
	return [[self alloc] initWithChannel:[[ZZDataChannel alloc] initWithData:data]
								 options:nil
								   error:error];
}

- (id)initWithURL:(NSURL*)URL
		  options:(NSDictionary*)options
			error:(out NSError**)error
{
	return [self initWithChannel:[[ZZFileChannel alloc] initWithURL:URL]
						 options:options
						   error:error];
}

- (id)initWithData:(NSData*)data
		   options:(NSDictionary*)options
			 error:(out NSError**)error
{
	return [self initWithChannel:[[ZZDataChannel alloc] initWithData:data]
						 options:options
						   error:error];
}

- (id)initWithChannel:(id<ZZChannel>)channel
			  options:(NSDictionary*)options
				error:(out NSError**)error
{
	if ((self = [super init]))
	{
		_channel = channel;

		NSNumber* encoding = options[ZZOpenOptionsEncodingKey];
		_encoding = encoding ? encoding.unsignedIntegerValue : NSUTF8StringEncoding;

		NSNumber* createIfMissing = options[ZZOpenOptionsCreateIfMissingKey];
		if (![self loadCanMiss:createIfMissing.boolValue error:error])
			return nil;
	}
	return self;
}

- (NSURL*)URL
{
	return _channel.URL;
}

- (BOOL)loadCanMiss:(BOOL)canMiss error:(out NSError**)error
{
	// memory-map the contents from the zip file
	NSError* __autoreleasing readError;
	NSData* contents = [_channel newInput:&readError];
	if (!contents)
	{
		if (canMiss && readError.code == NSFileReadNoSuchFileError && [readError.domain isEqualToString:NSCocoaErrorDomain])
		{
			_contents = nil;
			_entries = nil;
			return YES;
		}
		else
			return ZZRaiseErrorNo(error, ZZOpenReadErrorCode, @{NSUnderlyingErrorKey : readError});
	}

	// search for the end of directory signature in last 64K of file
	const uint8_t* beginContent = (const uint8_t*)contents.bytes;
	const uint8_t* endContent = beginContent + contents.length;
	const uint8_t* beginRangeEndOfCentralDirectory = beginContent + ENDOFCENTRALDIRECTORY_MAXSEARCH < endContent ? endContent - ENDOFCENTRALDIRECTORY_MAXSEARCH : beginContent;
	const uint8_t* endRangeEndOfCentralDirectory = beginContent + ENDOFCENTRALDIRECTORY_MINSEARCH < endContent ? endContent - ENDOFCENTRALDIRECTORY_MINSEARCH : beginContent;
	const uint32_t sign = ZZEndOfCentralDirectory::sign;
	const uint8_t* endOfCentralDirectory = std::find_end(beginRangeEndOfCentralDirectory,
														 endRangeEndOfCentralDirectory,
														 (const uint8_t*)&sign,
														 (const uint8_t*)(&sign + 1));
	const ZZEndOfCentralDirectory* endOfCentralDirectoryRecord = (const ZZEndOfCentralDirectory*)endOfCentralDirectory;
	
	// sanity check:
	if (
		// found the end of central directory signature
		endOfCentralDirectory == endRangeEndOfCentralDirectory
		// single disk zip
		|| endOfCentralDirectoryRecord->numberOfThisDisk != 0
		|| endOfCentralDirectoryRecord->numberOfTheDiskWithTheStartOfTheCentralDirectory != 0
		|| endOfCentralDirectoryRecord->totalNumberOfEntriesInTheCentralDirectoryOnThisDisk
			!= endOfCentralDirectoryRecord->totalNumberOfEntriesInTheCentralDirectory
		// central directory occurs before end of central directory, and has enough minimal space for the given entries
		|| beginContent
			+ endOfCentralDirectoryRecord->offsetOfStartOfCentralDirectoryWithRespectToTheStartingDiskNumber
			+ endOfCentralDirectoryRecord->totalNumberOfEntriesInTheCentralDirectory * sizeof(ZZCentralFileHeader)
			> endOfCentralDirectory
		// end of central directory occurs at actual end of the zip
		|| endContent
			!= endOfCentralDirectory + sizeof(ZZEndOfCentralDirectory) + endOfCentralDirectoryRecord->zipFileCommentLength)
		return ZZRaiseErrorNo(error, ZZEndOfCentralDirectoryReadErrorCode, nil);
			
	// add an entry for each central header in the sequence
	ZZCentralFileHeader* nextCentralFileHeader = (ZZCentralFileHeader*)(beginContent
																		+ endOfCentralDirectoryRecord->offsetOfStartOfCentralDirectoryWithRespectToTheStartingDiskNumber);
	NSMutableArray* entries = [NSMutableArray array];
	for (NSUInteger index = 0; index < endOfCentralDirectoryRecord->totalNumberOfEntriesInTheCentralDirectory; ++index)
	{
		// sanity check:
		if (
			// correct signature
			nextCentralFileHeader->sign != ZZCentralFileHeader::sign
			// single disk zip
			|| nextCentralFileHeader->diskNumberStart != 0
			// local file occurs before first central file header, and has enough minimal space for at least local file
			|| nextCentralFileHeader->relativeOffsetOfLocalHeader + sizeof(ZZLocalFileHeader)
				> endOfCentralDirectoryRecord->offsetOfStartOfCentralDirectoryWithRespectToTheStartingDiskNumber)
			return ZZRaiseErrorNo(error, ZZCentralFileHeaderReadErrorCode, @{ZZEntryIndexKey : @(index)});
								
		ZZLocalFileHeader* nextLocalFileHeader = (ZZLocalFileHeader*)(beginContent
																	  + nextCentralFileHeader->relativeOffsetOfLocalHeader);
		
		[entries addObject:[[ZZOldArchiveEntry alloc] initWithCentralFileHeader:nextCentralFileHeader
																localFileHeader:nextLocalFileHeader
																	   encoding:_encoding]];
		
		nextCentralFileHeader = nextCentralFileHeader->nextCentralFileHeader();
	}
	
	// having successfully negotiated the new contents + entries, replace in one go
	_contents = contents;
	_entries = entries;
	return YES;
}

- (BOOL)updateEntries:(NSArray*)newEntries
				error:(out NSError**)error
{
	// determine how many entries to skip, where initial old and new entries match
	NSUInteger oldEntriesCount = _entries.count;
	NSUInteger newEntriesCount = newEntries.count;
	NSUInteger skipIndex;
	for (skipIndex = 0; skipIndex < std::min(oldEntriesCount, newEntriesCount); ++skipIndex)
		if (newEntries[skipIndex] != _entries[skipIndex])
			break;
	
	// get an entry writer for each new entry
	NSMutableArray* newEntryWriters = [NSMutableArray array];
    
    [newEntries enumerateObjectsUsingBlock:^(ZZArchiveEntry *anEntry, NSUInteger index, BOOL* stop)
     {
         [newEntryWriters addObject:[anEntry newWriterCanSkipLocalFile:index < skipIndex]];
     }];
	
	// skip the initial matching entries
	uint32_t initialSkip = skipIndex > 0 ? [newEntryWriters[skipIndex - 1] offsetToLocalFileEnd] : 0;

	NSError* __autoreleasing underlyingError;

	// create a temp channel for all output
	id<ZZChannel> temporaryChannel = [_channel temporaryChannel:&underlyingError];
	if (!temporaryChannel)
		return ZZRaiseErrorNo(error, ZZOpenWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError});
	ZZScopeGuard temporaryChannelRemover(^{[temporaryChannel removeAsTemporary];});
	
	{
		// open the channel
		id<ZZChannelOutput> temporaryChannelOutput = [temporaryChannel newOutput:&underlyingError];
		if (!temporaryChannelOutput)
			return ZZRaiseErrorNo(error, ZZOpenWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError});
		ZZScopeGuard temporaryChannelOutputCloser(^{[temporaryChannelOutput close];});
	
		// write out local files
		for (NSUInteger index = skipIndex; index < newEntriesCount; ++index)
			if (![newEntryWriters[index] writeLocalFileToChannelOutput:temporaryChannelOutput
																	  withInitialSkip:initialSkip
																				error:&underlyingError])
				return ZZRaiseErrorNo(error, ZZLocalFileWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError, ZZEntryIndexKey : @(index)});
		
		ZZEndOfCentralDirectory endOfCentralDirectory;
		endOfCentralDirectory.signature = ZZEndOfCentralDirectory::sign;
		endOfCentralDirectory.numberOfThisDisk
			= endOfCentralDirectory.numberOfTheDiskWithTheStartOfTheCentralDirectory
			= 0;
		endOfCentralDirectory.totalNumberOfEntriesInTheCentralDirectoryOnThisDisk
			= endOfCentralDirectory.totalNumberOfEntriesInTheCentralDirectory
			= newEntriesCount;
		endOfCentralDirectory.offsetOfStartOfCentralDirectoryWithRespectToTheStartingDiskNumber = [temporaryChannelOutput offset] + initialSkip;
		
		// write out central file headers
		for (NSUInteger index = 0; index < newEntriesCount; ++index)
			if (![newEntryWriters[index] writeCentralFileHeaderToChannelOutput:temporaryChannelOutput
																						error:&underlyingError])
				return ZZRaiseErrorNo(error, ZZCentralFileHeaderWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError, ZZEntryIndexKey : @(index)});
		
		endOfCentralDirectory.sizeOfTheCentralDirectory = [temporaryChannelOutput offset] + initialSkip
			- endOfCentralDirectory.offsetOfStartOfCentralDirectoryWithRespectToTheStartingDiskNumber;
		endOfCentralDirectory.zipFileCommentLength = 0;
		
		// write out the end of central directory
		if (![temporaryChannelOutput writeData:[NSData dataWithBytesNoCopy:&endOfCentralDirectory
																	length:sizeof(endOfCentralDirectory)
															  freeWhenDone:NO]
										 error:&underlyingError])
			return ZZRaiseErrorNo(error, ZZEndOfCentralDirectoryWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError});
	}
	
	if (initialSkip)
	{
		// something skipped, append the temporary channel contents at the skipped offset
		id<ZZChannelOutput> channelOutput = [_channel newOutput:&underlyingError];
		if (!channelOutput)
			return ZZRaiseErrorNo(error, ZZReplaceWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError});
		ZZScopeGuard channelOutputCloser(^{[channelOutput close];});

		NSData* channelInput = [temporaryChannel newInput:&underlyingError];
		if (!channelInput
			|| ![channelOutput seekToOffset:initialSkip
									  error:&underlyingError]
			|| ![channelOutput writeData:channelInput
								   error:&underlyingError]
			|| ![channelOutput truncateAtOffset:[channelOutput offset]
										  error:&underlyingError])
			return ZZRaiseErrorNo(error, ZZReplaceWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError});
		
	}
	else
		// nothing skipped, temporary channel is entire contents: simply replace the original
		if (![_channel replaceWithChannel:temporaryChannel
									error:&underlyingError])
			return ZZRaiseErrorNo(error, ZZReplaceWriteErrorCode, @{NSUnderlyingErrorKey : underlyingError});
	
	// reload entries + content
	return [self loadCanMiss:NO error:error];
}

@end

