/**
 * Copyright 2012, hetima
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <objc/message.h>
#import "SIMBL.h"
#import "ESPluginListManager.h"
#import "ESPluginListCellView.h"

static char ESPluginListManagerAlertAssociatedObjectKey;


@implementation ESPluginListManager
@synthesize plugins = _plugins;
@synthesize removePopover = _removePopover;
@synthesize listView = _listView;
@synthesize removePopoverCaption = _removePopoverCaption;
@synthesize pluginsDirectory = _pluginsDirectory;
@synthesize disabledPluginsDirectory = _disabledPluginsDirectory;

- (id)init
{
    self = [super init];
    if (self) {
        _eventStream=nil;
        NSString *applicationSupportPath = [SIMBL applicationSupportPath];
        self.pluginsDirectory = [applicationSupportPath stringByAppendingPathComponent:EasySIMBLPluginsPathComponent];
        self.disabledPluginsDirectory = [applicationSupportPath stringByAppendingPathComponent:[EasySIMBLPluginsPathComponent stringByAppendingString:@" (Disabled)"]];
        if (![[NSFileManager defaultManager]fileExistsAtPath:self.pluginsDirectory]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:self.pluginsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager]fileExistsAtPath:self.disabledPluginsDirectory]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:self.disabledPluginsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setup:) name:NSApplicationWillFinishLaunchingNotification object:NSApp];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cleanup:) name:NSApplicationWillTerminateNotification object:NSApp];
        
    }
    return self;
}

- (void)setup:(NSNotification*)note
{
    [self scanPlugins];
    if (!_eventStream) {
        [self setupEventStream];
    }
}

- (void)cleanup:(NSNotification*)note
{
    [self invalidateEventStream];
}

- (NSMutableArray*)scanPluginsInDirectory:(NSString*)dir{
    
    NSArray* files=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:dir error:nil];
    NSMutableArray* ary=[NSMutableArray arrayWithCapacity:[files count]];
    
    for (NSString* fileName in files) {
        if ([fileName hasSuffix:@".bundle"]) {
            NSString* path=[dir stringByAppendingPathComponent:fileName];
            NSString* name=[fileName stringByDeletingPathExtension];
            //check Info.plist
            NSBundle* bundle = [NSBundle bundleWithPath:path];
            NSDictionary* info=[bundle SIMBL_infoDictionary];
            NSString* bundleIdentifier=[bundle bundleIdentifier];
            if(![bundleIdentifier length])bundleIdentifier=@"(null)";
            
            NSString* bundleVersion=[bundle _dt_version];
            if(![bundleVersion length])bundleVersion=[bundle _dt_bundleVersion];
            
            NSString* description=bundleIdentifier;
            if([bundleVersion length]){
                description=[NSString stringWithFormat:@"%@ - %@", bundleVersion, description];
            }
            
            NSMutableDictionary* itm=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      name, @"name", path, @"path", description, @"description",
                                      bundleIdentifier, @"bundleId", bundleVersion, @"version",
                                      info, @"bundleInfo",
                                      [NSNumber numberWithBool:YES], @"enabled",
                                      [NSNumber numberWithBool:NO], @"fileSystemConflict",
                                      nil];
            
            if (itm) {
                [ary addObject:itm];
            }
        }
    }
    
    return ary;
}

- (void)scanPlugins{
    
    //scan plugins
    NSString* pluginPath=self.pluginsDirectory;
    NSMutableArray* plugins=[self scanPluginsInDirectory:pluginPath];
    for (NSMutableDictionary* itm in plugins) {
        [itm setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    }
    
    //scan disabled plugins
    pluginPath=self.disabledPluginsDirectory;
    NSMutableArray* disabledPlugins=[self scanPluginsInDirectory:pluginPath];
    for (NSMutableDictionary* itm in disabledPlugins) {
        [itm setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
    }
    
    //merge and sort
    if ([disabledPlugins count]>0) {
        [plugins addObjectsFromArray:disabledPlugins];
        [plugins sortWithOptions:0 usingComparator: ^(id obj1, id obj2) {
            NSString* name1=[obj1 objectForKey:@"name"];
            NSString* name2=[obj2 objectForKey:@"name"];
            NSComparisonResult result=[name1 compare:name2];
            if (result==NSOrderedSame) { //exists both folder
                //fileSystemConflict flag disables checkbox
                [obj1 setObject:[NSNumber numberWithBool:YES] forKey:@"fileSystemConflict"];
                [obj2 setObject:[NSNumber numberWithBool:YES] forKey:@"fileSystemConflict"];
            }
            return result;
        }];
    }
    
    self.plugins=plugins;
    
}

#pragma mark - action

// from checkbox on tableview
- (IBAction)actToggleEnabled:(id)sender
{
    ESPluginListCellView* cellView=(ESPluginListCellView*)[sender superview];
    NSMutableDictionary* target=cellView.objectValue;
    //enabled value is already new
    BOOL bEnabled = [[target objectForKey:@"enabled"]boolValue];
    if ([[NSApp currentEvent]modifierFlags] & NSCommandKeyMask) {
        for (NSMutableDictionary *plugin in self.plugins) {
            [self switchEnabled:bEnabled forPlugin:[plugin objectForKey:@"path"]];
        }
    } else {
        [self switchEnabled:bEnabled forPlugin:[target objectForKey:@"path"]];
    }
    
    [self scanPlugins];
}

// from x button on tableview
// show confirm popover
- (IBAction)actConfirmUninstall:(id)sender
{
    if (self.removePopover.delegate) {
        [self.removePopover performClose:self];
        return;
    }
    
    ESPluginListCellView* cellView=(ESPluginListCellView*)[sender representedObject];
    NSMutableDictionary* target=cellView.objectValue;
    NSString* captionTemplate=@"Are you sure you want to uninstall \"%@\" ?";
    NSString* caption=[NSString stringWithFormat:captionTemplate, [target objectForKey:@"name"]];
    
    [self.removePopoverCaption setStringValue:caption];
    
    
    //popover の delegate でアンインストールするプラグインを把握
    [self.removePopover setDelegate:cellView];
    [self.removePopover showRelativeToRect:[[self.removePopover.contentViewController view]bounds] ofView:cellView preferredEdge:CGRectMinYEdge];
}

// from Uninstall button on popover
- (IBAction)actDecideUninstall:(id)sender
{
    ESPluginListCellView* cellView=(ESPluginListCellView*)self.removePopover.delegate;
    NSMutableDictionary* target=cellView.objectValue;
    [self.removePopover performClose:self];
    if (target) {
        //remove
        NSString* path=[target objectForKey:@"path"];
        [self uninstallPlugin:path];
    }
}

- (IBAction)actShowPluginFolder:(id)sender
{
    NSString* dir=self.pluginsDirectory;
    [[NSWorkspace sharedWorkspace]selectFile:dir inFileViewerRootedAtPath:nil];
}

-(NSMenu*)menuForTableView:(NSTableView*)tableView row:(NSInteger)row
{
    if ([self.plugins count]<=row) {
        return nil;
    }
    NSDictionary* pluginInfo=[self.plugins objectAtIndex:row];
    
    NSMenu* menu=[[NSMenu alloc]initWithTitle:@"menu"];
    NSView* cellView=[tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    NSMenuItem* item;
    NSString* uninstallLabel = [NSString stringWithFormat:@"Uninstall \"%@\" ...", [pluginInfo objectForKey:@"name"]];
    item = [menu addItemWithTitle:uninstallLabel action:@selector(actConfirmUninstall:) keyEquivalent:@""];
    [item setRepresentedObject:cellView];
    [item setTarget:self];
    
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"SIMBLTargetApplications:" action:nil keyEquivalent:@""];
    NSDictionary* bundleInfo = [pluginInfo objectForKey:@"bundleInfo"];
    NSArray* targetApps = [bundleInfo objectForKey:SIMBLTargetApplications];
    for (NSDictionary* targetApp in targetApps) {
        NSNumber* number;
        NSString* appID = [targetApp objectForKey:SIMBLBundleIdentifier];
        NSInteger minVer = 0;
        NSInteger maxVer = 0;
        number=[targetApp objectForKey:SIMBLMinBundleVersion];
        if (number) {
            minVer=[number integerValue];
        }
        number = [targetApp objectForKey:SIMBLMaxBundleVersion];
        if (number) {
            maxVer=[number integerValue];
        }
        
        item = [menu addItemWithTitle:appID action:nil keyEquivalent:@""];
        [item setIndentationLevel:1];
        if (minVer || maxVer) {
            NSString* minVerStr = minVer ? [NSString stringWithFormat:@"%li", minVer] : @"";
            NSString* maxVerStr = maxVer ? [NSString stringWithFormat:@"%li", maxVer] : @"";
            NSString* verStr=[NSString stringWithFormat:@"version:%@ - %@", minVerStr, maxVerStr];
            item = [menu addItemWithTitle:verStr action:nil keyEquivalent:@""];
            [item setIndentationLevel:2];
        }
    }
    return menu;
}


#pragma mark - file manage

- (void)switchEnabled:(BOOL)enabled forPlugin:(NSString*)path
{
    NSString* destination;
    if (enabled) {
        destination=self.pluginsDirectory;
    }else {
        destination=self.disabledPluginsDirectory;
    }
    destination=[destination stringByAppendingPathComponent:[path lastPathComponent]];
    [[NSFileManager defaultManager]moveItemAtPath:path toPath:destination error:nil];
}



// install. copy to plugin dir
- (void)installPlugins:(NSArray *)plugins
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSInteger waitCount = 0;
    for (NSString *path in plugins) {
        //check from plugin folder
        if ([path hasPrefix:self.pluginsDirectory]) {
            continue;
        }
        
        //check already installed
        NSString* installPath=[self installedPathForFileName:[path lastPathComponent]];
        if (installPath) {
            //already installed
            //
            NSString* alertText=@"\"%@\" is already exists. Do you want to replace?";
            NSString* const informativeText=@"If replace, existing file is moved to trash.";
            alertText=[NSString stringWithFormat:alertText, [path lastPathComponent]];
            NSAlert *alert=[NSAlert alertWithMessageText:alertText defaultButton:@"Replace" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:informativeText];
            
            NSDictionary* pathInfo=[NSDictionary dictionaryWithObjectsAndKeys:path, @"from", installPath, @"to", nil];
            objc_setAssociatedObject(alert, &ESPluginListManagerAlertAssociatedObjectKey, pathInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [alert beginSheetModalForWindow:self.listView.window modalDelegate:self
                             didEndSelector:@selector(installAlertDidEnd:returnCode:contextInfo:) contextInfo:semaphore];
            [NSApp runModalForWindow:self.listView.window];
            waitCount++;
        }else {
            installPath=[self.pluginsDirectory stringByAppendingPathComponent:[path lastPathComponent]];
            [self installPlugin:path toPath:installPath];
        }
    }
    dispatch_async(dispatch_get_current_queue(), ^{
        for (NSInteger i=0; i<waitCount; i++) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        dispatch_release(semaphore);
        [self scanPlugins];
    });
}

- (void)installAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [NSApp stopModal];
    if (returnCode==1) {
        NSDictionary* pathInfo=(NSDictionary*)objc_getAssociatedObject(alert, &ESPluginListManagerAlertAssociatedObjectKey);
        NSString* path=[pathInfo objectForKey:@"from"];
        NSString* installPath=[pathInfo objectForKey:@"to"];
        
        NSURL* URL=[NSURL fileURLWithPath:installPath];
        NSArray *URLs=[NSArray arrayWithObject:URL];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [[NSWorkspace sharedWorkspace]recycleURLs:URLs
                                    completionHandler:^(NSDictionary *newURLs, NSError *error){
                                        [self installPlugin:path toPath:installPath];
                                        dispatch_semaphore_signal(contextInfo);
                                    }];
        });
    } else {
        dispatch_semaphore_signal(contextInfo);
    }
}

- (void)installPlugin:(NSString*)path toPath:(NSString*)installPath
{
    NSError *err;
    if (![[NSFileManager defaultManager]copyItemAtPath:path toPath:installPath error:&err]){
        SIMBLLogNotice(@"install error:%@", err);
    }
}

- (NSString*)installedPathForFileName:(NSString*)filename
{
    NSString* pluginPath=[self.pluginsDirectory stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager]fileExistsAtPath:pluginPath]) {
        return pluginPath;
    }
    pluginPath=[self.disabledPluginsDirectory stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager]fileExistsAtPath:pluginPath]) {
        return pluginPath;
    }
    return nil;
}

// uninstall. move to trash
- (void)uninstallPlugin:(NSString*)path
{
    if (!path) {
        return;
    }
    NSURL* URL=[NSURL fileURLWithPath:path];
    NSArray *URLs=[NSArray arrayWithObject:URL];
    [[NSWorkspace sharedWorkspace]recycleURLs:URLs completionHandler:^(NSDictionary *newURLs, NSError *error){
        [self scanPlugins];
    }];
}



#pragma mark FSEvents

#define ESFSEventStreamLatency			((CFTimeInterval)3.0)

static void ESFSEventsCallback(
                               ConstFSEventStreamRef streamRef,
                               void *callbackCtxInfo,
                               size_t numEvents,
                               void *eventPaths,
                               const FSEventStreamEventFlags eventFlags[],
                               const FSEventStreamEventId eventIds[])
{
	ESPluginListManager *watcher = (__bridge ESPluginListManager *)callbackCtxInfo;
    [watcher scanPlugins];
}

- (void)invalidateEventStream{
    if (_eventStream) {
        FSEventStreamStop(_eventStream);
        FSEventStreamInvalidate(_eventStream);
        FSEventStreamRelease(_eventStream);
        _eventStream = nil;
    }
}

- (void)setupEventStream
{
    [self invalidateEventStream];
    
    NSArray* watchPaths=[NSArray arrayWithObjects:self.pluginsDirectory, self.disabledPluginsDirectory, nil];
    
    FSEventStreamCreateFlags   flags = (/*kFSEventStreamCreateFlagUseCFTypes|*/ kFSEventStreamCreateFlagIgnoreSelf);
    
	FSEventStreamContext callbackCtx;
	callbackCtx.version = 0;
	callbackCtx.info = (__bridge void *)self;
	callbackCtx.retain = NULL;
	callbackCtx.release = NULL;
	callbackCtx.copyDescription	= NULL;
    
	_eventStream = FSEventStreamCreate(kCFAllocatorDefault,
									   &ESFSEventsCallback,
									   &callbackCtx,
									   (__bridge CFArrayRef)watchPaths,
									   kFSEventStreamEventIdSinceNow,
									   ESFSEventStreamLatency,
									   flags);
    FSEventStreamScheduleWithRunLoop(_eventStream, [[NSRunLoop currentRunLoop]getCFRunLoop], kCFRunLoopDefaultMode);
    if (!FSEventStreamStart(_eventStream)) {
        
    }
}

@end
