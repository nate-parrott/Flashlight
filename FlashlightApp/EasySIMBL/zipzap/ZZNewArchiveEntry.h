//
//  ZZNewArchiveEntry.h
//  zipzap
//
//  Created by Glen Low on 8/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#include <CoreGraphics/CoreGraphics.h>
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#include <ApplicationServices/ApplicationServices.h>
#endif

#import <Foundation/Foundation.h>

#import "ZZArchiveEntry.h"

@interface ZZNewArchiveEntry : ZZArchiveEntry

@property (readonly, nonatomic) BOOL compressed;
@property (readonly, nonatomic) NSDate* lastModified;
@property (readonly, nonatomic) mode_t fileMode;
@property (readonly, nonatomic) NSString* fileName;

- (id)initWithFileName:(NSString*)fileName
			  fileMode:(mode_t)fileMode
		  lastModified:(NSDate*)lastModified
	  compressionLevel:(NSInteger)compressionLevel
			 dataBlock:(NSData*(^)(NSError** error))dataBlock
		   streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock
	 dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;

@end
