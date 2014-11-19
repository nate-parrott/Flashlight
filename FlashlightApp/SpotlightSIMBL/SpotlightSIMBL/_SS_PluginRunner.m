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
#import "NSTask+_FlashlightExtensions.h"

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

+ (NSString *)pathForPlugin:(NSString *)pluginName {
    return [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library/FlashlightPlugins"] stringByAppendingPathComponent:pluginName] stringByAppendingPathExtension:@"bundle"];
}

+ (NSDictionary *)resultDictionariesFromPluginsForQuery:(NSString *)query {
    
    NSTask *task = [NSTask new];
    task.launchPath = [self parseQueryScriptPath];
    __SS_markPathExecutable(task.launchPath);
    
    task.currentDirectoryPath = [self naturalCommandScriptsDir];
    task.arguments = @[query, [self supplementalTaggingJSONForQuery:query]];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    [task launchWithTimeout:2 consoleLabelForErrorDump:@"Querying Flashlight plugins"];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
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
    [task launchWithTimeout:0 consoleLabelForErrorDump:[NSString stringWithFormat:@"Running action for Flashlight plugin '%@'", pluginName]];
}

#pragma mark Supplemental Tagging
+ (NSString *)supplementalTaggingJSONForQuery:(NSString *)query {
    NSLinguisticTaggerOptions options = NSLinguisticTaggerJoinNames|NSLinguisticTaggerOmitWhitespace;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = query;
    NSMutableDictionary *training = [NSMutableDictionary new];
    [tagger enumerateTagsInRange:NSMakeRange(0, query.length) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *key = [@"_" stringByAppendingString:tag];
        if (!training[key]) training[key] = [NSMutableArray new];
        [training[key] addObject:[tagger.string substringWithRange:tokenRange]];
    }];
    NSString *trainingString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:training options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSLog(@"SUP: %@", trainingString);
    return trainingString;
}

@end
