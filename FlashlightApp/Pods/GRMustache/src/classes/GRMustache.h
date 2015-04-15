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

@protocol GRMustacheRendering;
@class GRMustacheTag;
@class GRMustacheContext;

/**
 * A C struct that hold GRMustache version information
 * 
 * @since v1.0
 */
typedef struct {
    int major;    /**< The major component of the version. */
    int minor;    /**< The minor component of the version. */
    int patch;    /**< The patch-level component of the version. */
} GRMustacheVersion;


/**
 * The GRMustache class provides with global-level information and configuration
 * of the GRMustache library.
 *
 * @since v1.0
 */
@interface GRMustache: NSObject

////////////////////////////////////////////////////////////////////////////////
/// @name Getting the GRMustache version
////////////////////////////////////////////////////////////////////////////////

/**
 * @return The version of GRMustache as a GRMustacheVersion struct.
 *
 * @since v7.0
 */
+ (GRMustacheVersion)libraryVersion AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Preventing NSUndefinedKeyException in Development configuration
////////////////////////////////////////////////////////////////////////////////

/**
 * Have GRMustache avoid most `NSUndefinedKeyExceptions` when rendering
 * templates.
 * 
 * The rendering of a GRMustache template can lead to `NSUndefinedKeyExceptions`
 * to be raised, because of the usage of the `valueForKey:` method. Those
 * exceptions are nicely handled by GRMustache, and are part of the regular
 * rendering of a template.
 *
 * Unfortunately, Objective-C exceptions have several drawbacks, particularly:
 * 
 * 1. they play badly with autorelease pools, and are reputed to leak memory.
 * 2. they usually stop your debugger when you are developping your application.
 * 
 * The first point is indeed a matter of worry: Apple does not guarantee that
 * exceptions raised by `valueForKey:` do not leak memory. However, I never had
 * any evidence of such a leak from NSObject's implementation.
 * 
 * Should you still worry, we recommend that you avoid the `valueForKey:` method
 * altogether. Instead, implement the [keyed subscripting](http://clang.llvm.org/docs/ObjectiveCLiterals.html#dictionary-style-subscripting)
 * `objectForKeyedSubscript:` method on objects that you provide to GRMustache.
 * 
 * The second point is valid also: NSUndefinedKeyException raised by template
 * rendering may become a real annoyance when you are debugging your project,
 * because it's likely you've told your debugger to stop on every Objective-C
 * exceptions.
 * 
 * You can avoid them as well: make sure you invoke once, early in your
 * application, the `preventNSUndefinedKeyExceptionAttack` method.
 * 
 * Depending on the number of NSUndefinedKeyException that get prevented, you
 * will experience a slight performance hit, or a performance improvement.
 * 
 * Since the main use case for this method is to avoid Xcode breaks on rendering
 * exceptions, the best practice is to conditionally invoke this method, using
 * the [NS_BLOCK_ASSERTIONS](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/Reference/reference.html)
 * that helps identifying the Debug configuration of your targets:
 * 
 * ```
 * #if !defined(NS_BLOCK_ASSERTIONS)
 * // Debug configuration: keep GRMustache quiet
 * [GRMustache preventNSUndefinedKeyExceptionAttack];
 * #endif
 * ```
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/runtime.md
 * 
 * @since v1.7
 */
+ (void)preventNSUndefinedKeyExceptionAttack AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Standard Library
////////////////////////////////////////////////////////////////////////////////

/**
 * @return The GRMustache standard library.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md
 *
 * @since v6.4
 */
+ (NSObject *)standardLibrary AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Building rendering objects
////////////////////////////////////////////////////////////////////////////////

/**
 * This method is deprecated. Use
 * `+[GRMustacheRendering renderingObjectForObject:]` instead.
 *
 * @see GRMustacheRendering class
 *
 * @since v6.0
 * @deprecated v7.0
 */
+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER_BUT_DEPRECATED;

/**
 * This method is deprecated. Use
 * `+[GRMustacheRendering renderingObjectWithBlock:]` instead.
 *
 * @see GRMustacheRendering class
 *
 * @since v6.0
 * @deprecated v7.0
 */
+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER_BUT_DEPRECATED;

@end

#import "GRMustacheTemplate.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheTemplateRepository.h"
#import "GRMustacheFilter.h"
#import "GRMustacheError.h"
#import "GRMustacheVersion.h"
#import "GRMustacheContentType.h"
#import "GRMustacheContext.h"
#import "GRMustacheRendering.h"
#import "GRMustacheTag.h"
#import "GRMustacheConfiguration.h"
#import "GRMustacheLocalizer.h"
#import "GRMustacheSafeKeyAccess.h"
#import "NSValueTransformer+GRMustache.h"
#import "NSFormatter+GRMustache.h"
