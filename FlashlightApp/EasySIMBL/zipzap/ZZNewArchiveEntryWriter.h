//
//  ZZNewArchiveEntryWriter.h
//  zipzap
//
//  Created by Glen Low on 9/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZZArchiveEntryWriter.h"

@interface ZZNewArchiveEntryWriter : NSObject <ZZArchiveEntryWriter>

- (id)initWithFileName:(NSString*)fileName
			  fileMode:(mode_t)fileMode
		  lastModified:(NSDate*)lastModified
	  compressionLevel:(NSInteger)compressionLevel
			 dataBlock:(NSData*(^)(NSError** error))dataBlock
		   streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock
	 dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;

- (uint32_t)offsetToLocalFileEnd;
- (BOOL)writeLocalFileToChannelOutput:(id<ZZChannelOutput>)channelOutput
					  withInitialSkip:(uint32_t)initialSkip
								error:(out NSError**)error;
- (BOOL)writeCentralFileHeaderToChannelOutput:(id<ZZChannelOutput>)channelOutput
										error:(out NSError**)error;

@end

