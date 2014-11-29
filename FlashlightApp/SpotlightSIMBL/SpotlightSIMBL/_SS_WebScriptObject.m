//
//  _SS_WebScriptObject.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/29/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_SS_WebScriptObject.h"

@implementation _SS_WebScriptObject

- (NSString *)bash:(NSString*) args {
    NSPipe *pipeIn = [NSPipe pipe];
    NSPipe *pipeOut = [NSPipe pipe];
    NSFileHandle *file = pipeOut.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = [NSArray arrayWithObjects:@"-l", @"-c", args, nil];
    task.standardInput = pipeIn;
    task.standardOutput = pipeOut;
    
    [task waitUntilExit];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return grepOutput;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
    if(sel == @selector(bash:))
        return NO;
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
    if(sel == @selector(bash:))
        return @"bash";
    return nil;
}

@end
