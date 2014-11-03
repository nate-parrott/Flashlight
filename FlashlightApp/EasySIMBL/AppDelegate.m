/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <ServiceManagement/SMLoginItem.h>
#import "AppDelegate.h"
#import "SIMBL.h"
#import "ESPluginListManager.h"

@implementation AppDelegate

@synthesize loginItemBundleIdentifier=_loginItemBundleIdentifier;

@synthesize window = _window;
@synthesize useSIMBL = _useSIMBL;
@synthesize pluginListManager = _pluginListManager;

#pragma mark User defaults

+ (void)initialize {
    NSDictionary *initialValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:2],SIMBLPrefKeyLogLevel, nil];
    [[NSUserDefaults standardUserDefaults]registerDefaults:initialValues];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValues];
}

#pragma mark NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSString *loginItemBundlePath = nil;
    NSBundle *loginItemBundle = nil;
    NSString *loginItemBundleVersion = nil;
    NSError *error = nil;
    NSString *loginItemsPath = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"Contents/Library/LoginItems"];
    NSArray *loginItems = [[[NSFileManager defaultManager]contentsOfDirectoryAtPath:loginItemsPath error:&error]
                           pathsMatchingExtensions:[NSArray arrayWithObject:@"app"]];
    if (error) {
        SIMBLLogNotice(@"contentsOfDirectoryAtPath error:%@", error);
    } else if (![loginItems count]) {
        SIMBLLogNotice(@"no loginItems found at %@", loginItemsPath);
    } else {
        loginItemBundlePath = [loginItemsPath stringByAppendingPathComponent:[loginItems objectAtIndex:0]];
        loginItemBundle = [NSBundle bundleWithPath:loginItemBundlePath];
        loginItemBundleVersion = [loginItemBundle _dt_bundleVersion];
        self.loginItemBundleIdentifier = [loginItemBundle bundleIdentifier];
    }
    if (self.loginItemBundleIdentifier && loginItemBundleVersion) {
        NSArray *runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:self.loginItemBundleIdentifier];
        
        NSInteger state = NSOffState;
        if ([runningApplications count]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults addSuiteNamed:self.loginItemBundleIdentifier];
            
            if ([[defaults objectForKey:self.loginItemBundleIdentifier] isEqualToString:loginItemBundleVersion]) {
                SIMBLLogInfo(@"Already my 'SIMBL Agent' is running.");
                
                state = NSOnState;
            } else {
                // if running agent's bundle is different from my bundle, need restart agent from my bundle.
                SIMBLLogInfo(@"Already 'SIMBL Agent' is running, but version is different.");
                
                CFStringRef bundleIdentifeierRef = (__bridge CFStringRef)self.loginItemBundleIdentifier;
                [self.useSIMBL setEnabled:NO];
                state = NSOffState;
                NSRunningApplication *runningApplication = [runningApplications objectAtIndex:0];
                [runningApplication addObserver:self
                                     forKeyPath:@"isTerminated"
                                        options:NSKeyValueObservingOptionNew
                                        context:(__bridge_retained void*)runningApplication];
                if (!SMLoginItemSetEnabled(bundleIdentifeierRef, NO)) {
                    SIMBLLogNotice(@"SMLoginItemSetEnabled(YES) failed!");
                }
            }
        } else {
            SIMBLLogInfo(@"'SIMBL Agent' is not running.");
        }
        self.useSIMBL.state = state;
    } else {
        [self.useSIMBL setEnabled:NO];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    [self.pluginListManager installPlugins:filenames];
    [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

#pragma mark NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isTerminated"]) {
        [object removeObserver:self forKeyPath:keyPath];
        [self.useSIMBL setEnabled:YES];
        CFRelease((CFTypeRef)context);
    }
}

#pragma mark IBAction

- (IBAction)toggleUseSIMBL:(id)sender {
    NSInteger result = self.useSIMBL.state;
    
    CFStringRef bundleIdentifeierRef = (__bridge CFStringRef)self.loginItemBundleIdentifier;
    if (!SMLoginItemSetEnabled(bundleIdentifeierRef, self.useSIMBL.state == NSOnState)) {
        self.useSIMBL.state = self.useSIMBL.state == NSOnState ? NSOffState : NSOnState;
        SIMBLLogNotice(@"SMLoginItemSetEnabled() failed!");
    }
    self.useSIMBL.state = result;
}
@end
