//
//  ZZArchiveEntry.h
//  zipzap
//
//  Created by Glen Low on 25/09/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#include <CoreGraphics/CoreGraphics.h>
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#include <ApplicationServices/ApplicationServices.h>
#endif

#import <Foundation/Foundation.h>

@protocol ZZArchiveEntryWriter;

/**
 * The ZZArchiveEntry class represents an entry in the ZZArchive instance.
 */
@interface ZZArchiveEntry : NSObject

/**
 * Whether the entry is compressed.
 */
@property (readonly, nonatomic) BOOL compressed;

/**
 * Whether the entry is encrypted.
 */
@property (readonly, nonatomic) BOOL encrypted;

/**
 * The last modified date and time of the entry. The time value is only accurate to 2 seconds.
 */
@property (readonly, nonatomic) NSDate* lastModified;

/**
 * The CRC32 code of the entry file: 0 for new entries.
 */
@property (readonly, nonatomic) NSUInteger crc32;

/**
 * The compressed size of the entry file: 0 for new entries.
 */
@property (readonly, nonatomic) NSUInteger compressedSize;

/**
 * The uncompressed size of the entry file: 0 for new entries.
 */
@property (readonly, nonatomic) NSUInteger uncompressedSize;

/**
 * The UNIX file mode for the entry: 0 for new or non-UNIX entries. This includes the file type bits.
 */
@property (readonly, nonatomic) mode_t fileMode;

/**
 * The file name of the entry.
 */
@property (readonly, nonatomic) NSString* fileName;

/**
 * Creates a new file entry from a streaming callback.
 *
 * @param fileName The file name for the entry.
 * @param compress Whether to compress the entry.
 * @param streamBlock The callback to write the entry's data to the stream. Returns whether the write should be considered successful.
 * @return The created entry.
 */
+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								compress:(BOOL)compress
							 streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock;

/**
 * Creates a new file entry from a data callback.
 *
 * @param fileName The file name for the entry.
 * @param compress Whether to compress the entry.
 * @param dataBlock The callback to return the entry's data. Returns nil if the write should be considered unsuccessful.
 * @return The created entry.
 */
+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								compress:(BOOL)compress
							   dataBlock:(NSData*(^)(NSError** error))dataBlock;

/**
 * Creates a new file entry from a data-consuming callback.
 *
 * @param fileName The file name for the entry.
 * @param compress Whether to compress the entry.
 * @param dataConsumerBlock The callback to put the entry's data into the data consumer. Returns whether the write should be considered successful.
 * @return The created entry.
 */
+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								compress:(BOOL)compress
					   dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;

/**
 * Creates a new directory entry.
 *
 * @param directoryName The directory name for the entry.
 * @return The created entry.
 */
+ (instancetype)archiveEntryWithDirectoryName:(NSString*)directoryName;

/**
 * Creates a new entry.
 *
 * The archive entry will choose the first non-nil dataBlock, streamBlock or dataConsumerBlock to supply its data.
 *
 * @param fileName The file name for the entry.
 * @param fileMode The UNIX file mode for the entry. This includes the file type bits.
 * @param lastModified The last modified date and time for the entry. The time value is only accurate to 2 seconds.
 * @param compressionLevel The compression level for the entry: 0 for stored, -1 for default deflate, 1 - 9 for custom deflate levels.
 * @param dataBlock The callback that returns the entry file data. Returns nil if the write should be considered unsuccessful.
 * @param streamBlock The callback that writes the entry file to the stream. Returns whether the write should be considered successful.
 * @param dataConsumerBlock The callback that writes the entry file to the data consumer. Returns whether the write should be considered successful.
 * @return The created entry.
 */
+ (instancetype)archiveEntryWithFileName:(NSString*)fileName
								fileMode:(mode_t)fileMode
							lastModified:(NSDate*)lastModified
						compressionLevel:(NSInteger)compressionLevel
							   dataBlock:(NSData*(^)(NSError** error))dataBlock
							 streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock
					   dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;

/**
 * Checks whether the entry file is consistent.
 *
 * Checks whether the local file entry is consistent with the central file entry and also that
 * the recorded and actual checksums of the data agree.
 *
 * @param error The error information when an error occurs. Pass in nil if you do not want error information.
 * @return Whether entry file is consistent or not.
 */
- (BOOL)check:(out NSError**)error;

/**
 * Creates a stream to represent the entry file.
 *
 * @param error A pointer to a variable that will contain the error if any.
 * @return The new stream: nil for new entries.
 */
- (NSInputStream*)newStreamWithError:(NSError**)error;

/**
 * Creates a stream to represent the entry file.
 *
 * @param password The password to be used for decryption.
 * @param error A pointer to a variable that will contain the error if any.
 * @return The new stream: nil for new entries.
 */
- (NSInputStream*)newStreamWithPassword:(NSString*)password error:(NSError**)error;

/**
 * Creates data to represent the entry file.
 *
 * @param error A pointer to a variable that will contain the error if any.
 * @return The new data: nil for new entries.
 */
- (NSData*)newDataWithError:(NSError**)error;

/**
 * Creates data to represent the entry file.
 *
 * @param password The password to be used for decryption.
 * @param error A pointer to a variable that will contain the error if any.
 * @return The new data: nil for new entries.
 */
- (NSData*)newDataWithPassword:(NSString*)password error:(NSError**)error;

/**
 * Creates a data provider to represent the entry file.
 *
 * @param error A pointer to a variable that will contain the error if any.
 * @return The new data provider: nil for new entries.
 */
- (CGDataProviderRef)newDataProviderWithError:(NSError**)error;

/**
 * Creates a data provider to represent the entry file.
 *
 * @param password The password to be used for decryption.
 * @param error A pointer to a variable that will contain the error if any.
 * @return The new data provider: nil for new entries.
 */
- (CGDataProviderRef)newDataProviderWithPassword:(NSString*)password error:(NSError**)error;

- (id<ZZArchiveEntryWriter>)newWriterCanSkipLocalFile:(BOOL)canSkipLocalFile;

@end
