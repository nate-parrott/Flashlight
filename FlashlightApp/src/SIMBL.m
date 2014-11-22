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

#import "SIMBL.h"
#import "NSAlert_SIMBL.h"

@implementation NSBundle (SIMBLCocoaExtensions)

/*!
 *  Non cached version of -infoDictionary
 *
 *  @return A dictionary, constructed from the bundle's Info.plist file, that contains information about the receiver.
 *          If the bundle does not contain an Info.plist file, a empty dictionary is returned.
 */
- (NSDictionary*) SIMBL_infoDictionary;
{
    NSString* infoPath = [[self bundlePath]stringByAppendingPathComponent:@"/Contents/Info.plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    return dictionary;
}

/*!
 *  Non cached and non localized version of -objectForInfoDictionaryKey: key
 *
 *  @param key A key in the receiver's property list.
 *
 *  @return The value associated with key in the receiver's property list (Info.plist).
 */
- (id) SIMBL_objectForInfoDictionaryKey: (NSString*)key
{
    return [[self SIMBL_infoDictionary]objectForKey:key];
}

- (NSString*) _dt_info
{
	return [self SIMBL_objectForInfoDictionaryKey: @"CFBundleGetInfoString"];
}

- (NSString*) _dt_version
{
	return [self SIMBL_objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

- (NSString*) _dt_bundleVersion
{
	return [self SIMBL_objectForInfoDictionaryKey: (NSString*)kCFBundleVersionKey];
}

- (NSString*) _dt_name
{
	return [self SIMBL_objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
}

- (BOOL) SIMBL_isLSUIElement
{
    return [[self SIMBL_objectForInfoDictionaryKey:@"LSUIElement"]boolValue];
}

- (BOOL) SIMBL_isLSBackgroundOnly
{
    return [[self SIMBL_objectForInfoDictionaryKey:@"LSBackgroundOnly"]boolValue];
}

@end

/*
 <key>SIMBLTargetApplications</key>
 <array>
 <dict>
 <key>BundleIdentifier</key>
 <string>com.apple.Safari</string>
 <key>MinBundleVersion</key>
 <integer>125</integer>
 <key>MaxBundleVersion</key>
 <integer>125</integer>
 </dict>
 </array>
 */

@implementation SIMBL

static NSMutableDictionary* loadedBundleIdentifiers = nil;

+ (void) initialize
{
    if (![[[NSBundle mainBundle]bundleIdentifier] isEqualToString:EasySIMBLSuiteBundleIdentifier]) {
        NSUserDefaults* defaults = [[NSUserDefaults alloc] init];
        [defaults addSuiteNamed:EasySIMBLSuiteBundleIdentifier];
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SIMBLLogLevelDefault], SIMBLPrefKeyLogLevel, nil]];
#if !__has_feature(objc_arc)
        [defaults release];
#endif
    }
}

+ (void) logMessage:(NSString*)message atLevel:(int)level
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![[[NSBundle mainBundle]bundleIdentifier] isEqualToString:EasySIMBLSuiteBundleIdentifier]) {
        [defaults addSuiteNamed:EasySIMBLSuiteBundleIdentifier];
    }
	if ([defaults integerForKey:SIMBLPrefKeyLogLevel] <= level) {
		NSLog(@"#Flashlight SIMBL%@", message);
	}
}

+ (NSArray*) pluginPathList
{
	NSMutableArray* pluginPathList = [NSMutableArray array];
    
    // NSApplicationSupportDirectory does not return Container, so use NSLibraryDirectory.
    
	/*NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,  NSUserDomainMask, YES);
	for (NSString* libraryPath in paths) {
		NSString* simblPath = [NSString pathWithComponents:[NSArray arrayWithObjects:libraryPath, EasySIMBLApplicationSupportPathComponent, EasySIMBLPluginsPathComponent, nil]];
        NSError *err = NULL;
		NSArray* simblBundles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:simblPath error:&err] pathsMatchingExtensions:[NSArray arrayWithObject:@"bundle"]];
        if (err) {
            SIMBLLogNotice(@"contentsOfDirectoryAtPath err:%@",err);
        }
		for (NSString* bundleName in simblBundles) {
			[pluginPathList addObject:[simblPath stringByAppendingPathComponent:bundleName]];
		}
	}*/
    
    //NSString* simblPath = [[[NSBundle bundleWithIdentifier:@"com.nateparrott.Flashlight.SIMBL-Agent"] resourcePath] stringByAppendingPathComponent:@"SIMBLPlugins"];
    NSString *simblPath = [[[[[[[[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.nateparrott.Flashlight"] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"LoginItems"] stringByAppendingPathComponent:@"FlashlightSIMBLAgent.app"] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:@"SIMBLPlugins"];
    NSError *err = NULL;
    NSArray* simblBundles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:simblPath error:&err] pathsMatchingExtensions:[NSArray arrayWithObject:@"bundle"]];
    if (err) {
        SIMBLLogNotice(@"contentsOfDirectoryAtPath err:%@ in path %@",err, simblPath);
    }
    for (NSString* bundleName in simblBundles) {
        [pluginPathList addObject:[simblPath stringByAppendingPathComponent:bundleName]];
    }
    
    SIMBLLogNotice(@"Got plugins: %@ from %@", [simblBundles componentsJoinedByString:@", "], simblPath);
    
	return pluginPathList;
}


+ (void) installPlugins
{
	if (loadedBundleIdentifiers == nil)
		loadedBundleIdentifiers = [[NSMutableDictionary alloc] init];
	
	SIMBLLogDebug(@"SIMBL loaded by path %@ <%@>", [[NSBundle mainBundle] bundlePath], [[NSBundle mainBundle]bundleIdentifier]);
	
	for (NSString* path in [SIMBL pluginPathList]) {
		BOOL bundleLoaded = [SIMBL loadBundleAtPath:path];
		if (bundleLoaded)
			SIMBLLogDebug(@"loaded %@", path);
	}
    
    [[NSDistributedNotificationCenter defaultCenter]postNotificationName:EasySIMBLHasBeenLoadedNotification
                                                                  object:[[NSBundle mainBundle]bundleIdentifier]];
}


+ (BOOL) shouldInstallPluginsIntoApplication:(NSRunningApplication*)runningApp;
{
  if (![runningApp.bundleIdentifier isEqualToString:@"com.apple.Spotlight"]) return NO;
    
	return YES;
}


+ (NSString*)applicationSupportPath;
{
    static NSString *applicationSupportPath = nil;
    if (!applicationSupportPath) {
        
        // NSApplicationSupportDirectory does not return Container, so use NSLibraryDirectory.
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,  NSUserDomainMask, YES);
        applicationSupportPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:EasySIMBLApplicationSupportPathComponent];
    }
    return applicationSupportPath;
}

/**
 * get this list of allowed application identifiers from the plugin's Info.plist
 * the special value * will cause any Cocoa app to load a bundle
 * @return YES if this should be loaded
 */
+ (BOOL) shouldLoadBundleAtPath:(NSString*)_bundlePath
{
	NSRunningApplication *runningApp = [NSRunningApplication currentApplication];
	return [SIMBL shouldApplication:runningApp loadBundleAtPath:_bundlePath];
}


/**
 * get this list of allowed application identifiers from the plugin's Info.plist
 * the special value * will cause any Cocoa app to load a bundle
 * @return YES if this should be loaded
 */
+ (BOOL) shouldApplication:(NSRunningApplication*)runningApp loadBundleAtPath:(NSString*)_bundlePath
{
	SIMBLLogDebug(@"checking bundle %@", _bundlePath);
	_bundlePath = [_bundlePath stringByStandardizingPath];
	NSBundle* pluginBundle = [NSBundle bundleWithPath:_bundlePath];
	if (pluginBundle == nil) {
		SIMBLLogNotice(@"Unable to load bundle at path '%@'", _bundlePath);
		return NO;
	}
	
	NSString* pluginIdentifier = [pluginBundle bundleIdentifier];
	if (pluginIdentifier == nil) {
		SIMBLLogNotice(@"No identifier for bundle at path '%@'", _bundlePath);
		return NO;
	}
	
	// this is the new way of specifying when to load a bundle
	NSArray* targetApplications = [pluginBundle SIMBL_objectForInfoDictionaryKey:SIMBLTargetApplications];
	if (targetApplications)
		return [self shouldApplication:runningApp loadBundle:pluginBundle withTargetApplications:targetApplications];
	
	// fall back to the old method for older plugins - we should probably throw a depreaction warning
	NSArray* applicationIdentifiers = [pluginBundle SIMBL_objectForInfoDictionaryKey:SIMBLApplicationIdentifier];
	if (applicationIdentifiers)
		return [self shouldApplication:runningApp loadBundle:pluginBundle withApplicationIdentifiers:applicationIdentifiers];
	
	return NO;
}


/**
 * get this list of allowed application identifiers from the plugin's Info.plist
 * the special value * will cause any Cocoa app to load a bundle
 * if there is a match, this calls the main bundle's load method
 * @return YES if this bundle was loaded
 */
+ (BOOL) loadBundleAtPath:(NSString*)_bundlePath
{
	if ([SIMBL shouldLoadBundleAtPath:_bundlePath] == NO) {
		return NO;
	}
	
	NSBundle* pluginBundle = [NSBundle bundleWithPath:_bundlePath];
    
	// check to see if we already loaded code for this identifier (keeps us from double loading)
	// this is common if you have User vs. System-wide installs - probably mostly for developers
	// "physician, heal thyself!"
	NSString* pluginIdentifier = [pluginBundle bundleIdentifier];
	if ([loadedBundleIdentifiers objectForKey:pluginIdentifier] != nil)
		return NO;
	return [SIMBL loadBundle:pluginBundle];
}


/**
 * get this list of allowed application identifiers from the plugin's Info.plist
 * the special value * will cause any Cocoa app to load a bundle
 * if there is a match, this calls the main bundle's load method
 * @return YES if this bundle should be loaded
 */
+ (BOOL) shouldApplication:(NSRunningApplication*)runningApp loadBundle:(NSBundle*)_bundle withApplicationIdentifiers:(NSArray*)_applicationIdentifiers
{
	NSString* appIdentifier = [runningApp bundleIdentifier];
	for (NSString* specifiedIdentifier in _applicationIdentifiers) {
		SIMBLLogDebug(@"checking bundle %@ for identifier %@", [_bundle bundleIdentifier], specifiedIdentifier);
		if ([specifiedIdentifier isEqualToString:appIdentifier] == YES ||
            // wildcard targeting plugins should not be loaded into background apps or agent apps
			([specifiedIdentifier isEqualToString:@"*"] == YES &&
             runningApp.activationPolicy != NSApplicationActivationPolicyAccessory &&
             runningApp.activationPolicy != NSApplicationActivationPolicyProhibited)) {
			SIMBLLogDebug(@"load bundle %@", [_bundle bundleIdentifier]);
			SIMBLLogNotice(@"The plugin %@ (%@) is using a deprecated interface to SIMBL. Please contact the appropriate developer (not the SIMBL author) and refer them to http://code.google.com/p/simbl/wiki/Tutorial", [_bundle bundlePath], [_bundle bundleIdentifier]);
			return YES;
		}
	}
	
	return NO;
}


/**
 * get this list of allowed target applications from the plugin's Info.plist
 * the special value * will cause any Cocoa app to load a bundle
 * if there is a match, this calls the main bundle's load method
 * @return YES if this bundle should be loaded
 */
+ (BOOL) shouldApplication:(NSRunningApplication*)runningApp loadBundle:(NSBundle*)_bundle withTargetApplications:(NSArray*)_targetApplications
{
	NSString* appIdentifier = [runningApp bundleIdentifier];
    NSURL *bundleURL = runningApp.bundleURL;
    NSBundle *_appBundle = bundleURL ? [NSBundle bundleWithURL:bundleURL] : nil;
	for (NSDictionary* targetAppProperties in _targetApplications) {
		NSString* targetAppIdentifier = [targetAppProperties objectForKey:SIMBLBundleIdentifier];
		SIMBLLogDebug(@"checking target identifier %@", targetAppIdentifier);
        
        // wildcard targeting plugins should not be loaded into background apps or agent apps
        if ([targetAppIdentifier isEqualToString:@"*"] == YES &&
            (runningApp.activationPolicy == NSApplicationActivationPolicyAccessory ||
             runningApp.activationPolicy == NSApplicationActivationPolicyProhibited))
            continue;
        
		if ([targetAppIdentifier isEqualToString:appIdentifier] == NO &&
            [targetAppIdentifier isEqualToString:@"*"] == NO)
			continue;
        
		NSString* targetAppPath = [targetAppProperties objectForKey:SIMBLTargetApplicationPath];
		if (targetAppPath && [targetAppPath isEqualToString:[_appBundle bundlePath]] == NO)
			continue;
        
		// FIXME: this has never been used - it should probably be removed.
		NSArray* requiredFrameworks = [targetAppProperties objectForKey:SIMBLRequiredFrameworks];
		BOOL missingFramework = NO;
		if (requiredFrameworks)
		{
			SIMBLLogDebug(@"requiredFrameworks: %@", requiredFrameworks);
			NSEnumerator* requiredFrameworkEnum = [requiredFrameworks objectEnumerator];
			NSDictionary* requiredFramework;
			while ((requiredFramework = [requiredFrameworkEnum nextObject]) && missingFramework == NO)
			{
				NSBundle* framework = [NSBundle bundleWithIdentifier:[requiredFramework objectForKey:@"BundleIdentifier"]];
				NSString* frameworkPath = [framework bundlePath];
				NSString* requiredPath = [requiredFramework objectForKey:@"BundlePath"];
				if ([frameworkPath isEqualToString:requiredPath] == NO) {
					missingFramework = YES;
				}
			}
		}
		
		if (missingFramework)
			continue;
		
		int appVersion = [[_appBundle _dt_bundleVersion] intValue];
		
		int minVersion = 0;
		NSNumber* number;
		if ((number = [targetAppProperties objectForKey:SIMBLMinBundleVersion]))
			minVersion = [number intValue];
        
		int maxVersion = 0;
		if ((number = [targetAppProperties objectForKey:SIMBLMaxBundleVersion]))
			maxVersion = [number intValue];
		
		if ((maxVersion && appVersion > maxVersion) || (minVersion && appVersion < minVersion))
		{
			// [NSAlert errorAlert:NSLocalizedStringFromTableInBundle(@"Error", SIMBLStringTable, [NSBundle bundleForClass:[self class]], @"Error alert primary message") withDetails:NSLocalizedStringFromTableInBundle(@"%@ %@ (v%@) has not been tested with the plugin %@ %@ (v%@). As a precaution, it has not been loaded. Please contact the plugin developer for further information.", SIMBLStringTable, [NSBundle bundleForClass:[self class]], @"Error alert details, substitute application and plugin version strings"), [_appBundle _dt_name], [_appBundle _dt_version], [_appBundle _dt_bundleVersion], [_bundle _dt_name], [_bundle _dt_version], [_bundle _dt_bundleVersion]];
			continue;
		}
		
		return YES;
	}
	
	return NO;
}

+ (BOOL) isRunningOriginalSIMBLAgent
{
    return [[NSRunningApplication runningApplicationsWithBundleIdentifier:EasySIMBLOriginalSIMBLAgentBundleIdentifier]count];
}

+ (BOOL) loadBundle:(NSBundle*)_plugin
{
	@try
	{
		// getting the principalClass should force the bundle to load
		NSBundle* bundle = [NSBundle bundleWithPath:[_plugin bundlePath]];
		Class principalClass = [bundle principalClass];
		
		// if the principal class has an + (void) install message, call it
		if (principalClass && [principalClass respondsToSelector:@selector(install)]) {
            if ([self isRunningOriginalSIMBLAgent]) {
                SIMBLLogNotice(@"It seems the original SIMBL Agent is running. So, I don't call +install because which cause double initialization problem of plugin.");
            } else {
                [principalClass install];
            }
        }
		
		// set that we've loaded this bundle to prevent collisions
		[loadedBundleIdentifiers setObject:@"loaded" forKey:[bundle bundleIdentifier]];
		
		return YES;
	}
	@catch (NSException* exception)
	{
		[NSAlert errorAlert:NSLocalizedStringFromTableInBundle(@"Error", SIMBLStringTable, [NSBundle bundleForClass:[self class]], @"Error alert primary message") withDetails:NSLocalizedStringFromTableInBundle(@"Failed to load the %@ plugin.\n%@", SIMBLStringTable, [NSBundle bundleForClass:[self class]], @"Error alert details, sub plugin name and error reason"), [_plugin _dt_name], [exception reason]];
	}
	
	return NO;
}

@end
