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
 * The content type of strings rendered by templates.
 *
 * @see GRMustacheConfiguration
 * @see GRMustacheTemplateRepository
 *
 * @since v6.2
 */
typedef NS_ENUM(NSUInteger, GRMustacheContentType) {
    /**
     * The `GRMustacheContentTypeHTML` content type has templates render HTML.
     * HTML template escape the input of variable tags such as `{{name}}`. Use
     * triple mustache tags `{{{content}}}` in order to avoid the HTML-escaping.
     *
     * @since v6.2
     */
    GRMustacheContentTypeHTML AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER,
    
    /**
     * The `GRMustacheContentTypeText` content type has templates render text.
     * They do not HTML-escape their input: `{{name}}` and `{{{name}}}` have
     * identical renderings.
     *
     * @since v6.2
     */
    GRMustacheContentTypeText AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER,
} AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER;

