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

/**
 * The kinds of tokens
 */
typedef NS_ENUM(NSInteger, GRMustacheTokenType) {
    
    /**
     * The kind of tokens representing raw template text.
     */
    GRMustacheTokenTypeText,
    
    /**
     * The kind of tokens representing escaped variable tags such as `{{name}}`.
     */
    GRMustacheTokenTypeEscapedVariable,
    
    /**
     * The kind of tokens representing a comment tag such as `{{! comment }}`.
     */
    GRMustacheTokenTypeComment,
    
    /**
     * The kind of tokens representing unescaped variable tag such as
     * `{{{name}}}` and `{{&name}}`.
     */
    GRMustacheTokenTypeUnescapedVariable,
    
    /**
     * The kind of tokens representing section opening tags such as `{{#name}}`.
     */
    GRMustacheTokenTypeSectionOpening,
    
    /**
     * The kind of tokens representing inverted section opening tags such as
     * `{{^name}}`.
     */
    GRMustacheTokenTypeInvertedSectionOpening,
    
    /**
     * The kind of tokens representing closing tags such as `{{/name}}`.
     */
    GRMustacheTokenTypeClosing,
    
    /**
     * The kind of tokens representing partial tags such as `{{>name}}`.
     */
    GRMustacheTokenTypePartial,
    
    /**
     * The kind of tokens representing delimiters tags such as `{{=< >=}}`.
     */
    GRMustacheTokenTypeSetDelimiter,
    
    /**
     * The kind of tokens representing pragma tags such as `{{%FILTERS}}`.
     */
    GRMustacheTokenTypePragma,
    
    /**
     * The kind of tokens representing inheritable partial tags such as
     * `{{<name}}`.
     */
    GRMustacheTokenTypeInheritablePartial,
    
    /**
     * The kind of tokens representing inheritable ection opening tags such as
     * `{{$name}}`.
     */
    GRMustacheTokenTypeInheritableSectionOpening,
};

/**
 * A GRMustacheToken is the product of GRMustacheTemplateParser. It represents a
 * {{Mustache}} tag, or raw text between tags.
 *
 * For example, the template string "hello {{name}}!" would be represented by
 * three tokens:
 *
 * - a token of type GRMustacheTokenTypeText holding "hello "
 * - a token of type GRMustacheTokenTypeEscapedVariable holding "{{name}}"
 * - a token of type GRMustacheTokenTypeText holding "!"
 */
@interface GRMustacheToken : NSObject {
@private
    GRMustacheTokenType _type;
    NSString *_templateString;
    id _templateID;
    NSUInteger _line;
    NSRange _range;
    NSRange _tagInnerRange;
}

/**
 * The type of the token.
 */
@property (nonatomic) GRMustacheTokenType type GRMUSTACHE_API_INTERNAL;

/**
 * The Mustache template string this token comes from.
 */
@property (nonatomic, retain) NSString *templateString GRMUSTACHE_API_INTERNAL;

/**
 * The template ID of the template this token comes from.
 *
 * @see GRMustacheTemplateRepository
 */
@property (nonatomic, retain) id templateID GRMUSTACHE_API_INTERNAL;

/**
 * The line in templateString where this token lies.
 */
@property (nonatomic) NSUInteger line GRMUSTACHE_API_INTERNAL;

/**
 * The range in templateString where this token lies.
 *
 * For tokens of type GRMustacheTokenTypeText, the range is the full range of
 * the represented text.
 *
 * For tokens of a tag type, the range is the full range of the tag, from
 * `{{` to `}}` included.
 */
@property (nonatomic) NSRange range GRMUSTACHE_API_INTERNAL;

/**
 * @see range
 */
@property (nonatomic, readonly) NSString *templateSubstring GRMUSTACHE_API_INTERNAL;

/**
 * The range of the inner content of the tag.
 *
 * GRMustacheTemplateParser sets it for tokens of types:
 *
 * - GRMustacheTokenTypeSetDelimiter
 * - GRMustacheTokenTypeComment;
 * - GRMustacheTokenTypeSectionOpening;
 * - GRMustacheTokenTypeInvertedSectionOpening;
 * - GRMustacheTokenTypeInheritableSectionOpening;
 * - GRMustacheTokenTypeClosing;
 * - GRMustacheTokenTypePartial;
 * - GRMustacheTokenTypeInheritablePartial;
 * - GRMustacheTokenTypeUnescapedVariable;
 * - GRMustacheTokenTypePragma;
 * - GRMustacheTokenTypeEscapedVariable;
 */
@property (nonatomic) NSRange tagInnerRange GRMUSTACHE_API_INTERNAL;

/**
 * @see tagInnerRange
 */
@property (nonatomic, readonly) NSString *tagInnerContent GRMUSTACHE_API_INTERNAL;

/**
 * Builds and return a token.
 */
+ (instancetype)tokenWithType:(GRMustacheTokenType)type templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range GRMUSTACHE_API_INTERNAL;
@end
