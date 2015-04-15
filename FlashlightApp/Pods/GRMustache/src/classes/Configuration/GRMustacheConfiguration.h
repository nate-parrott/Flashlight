// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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
#import "GRMustacheContentType.h"

@class GRMustacheContext;
@protocol GRMustacheTagDelegate;

/**
 * A GRMustacheConfiguration instance configures GRMustache rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/configuration.md
 *
 * The default configuration [GRMustacheConfiguration defaultConfiguration]
 * applies to all GRMustache rendering by default:
 *
 * ```
 * // Have GRMustache templates render text by default,
 * // and do not HTML-escape their input.
 * [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
 * ```
 *
 * You can also alter the configuration of a specific template repository: its
 * configuration only applies to the templates built by this very template
 * repository:
 *
 * ```
 * // All templates loaded from _repo_ will use [[ and ]] as tag delimiters.
 * GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithBundle:nil];
 * repo.configuration.tagStartDelimiter = @"[[";
 * repo.configuration.tagEndDelimiter = @"]]";
 * ```
 *
 * A third option is to create a new configuration, and assign it to the template:
 *
 * ```
 * // Create a configuration
 * GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
 * configuration.... // setup
 *
 * GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithBundle:nil];
 * repo.configuration = configuration;
 * ```
 *
 * The `contentType` option can be specified at the template level, so that your
 * repositories can mix HTML and text templates: see the documentation of this
 * property.
 *
 * The `tagStartDelimiter` and `tagEndDelimiter` options can also be specified
 * at the template level, using a "Set Delimiters tag": see the documentation of
 * these properties.
 *
 * @see GRMustacheTemplateRepository
 *
 * @since v6.2
 */
@interface GRMustacheConfiguration : NSObject<NSCopying> {
@private
    GRMustacheContentType _contentType;
    NSString *_tagStartDelimiter;
    NSString *_tagEndDelimiter;
    GRMustacheContext *_baseContext;
    BOOL _locked;
}


////////////////////////////////////////////////////////////////////////////////
/// @name Default Configuration
////////////////////////////////////////////////////////////////////////////////


/**
 * The default configuration.
 *
 * All templates and template repositories use the default configuration unless
 * you specify otherwise by setting the configuration of a template repository.
 *
 * The "default" defaultConfiguration has GRMustacheContentTypeHTML contentType,
 * and {{ and }} as tag delimiters.
 *
 * @returns The default configuration.
 *
 * @since v6.2
 */
+ (GRMustacheConfiguration *)defaultConfiguration AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Creating Configuration
////////////////////////////////////////////////////////////////////////////////


/**
 * @returns A new factory configuration.
 *
 * Its contentType is GRMustacheContentTypeHTML.
 * Its tag delimiters are {{ and }}.
 *
 * @since v6.2
 */
+ (GRMustacheConfiguration *)configuration AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Set Up Configuration
////////////////////////////////////////////////////////////////////////////////


/**
 * The base context for templates rendering. The default base context contains
 * the GRMustache standard Library.
 *
 * @see GRMustacheTemplate
 *
 * @since v6.4
 */
@property (nonatomic, retain) GRMustacheContext *baseContext AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Extends the base context of the receiver with the provided object, making its
 * keys available for all renderings.
 *
 * For example:
 *
 * ```
 * GRMustacheConfiguration *configuration = [GRMustacheConfiguration defaultConfiguration];
 *
 * // Have the `name` key defined for all template renderings:
 * id object = @{ @"name": @"Arthur" };
 * [configuration extendBaseContextWithObject:object];
 *
 * // Renders "Arthur"
 * [GRMustacheTemplate renderObject:nil fromString:@"{{name}}" error:NULL];
 * ```
 *
 * Keys defined by _object_ can be overriden by other objects that will
 * eventually enter the context stack:
 *
 * ```
 * // Renders "Billy", not "Arthur"
 * [GRMustacheTemplate renderObject:nil:@{ @"name": @"Billy" } fromString:@"{{name}}" error:NULL];
 * ```
 *
 * This method is a shortcut. It is equivalent to the following line of code:
 *
 * ```
 * configuration.baseContext = [configuration.baseContext contextByAddingObject:object];
 * ```
 *
 * @param object  An object
 *
 * @see baseContext
 * @see extendBaseContextWithProtectedObject:
 * @see extendBaseContextWithTagDelegate:
 *
 * @since v6.8
 */
- (void)extendBaseContextWithObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * Extends the base context of the receiver with the provided object, making its
 * keys available for all renderings.
 *
 * Keys defined by _object_ are given priority, which means that they can not be
 * overriden by other objects that will eventually enter the context stack.
 *
 * For example:
 *
 * ```
 * GRMustacheConfiguration *configuration = [GRMustacheConfiguration defaultConfiguration];
 *
 * // The `precious` key is given priority:
 * [configuration extendBaseContextWithProtectedObject:@{ @"precious": @"gold" }];
 *
 * // Renders "gold", not "lead".
 * [GRMustacheTemplate renderObject:nil:@{ @"precious": @"lead" } fromString:@"{{precious}}" error:NULL];
 * ```
 *
 * This method is a shortcut. It is equivalent to the following line of code:
 *
 * ```
 * configuration.baseContext = [configuration.baseContext contextByAddingProtectedObject:object];
 * ```
 *
 * @param object  An object
 *
 * @see baseContext
 * @see extendBaseContextWithObject:
 * @see extendBaseContextWithTagDelegate:
 *
 * @since v6.8
 */
- (void)extendBaseContextWithProtectedObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;;

/**
 * Extends the base context of the receiver with a tag delegate, making it aware
 * of the rendering of all template tags.
 *
 * This method is a shortcut. It is equivalent to the following line of code:
 *
 * ```
 * configuration.baseContext = [configuration.baseContext contextByAddingTagDelegate:tagDelegate];
 * ```
 *
 * @param tagDelegate  A tag delegate
 *
 * @see baseContext
 * @see extendBaseContextWithObject:
 * @see extendBaseContextWithProtectedObject:
 *
 * @since v6.8
 */
- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;;

/**
 * The content type of strings rendered by templates.
 *
 * This property affects the HTML-escaping of your data, and the inclusion
 * of templates in other templates.
 *
 * The `GRMustacheContentTypeHTML` content type has templates render HTML.
 * This is the default behavior. HTML template escape the input of variable tags
 * such as `{{name}}`. Use triple mustache tags `{{{content}}}` in order to
 * avoid the HTML-escaping.
 *
 * The `GRMustacheContentTypeText` content type has templates render text.
 * They do not HTML-escape their input: `{{name}}` and `{{{name}}}` have
 * identical renderings.
 *
 * GRMustache safely keeps track of the content type of templates: should a HTML
 * template embed a text template, the content of the text template would be
 * HTML-escaped.
 *
 * There is no API to specify the content type of individual templates. However,
 * you can use pragma tags right in the content of your templates:
 *
 * - `{{% CONTENT_TYPE:TEXT }}` turns a template into a text template.
 * - `{{% CONTENT_TYPE:HTML }}` turns a template into a HTML template.
 *
 * Insert those pragma tags early in your templates. For example:
 *
 * ```
 * {{! This template renders a bash script. }}
 * {{% CONTENT_TYPE:TEXT }}
 * export LANG={{ENV.LANG}}
 * ...
 * ```
 *
 * Should two such pragmas be found in a template content, the last one wins.
 *
 * @since v6.2
 */
@property (nonatomic) GRMustacheContentType contentType AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * The opening delimiter for Mustache tags. Its default value is `{{`.
 *
 * You can also change the delimiters right in your templates using a "Set
 * Delimiter tag": {{=[[ ]]=}} changes start and end delimiters to [[ and ]].
 *
 * @since v6.4
 */
@property (nonatomic, copy) NSString *tagStartDelimiter AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * The closing delimiter for Mustache tags. Its default value is `}}`.
 *
 * You can also change the delimiters right in your templates using a "Set
 * Delimiter tag": {{=[[ ]]=}} changes start and end delimiters to [[ and ]].
 *
 * @since v6.4
 */
@property (nonatomic, copy) NSString *tagEndDelimiter AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end
