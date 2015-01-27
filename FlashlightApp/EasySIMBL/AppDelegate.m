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
#import "PluginModel.h"
#import <LetsMove/PFMoveApplication.h>
#import "UpdateChecker.h"
#import "PluginInstallTask.h"

@interface AppDelegate ()

@property (nonatomic,weak) IBOutlet NSTextField *enablePluginsLabel;
@property (nonatomic,weak) IBOutlet NSMenuItem *createNewAutomatorPluginMenuItem;
@property (nonatomic,weak) IBOutlet NSTextField *versionLabel, *searchAnything;
@property (nonatomic,weak) IBOutlet NSButton *openGithub, *requestPlugin, *leaveFeedback;

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
    
    self.versionLabel.stringValue = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    PFMoveToApplicationsFolderIfNecessary();
    
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
                SIMBLLogInfo(@"'SIMBL Agent' is already running.");
                
                state = NSOnState;
            } else {
                // if running agent's bundle is different from my bundle, need restart agent from my bundle.
                SIMBLLogInfo(@"'SIMBL Agent' is already running, but version is different.");
                
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
    self.leaveFeedback.stringValue = NSLocalizedString(@"Leave Feedback", @"");
    self.openGithub.stringValue = NSLocalizedString(@"Contribute on GitHub", @"");
    self.requestPlugin.stringValue = NSLocalizedString(@"Request a Plugin", @"");
    self.searchAnything.stringValue = NSLocalizedString(@"Search anything.", @"");
    
    [UpdateChecker shared]; // begin fetch
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

- (void)awakeFromNib {
    [super awakeFromNib];
    self.SIMBLOn = self.SIMBLOn;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    BOOL anyFilesMatch = NO;
    for (NSString *filename in filenames) {
        if ([filename.pathExtension isEqualToString:@"flashlightplugin"]) {
            PluginInstallTask *task = [PluginInstallTask new];
            [task installPluginData:[NSData dataWithContentsOfFile:filename] intoPluginsDirectory:[PluginModel pluginsDir] callback:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.pluginListController showInstalledPluginWithName:task.installedPluginName];
                        });
                    } else {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert setMessageText:NSLocalizedString(@"Couldn't Install Plugin", @"")];
                        [alert addButtonWithTitle:NSLocalizedString(@"Okay", @"")]; // FirstButton, rightmost button
                        [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"This file doesn't appear to be a valid plugin.", @"")]];
                        alert.alertStyle = NSCriticalAlertStyle;
                        [alert runModal];
                    }
                });
            }];
        }
    }
    if (anyFilesMatch) {
        [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
    } else {
        [sender replyToOpenOrPrint:NSApplicationDelegateReplyFailure];
    }
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
    self.useSIMBLSwitch.state = SIMBLOn ? NSOnState : NSOffState;
    self.pluginListController.enabled = SIMBLOn;
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
    if (![@[@"911", @"916", @"917"] containsObject:spotlightVersion]) {
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
- (IBAction)requestAPlugin:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://flashlight.nateparrott.com/ideas"]];
}
#pragma mark Links
- (IBAction)showPythonAPI:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/nate-parrott/Flashlight/blob/master/Docs/Tutorial.markdown"]];

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
    } else if ([url.scheme isEqualToString:@"flashlight"]) {
        NSArray *parts = [[NSArray arrayWithObject:url.host] arrayByAddingObjectsFromArray:[url.pathComponents subarrayWithRange:NSMakeRange(1, url.pathComponents.count - 1)]];
        if (parts.count >= 2 && [parts[0] isEqualToString:@"plugin"]) {
            NSString *pluginName = parts[1];
            if (parts.count == 2) {
                [self.pluginListController showPluginWithName:pluginName];
            } else {
                if (parts.count == 3 && [parts[2] isEqualToString:@"preferences"]) {
                    [[PluginModel installedPluginNamed:parts[1]] presentOptionsInWindow:self.window];
                }
            }
        }
    }
}
@end
