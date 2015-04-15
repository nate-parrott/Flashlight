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
#import "GRMustacheAvailabilityMacros_private.h"

#if !defined(NS_BLOCK_ASSERTIONS)
/**
 * This global variable is used by GRPreventNSUndefinedKeyExceptionAttackTest.
 */
extern BOOL GRMustacheKeyAccessDidCatchNSUndefinedKeyException;
#endif

/**
 * GRMustacheKeyAccess implements all the GRMustache key-fetching logic.
 */
@interface GRMustacheKeyAccess : NSObject

/**
 * Avoids most NSUndefinedException to be raised by the invocation of
 * `valueForMustacheKey:inObject:`.
 *
 * @see valueForMustacheKey:inObject:
 */
+ (void)preventNSUndefinedKeyExceptionAttack GRMUSTACHE_API_INTERNAL;

/**
 * Sends the `objectForKeyedSubscript:` or `valueForKey:` message to object
 * with the provided key, and returns the result.
 *
 * If object responds to `objectForKeyedSubscript:`, `valueForKey:` is not
 * invoked.
 *
 * If `valueForKey:` raise an NSUndefinedKeyException, the method returns nil.
 *
 * @param key              The searched key
 * @param object           The queried object
 * @param unsafeKeyAccess  If YES, the `valueForKey:` method will be used
 *                         without any restriction.
 *
 * @return The value that should be handled by Mustache rendering for a given
 *         key.
 */
+ (id)valueForMustacheKey:(NSString *)key inObject:(id)object unsafeKeyAccess:(BOOL)unsafeKeyAccess GRMUSTACHE_API_INTERNAL;

@end
