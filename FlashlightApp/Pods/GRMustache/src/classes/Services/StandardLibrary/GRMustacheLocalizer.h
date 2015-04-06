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
#import "GRMustacheRendering.h"
#import "GRMustacheFilter.h"

/**
 * GRMustacheLocalizer can localize the content of a Mustache section.
 * It also has a filter facet that localizes your data.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md#localize
 *
 * The GRMustache standard library has a `localize` key which returns a
 * GRMustacheLocalizer that localizes just like the NSLocalizableString macro
 * does: with the Localizable.strings table of the main bundle.
 *
 * ### Localizing data:
 *
 * `{{ localize(greeting) }}` renders `NSLocalizedString(@"Hello", nil)`,
 * assuming the `greeting` key resolves to the `Hello` string.
 *
 * ### Localizing sections:
 *
 * `{{#localize}}Hello{{/localize}}` renders `NSLocalizedString(@"Hello", nil)`.
 *
 * ### Localizing sections with arguments:
 *
 * `{{#localize}}Hello {{name}}{{/localize}}` builds the format string
 * `Hello %@`, localizes it with NSLocalizedString, and finally
 * injects the name with `[NSString stringWithFormat:]`.
 *
 * ### Localize sections with arguments and conditions:
 *
 * `{{#localize}}Good morning {{#title}}{{title}}{{/title}} {{name}}{{/localize}}`
 * build the format string `Good morning %@" or @"Good morning %@ %@`,
 * depending on the presence of the `title` key. It then injects the name, or
 * both title and name, with `[NSString stringWithFormat:]`, to build the final
 * rendering.
 *
 * ### Custom GRMustacheLocalizer
 *
 * You can build your own localizing helper with the initWithBundle:tableName:
 * method. The helper would then localize using the specified table from the
 * specified bundle.
 *
 * @since v6.4
 */
@interface GRMustacheLocalizer : NSObject<GRMustacheRendering, GRMustacheFilter> {
@private
    NSBundle *_bundle;
    NSString *_tableName;
    NSMutableArray *_formatArguments;
}

/**
 * Returns an initialized localizing helper.
 *
 * @param bundle     The bundle where to look for localized strings. If nil, the
 *                   main bundle is used.
 * @param tableName  The table where to look for localized strings. If nil, the
 *                   default Localizable.strings table would be searched.
 *
 * @return A newly initialized localizing helper.
 *
 * @since v6.4
 */
- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * The bundle where to look for localized strings.
 *
 * @since v6.4
 */
@property (nonatomic, retain, readonly) NSBundle *bundle AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

/**
 * The table where to look for localized strings.
 *
 * If nil, the default Localizable.strings table would be searched.
 *
 * @since v6.4
 */
@property (nonatomic, retain, readonly) NSString *tableName AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

@end

