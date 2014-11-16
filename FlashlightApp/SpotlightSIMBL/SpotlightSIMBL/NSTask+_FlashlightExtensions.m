//
//  NSTask+_FlashlightExtensions.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "NSTask+_FlashlightExtensions.h"

@implementation NSTask (_FlashlightExtensions)

- (void)launchWithTimeout:(NSTimeInterval)timeout consoleLabelForErrorDump:(NSString *)label {
    NSPipe *errorPipe = [NSPipe pipe];
    self.standardError = errorPipe;
    void (^onDone)() = ^{
        NSData *errorData = [[errorPipe fileHandleForReading] availableData];
        if (errorData.length) {
            NSLog(@"%@:\n%@", label, [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
        }
        if ([self isRunning]) {
            [self terminate];
            NSLog(@"%@: [timed out]", label);
        }
    };
    
    if (timeout) {
        [self launch];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onDone();
        });
    } else {
        self.terminationHandler = ^(NSTask *t){
            onDone();
        };
        [self launch];
    }
}

@end
