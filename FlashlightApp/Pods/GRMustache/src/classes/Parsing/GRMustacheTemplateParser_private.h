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

@class GRMustacheToken;
@class GRMustacheTemplateParser;
@class GRMustacheConfiguration;


// =============================================================================
#pragma mark - <GRMustacheTemplateParserDelegate>

/**
 * The protocol for the delegate of a GRMustacheTemplateParser.
 *
 * The delegate's responsability is to consume tokens and handle parser
 * errors.
 *
 * @see GRMustacheCompiler
 */
@protocol GRMustacheTemplateParserDelegate<NSObject>
@optional

/**
 * Sent after the parser has parsed a token.
 *
 * @param parser   The parser that did find a token.
 * @param token       The token
 *
 * @return YES if the parser should continue producing tokens; otherwise, NO.
 *
 * @see GRMustacheToken
 */
- (BOOL)templateParser:(GRMustacheTemplateParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token GRMUSTACHE_API_INTERNAL;

/**
 * Sent after the token has failed.
 *
 * @param parser   The parser that failed to producing tokens.
 * @param error       The error that occurred.
 */
- (void)templateParser:(GRMustacheTemplateParser *)parser didFailWithError:(NSError *)error GRMUSTACHE_API_INTERNAL;
@end


// =============================================================================
#pragma mark - GRMustacheTemplateParser

/**
 * The GRMustacheTemplateParser consumes a Mustache template string, and
 * produces tokens.
 *
 * Those tokens are consumed by the parser's delegate.
 *
 * @see GRMustacheToken
 * @see GRMustacheTemplateParserDelegate
 */
@interface GRMustacheTemplateParser : NSObject {
@private
    id<GRMustacheTemplateParserDelegate> _delegate;
    NSString *_tagStartDelimiter;
    NSString *_tagEndDelimiter;
}

/**
 * The parser's delegate.
 *
 * The delegate is sent messages as the parser interprets a Mustache template
 * string.
 *
 * @see GRMustacheTemplateParserDelegate
 */
@property (nonatomic, assign) id<GRMustacheTemplateParserDelegate> delegate GRMUSTACHE_API_INTERNAL;

/**
 * Returns an initialized parser.
 *
 * @param configuration  The GRMustacheConfiguration that affects the
 *                       parsing phase.
 * @return a compiler
 */
- (instancetype)initWithConfiguration:(GRMustacheConfiguration *)configuration GRMUSTACHE_API_INTERNAL;

/**
 * The parser will invoke its delegate as it builds tokens from the template
 * string.
 *
 * @param templateString  A Mustache template string
 * @param templateID      A template ID (see GRMustacheTemplateRepository)
 */
- (void)parseTemplateString:(NSString *)templateString templateID:(id)templateID GRMUSTACHE_API_INTERNAL;

/**
 * Returns a template name from a string.
 *
 * @param string  A string.
 * @param empty   If there is an error parsing a template name, upon return
 *                contains YES if the string contains no information.
 * @param error   If there is an error parsing a template name, upon return
 *                contains an NSError object that describes the problem.
 *
 * @return a template name, or nil if the string is not a partial name.
 */
- (NSString *)parseTemplateName:(NSString *)string empty:(BOOL *)empty error:(NSError **)error GRMUSTACHE_API_INTERNAL;

/**
 * Returns an inheritable section name from a string.
 *
 * @param string  A string.
 * @param empty   If there is an error parsing an identifier, upon return
 *                contains YES if the string contains no information.
 * @param error   If there is an error parsing an identifier, upon return
 *                contains an NSError object that describes the problem.
 *
 * @return a template name, or nil if the string is not a partial name.
 */
- (NSString *)parseInheritableSectionName:(NSString *)string empty:(BOOL *)empty error:(NSError **)error GRMUSTACHE_API_INTERNAL;

/**
 * Returns a pragma from a string
 *
 * @param string  A string
 *
 * @return a pragma, or nil if the string is not a pragma.
 */
- (NSString *)parsePragma:(NSString *)string GRMUSTACHE_API_INTERNAL;

@end
