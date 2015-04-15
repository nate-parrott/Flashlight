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

#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheTemplateASTNode_private.h"

@class GRMustacheTemplateAST;

/**
 * A GRMustachePartialNode is an AST node that represents partial tags as
 * `{{>name}}`.
 */
@interface GRMustachePartialNode : NSObject<GRMustacheTemplateASTNode> {
@private
    NSString *_name;
    GRMustacheTemplateAST *_templateAST;
}

/**
 * The name of the partial:
 *
 *     {{> name }}
 */
@property (nonatomic, retain, readonly) NSString *name GRMUSTACHE_API_INTERNAL;

/**
 * The abstract syntax tree of the partial template.
 */
@property (nonatomic, retain, readonly) GRMustacheTemplateAST *templateAST GRMUSTACHE_API_INTERNAL;

/**
 * Returns a newly created partial node.
 *
 * @param templateAST  The abstract syntax tree of the partial template.
 * @param name         The name of the partial template.
 *
 * @return  a newly created partial node.
 */
+ (instancetype)partialNodeWithTemplateAST:(GRMustacheTemplateAST *)templateAST name:(NSString *)name GRMUSTACHE_API_INTERNAL;
@end
