//
//  _SS_PluginRunner.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "_SS_PluginRunner.h"
#import <AppKit/AppKit.h>
#import <sys/stat.h>

void __SS_markPathExecutable(NSString *path) {
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


@implementation _SS_PluginRunner

+ (NSString *)naturalCommandScriptsDir {
    return [[[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.nateparrott.Flashlight"] path] stringByAppendingPathComponent:@"Contents/Resources/NaturalCommands"];
}

+ (NSString *)parseQueryScriptPath {
    return [[self naturalCommandScriptsDir] stringByAppendingPathComponent:@"parse_query.py"];
}

+ (NSString *)runPluginScriptPath {
    return [[self naturalCommandScriptsDir] stringByAppendingPathComponent:@"run.py"];
}

+ (NSDictionary *)resultDictionariesFromPluginsForQuery:(NSString *)query {
    NSTask *task = [NSTask new];
    task.launchPath = [self parseQueryScriptPath];
    __SS_markPathExecutable(task.launchPath);
    
    task.currentDirectoryPath = [self naturalCommandScriptsDir];
    task.arguments = @[query];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    NSPipe *errorPipe = [NSPipe pipe];
    task.standardError = errorPipe;
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    if (errorData.length) {
        NSLog(@"ERROR: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
    }
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    } else {
        return nil;
    }
}

+ (void)runQueryResultWithArgs:(id)runArgs sourcePlugin:(NSString *)pluginName {
    NSTask *task = [NSTask new];
    task.launchPath = [self runPluginScriptPath];
    __SS_markPathExecutable(task.launchPath);
    
    task.currentDirectoryPath = [[self runPluginScriptPath] stringByDeletingLastPathComponent];
    NSString *runArgsAsJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:runArgs options:0 error:nil] encoding:NSUTF8StringEncoding];
    task.arguments = @[pluginName, runArgsAsJson];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    [task launch];
}

@end
