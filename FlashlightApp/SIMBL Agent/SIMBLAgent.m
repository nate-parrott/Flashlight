/**
 * Copyright 2003-2009, Mike Solomon <mas63@cornell.edu>
 * SIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */
/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <ScriptingBridge/ScriptingBridge.h>
#import <Carbon/Carbon.h>
#import "SIMBL.h"
#import "SIMBLAgent.h"

@implementation SIMBLAgent

@synthesize waitingInjectionNumber=_waitingInjectionNumber;
@synthesize scriptingAdditionsPath=_scriptingAdditionsPath;
@synthesize osaxPath=_osaxPath;
@synthesize linkedOsaxPath=_linkedOsaxPath;
@synthesize applicationSupportPath=_pluginsPath;
@synthesize plistPath=_plistPath;
@synthesize runningSandboxedApplications=_runningSandboxedApplications;

NSString * const kInjectedSandboxBundleIdentifiers = @"InjectedSandboxBundleIdentifiers";

#pragma NSApplicationDelegate Protocol

- (void) applicationDidFinishLaunching:(NSNotification*)notificaion
{
    SIMBLLogInfo(@"agent started");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,  NSUserDomainMask, YES);
    NSString *libraryPath = (NSString*)[paths objectAtIndex:0];
    self.scriptingAdditionsPath = [libraryPath stringByAppendingPathComponent:EasySIMBLScriptingAdditionsPathComponent];
    self.osaxPath = [[[[NSBundle mainBundle]builtInPlugInsPath]stringByAppendingPathComponent:EasySIMBLBundleBaseName]stringByAppendingPathExtension:EasySIMBLBundleExtension];
    self.linkedOsaxPath = [self.scriptingAdditionsPath stringByAppendingPathComponent:EasySIMBLBundleName];
    self.waitingInjectionNumber = 0;
    self.applicationSupportPath = [SIMBL applicationSupportPath];
    self.plistPath = [NSString pathWithComponents:[NSArray arrayWithObjects:libraryPath, EasySIMBLPreferencesPathComponent, [EasySIMBLSuiteBundleIdentifier stringByAppendingPathExtension:EasySIMBLPreferencesExtension], nil]];
    self.runningSandboxedApplications = [NSMutableArray array];
    
    [[NSDistributedNotificationCenter defaultCenter]addObserver:self
                                                       selector:@selector(receiveSIMBLHasBeenLoadedNotification:)
                                                           name:EasySIMBLHasBeenLoadedNotification
                                                         object:nil];
    
    // Save version information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[[NSBundle mainBundle]_dt_bundleVersion]
                forKey:[[NSBundle mainBundle]bundleIdentifier]];
    
    // hold previous injected sandbox
    NSMutableSet *previousInjectedSandboxBundleIdentifierSet = [NSMutableSet setWithArray:[defaults objectForKey:kInjectedSandboxBundleIdentifiers]];
    [defaults removeObjectForKey:kInjectedSandboxBundleIdentifiers];
    [defaults synchronize];
    
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace addObserver:self
                forKeyPath:@"runningApplications"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:NULL];
    
    // inject into resumed applications
    for (NSRunningApplication *runningApp in [workspace runningApplications]) {
        [self injectSIMBL:runningApp];
    }
    
    // previous minus running, it should be uninject
    [previousInjectedSandboxBundleIdentifierSet minusSet:[NSMutableSet setWithArray:[defaults objectForKey:kInjectedSandboxBundleIdentifiers]]];
    if ([previousInjectedSandboxBundleIdentifierSet count]) {
        [[NSProcessInfo processInfo]disableSuddenTermination];
        for (NSString *bundleItentifier in previousInjectedSandboxBundleIdentifierSet) {
            [self injectContainerBundleIdentifier:bundleItentifier enabled:NO];
        }
        [[NSProcessInfo processInfo]enableSuddenTermination];
    }
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[@"Spotlight"]];
}

#pragma mark SBApplicationDelegate Protocol

- (id) eventDidFail:(const AppleEvent *)event withError:(NSError *)error;
{
    return nil;
}

#pragma mark NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isTerminated"]) {
        SIMBLLogDebug(@"runningApp %@ isTerminated.", object);
        [object removeObserver:self forKeyPath:keyPath];
        
        [self injectContainerForApplication:(NSRunningApplication*)object enabled:NO];
    } else if ([keyPath isEqualToString:@"runningApplications"]) {
        // for apps which will be terminated without called @"isFinishedLaunching"
        static NSMutableSet *appsObservingFinishedLaunching = nil;
        if (!appsObservingFinishedLaunching) {
            appsObservingFinishedLaunching = [NSMutableSet set];
        }
        
		for (NSRunningApplication *app in [change objectForKey:NSKeyValueChangeNewKey]) {
            if (app.isFinishedLaunching) {
                SIMBLLogDebug(@"runningApp %@ is already isFinishedLaunching", app);
                [self injectSIMBL:app];
            } else {
                [app addObserver:self forKeyPath:@"isFinishedLaunching" options:NSKeyValueObservingOptionNew context:NULL];
                [appsObservingFinishedLaunching addObject:app];
            }
		}
		for (NSRunningApplication *app in [change objectForKey:NSKeyValueChangeOldKey]) {
            if ([appsObservingFinishedLaunching containsObject:app]) {
                [app removeObserver:self forKeyPath:@"isFinishedLaunching"];
                [appsObservingFinishedLaunching removeObject:app];
            }
        }
    } else if ([keyPath isEqualToString:@"isFinishedLaunching"]) {
        SIMBLLogDebug(@"runningApp %@ isFinishedLaunching.", object);
        [self injectSIMBL:(NSRunningApplication*)object];
    }
}

#pragma mark EasySIMBLHasBeenLoadedNotification

- (void) receiveSIMBLHasBeenLoadedNotification:(NSNotification*)notification
{
    SIMBLLogDebug(@"receiveSIMBLHasBeenLoadedNotification from %@", notification.object);
	self.waitingInjectionNumber--;
    if (!self.waitingInjectionNumber) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager]removeItemAtPath:self.linkedOsaxPath error:&error]) {
            SIMBLLogNotice(@"removeItemAtPath error:%@",error);
        }
    }
    [[NSProcessInfo processInfo]enableSuddenTermination];
}

#pragma mark -

- (void) injectSIMBL:(NSRunningApplication *)runningApp
{
	// NOTE: if you change the log level externally, there is pretty much no way
	// to know when the changed. Just reading from the defaults doesn't validate
	// against the backing file very ofter, or so it seems.
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
    
    if ([[NSRunningApplication currentApplication]isEqual:runningApp]) {
        return;
    }
    
	NSString* appName = [runningApp localizedName];
	SIMBLLogInfo(@"%@ started", appName);
	SIMBLLogDebug(@"app start notification: %@", runningApp);
    
	// check to see if there are plugins to load
    if ([SIMBL shouldInstallPluginsIntoApplication:runningApp] == NO) {
        SIMBLLogDebug(@"No plugins match for %@", runningApp);
		return;
	}
	
	// BUG: http://code.google.com/p/simbl/issues/detail?id=11
	// NOTE: believe it or not, some applications cause a crash deep in the
	// ScriptingBridge code. Due to the launchd behavior of restarting crashed
	// agents, this is mostly harmless. To reduce the crashing we leave a
	// blacklist to prevent injection.  By default, this is empty.
	NSString* appIdentifier = [runningApp bundleIdentifier];
	NSArray* blacklistedIdentifiers = [defaults stringArrayForKey:@"SIMBLApplicationIdentifierBlacklist"];
	if (blacklistedIdentifiers != nil &&
        [blacklistedIdentifiers containsObject:appIdentifier]) {
		SIMBLLogNotice(@"ignoring injection attempt for blacklisted application %@ (%@)", appName, appIdentifier);
		return;
	}
    
	SIMBLLogDebug(@"send inject event");
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:self.scriptingAdditionsPath isDirectory:&isDirectory]) {
        if (![fileManager createDirectoryAtPath:self.scriptingAdditionsPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error]) {
            SIMBLLogNotice(@"createDirectoryAtPath error:%@",error);
            return;
        }
    } else if (!isDirectory) {
        SIMBLLogNotice(@"%@ is file. Expect are directory", self.scriptingAdditionsPath);
        return;
    }
    
    if ([fileManager fileExistsAtPath:self.osaxPath isDirectory:&isDirectory] && isDirectory) {
        // Find the process to target
        pid_t pid = [runningApp processIdentifier];
        SBApplication* sbApp = [SBApplication applicationWithProcessIdentifier:pid];
        [sbApp setDelegate:self];
        if (!sbApp) {
            SIMBLLogNotice(@"Can't find app with pid %d", pid);
            return;
        }
        
        // create SIMBL.osax to ScriptingAdditions
        if (!self.waitingInjectionNumber) {
            [fileManager removeItemAtPath:self.linkedOsaxPath error:nil];
            
            // check fileSystems
            id fsOflinkedOsax = [[fileManager attributesOfItemAtPath:self.scriptingAdditionsPath error:&error] objectForKey:NSFileSystemNumber];
            if (error) {
                SIMBLLogNotice(@"attributesOfItemAtPath error:%@",error);
                return;
            }
            id fsOfOsax = [[fileManager attributesOfItemAtPath:self.osaxPath error:&error] objectForKey:NSFileSystemNumber];
            if (error) {
                SIMBLLogNotice(@"attributesOfItemAtPath error:%@",error);
                return;
            }
            
            if ([fsOflinkedOsax isEqual:fsOfOsax]) {
                // create hard link
                if (![fileManager linkItemAtPath:self.osaxPath toPath:self.linkedOsaxPath error:&error]) {
                    SIMBLLogNotice(@"linkItemAtPath error:%@",error);
                    return;
                }
            } else {
                // create copy
                if (![fileManager copyItemAtPath:self.osaxPath toPath:self.linkedOsaxPath error:&error]) {
                    SIMBLLogNotice(@"copyItemAtPath error:%@",error);
                    return;
                }
            }
        }
        self.waitingInjectionNumber++;
        
        // hardlink to Container
        [self injectContainerForApplication:runningApp enabled:YES];
        
        
        // Force AppleScript to initialize in the app, by getting the dictionary
        // When initializing, you need to wait for the event reply, otherwise the
        // event might get dropped on the floor. This is only seems to happen in 10.5
        // but it shouldn't harm anything.
        
        // 10.9 stop responding here when injecting into some non-sandboxed apps,
        // because those target apps never reply.
        // EasySIMBL stop waiting reply.
        // It works on OS X 10.7, 10.8 and 10.9 all of EasySIMBL target.
        [sbApp setSendMode:kAENoReply | kAENeverInteract | kAEDontRecord];
        [sbApp sendEvent:kASAppleScriptSuite id:kGetAEUT parameters:0];
        
        // the reply here is of some unknown type - it is not an Objective-C object
        // as near as I can tell because trying to print it using "%@" or getting its
        // class both cause the application to segfault. The pointer value always seems
        // to be 0x10000 which is a bit fishy. It does not seem to be an AEDesc struct
        // either.
        // since we are waiting for a reply, it seems like this object might need to
        // be released - but i don't know what it is or how to release it.
        // NSLog(@"initReply: %p '%64.64s'", initReply, (char*)initReply);
        
        // Inject!
        [sbApp setSendMode:kAENoReply | kAENeverInteract | kAEDontRecord];
        id injectReply = [sbApp sendEvent:'SPOT' id:'load' parameters:0];
        if (injectReply != nil) {
            SIMBLLogNotice(@"unexpected injectReply: %@", injectReply);
        }
        [[NSProcessInfo processInfo]disableSuddenTermination];
    }
}

- (void)injectContainerForApplication:(NSRunningApplication*)runningApp enabled:(BOOL)bEnabled;
{
    NSString *identifier = [runningApp bundleIdentifier];
    if (bEnabled) {
        if ([self injectContainerBundleIdentifier:identifier enabled:YES]) {
            SIMBLLogDebug(@"Start observing %@'s 'isTerminated'.", identifier);
            
            [runningApp addObserver:self forKeyPath:@"isTerminated" options:NSKeyValueObservingOptionNew context:NULL];
            [self.runningSandboxedApplications addObject:runningApp];
            
            NSMutableSet *injectedSandboxBundleIdentifierSet = [NSMutableSet set];
            for (NSRunningApplication *app in self.runningSandboxedApplications) {
                [injectedSandboxBundleIdentifierSet addObject:[app bundleIdentifier]];
            }
            [[NSUserDefaults standardUserDefaults]setObject:[injectedSandboxBundleIdentifierSet allObjects]
                                                     forKey:kInjectedSandboxBundleIdentifiers];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    } else {
        BOOL (^hasSameBundleIdentifier)(id, NSUInteger, BOOL *) = ^(id obj, NSUInteger idx, BOOL *stop) {
            return *stop = [identifier isEqualToString:[(NSRunningApplication*)obj bundleIdentifier]];
        };
        
        [self.runningSandboxedApplications removeObject:runningApp];
        // check multi instance application
        if (NSNotFound == [self.runningSandboxedApplications indexOfObjectWithOptions:NSEnumerationConcurrent
                                                                          passingTest:hasSameBundleIdentifier]) {
            if ([self injectContainerBundleIdentifier:identifier enabled:NO]) {
                
                NSMutableSet *injectedSandboxBundleIdentifierSet = [NSMutableSet set];
                for (NSRunningApplication *app in self.runningSandboxedApplications) {
                    [injectedSandboxBundleIdentifierSet addObject:[app bundleIdentifier]];
                }
                [[NSUserDefaults standardUserDefaults]setObject:[injectedSandboxBundleIdentifierSet allObjects]
                                                         forKey:kInjectedSandboxBundleIdentifiers];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
    }
}

- (BOOL)injectContainerBundleIdentifier:(NSString*)bundleIdentifier enabled:(BOOL)bEnabled;
{
    BOOL bResult = NO;
    if ([bundleIdentifier length]>0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,  NSUserDomainMask, YES);
        NSString *containerPath = [NSString pathWithComponents:[NSArray arrayWithObjects:[paths objectAtIndex:0], @"Containers", bundleIdentifier, nil]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:containerPath isDirectory:&isDirectory] && isDirectory) {
            NSString *dataLibraryPath = @"Data/Library";
            NSString *containerScriptingAddtionsPath = [NSString pathWithComponents:[NSArray arrayWithObjects:containerPath, dataLibraryPath, EasySIMBLScriptingAdditionsPathComponent, nil]];
            NSString *containerApplicationSupportPath = [NSString pathWithComponents:[NSArray arrayWithObjects:containerPath, dataLibraryPath, EasySIMBLApplicationSupportPathComponent, nil]];
            NSString *containerPlistPath = [NSString pathWithComponents:[NSArray arrayWithObjects:containerPath, dataLibraryPath,EasySIMBLPreferencesPathComponent, [EasySIMBLSuiteBundleIdentifier stringByAppendingPathExtension:EasySIMBLPreferencesExtension], nil]];
            if (bEnabled) {
                if (![fileManager linkItemAtPath:self.scriptingAdditionsPath toPath:containerScriptingAddtionsPath error:&error]) {
                    SIMBLLogNotice(@"linkItemAtPath error:%@",error);
                }
                if (![fileManager linkItemAtPath:self.applicationSupportPath toPath:containerApplicationSupportPath error:&error]) {
                    SIMBLLogNotice(@"linkItemAtPath error:%@",error);
                }
                if ([fileManager fileExistsAtPath:self.plistPath] && ![fileManager linkItemAtPath:self.plistPath toPath:containerPlistPath error:&error]) {
                    SIMBLLogNotice(@"linkItemAtPath error:%@",error);
                }
                bResult = YES;
                SIMBLLogDebug(@"%@'s container has been injected.", bundleIdentifier);
            } else {
                if (![fileManager removeItemAtPath:containerScriptingAddtionsPath error:&error]) {
                    SIMBLLogNotice(@"removeItemAtPath error:%@",error);
                }
                if (![fileManager removeItemAtPath:containerApplicationSupportPath error:&error]) {
                    SIMBLLogNotice(@"removeItemAtPath error:%@",error);
                }
                if ([fileManager fileExistsAtPath:containerPlistPath] && ![fileManager removeItemAtPath:containerPlistPath error:&error]) {
                    SIMBLLogNotice(@"removeItemAtPath error:%@",error);
                }
                bResult = YES;
                SIMBLLogDebug(@"%@'s container has been uninjected.", bundleIdentifier);
            }
        }
    }
    return bResult;
}

@end
