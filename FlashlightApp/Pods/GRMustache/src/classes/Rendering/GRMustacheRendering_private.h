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
#import "GRMustacheContentType.h"

// prevent GRMustacheFilter.h to load
#define GRMUSTACHE_RENDERING


@class GRMustacheContext;
@class GRMustacheTag;
@class GRMustacheTemplateRepository;


// =============================================================================
#pragma mark - <GRMustacheRendering>


// Documented in GRMustacheRendering.h
@protocol GRMustacheRendering <NSObject>
@required

// Documented in GRMustacheRendering.h
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error GRMUSTACHE_API_PUBLIC;

@optional

/**
 * The boolean value of the rendering object.
 *
 * A YES boolean value triggers the rendering of {{#section}}...{{/section}}
 * tags, and avoids the rendering of inverted {{^section}}...{{/section}} tags.
 *
 * A NO boolean value avoids the rendering of {{#section}}...{{/section}}
 * tags, and triggers the rendering of inverted {{^section}}...{{/section}} tags.
 *
 * When this method is not provided, the rendering object is assumed to be
 * true.
 */
@property (nonatomic, readonly) BOOL mustacheBoolValue GRMUSTACHE_API_INTERNAL;

@end


// =============================================================================
#pragma mark - <GRMustacheRenderingWithEnumerationSupport>

/**
 * The GRMustacheRenderingWithIterationSupport protocol is a private extension
 * to the public GRMustacheRendering protocol.
 *
 * Objects conforming to this protocol can have a different rendering when
 * they render as an enumeration item.
 *
 * Use cases are:
 *
 * - An NSNumber does not enter the context stack when it renders a
 *   section, as in {{# 1 }}...{{/}}.
 *
 * - An NSNumber does enter the context stack when it renders as an enumeration
 *   item, as in {{# [0,1,2] }}...{{/}}.
 *
 * - An enumerable object renders all of its items when it renders a
 *   section, as in {{# [a,b,c] }}...{{/}}.
 *
 * - An enumerable object have itself enter the context stack when it renders as
 *   an enumeration item, as in {{# [[a,b,c],[d,e,f]] }}...{{/}}.
 */
@protocol GRMustacheRenderingWithIterationSupport <GRMustacheRendering>
@required

/**
 * This method is invoked when the receiver should be rendered by a Mustache
 * tag.
 *
 * It returns three values: the rendering itself, a boolean that says whether
 * the rendering is HTML-safe or not, and an eventual error.
 *
 * Input values are the tag that should be rendered, the context object that
 * represents the current context stack, and whether the object renders as an
 * enumeratiom item or not.
 *
 * Depending on the content type of the currently rendered template, an output
 * parameter _HTMLSafe_ set to NO will have the returned string HTML-escaped.
 *
 * @param tag              The tag to be rendered
 * @param enumerationItem  YES if the receiver renders as an enumeration item.
 * @param context          A context for rendering inner tags.
 * @param HTMLSafe         Upon return contains YES if the result is HTML-safe.
 * @param error            If there is an error performing the rendering, upon
 *                         return contains an NSError object that describes the
 *                         problem.
 *
 * @return The rendering of the receiver.
 *
 * @see GRMustacheTag
 * @see GRMustacheContext
 * @see GRMustacheContentType
 *
 * @since v6.0
 */
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                 asEnumerationItem:(BOOL)enumerationItem
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error GRMUSTACHE_API_INTERNAL;

@end



// =============================================================================
#pragma mark - GRMustacheRendering

// Documented in GRMustacheRendering.h
@interface GRMustacheRendering : NSObject

// Documented in GRMustacheRendering.h
+ (id<GRMustacheRenderingWithIterationSupport>)renderingObjectForObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheRendering.h
+ (id<GRMustacheRenderingWithIterationSupport>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock GRMUSTACHE_API_PUBLIC;

+ (void)pushCurrentTemplateRepository:(GRMustacheTemplateRepository *)templateRepository GRMUSTACHE_API_INTERNAL;
+ (void)popCurrentTemplateRepository GRMUSTACHE_API_INTERNAL;
+ (GRMustacheTemplateRepository *)currentTemplateRepository GRMUSTACHE_API_INTERNAL;

+ (void)pushCurrentContentType:(GRMustacheContentType)contentType GRMUSTACHE_API_INTERNAL;
+ (void)popCurrentContentType GRMUSTACHE_API_INTERNAL;
+ (GRMustacheContentType)currentContentType GRMUSTACHE_API_INTERNAL;

@end

