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
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@property (nonatomic,weak) IBOutlet NSButton *enablePluginsButton;
@property (nonatomic,weak) IBOutlet NSMenuItem *createNewAutomatorPluginMenuItem;
@property (nonatomic,weak) IBOutlet NSTextField *versionLabel, *searchAnything;
@property (nonatomic,weak) IBOutlet NSButton *openGithub, *requestPlugin, *leaveFeedback;
@property (nonatomic,weak) IBOutlet NSWindow *aboutWindow;
@property (nonatomic,weak) IBOutlet NSButton *menuBarItemPreferenceButton;
@property (nonatomic,weak) IBOutlet NSMenuItem *flashlightEnabledMenuItem;

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
    
    [Crashlytics startWithAPIKey:@"c00a274f2c47ad5ee89b17ccb2fdb86e8d1fece8"];
    
    self.SIMBLOn = YES;
    
    [self checkSpotlightVersion];
    
    [self setupDefaults];
    
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
    }
    
    [self restartSIMBLIfUpdated];
    
    // i18n:
    self.enablePluginsButton.title = NSLocalizedString(@"Enable", @"");
    self.createNewAutomatorPluginMenuItem.title = NSLocalizedString(@"New Automator Plugin...", @"");
    self.leaveFeedback.stringValue = NSLocalizedString(@"Leave Feedback", @"");
    self.openGithub.stringValue = NSLocalizedString(@"Contribute on GitHub", @"");
    self.requestPlugin.stringValue = NSLocalizedString(@"Request a Plugin", @"");
    self.searchAnything.stringValue = NSLocalizedString(@"Search anything.", @"");
    self.menuBarItemPreferenceButton.stringValue = NSLocalizedString(@"Show menu bar item", @"");
    [self.menuBarItemPreferenceButton sizeToFit];
    self.menuBarItemPreferenceButton.frame = NSMakeRect(self.menuBarItemPreferenceButton.superview.bounds.size.width/2 - self.menuBarItemPreferenceButton.frame.size.width/2, self.menuBarItemPreferenceButton.frame.origin.y, self.menuBarItemPreferenceButton.frame.size.width, self.menuBarItemPreferenceButton.frame.size.height);
    
    [UpdateChecker shared]; // begin fetch
    
    [self setupURLHandling];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self.window makeKeyAndOrderFront:nil];
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
        CFRelease((CFTypeRef)context);
    }
}

#pragma mark IBAction

- (IBAction)toggleFlashlightEnabled:(id)sender {
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
    
    if (result) {
        // show available plugins on enable
        [self.pluginListController showInstalledPlugins];
    }
}
- (void)setSIMBLOn:(BOOL)SIMBLOn {
    [self setSIMBLOn:SIMBLOn animated:YES];
}
- (void)setSIMBLOn:(BOOL)SIMBLOn animated:(BOOL)animated {
    _SIMBLOn = SIMBLOn;
    self.pluginListController.enabled = SIMBLOn;
    self.flashlightEnabledMenuItem.state = SIMBLOn ? NSOnState : NSOffState;
    self.flashlightEnabledMenuItem.title = SIMBLOn ? NSLocalizedString(@"Flashlight Enabled", nil) : NSLocalizedString(@"Flashlight Disabled", nil);
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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/nate-parrott/Flashlight/wiki/Creating-a-Plugin"]];

}

#pragma mark URL scheme
- (void)setupURLHandling {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject]
                        stringValue];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableDictionary *query = [NSMutableDictionary new];
    for (NSURLQueryItem *queryItem in [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO].queryItems) {
        query[queryItem.name] = queryItem.value ? : @"";
    }
    
    if ([url.scheme isEqualToString:@"flashlight-show"]) {
        [self.pluginListController showPluginWithName:url.host];
    } else if ([url.scheme isEqualToString:@"flashlight"]) {
        NSMutableArray *parts = [@[url.host] arrayByAddingObjectsFromArray:url.pathComponents].mutableCopy;
        if (parts.count >= 2) {
            [parts removeObjectAtIndex:1];
        }
        if (parts.count >= 2 && [parts[0] isEqualToString:@"plugin"]) {
            NSString *pluginName = parts[1];
            if (parts.count == 2) {
                [self.pluginListController showPluginWithName:pluginName];
            } else {
                if (parts.count == 3 && [parts[2] isEqualToString:@"preferences"]) {
                    [[PluginModel installedPluginNamed:parts[1]] presentOptionsInWindow:self.window];
                }
            }
        } else if (parts.count == 2 && [parts[0] isEqualToString:@"category"]) {
            [self.pluginListController showCategory:parts[1]];
        } else if (parts.count == 1 && [parts[0] isEqualToString:@"search"]) {
            [self.pluginListController showSearch:query[@"q"]];
        } else if (parts.count >= 1 && [parts[0] isEqualToString:@"preferences"]) {
            if (parts.count == 2 && [parts[1] isEqualToString:@"menuBarItem"]) {
                [self.aboutWindow makeKeyAndOrderFront:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // in case we're mid-launch — we don't want the main window to be made key above this window
                    [self.aboutWindow makeKeyAndOrderFront:nil];
                });
            }
        }
    }
}
#pragma mark Preferences
- (void)setupDefaults {
    NSDictionary *defaults = @{
                               @"ShowMenuItem": @YES
                               };
    for (NSString *key in defaults) {
        if (![[NSUserDefaults standardUserDefaults] valueForKey:key]) {
            [[NSUserDefaults standardUserDefaults] setValue:defaults[key] forKey:key];
        }
    }
}

- (IBAction)showMenuBarItemPressed:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nateparrott.Flashlight.DefaultsChanged" object:@"com.nateparrott.Flashlight" userInfo:nil options:NSNotificationPostToAllSessions | NSNotificationDeliverImmediately];
    });
}

#pragma mark Uninstallation

- (IBAction)uninstall:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Uninstall Flashlight?"];
    [alert setInformativeText:@"If you select \"Uninstall\", Flashlight will quit, and you can drag its app icon to the trash."];
    [alert addButtonWithTitle:@"Uninstall"]; // FirstButton, rightmost button
    [alert addButtonWithTitle:@"Cancel"]; // SecondButton
    alert.alertStyle = NSCriticalAlertStyle;
    NSModalResponse resp = [alert runModal];
    if (resp == NSAlertFirstButtonReturn) {
        if (self.SIMBLOn) {
            [self toggleFlashlightEnabled:nil];
        }
        [[NSWorkspace sharedWorkspace] selectFile:[[NSBundle mainBundle] bundlePath] inFileViewerRootedAtPath:nil];
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.5];
    }
}

@end
