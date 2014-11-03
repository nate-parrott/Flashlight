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

@interface NSBundle (SIMBLCocoaExtensions)

- (NSDictionary*) SIMBL_infoDictionary;
- (id) SIMBL_objectForInfoDictionaryKey: (NSString*)key;
- (NSString*) _dt_info;
- (NSString*) _dt_version;
- (NSString*) _dt_bundleVersion;
- (NSString*) _dt_name;
- (BOOL) SIMBL_isLSUIElement;
- (BOOL) SIMBL_isLSBackgroundOnly;

@end

#define EasySIMBLApplicationSupportPathComponent @"Application Support/Flashlight"
#define EasySIMBLPluginsPathComponent @"Plugins"
#define EasySIMBLScriptingAdditionsPathComponent @"ScriptingAdditions"
#define EasySIMBLBundleBaseName @"Flashlight"
#define EasySIMBLBundleExtension @"osax"
#define EasySIMBLBundleName @"Flashlight.osax"
#define EasySIMBLPreferencesPathComponent @"Preferences"
#define EasySIMBLSuiteBundleIdentifier @"com.nateparrott.Flashlight"
#define EasySIMBLPreferencesExtension @"plist"
#define EasySIMBLHasBeenLoadedNotification @"FlashlightSIMBLHasBeenLoadedNotification"
#define EasySIMBLOriginalSIMBLAgentBundleIdentifier @"net.culater.SIMBL_Agent"

#define SIMBLStringTable @"SIMBLStringTable"
#define SIMBLApplicationIdentifier @"SIMBLApplicationIdentifier"
#define SIMBLTargetApplications @"SIMBLTargetApplications"
#define SIMBLBundleIdentifier @"BundleIdentifier"
#define SIMBLMinBundleVersion @"MinBundleVersion"
#define SIMBLMaxBundleVersion @"MaxBundleVersion"
#define SIMBLTargetApplicationPath @"TargetApplicationPath"
#define SIMBLRequiredFrameworks @"RequiredFrameworks"

#define SIMBLPrefKeyLogLevel @"SIMBLLogLevel"
#define SIMBLLogLevelDefault 2
#define SIMBLLogLevelNotice 2
#define SIMBLLogLevelInfo 1
#define SIMBLLogLevelDebug 0

@protocol SIMBLPlugin
+ (void) install;
@end

#define SIMBLLogDebug(format, ...) [SIMBL logMessage:[NSString stringWithFormat:format, ##__VA_ARGS__] atLevel:SIMBLLogLevelDebug]
#define SIMBLLogInfo(format, ...) [SIMBL logMessage:[NSString stringWithFormat:format, ##__VA_ARGS__] atLevel:SIMBLLogLevelInfo]
#define SIMBLLogNotice(format, ...) [SIMBL logMessage:[NSString stringWithFormat:format, ##__VA_ARGS__] atLevel:SIMBLLogLevelNotice]


@interface SIMBL : NSObject

+ (void) logMessage:(NSString*)message atLevel:(int)level;
+ (void) installPlugins;
+ (BOOL) shouldInstallPluginsIntoApplication:(NSRunningApplication*)runningApp;

+ (NSString*)applicationSupportPath;

@end
