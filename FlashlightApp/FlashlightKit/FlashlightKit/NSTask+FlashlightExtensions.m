//
//  NSTask+FlashlightExtensions.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "NSTask+FlashlightExtensions.h"

@implementation NSTask (FlashlightExtensions)

- (void)launchWithTimeout:(NSTimeInterval)timeout callback:(FlashlightNSTaskCallback)callback {
    NSPipe *errorPipe = [NSPipe pipe];
    self.standardError = errorPipe;
    NSPipe *stdoutPipe = [NSPipe pipe];
    self.standardOutput = stdoutPipe;
    void (^onDone)() = ^{
        NSData *errorData = [[errorPipe fileHandleForReading] availableData];
        NSData *data = [[stdoutPipe fileHandleForReading] readDataToEndOfFile];
        callback(data, errorData);
    };
    
    self.terminationHandler = ^(NSTask *t){
        onDone();
    };
    [self launch];
    
    if (timeout) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self safeTerminate];
        });
    }
}

- (void)safeTerminate {
    // TODO: make this better
    if ([self isRunning]) {
        [self terminate];
    }
}

@end
