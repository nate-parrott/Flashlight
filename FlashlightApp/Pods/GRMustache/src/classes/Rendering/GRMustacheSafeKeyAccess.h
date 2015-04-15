// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"


/**
 * Your data classes should conform to the GRMustacheSafeKeyAccess protocol
 * to filter the keys that can be accessed by GRMustache templates.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/runtime/security.md
 */
@protocol GRMustacheSafeKeyAccess <NSObject>

/**
 * List the name of the keys GRMustache can access on this class using the
 * `valueForKey:` method.
 *
 * When objects do not respond to this method, only declared properties can be
 * accessed. All properties of Core Data NSManagedObjects are also accessible,
 * even without property declaration.
 *
 * This method is not used for objects responding to `objectForKeyedSubscript:`.
 * For those objects, all keys are accessible from templates.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/security.md
 *
 * @return The set of accessible keys on the class.
 *
 * @since v7.0
 */
+ (NSSet *)safeMustacheKeys AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end
