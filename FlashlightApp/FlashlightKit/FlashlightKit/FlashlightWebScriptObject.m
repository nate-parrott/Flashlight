//
//  FlashlightWebScriptObject.m
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "FlashlightWebScriptObject.h"
#import <AppKit/AppKit.h>

@interface _Flashlight_DummyClass : NSObject

@end

@implementation _Flashlight_DummyClass

- (void)openTargetResultWithOptions:(unsigned long long)ops {
    
}

@end


@implementation FlashlightWebScriptObject

- (NSString *)bash:(NSString*) args {
    NSPipe *pipeIn = [NSPipe pipe];
    NSPipe *pipeOut = [NSPipe pipe];
    NSFileHandle *file = pipeOut.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = [NSArray arrayWithObjects:@"-l", @"-c", args, nil];
    task.standardInput = pipeIn;
    task.standardOutput = pipeOut;
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return grepOutput;
}

- (void)invoke {
    NSObject *appDelegate = [NSApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(openTargetResultWithOptions:)]) {
        [(id)appDelegate openTargetResultWithOptions:0];
    }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
    if(sel == @selector(bash:))
        return NO;
    if(sel == @selector(invoke))
        return NO;
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
    if(sel == @selector(bash:))
        return @"bash";
    return nil;
}

@end
