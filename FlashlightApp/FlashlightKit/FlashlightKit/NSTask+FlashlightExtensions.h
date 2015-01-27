//
//  NSTask+FlashlightExtensions.h
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FlashlightNSTaskCallback)(NSData *stdoutData, NSData *stderrData);

@interface NSTask (FlashlightExtensions)

- (void)launchWithTimeout:(NSTimeInterval)timeout callback:(FlashlightNSTaskCallback)callback;

- (void)safeTerminate;

+ (NSTask *)withPathMarkedAsExecutableIfNecessary:(NSString *)path;

@end
