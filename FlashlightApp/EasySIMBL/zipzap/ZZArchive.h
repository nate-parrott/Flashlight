//
//  ZZArchive.h
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

#import <Foundation/Foundation.h>
#import "ZZConstants.h"

/**
 * The ZZArchive class represents a zip file for reading only.
 */
@interface ZZArchive : NSObject

/**
 * The URL representing this archive.
 */
@property (readonly, nonatomic) NSURL* URL;

/**
 * The uninterpreted contents of this archive.
 */
@property (readonly, nonatomic) NSData* contents;

/**
 * The array of ZZArchiveEntry entries within this archive.
 */
@property (readonly, nonatomic) NSArray* entries;

/**
 * Creates a new archive with the zip file at the given file URL.
 *
 * The archive will use UTF-8 encoding for reading entry file names and comments, and will not create the file if it is missing.
 *
 * @param URL The file URL of the zip file.
 * @param error The error information when an error occurs. Pass in nil if you do not want error information.
 * @return The initialized archive. Returns nil if the archive cannot be initialized.
 */
+ (instancetype)archiveWithURL:(NSURL*)URL
						 error:(out NSError**)error;

/**
 * Creates a new archive with the raw zip file data given.
 *
 * The archive will use UTF-8 encoding for reading entry file names and comments, and will not create the data if it is missing.
 *
 * @param data The raw data of the zip file.
 * @param error The error information when an error occurs. Pass in nil if you do not want error information.
 * @return The initialized archive. Returns nil if the archive cannot be initialized.
 */
+ (instancetype)archiveWithData:(NSData*)data
						  error:(out NSError**)error;

/**
 * Initializes a new archive with the zip file at the given file URL.
 *
 * @param URL The file URL of the zip file.
 * @param options The options to consider when opening the zip file.
 * @param error The error information when an error occurs. Pass in nil if you do not want error information.
 * @return The initialized archive. Returns nil if the archive cannot be initialized.
 */
- (id)initWithURL:(NSURL*)URL
		  options:(NSDictionary*)options
			error:(out NSError**)error;

/**
 * Initializes a new archive with the raw zip file data given.
 *
 * @param data The raw data of the zip file
 * @param options The options to consider when opening the zip file.
 * @param error The error information when an error occurs. Pass in nil if you do not want error information.
 * @return The initialized archive. Returns nil if the archive cannot be initialized.
 */
- (id)initWithData:(NSData*)data
		   options:(NSDictionary*)options
			 error:(out NSError**)error;

/**
 * Updates the entries and writes them to the source.
 *
 * If the write fails and the entries are completely new, the existing zip file will be untouched.
 *
 * If the write fails and the entries contain some or all existing entries, the zip file may be corrupted.
 * In this case, the error information will report the ZZReplaceWriteErrorCode error code.
 *
 * @param newEntries The entries to update to, may contain some or all existing entries.
 * @param error The error information when an error occurs. Pass in nil if you do not want error information.
 * @return Whether the update was successful or not.
 *
 */
- (BOOL)updateEntries:(NSArray*)newEntries
				error:(out NSError**)error;

@end
