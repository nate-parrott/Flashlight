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
#import "GRMustacheTemplateParser_private.h"
#import "GRMustacheContentType.h"

@class GRMustacheTemplateRepository;
@class GRMustacheTemplateAST;

/**
 * The GRMustacheCompiler interprets GRMustacheTokens provided by a
 * GRMustacheTemplateParser, and outputs a syntax tree of objects conforming to
 * the GRMustacheTemplateASTNode protocol.
 *
 * @see GRMustacheTemplateASTNode
 * @see GRMustacheToken
 * @see GRMustacheTemplateParser
 */
@interface GRMustacheCompiler : NSObject<GRMustacheTemplateParserDelegate> {
@private
    NSError *_fatalError;
    
    NSMutableArray *_currentASTNodes;
    NSMutableArray *_ASTNodesStack;
    
    GRMustacheToken *_currentOpeningToken;
    NSMutableArray *_openingTokenStack;
    
    NSObject *_currentTagValue;
    NSMutableArray *_tagValueStack;
    
    GRMustacheTemplateRepository *_templateRepository;
    id _baseTemplateID;
    GRMustacheContentType _contentType;
    BOOL _contentTypeLocked;
}

/**
 * The template repository that provides partial templates to the compiler.
 */
@property (nonatomic, assign) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_INTERNAL;

/**
 * ID of the currently compiled template
 */
@property (nonatomic, retain) id baseTemplateID GRMUSTACHE_API_INTERNAL;

/**
 * Returns an initialized compiler.
 *
 * @param contentType  The contentType that affects the compilation phase.
 *
 * @return a compiler
 */
- (instancetype)initWithContentType:(GRMustacheContentType)contentType GRMUSTACHE_API_INTERNAL;

/**
 * Returns a Mustache Abstract Syntax Tree.
 *
 * The AST will contain something if a GRMustacheTemplateParser has provided
 * GRMustacheToken instances to the compiler.
 *
 * For example:
 *
 * ```
 * // Create a Mustache compiler
 * GRMustacheCompiler *compiler = [[[GRMustacheCompiler alloc] initWithContentType:...] autorelease];
 *
 * // Some GRMustacheCompilerDataSource tells the compiler where are the
 * // partials.
 * compiler.dataSource = ...;
 *
 * // Create a Mustache parser
 * GRMustacheTemplateParser *parser = [[[GRMustacheTemplateParser alloc] initWithContentType:...] autorelease];
 *
 * // The parser feeds the compiler
 * parser.delegate = compiler;
 *
 * // Parse some string
 * [parser parseTemplateString:... templateID:...];
 *
 * // Extract template ASTNodes from the compiler
 * GRMustacheTemplateAST *templateAST = [compiler templateASTReturningError:...];
 * ```
 *
 * @param error  If there is an error building the abstract syntax tree, upon
 *               return contains an NSError object that describes the problem.
 *
 * @return A GRMustacheTemplateAST instance
 *
 * @see GRMustacheTemplateAST
 */
- (GRMustacheTemplateAST *)templateASTReturningError:(NSError **)error GRMUSTACHE_API_INTERNAL;
@end
