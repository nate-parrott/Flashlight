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

@class GRMustacheTemplateRepository;

/**
 * The types of Mustache tags
 *
 * @since v6.0
 */
typedef NS_ENUM(NSUInteger, GRMustacheTagType) {
    /**
     * The type for variable tags such as `{{name}}`.
     *
     * @since v6.0
     */
    GRMustacheTagTypeVariable = 1 << 1 AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER,
    
    /**
     * The type for regular and inverted section tags, such as
     * `{{#name}}...{{/name}}` and `{{#name}}...{{/name}}`.
     *
     * @since v6.0
     */
    GRMustacheTagTypeSection = 1 << 2 AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER,
    
} AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * The type for inverted section tags such as {{^ name }}...{{/}}
 *
 * This value is deprecated.
 *
 * @since v6.0
 * @deprecated v7.2
 */
AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_7_2 static GRMustacheTagType const GRMustacheTagTypeInvertedSection = 1 << 3;

/**
 * GRMustacheTag instances represent Mustache tags that render values, such as
 * a variable tag `{{ name }}`, or a section tag `{{# name }}...{{/ })`.
 *
 * **Companion guides:**
 * 
 * - https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/rendering_objects.md
 */
@interface GRMustacheTag: NSObject


////////////////////////////////////////////////////////////////////////////////
/// @name Tag Information
////////////////////////////////////////////////////////////////////////////////


/**
 * The type of the tag
 */
@property (nonatomic, readonly) GRMustacheTagType type AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns the literal and unprocessed inner content of the tag.
 *
 * A section tag such as `{{# name }}inner content{{/}}` returns `inner content`.
 *
 * Variable tags such as `{{ name }}` have no inner content: their inner
 * template string is the empty string.
 */
@property (nonatomic, readonly) NSString *innerTemplateString AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns the description of the tag.
 *
 * For example:
 *
 * ```
 * <GRMustacheVariableTag `{{ name }}` at line 18 of template /path/to/Document.mustache>
 * ```
 */
- (NSString *)description;

////////////////////////////////////////////////////////////////////////////////
/// @name Methods Dedicated to the GRMustacheRendering Protocol
////////////////////////////////////////////////////////////////////////////////

/**
 * This method is deprecated.
 *
 * Replace `[tag.templateRepository templateFromString:... error:...]` with
 * `[GRMustacheTemplate templateFromString:... error:...]`.
 *
 * Replace `[tag.templateRepository templateNamed:... error:...]` with explicit
 * invocation of the targeted template repository.
 *
 * @since v6.0
 * @deprecated v7.0
 */
@property (nonatomic, readonly) GRMustacheTemplateRepository *templateRepository AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER_BUT_DEPRECATED;

/**
 * Returns the rendering of the tag's inner content, rendering all inner
 * Mustache tags with the rendering context argument.
 *
 * This method is intended for objects conforming to the GRMustacheRendering
 * protocol. The following Guides show some use cases for this method:
 *
 * - https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/rendering_objects.md
 *
 * Note that variable tags such as `{{ name }}` have no inner content, and
 * return the empty string.
 *
 * @param context   A context for rendering inner tags.
 * @param HTMLSafe  Upon return contains YES or NO, depending on the content
 *                  type of the tag's template, as set by the configuration of
 *                  the source template repository. HTML templates yield YES,
 *                  text templates yield NO.
 * @param error     If there is an error rendering the tag, upon return contains
 *                  an NSError object that describes the problem.
 *
 * @see GRMustacheRendering
 * @see GRMustacheContext
 *
 * @return The rendering of the tag's inner content.
 */
- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end
