//
//  ZZOldArchiveEntry.m
//  zipzap
//
//  Created by Glen Low on 24/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//
//

#include <zlib.h>

#import "ZZDataProvider.h"
#import "ZZError.h"
#import "ZZInflateInputStream.h"
#import "ZZOldArchiveEntry.h"
#import "ZZOldArchiveEntryWriter.h"
#import "ZZHeaders.h"
#import "ZZArchiveEntryWriter.h"
#import "ZZScopeGuard.h"
#import "ZZStandardDecryptInputStream.h"
#import "ZZAESDecryptInputStream.h"
#import "ZZConstants.h"

@interface ZZOldArchiveEntry ()

- (NSData*)fileData;
- (NSString*)stringWithBytes:(uint8_t*)bytes length:(NSUInteger)length;

- (BOOL)checkEncryptionAndCompression:(out NSError**)error;
- (NSInputStream*)streamForData:(NSData*)data withPassword:(NSString*)password error:(out NSError**)error;

@end

@implementation ZZOldArchiveEntry
{
	ZZCentralFileHeader* _centralFileHeader;
	ZZLocalFileHeader* _localFileHeader;
	NSStringEncoding _encoding;
	ZZEncryptionMode _encryptionMode;
}

- (id)initWithCentralFileHeader:(struct ZZCentralFileHeader*)centralFileHeader
				localFileHeader:(struct ZZLocalFileHeader*)localFileHeader
					   encoding:(NSStringEncoding)encoding
{
	if ((self = [super init]))
	{
		_centralFileHeader = centralFileHeader;
		_localFileHeader = localFileHeader;
		_encoding = encoding;
		
		if ((_centralFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::encrypted) != ZZGeneralPurposeBitFlag::none)
		{
			ZZWinZipAESExtraField *winZipAESRecord = _centralFileHeader->extraField<ZZWinZipAESExtraField>();
			if (winZipAESRecord)
				_encryptionMode = ZZEncryptionModeWinZipAES;
			else if ((_centralFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::encryptionStrong) != ZZGeneralPurposeBitFlag::none)
				_encryptionMode = ZZEncryptionModeStrong;
			else
				_encryptionMode = ZZEncryptionModeStandard;
		}
		else
			_encryptionMode = ZZEncryptionModeNone;
	}
	return self;
}


- (NSData*)fileData
{
	uint8_t* dataStart = _localFileHeader->fileData();
	NSUInteger dataLength = _centralFileHeader->compressedSize;
	
	// adjust for any standard encryption header
	if (_encryptionMode == ZZEncryptionModeStandard)
	{
		dataStart += 12;
		dataLength -= 12;
	}
	else if (_encryptionMode == ZZEncryptionModeWinZipAES)
	{
		ZZWinZipAESExtraField *winZipAESRecord = _localFileHeader->extraField<ZZWinZipAESExtraField>();
		if (winZipAESRecord)
		{
			size_t saltLength = getSaltLength(winZipAESRecord->encryptionStrength);
			dataStart += saltLength + 2; // saltLength + password verifier length
			dataLength -= saltLength + 2 + 10; // saltLength + password verifier + authentication stuff
		}
	}

	return [NSData dataWithBytesNoCopy:dataStart length:dataLength freeWhenDone:NO];
}

- (NSString*)stringWithBytes:(uint8_t*)bytes length:(NSUInteger)length
{
	// if EFS bit is set, use UTF-8; otherwise use fallback encoding
	return [[NSString alloc] initWithBytes:bytes
									length:length
								  encoding:(_centralFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::fileNameUTF8Encoded) == ZZGeneralPurposeBitFlag::none ? _encoding :NSUTF8StringEncoding];
}

- (ZZCompressionMethod)compressionMethod
{
    if (_encryptionMode == ZZEncryptionModeWinZipAES)
	{
		ZZWinZipAESExtraField *winZipAESRecord = _centralFileHeader->extraField<ZZWinZipAESExtraField>();
		if (winZipAESRecord)
			return winZipAESRecord->compressionMethod;
	}
	return _centralFileHeader->compressionMethod;
}

- (BOOL)compressed
{
	return self.compressionMethod != ZZCompressionMethod::stored;
}

- (BOOL)encrypted
{
	return (_centralFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::encrypted) != ZZGeneralPurposeBitFlag::none;
}

- (NSDate*)lastModified
{
	// convert last modified MS-DOS time, date into a Foundation date
	
	NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
	dateComponents.second = (_centralFileHeader->lastModFileTime & 0x1F) << 1;
	dateComponents.minute = (_centralFileHeader->lastModFileTime & 0x7E0) >> 5;
	dateComponents.hour = (_centralFileHeader->lastModFileTime & 0xF800) >> 11;
	dateComponents.day = _centralFileHeader->lastModFileDate & 0x1F;
	dateComponents.month = (_centralFileHeader->lastModFileDate & 0x1E0) >> 5;
	dateComponents.year = ((_centralFileHeader->lastModFileDate & 0xFE00) >> 9) + 1980;
	
	return [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] dateFromComponents:dateComponents];
}

- (NSUInteger)crc32
{
	return _centralFileHeader->crc32;
}

- (NSUInteger)compressedSize
{
	return _centralFileHeader->compressedSize;
}

- (NSUInteger)uncompressedSize
{
	return _centralFileHeader->uncompressedSize;
}

- (mode_t)fileMode
{
	uint32_t externalFileAttributes = _centralFileHeader->externalFileAttributes;
	switch (_centralFileHeader->fileAttributeCompatibility)
	{
		case ZZFileAttributeCompatibility::msdos:
		case ZZFileAttributeCompatibility::ntfs:
			// if we have MS-DOS or NTFS file attributes, synthesize UNIX ones from them
			return S_IRUSR | S_IRGRP | S_IROTH
				| (externalFileAttributes & static_cast<uint32_t>(ZZMSDOSAttributes::readonly) ? 0 : S_IWUSR)
            | (externalFileAttributes & (static_cast<uint32_t>(ZZMSDOSAttributes::subdirectory) | static_cast<uint32_t>(ZZMSDOSAttributes::volume)) ? S_IFDIR | S_IXUSR | S_IXGRP | S_IXOTH : S_IFREG);
		case ZZFileAttributeCompatibility::unix:
			// if we have UNIX file attributes, they are in the high 16 bits
			return externalFileAttributes >> 16;
		default:
			return 0;
	}
}

- (NSString*)fileName
{
	return [self stringWithBytes:_centralFileHeader->fileName()
						  length:_centralFileHeader->fileNameLength];
}

- (BOOL)check:(out NSError**)error
{
	// descriptor fields either from local file header or data descriptor
	uint32_t dataDescriptorSignature;
	uint32_t localCrc32;
	uint32_t localCompressedSize;
	uint32_t localUncompressedSize;
	if ((_localFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::sizeInDataDescriptor) == ZZGeneralPurposeBitFlag::none)
	{
		dataDescriptorSignature = ZZDataDescriptor::sign;
		localCrc32 = _localFileHeader->crc32;
		localCompressedSize = _localFileHeader->compressedSize;
		localUncompressedSize = _localFileHeader->uncompressedSize;
	}
	else
	{
		const ZZDataDescriptor* dataDescriptor = _localFileHeader->dataDescriptor(_localFileHeader->compressedSize);
		dataDescriptorSignature = dataDescriptor->signature;
		localCrc32 = dataDescriptor->crc32;
		localCompressedSize = dataDescriptor->compressedSize;
		localUncompressedSize = dataDescriptor->uncompressedSize;
	}
	
	// figure out local encryption mode
	ZZEncryptionMode localEncryptionMode;
	if ((_localFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::encrypted) != ZZGeneralPurposeBitFlag::none)
	{
		ZZWinZipAESExtraField *winZipAESRecord = _localFileHeader->extraField<ZZWinZipAESExtraField>();
		
		if (winZipAESRecord)
			localEncryptionMode = ZZEncryptionModeWinZipAES;
		else if ((_localFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::encryptionStrong) != ZZGeneralPurposeBitFlag::none)
			localEncryptionMode = ZZEncryptionModeStrong;
		else
			localEncryptionMode = ZZEncryptionModeStandard;
	}
	else
		localEncryptionMode = ZZEncryptionModeNone;
	
	// sanity check:
	if (
		// correct signature
		_localFileHeader->signature != ZZLocalFileHeader::sign
		// general fields in local and central headers match
		|| _localFileHeader->versionNeededToExtract != _centralFileHeader->versionNeededToExtract
		|| _localFileHeader->generalPurposeBitFlag != _centralFileHeader->generalPurposeBitFlag
		|| _localFileHeader->compressionMethod != self.compressionMethod
		|| _localFileHeader->lastModFileDate != _centralFileHeader->lastModFileDate
		|| _localFileHeader->lastModFileTime != _centralFileHeader->lastModFileTime
		|| _localFileHeader->fileNameLength != _centralFileHeader->fileNameLength
		// file name in local and central headers match
		|| memcmp(_localFileHeader->fileName(), _centralFileHeader->fileName(), _localFileHeader->fileNameLength) != 0
		// descriptor fields in local and central headers match
		|| dataDescriptorSignature != ZZDataDescriptor::sign
		|| localCrc32 != _centralFileHeader->crc32
		|| localCompressedSize != _centralFileHeader->compressedSize
		|| localUncompressedSize != _centralFileHeader->uncompressedSize
		|| localEncryptionMode != _encryptionMode)
		return ZZRaiseErrorNo(error, ZZLocalFileReadErrorCode, nil);
	
	if (_encryptionMode == ZZEncryptionModeStandard)
	{
		// validate encrypted CRC (?)
		unsigned char crcBytes[4];
		memcpy(&crcBytes[0], &_centralFileHeader->crc32, 4);
		
		crcBytes[3] = (crcBytes[3] & 0xFF);
		crcBytes[2] = ((crcBytes[3] >> 8) & 0xFF);
		crcBytes[1] = ((crcBytes[3] >> 16) & 0xFF);
		crcBytes[0] = ((crcBytes[3] >> 24) & 0xFF);
		
		if (crcBytes[2] > 0 || crcBytes[1] > 0 || crcBytes[0] > 0)
			return ZZRaiseErrorNo(error, ZZInvalidCRChecksum, @{});
	}
	
	return YES;
}

- (BOOL)checkEncryptionAndCompression:(out NSError**)error
{
	switch (_encryptionMode)
	{
		case ZZEncryptionModeNone:
		case ZZEncryptionModeStandard:
		case ZZEncryptionModeWinZipAES:
			break;
		default:
			return ZZRaiseErrorNo(error, ZZUnsupportedEncryptionMethod, @{});
	}
	
	switch (self.compressionMethod)
	{
		case ZZCompressionMethod::stored:
		case ZZCompressionMethod::deflated:
			break;
		default:
			return ZZRaiseErrorNo(error, ZZUnsupportedCompressionMethod, @{});
	}
	
	return YES;
}

- (NSInputStream*)streamForData:(NSData*)data withPassword:(NSString*)password error:(out NSError**)error
{
	// We need to output an error, becase in AES we have (most of the time) knowledge about the password verification even before starting to decrypt. So we should not supply a stream when we KNOW that the password is wrong.
	
	NSInputStream* dataStream = [NSInputStream inputStreamWithData:data];
	
	// decrypt if needed
	NSInputStream* decryptedStream;
	switch (_encryptionMode)
	{
		case ZZEncryptionModeNone:
			decryptedStream = dataStream;
			break;
		case ZZEncryptionModeStandard:
			// to check the password: if CRC32 in data descriptor, use lastModFileTime; otherwise use high word of CRC32
			decryptedStream = [[ZZStandardDecryptInputStream alloc] initWithStream:dataStream
																		  password:password
																			header:_localFileHeader->fileData()
																			 check:(_centralFileHeader->generalPurposeBitFlag & ZZGeneralPurposeBitFlag::sizeInDataDescriptor) == ZZGeneralPurposeBitFlag::none ? (_centralFileHeader->crc32 >> 16) : _centralFileHeader->lastModFileTime
																		   version:_centralFileHeader->versionMadeBy
																			 error:error];
			break;
		case ZZEncryptionModeWinZipAES:
			decryptedStream = [[ZZAESDecryptInputStream alloc] initWithStream:dataStream
																	 password:password
																	   header:_localFileHeader->fileData()
																	 strength:_localFileHeader->extraField<ZZWinZipAESExtraField>()->encryptionStrength
																		error:error];
			break;
		default:
			decryptedStream = nil;
			break;
	}
	if (!decryptedStream)
		return nil;

	// decompress if needed
	NSInputStream* decompressedDecryptedStream;
	switch (self.compressionMethod)
	{
		case ZZCompressionMethod::stored:
			decompressedDecryptedStream = decryptedStream;
			break;
		case ZZCompressionMethod::deflated:
			decompressedDecryptedStream = [[ZZInflateInputStream alloc] initWithStream:decryptedStream];
			break;
		default:
			decompressedDecryptedStream = nil;
			break;
	}
	
	return decompressedDecryptedStream;
}

- (NSInputStream*)newStreamWithPassword:(NSString*)password error:(out NSError**)error
{
	if (![self checkEncryptionAndCompression:error])
		return nil;

	NSData* fileData = [self fileData];
	return [self streamForData:fileData withPassword:password error:error];
}

- (NSData*)newDataWithPassword:(NSString*)password error:(out NSError**)error
{
	if (![self checkEncryptionAndCompression:error])
		return nil;
	
	NSData* fileData = [self fileData];
	
	if (_encryptionMode == ZZEncryptionModeNone)
		switch (self.compressionMethod)
		{
			case ZZCompressionMethod::stored:
				// unencrypted, stored: just return as-is. Make sure to create a new object since [NSData copy] returns the same object on pre-10.9 systems.
				return [[NSData alloc] initWithBytes:fileData.bytes length:fileData.length];
			case ZZCompressionMethod::deflated:
				// unencrypted, deflated: inflate in one go
				return [ZZInflateInputStream decompressData:fileData
									   withUncompressedSize:_centralFileHeader->uncompressedSize];
			default:
				return nil;
		}
	else
	{
		NSInputStream* stream = [self streamForData:fileData withPassword:password error:error];
		if (!stream) return nil;
		
		NSMutableData* data = [NSMutableData dataWithLength:_centralFileHeader->uncompressedSize];
		
		[stream open];
		ZZScopeGuard streamCloser(^{[stream close];});
		
		// read until all decompressed or EOF (should not happen since we know uncompressed size) or error
		NSUInteger totalBytesRead = 0;
		while (totalBytesRead < _centralFileHeader->uncompressedSize)
		{
			NSInteger bytesRead = [stream read:(uint8_t*)data.mutableBytes + totalBytesRead
									 maxLength:_centralFileHeader->uncompressedSize - totalBytesRead];
			if (bytesRead > 0)
				totalBytesRead += bytesRead;
			else
				break;
		}
		if (stream.streamError)
		{
			if (error)
				*error = stream.streamError;
			return nil;
		}
		return data;
	}
}

- (CGDataProviderRef)newDataProviderWithPassword:(NSString*)password error:(out NSError**)error
{
	if (![self checkEncryptionAndCompression:error])
		return nil;

	NSData* fileData = [self fileData];
	
	if (self.compressionMethod == ZZCompressionMethod::stored && _encryptionMode == ZZEncryptionModeNone)
		// simple data provider that just wraps the data.  Make sure to create a new object since [NSData copy] returns the same object on pre-10.9 systems.
		return CGDataProviderCreateWithCFData((__bridge CFDataRef)[[NSData alloc] initWithBytes:fileData.bytes length:fileData.length]);
	else
		return ZZDataProvider::create(^
									  {
										  // FIXME: How do we handle the error here?
										  return [self streamForData:fileData withPassword:password error:nil];
									  });
}

- (id<ZZArchiveEntryWriter>)newWriterCanSkipLocalFile:(BOOL)canSkipLocalFile
{
	return [[ZZOldArchiveEntryWriter alloc] initWithCentralFileHeader:_centralFileHeader
												  localFileHeader:_localFileHeader
											  shouldSkipLocalFile:canSkipLocalFile];
}

@end
