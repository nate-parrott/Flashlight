//
//  PSFileSource.m
//  FlashlightKit
//
//  Created by Nate Parrott on 1/23/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PSFileSource.h"
#import <CoreServices/CoreServices.h>
#import "PSTaggedText+ParseExample.h"
#import "Parsnip.h"
#import "Finder.h"

@interface PSFileSource ()

@property (nonatomic, copy) PSParsnipDataCallback callback;

@end

@implementation PSFileSource

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback {
    self = [super initWithIdentifier:identifier callback:callback];
    self.callback = callback;
    [self update];
    return self;
}

- (void)update {
    PSParsnipFieldProcessor fieldProcessor = [self fieldProcessor];
    Parsnip *parsnip = [Parsnip new];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"~fileSearch(anything)" rootTag:@"@file"]]];
    
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"documentsDir(documents)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"applicationsDir(applications)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"trashDir(the trash)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"downloadsDir(downloads)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"picturesDir(pictures)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"musicDir(music)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"desktopDir(the desktop)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"theseFiles(this file)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"theseFiles(this)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"theseFiles(these files)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"thisFolder(this folder)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"thisFolder(this directory)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"thisFolder(here)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"filePath(/Users/ioehngoe/Library/eipgnio4ge.pdf)" rootTag:@"@file"]]];
    [parsnip learnExamples:@[[PSTaggedText withExampleString:@"at path filePath(~/Library/iehrgorheo.txt)" rootTag:@"@file"]]];
    
    self.callback(self.identifier, @{PSParsnipSourceDataParsnipKey: parsnip, PSParsnipSourceFieldProcessorsDictionaryKey: @{@"@file": fieldProcessor}});
}

- (PSParsnipFieldProcessor)fieldProcessor {
    return ^id(PSTaggedText *tagged) {
        
        NSDictionary *directoryNameToPathMap = [self directoryNameToPathMap];
        for (NSString *tag in directoryNameToPathMap) {
            if ([tagged findChild:tag]) {
                NSString *path = [directoryNameToPathMap[tag] stringByExpandingTildeInPath];
                return @{@"query": [tagged getText], @"path": path};
            }
        }
        
        if ([tagged findChild:@"filePath"]) {
            NSString *path = [[tagged findChild:@"filePath"] getText];
            // determine if this is a valid path (HACK)
            BOOL isValid = !![NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]].path;
            if (isValid) {
                return @{@"query": [tagged getText], @"path": path};
            }
        }
        
        NSArray *selectedPaths = nil;
        if ([tagged findChild:@"thisFolder"]) {
            selectedPaths = [[self class] selectedFinderItems:YES];
        } else if ([tagged findChild:@"theseFiles"]) {
            selectedPaths = [[self class] selectedFinderItems:NO];
        }
        if (selectedPaths) {
            NSString *firstPath = selectedPaths.firstObject;
            NSArray *otherPaths = [selectedPaths subarrayWithRange:NSMakeRange(MIN(1, selectedPaths.count), selectedPaths.count - MIN(1, selectedPaths.count))];
            return @{
                     @"query": tagged.getText,
                     @"path": firstPath ? : [NSNull null],
                     @"otherPaths": otherPaths
                     };
        }
        
        NSString *searchQuery = [[tagged findChild:@"~fileSearch"] getText] ? : [tagged getText];
        if (searchQuery) {
            MDQueryRef query = MDQueryCreate(kCFAllocatorDefault, (CFStringRef)[self MDQueryStringForSearch:searchQuery], nil, nil);
            MDQuerySetMaxCount(query, 10);
            MDQuerySetSearchScope(query, (CFArrayRef)@[(id)kMDQueryScopeComputerIndexed], 0);
            MDQuerySetSortOrder(query, (CFArrayRef)@[(id)kMDItemFSContentChangeDate]);
            MDQuerySetSortOptionFlagsForAttribute(query, kMDItemFSContentChangeDate, kMDQueryReverseSortOrderFlag);
            if (!MDQueryExecute(query, kMDQuerySynchronous)) {
                NSLog(@"Search failed.");
                return nil;
            }
            
            NSMutableArray *mdItems = [NSMutableArray new];
            for (NSInteger i=0; i<MDQueryGetResultCount(query); i++) {
                MDItemRef item = (MDItemRef)MDQueryGetResultAtIndex(query, i);
                [mdItems addObject:(__bridge id)item];
            }
            /*[mdItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *r1 = CFBridgingRelease(MDItemCopyAttribute((MDItemRef)obj1, kMDQueryResultContentRelevance));
                NSNumber *r2 = CFBridgingRelease(MDItemCopyAttribute((MDItemRef)obj2, kMDQueryResultContentRelevance));
                return [r2 compare:r1];
            }];*/
            NSArray *paths = [mdItems mapFilter:^id(id obj) {
                return CFBridgingRelease(MDItemCopyAttribute((MDItemRef)obj, kMDItemPath));
            }];
            paths = [[self class] sortPaths:paths];
            return @{
                     @"query": searchQuery,
                     @"path": paths.firstObject ? : [NSNull null],
                     @"otherPaths": paths.count > 1 ? [paths subarrayWithRange:NSMakeRange(1, paths.count - 1)] : @[]
                     };
        }
        return nil;
    };
}

- (NSDictionary *)directoryNameToPathMap {
    static NSMutableDictionary *directoryNameToPathMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *directoryNameToIDMap = @{@"documentsDir": @(NSDocumentDirectory),
                                               @"downloadsDir": @(NSDownloadsDirectory),
                                               @"picturesDir": @(NSPicturesDirectory),
                                               @"musicDir": @(NSMusicDirectory),
                                               @"desktopDir": @(NSDesktopDirectory)};
        directoryNameToPathMap = [NSMutableDictionary new];
        for (NSString *dirName in directoryNameToIDMap) {
            NSInteger ID = [directoryNameToIDMap[dirName] integerValue];
            directoryNameToPathMap[dirName] = NSSearchPathForDirectoriesInDomains(ID, NSUserDomainMask, YES).firstObject;
        }
        directoryNameToPathMap[@"applicationsDir"] = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES).firstObject;
    });
    return directoryNameToPathMap;
}

- (NSString *)MDQueryStringForSearch:(NSString *)search {
    NSString *escaped = [[[search stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"] stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
    return [NSString stringWithFormat:@"kMDItemFSName == '%@*'cd ", escaped];
}

+ (NSArray *)selectedFinderItems:(BOOL)justFolders {
    FinderApplication * finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    
    NSArray *selection = [self getPathsFromItems:[[finder selection] get] onlyFolders:justFolders];
    if (selection.count == 0) {
        NSString *currentDir = [self frontmostFinderDirectory];
        NSArray *currentDirContents = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentDir error:nil] mapFilter:^id(id obj) {
            return [currentDir stringByAppendingPathComponent:obj];
        }];
        if (justFolders || currentDirContents.count == 0) {
            selection = [self getPathsFromItems:(currentDir ? @[currentDir] : @[]) onlyFolders:justFolders];
        } else {
            selection = currentDirContents;
        }
    }
    return selection;
}

+ (NSString *)frontmostFinderDirectory {
    FinderApplication *finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    
    SBElementArray *windows =  [finder windows ]; // array of finder windows
    NSArray *targetArray = [windows arrayByApplyingSelector:@selector(target)];// array of targets of the windows
    if (targetArray.count == 0) return nil;
    //gets the first object from the targetArray,gets its URL, and converts it to a posix path
    NSString * newURLString =   [[NSURL URLWithString: (id) [[targetArray   objectAtIndex:0]URL]] path];
    return newURLString ? : NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSArray *)getPathsFromItems:(NSArray *)items onlyFolders:(BOOL)onlyFolders {
    return [items mapFilter:^id(id obj) {
        NSString *path = [obj isKindOfClass:[NSString class]] ? obj : [NSURL URLWithString:[(FinderItem *)obj URL]].path;
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && (isDir || !onlyFolders)) {
            return path;
        } else {
            return nil;
        }
    }];
}

+ (NSArray *)sortPaths:(NSArray *)paths {
    NSDictionary *modDates = [paths mapToDict:^id(__autoreleasing id *key) {
        NSString *path = (*key);
        *key = path;
        return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileModificationDate];
    }];
    NSString *homeDir = NSHomeDirectory();
    return [paths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BOOL homeDir1 = [obj1 startsWith:homeDir];
        BOOL homeDir2 = [obj2 startsWith:homeDir];
        if (homeDir1 != homeDir2) {
            return homeDir1 ? NSOrderedAscending : NSOrderedDescending;
        }
        NSDate *mod1 = modDates[obj1];
        NSDate *mod2 = modDates[obj2];
        if (![mod1 isEqualToDate:mod2]) {
            return -[mod1 compare:mod2];
        }
        return NSOrderedSame;
    }];
}

@end
