/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import <ServiceManagement/SMLoginItem.h>
#import "AppDelegate.h"
#import "SIMBL.h"
#import "ITSwitch+Additions.h"
#import "PluginListController.h"

@interface AppDelegate ()

@property (nonatomic,weak) IBOutlet NSTextField *enablePluginsLabel;
@property (nonatomic,weak) IBOutlet NSMenuItem *createNewAutomatorPluginMenuItem;

@end

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
    NSLocalizedString(@"Flashlight: the missing plugin system for Spotlight.", @"");
    
    self.SIMBLOn = NO;
    
    [self checkSpotlightVersion];
    
    [self setupURLHandling];
    
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
        [self setSIMBLOn:state == NSOnState animated:NO];
    } else {
        [self.useSIMBLSwitch setEnabled:NO];
    }
    
    [self restartSIMBLIfUpdated];
    
    // i18n:
    self.enablePluginsLabel.stringValue = NSLocalizedString(@"Enable Spotlight Plugins", @"");
    self.createNewAutomatorPluginMenuItem.title = NSLocalizedString(@"New Automator Plugin...", @"");
}

- (void)restartSIMBLIfUpdated {
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"LastVersion"] isEqualToString:currentVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"LastVersion"];
        // restart simbl:
        if (self.SIMBLOn) {
            self.SIMBLOn = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.SIMBLOn = YES;
            });
        }
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
    
    if (!result) {
        // restart spotlight after 1 sec to remove injected code:
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[@"Spotlight"]];
        });
    }
}
- (void)setSIMBLOn:(BOOL)SIMBLOn {
    [self setSIMBLOn:SIMBLOn animated:YES];
}
- (void)setSIMBLOn:(BOOL)SIMBLOn animated:(BOOL)animated {
    _SIMBLOn = SIMBLOn;
    if (animated) {
        self.useSIMBLSwitch.on = SIMBLOn;
    } else {
        [self.useSIMBLSwitch setOnWithoutAnimation:SIMBLOn];
    }
    self.tableView.enabled = SIMBLOn;
    [self.tableView setAlphaValue:SIMBLOn ? 1 : 0.6];
    [self.webView setAlphaValue:SIMBLOn ? 1 : 0.6];
}

- (IBAction)openURLFromButton:(NSButton *)sender {
    NSString *str = sender.title;
    if ([str rangeOfString:@"://"].location == NSNotFound) {
        str = [@"http://" stringByAppendingString:str];
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:str]];
}

#pragma mark Version checking
- (void)checkSpotlightVersion {
    NSString *fullSpotlightVersion = [[NSBundle bundleWithPath:[[NSWorkspace sharedWorkspace] fullPathForApplication:@"Spotlight"]] infoDictionary][@"CFBundleVersion"];
    NSString *spotlightVersion = [fullSpotlightVersion componentsSeparatedByString:@"."][0];
    NSLog(@"DetectedSpotlightVersion: %@", spotlightVersion);
    if (![@[@"911", @"916"] containsObject:spotlightVersion]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Flashlight doesn't work with your version of Spotlight."];
            [alert addButtonWithTitle:@"Okay"]; // FirstButton, rightmost button
            [alert addButtonWithTitle:@"Check for updates"]; // SecondButton
            [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"As a precaution, plugins won't run on unsupported versions of Spotlight, even if you enable them. (You have Spotlight v%@)", @""), spotlightVersion]];
            alert.alertStyle = NSCriticalAlertStyle;
            NSModalResponse resp = [alert runModal];
            if (resp == NSAlertSecondButtonReturn) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/nate-parrott/flashlight"]];
            }
            
        });
    }
}

#pragma mark About Window actions
- (IBAction)openGithub:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/nate-parrott/Flashlight"]];
}
- (IBAction)leaveFeedback:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://flashlight.nateparrott.com/feedback"]];
}

#pragma mark URL scheme
- (void)setupURLHandling {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject]
                        stringValue];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([url.scheme isEqualToString:@"flashlight-show"]) {
        [self.pluginListController showPluginWithName:url.host];
    }
}

@end
