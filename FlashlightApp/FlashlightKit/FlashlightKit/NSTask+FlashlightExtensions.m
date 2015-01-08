//
//  NSTask+FlashlightExtensions.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "NSTask+FlashlightExtensions.h"
#import <sys/stat.h>

void _flashlight_markPathExecutable(NSString *path) {
    // make launch path executable:
    struct stat buf;
    int error = stat([path fileSystemRepresentation], &buf);
    /* check and handle error */
    
    /* Make the file user-executable. */
    mode_t mode = buf.st_mode;
    if (!(mode & S_IXUSR)) {
        mode |= S_IXUSR;
        error = chmod([path fileSystemRepresentation], mode);
    }
}

@interface FlashlightFileReader : NSObject

@property (nonatomic) NSFileHandle *fileHandle;
@property (nonatomic) NSMutableData *data;

@end

@implementation FlashlightFileReader

- (id)initWithFileHandle:(NSFileHandle *)handle {
    self = [super init];
    self.fileHandle = handle;
    self.data = [NSMutableData new];
    __weak FlashlightFileReader *weakSelf = self;
    self.fileHandle.readabilityHandler = ^(NSFileHandle *_) {
        [weakSelf.data appendData:weakSelf.fileHandle.availableData];
    };
    return self;
}

- (NSData *)allData {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.data appendData:[self.fileHandle readDataToEndOfFile]];
        self.fileHandle.readabilityHandler = nil;
    });
    return self.data;
}

@end



@implementation NSTask (FlashlightExtensions)

+ (NSTask *)withPathMarkedAsExecutableIfNecessary:(NSString *)path {
    _flashlight_markPathExecutable(path);
    NSTask *task = [NSTask new];
    task.launchPath = path;
    return task;
}

- (void)launchWithTimeout:(NSTimeInterval)timeout callback:(FlashlightNSTaskCallback)callback {
    NSPipe *errorPipe = [NSPipe pipe];
    self.standardError = errorPipe;
    FlashlightFileReader *errorReader = [[FlashlightFileReader alloc] initWithFileHandle:errorPipe.fileHandleForReading];
    
    NSPipe *stdoutPipe = [NSPipe pipe];
    self.standardOutput = stdoutPipe;
    FlashlightFileReader *outputReader = [[FlashlightFileReader alloc] initWithFileHandle:stdoutPipe.fileHandleForReading];
    
    void (^onDone)() = ^{
        NSData *errorData = [errorReader allData];
        NSData *data = [outputReader allData];
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
