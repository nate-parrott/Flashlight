/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import "SIMBL.h"

__attribute__((constructor))
static void EasySIMBLInitializer()
{
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SIMBL installPlugins];
        });
    }
}

__attribute__((visibility("default")))
OSErr InjectEventHandler(const AppleEvent *ev, AppleEvent *reply, long refcon)
{
	// do nothings, because sandboxed app call this. But leave this function for preventing errors are logged.
    // Now EasySIMBLInitializer() is used instead.
    SIMBLLogDebug(@"InjectEventHandler has called, but do nothings.");
	return noErr;
}

