//
//  ZZError.h
//  zipzap
//
//  Created by Glen Low on 25/01/13.
//  Copyright (c) 2013, Pixelglow Software. All rights reserved.
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

#import <Foundation/Foundation.h>

/**
 * The domain of zipzap errors.
 */
extern NSString* const ZZErrorDomain;

/**
 * The index of the erroneous entry.
 */
extern NSString* const ZZEntryIndexKey;

typedef NS_ENUM(NSInteger, ZZErrorCode)
{
	/**
	 * Cannot open an archive for reading.
	 */
	ZZOpenReadErrorCode,
	
	/**
	 * Cannot read the end of central directory.
	 */
	ZZEndOfCentralDirectoryReadErrorCode,
	
	/**
	 * Cannot read a central file header.
	 */
	ZZCentralFileHeaderReadErrorCode,
	
	/**
	 * Cannot read a local file.
	 */
	ZZLocalFileReadErrorCode,
	
	/**
	 * Cannot open an archive for writing.
	 */
	ZZOpenWriteErrorCode,
	
	/**
	 * Cannot write a local file.
	 */
	ZZLocalFileWriteErrorCode,
	
	/**
	 * Cannot write a central file header.
	 */
	ZZCentralFileHeaderWriteErrorCode,
	
	/**
	 * Cannot write the end of central directory.
	 */
	ZZEndOfCentralDirectoryWriteErrorCode,
    
	/**
	 * Cannot replace the zip file after writing.
	 */
	ZZReplaceWriteErrorCode,
	
	/**
	 * The compression used is currently unsupported.
	 */
	ZZUnsupportedCompressionMethod,
    
	/**
	 * The encryption used is currently unsupported.
	 */
	ZZUnsupportedEncryptionMethod,
    
	/**
	 * An invalid CRC checksum has been encountered.
	 */
	ZZInvalidCRChecksum,
    
	/**
	 * The wrong key was passed in.
	 */
	ZZWrongPassword
};

static inline BOOL ZZRaiseErrorNo(NSError** error, ZZErrorCode errorCode, NSDictionary* userInfo)
{
	if (error)
		*error = [NSError errorWithDomain:ZZErrorDomain
									 code:errorCode
								 userInfo:userInfo];
	return NO;
}

static inline id ZZRaiseErrorNil(NSError** error, ZZErrorCode errorCode, NSDictionary* userInfo)
{
	if (error)
		*error = [NSError errorWithDomain:ZZErrorDomain
									 code:errorCode
								 userInfo:userInfo];
	return nil;
}

