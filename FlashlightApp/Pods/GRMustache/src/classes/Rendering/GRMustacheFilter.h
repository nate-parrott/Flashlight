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

#ifndef GRMUSTACHE_FILTER
#define GRMUSTACHE_FILTER

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"


// =============================================================================
#pragma mark - <GRMustacheFilter>


/**
 * The protocol for implementing GRMustache filters.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/filters.md
 *
 * The responsability of a GRMustacheFilter is to transform a value into
 * another.
 *
 * For example, the tag `{{ uppercase(name) }}` uses a filter object that
 * returns the uppercase version of its input.
 *
 * @since v4.3
 */
@protocol GRMustacheFilter <NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Transforming Values
////////////////////////////////////////////////////////////////////////////////

/**
 * Applies some transformation to its input, and returns the transformed value.
 *
 * @param object  An object to be processed by the filter.
 *
 * @return A transformed value.
 *
 * @since v4.3
 */
- (id)transformedValue:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end



// =============================================================================
#pragma mark - GRMustacheFilter

/**
 * The GRMustacheFilter class helps building mustache filters without writing a
 * custom class that conforms to the GRMustacheFilter protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/filters.md
 *
 * @see GRMustacheFilter protocol
 *
 * @since v4.3
 */ 
@interface GRMustacheFilter : NSObject<GRMustacheFilter>

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Filters
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheFilter object that executes the provided block when
 * tranforming a value.
 *
 * @param block   The block that transforms its input.
 *
 * @return a GRMustacheFilter object.
 *
 * @since v4.3
 *
 * @see variadicFilterWithBlock:
 */
+ (id<GRMustacheFilter>)filterWithBlock:(id(^)(id value))block AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a GRMustacheFilter object that executes the provided block, given an
 * array of arguments.
 *
 * Those filters can evaluate expressions like `{{ f(a,b) }}`.
 *
 * GRMustache will invoke the filter regardless of the number of arguments in
 * the template: `{{ f(a) }}`, `{{ f(a,b) }}` and `{{ f(a,b,c) }}` will provide
 * arrays of 1, 2, and 3 arguments respectively. It is your responsability to
 * check that you are provided with as many arguments as you expect.
 *
 * @param block   The block that transforms its input.
 *
 * @return a GRMustacheFilter object.
 *
 * @since v5.5
 *
 * @see filterWithBlock:
 */
+ (id<GRMustacheFilter>)variadicFilterWithBlock:(id(^)(NSArray *arguments))block AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end

#endif
