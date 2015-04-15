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

@protocol GRMustacheTagDelegate;

/**
 * The GRMustacheContext represents a Mustache rendering context: it internally
 * maintains three stacks:
 *
 * - a *context stack*, that makes it able to provide the current context
 *   object, and to perform key lookup.
 *
 * - a *priority context stack*, whose objects define important keys that
 *   should not be overriden.
 *
 * - a *tag delegate stack*, so that tag delegates are notified when a Mustache
 *   tag is rendered.
 *
 * **Companion guides:**
 *
 * - https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/rendering_objects.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/security.md
 *
 * @warning GRMustacheContext is not suitable for subclassing.
 *
 * @see GRMustacheRendering protocol
 */
@interface GRMustacheContext : NSObject {
@private
#define GRMUSTACHE_STACK_TOP_IVAR(stackName) _ ## stackName ## Object
#define GRMUSTACHE_STACK_PARENT_IVAR(stackName) _ ## stackName ## Parent
#define GRMUSTACHE_STACK_DECLARE_IVARS(stackName, type) \
    GRMustacheContext *GRMUSTACHE_STACK_PARENT_IVAR(stackName); \
    type GRMUSTACHE_STACK_TOP_IVAR(stackName)
    
    GRMUSTACHE_STACK_DECLARE_IVARS(contextStack, id);
    GRMUSTACHE_STACK_DECLARE_IVARS(protectedContextStack, id);
    GRMUSTACHE_STACK_DECLARE_IVARS(hiddenContextStack, id);
    GRMUSTACHE_STACK_DECLARE_IVARS(tagDelegateStack, id<GRMustacheTagDelegate>);
    GRMUSTACHE_STACK_DECLARE_IVARS(inheritablePartialNodeStack, id);
    
    BOOL _unsafeKeyAccess;
}


////////////////////////////////////////////////////////////////////////////////
/// @name Creating Rendering Contexts
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns an initialized empty rendering context.
 *
 * Empty contexts do not provide any value for any key.
 *
 * If you wish to use the services provided by the GRMustache standard library,
 * you should create a context with the +[GRMustacheContext contextWithObject:]
 * method, like this:
 *
 * ```
 * [GRMustacheContext contextWithObject:[GRMustache standardLibrary]]
 * ```
 *
 * @return A rendering context.
 *
 * @see +[GRMustache standardLibrary]
 */
- (instancetype)init;

/**
 * Returns an empty rendering context.
 *
 * Empty contexts do not provide any value for any key.
 *
 * If you wish to use the services provided by the GRMustache standard library,
 * you should create a context with the +[GRMustacheContext contextWithObject:]
 * method, like this:
 *
 * ```
 * [GRMustacheContext contextWithObject:[GRMustache standardLibrary]]
 * ```
 *
 * @return A rendering context.
 *
 * @see contextWithObject:
 * @see +[GRMustache standardLibrary]
 *
 * @since v6.4
 */
+ (instancetype)context AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a rendering context containing a single object.
 *
 * Keys defined by _object_ gets available for template rendering.
 *
 * ```
 * context = [GRMustacheContext contextWithObject:@{ @"name": @"Arthur" }];
 * [context valueForMustacheKey:@"name"];   // @"Arthur"
 * ```
 *
 * If _object_ conforms to the GRMustacheTemplateDelegate protocol, it is also
 * made the top of the tag delegate stack.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param object  An object
 *
 * @return A rendering context.
 *
 * @see contextByAddingObject:
 *
 * @see GRMustacheTemplateDelegate
 *
 * @since v6.4
 */
+ (instancetype)contextWithObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a context containing a single priority object.
 *
 * Keys defined by _object_ are given priority, which means that they can not be
 * overriden by other objects that will eventually enter the context stack.
 *
 * ```
 * // Create a context with a priority `precious` key
 * context = [GRMustacheContext contextWithProtectedObject:@{ @"precious": @"gold" }];
 *
 * // Derive a new context by attempting to override the `precious` key:
 * context = [context contextByAddingObject:@{ @"precious": @"lead" }];
 *
 * // Priority keys can't be overriden
 * [context valueForMustacheKey:@"precious"];   // @"gold"
 * ```
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/security.md#priority-keys
 *
 * @param object  An object
 *
 * @return A rendering context.
 *
 * @see contextByAddingProtectedObject:
 *
 * @since v6.4
 */
+ (instancetype)contextWithProtectedObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a context containing a single tag delegate.
 *
 * _tagDelegate_ will be notified of the rendering of all tags rendered from the
 * receiver or from contexts derived from the receiver.
 *
 * Unlike contextWithObject: and contextWithProtectedObject:, _tagDelegate_ will
 * not provide any key to the templates. It will only be notified of the
 * rendering of tags.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param tagDelegate  A tag delegate
 *
 * @return A rendering context.
 *
 * @see GRMustacheTagDelegate
 *
 * @since v6.4
 */
+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Deriving New Contexts
////////////////////////////////////////////////////////////////////////////////


/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the context stack.
 *
 * Keys defined by _object_ gets available for template rendering, and override
 * the values defined by objects already contained in the context stack. Keys
 * unknown to _object_ will be looked up deeper in the context stack.
 *
 * ```
 * context = [GRMustacheContext contextWithObject:@{ @"a": @"ignored", @"b": @"foo" }];
 * context = [context contextByAddingObject:@{ @"a": @"bar" }];
 *
 * // `a` is overriden
 * [context valueForMustacheKey:@"a"];   // @"bar"
 *
 * // `b` is inherited
 * [context valueForMustacheKey:@"b"];   // @"foo"
 * ```
 *
 * _object_ can not override keys defined by the objects of the priority
 * context stack, though. See contextWithProtectedObject: and
 * contextByAddingProtectedObject:.
 *
 * If _object_ conforms to the GRMustacheTemplateDelegate protocol, it is also
 * added at the top of the tag delegate stack.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param object  An object
 *
 * @return A new rendering context.
 *
 * @see GRMustacheTemplateDelegate
 *
 * @since v6.0
 */
- (instancetype)contextByAddingObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the priority context stack.
 *
 * Keys defined by _object_ are given priority, which means that they can not be
 * overriden by other objects that will eventually enter the context stack.
 *
 * ```
 * // Derive a context with a priority `precious` key
 * context = [context contextByAddingProtectedObject:@{ @"precious": @"gold" }];
 *
 * // Derive a new context by attempting to override the `precious` key:
 * context = [context contextByAddingObject:@{ @"precious": @"lead" }];
 *
 * // Priority keys can't be overriden
 * [context valueForMustacheKey:@"precious"];   // @"gold"
 * ```
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/security.md#priority-keys
 *
 * @param object  An object
 *
 * @return A new rendering context.
 *
 * @since v6.0
 */
- (instancetype)contextByAddingProtectedObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the tag delegate stack.
 *
 * _tagDelegate_ will be notified of the rendering of all tags rendered from the
 * receiver or from contexts derived from the receiver.
 *
 * Unlike contextByAddingObject: and contextByAddingProtectedObject:,
 * _tagDelegate_ will not provide any key to the templates. It will only be
 * notified of the rendering of tags.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param tagDelegate  A tag delegate
 *
 * @return A new rendering context.
 *
 * @see GRMustacheTagDelegate
 *
 * @since v6.0
 */
- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Fetching Values from the Context Stack
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the object at the top of the receiver's context stack.
 *
 * The returned object is the same as the one that would be rendered by a
 * `{{ . }}` tag.
 *
 * ```
 * user = ...;
 * context = [GRMustacheContext contextWithObject:user];
 * context.topMustacheObject;  // user
 * ```
 *
 * @return The object at the top of the receiver's context stack.
 *
 * @see contextWithObject:
 * @see contextByAddingObject:
 *
 * @since v6.7
 */
@property (nonatomic, readonly) id topMustacheObject AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns the value stored in the context stack for the given key.
 *
 * If you want the value for an full expression such as `user.name` or
 * `uppercase(user.name)`, use the hasValue:forMustacheExpression:error:
 * method.
 *
 * ### Search Pattern for valueForMustacheKey
 *
 * The Mustache value of any object for a given key is defined as:
 *
 * 1. If the object responds to the `objectForKeyedSubscript:` instance method,
 *    return the result of this method.
 *
 * 2. Otherwise, build the list of safe keys:
 *    a. If the object responds to the `safeMustacheKeys` class method defined
 *       by the `GRMustacheSafeKeyAccess` protocol, use this method.
 *    b. Otherwise, use the list of Objective-C properties declared with
 *       `@property`.
 *    c. If object is an instance of NSManagedObject, add all the attributes of
 *       its Core Data entity.
 *
 * 3. If the key belongs to the list of safe keys, return the result of the
 *    `valueForKey:` method, unless this method throws NSUndefinedKeyException.
 *
 * 4. Otherwise, return nil.
 *
 * Contexts with unsafe key access skip the key validation step.
 *
 * In this method, the following search pattern is used:
 *
 * 1. Searches the priority context stack for an object that has a non-nil
 *    Mustache value for the key.
 *
 * 2. Otherwise (irrelevant priority context stack), search the context stack
 *    for an object that has a non-nil Mustache value for the key.
 *
 * 3. If none of the above situations occurs, returns nil.
 *
 * **Companion guides:** https://github.com/groue/GRMustache/blob/master/Guides/runtime.md,
 * https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 *
 * @param key  a key such as @"name"
 *
 * @return The value found in the context stack for the given key.
 *
 * @see contextWithUnsafeKeyAccess
 * @see hasValue:forMustacheExpression:error:
 *
 * @since v6.6
 */
- (id)valueForMustacheKey:(NSString *)key AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Evaluates an expression such as `name`, or `uppercase(user.name)`.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 *
 * @param value       Upon return contains the value of the expression.
 * @param expression  An expression.
 * @param error       If there is an error computing the value, upon return
 *                    contains an NSError object that describes the problem.
 *
 * @return YES if the value could be computed.
 *
 * @see valueForMustacheKey:
 *
 * @since v6.8
 */
- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)expression error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Unsafe Key Access
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns whether this context allows unsafe key access or not.
 *
 * @since v7.0
 */
@property (nonatomic, readonly) BOOL unsafeKeyAccess AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a new context with unsafe key access.
 *
 * Unsafe key access allows this context, and all contexts derived from it, to
 * access keys that are normally forbidden: keys that are not declared as
 * Objective-C properties, or keys that do not belong to the result of the
 * `safeMustacheKeys` method.
 *
 * Compare:
 *
 * ```
 * @interface DBRecord : NSObject
 * - (void)deleteRecord;
 * @end
 *
 * @implementation DBRecord
 * - (void)deleteRecord
 * {
 *     NSLog(@"Oooops, your record was just deleted!");
 * }
 * @end
 *
 * DBRecord *record = ...;
 * NSString *templateString = @"{{ deleteRecord }}";
 * GRMustacheTemplate * template = [GRMustacheTemplate templateWithString:templateString error:NULL];
 *
 * // Safe rendering of the dangerous template: record is not deleted.
 * [template renderObject:record error:NULL];
 *
 * // Unsafe rendering of the dangerous template: record is deleted.
 * template.baseContext = [GRMustacheContext contextWithUnsafeKeyAccess];
 * [template renderObject:record error:NULL];
 * ```
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/security.md
 *
 * @see GRMustacheSafeKeyAccess
 *
 * @since v7.0
 */
+ (instancetype)contextWithUnsafeKeyAccess AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Returns a new rendering context that is the copy of the receiver, with unsafe
 * key access.
 *
 * Unsafe key access allows this context, and all contexts derived from it, to
 * access keys that are normally forbidden: keys that are not declared as
 * Objective-C properties, or keys that do not belong to the result of the
 * `safeMustacheKeys` method.
 *
 * Compare:
 *
 * ```
 * @interface DBRecord : NSObject
 * - (void)deleteRecord;
 * @end
 *
 * @implementation DBRecord
 * - (void)deleteRecord
 * {
 *     NSLog(@"Oooops, your record was just deleted!");
 * }
 * @end
 *
 * DBRecord *record = ...;
 * NSString *templateString = @"{{ deleteRecord }}";
 * GRMustacheTemplate * template = [GRMustacheTemplate templateWithString:templateString error:NULL];
 *
 * // Safe rendering of the dangerous template: record is not deleted.
 * [template renderObject:record error:NULL];
 *
 * // Unsafe rendering of the dangerous template: record is deleted.
 * template.baseContext = [template.baseContext contextWithUnsafeKeyAccess];
 * [template renderObject:record error:NULL];
 * ```
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/security.md
 *
 * @see GRMustacheSafeKeyAccess
 *
 * @since v7.0
 */
- (instancetype)contextWithUnsafeKeyAccess AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end
