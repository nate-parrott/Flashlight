//
//  ZZArchiveEntry.m
//  zipzap
//
//  Created by Glen Low on 25/09/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#include <fcntl.h>

#import "ZZArchiveEntry.h"
#import "ZZNewArchiveEntry.h"

@implementation ZZArchiveEntry

+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
				  compress:(BOOL)compress
				 dataBlock:(NSData*(^)(NSError** error))dataBlock
{
	return [self archiveEntryWithFileName:fileName
								 fileMode:S_IFREG | S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
							 lastModified:[NSDate date]
						 compressionLevel:compress ? -1 : 0
								dataBlock:dataBlock
							  streamBlock:nil
						dataConsumerBlock:nil];
}

+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								compress:(BOOL)compress
							 streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock
{
	return [self archiveEntryWithFileName:fileName
								 fileMode:S_IFREG | S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
							 lastModified:[NSDate date]
						 compressionLevel:compress ? -1 : 0
								dataBlock:nil
							  streamBlock:streamBlock
						dataConsumerBlock:nil];
}

+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								compress:(BOOL)compress
					   dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock
{
	return [self archiveEntryWithFileName:fileName
								 fileMode:S_IFREG | S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
							 lastModified:[NSDate date]
						 compressionLevel:compress ? -1 : 0
								dataBlock:nil
							  streamBlock:nil
						dataConsumerBlock:dataConsumerBlock];
}

+ (instancetype)archiveEntryWithDirectoryName:(NSString*)directoryName
{
	return [self archiveEntryWithFileName:directoryName
								 fileMode:S_IFDIR | S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH
							 lastModified:[NSDate date]
						 compressionLevel:0
								dataBlock:nil
							  streamBlock:nil
						dataConsumerBlock:nil];
}

+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								fileMode:(mode_t)fileMode
							lastModified:(NSDate*)lastModified
						compressionLevel:(NSInteger)compressionLevel
							   dataBlock:(NSData*(^)(NSError** error))dataBlock
							 streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock
					   dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock
{
	return [[ZZNewArchiveEntry alloc] initWithFileName:fileName
										  fileMode:fileMode
									  lastModified:lastModified
								  compressionLevel:compressionLevel
										 dataBlock:dataBlock
									   streamBlock:streamBlock
								 dataConsumerBlock:dataConsumerBlock];
}

- (BOOL)compressed
{
	return NO;
}

- (BOOL)encrypted
{
	return NO;
}

- (NSDate*)lastModified
{
	return nil;
}

- (NSUInteger)crc32
{
	return 0;
}

- (NSUInteger)compressedSize
{
	return 0;
}

- (NSUInteger)uncompressedSize
{
	return 0;
}

- (mode_t)fileMode
{
	return 0;
}

- (NSString*)fileName
{
	return nil;
}

- (NSInputStream*)newStreamWithError:(NSError**)error
{
	return [self newStreamWithPassword:nil error:error];
}

- (NSInputStream*)newStreamWithPassword:(NSString*)password error:(NSError**)error
{
	return nil;
}

- (BOOL)check:(NSError**)error
{
	return YES;
}

- (NSData*)newDataWithError:(NSError**)error
{
	return [self newDataWithPassword:nil error:error];
}

- (NSData*)newDataWithPassword:(NSString*)password error:(NSError**)error
{
	return nil;
}

- (CGDataProviderRef)newDataProviderWithError:(NSError**)error
{
	return [self newDataProviderWithPassword:nil error:error];
}

- (CGDataProviderRef)newDataProviderWithPassword:(NSString*)password error:(NSError**)error
{
	return nil;
}

- (id<ZZArchiveEntryWriter>)newWriterCanSkipLocalFile:(BOOL)canSkipLocalFile
{
	return nil;
}

@end
