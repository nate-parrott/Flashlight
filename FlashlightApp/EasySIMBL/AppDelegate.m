/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <ServiceManagement/SMLoginItem.h>
#import "AppDelegate.h"
#import "SIMBL.h"

@implementation AppDelegate

@synthesize loginItemBundleIdentifier=_loginItemBundleIdentifier;

@synthesize window = _window;

#pragma mark User defaults

+ (void)initialize {
    NSDictionary *initialValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:2],SIMBLPrefKeyLogLevel, nil];
    [[NSUserDefaults standardUserDefaults]registerDefaults:initialValues];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValues];
}

#pragma mark NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    self.SIMBLOn = NO;
    
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
        self.loginItemPath = loginItemBundlePath;
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
                [self.useSIMBLSwitch setEnabled:NO];
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
        self.SIMBLOn = state == NSOnState ? YES : NO;
    } else {
        [self.useSIMBLSwitch setEnabled:NO];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    // TODO: install the plugin
    [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

#pragma mark NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isTerminated"]) {
        [object removeObserver:self forKeyPath:keyPath];
        [self.useSIMBLSwitch setEnabled:YES];
        CFRelease((CFTypeRef)context);
    }
}

#pragma mark IBAction

- (IBAction)toggleUseSIMBL:(id)sender {
    BOOL result = !self.SIMBLOn;
    
    NSURL *loginItemURL = [NSURL fileURLWithPath:self.loginItemPath];
    OSStatus status = LSRegisterURL((__bridge CFURLRef)loginItemURL, YES);
    if (status != noErr) {
        NSLog(@"Failed to LSRegisterURL '%@': %jd", loginItemURL, (intmax_t)status);
    }
    
    CFStringRef bundleIdentifierRef = (__bridge CFStringRef)self.loginItemBundleIdentifier;
    if (!SMLoginItemSetEnabled(bundleIdentifierRef, result)) {
        result = !result;
        SIMBLLogNotice(@"SMLoginItemSetEnabled() failed!");
    }
    self.SIMBLOn = result;
}
- (void)setSIMBLOn:(BOOL)SIMBLOn {
    _SIMBLOn = SIMBLOn;
    self.useSIMBLSwitch.on = SIMBLOn;
    self.tableView.enabled = SIMBLOn;
    [self.tableView setAlphaValue:SIMBLOn ? 1 : 0.6];
}

@end
