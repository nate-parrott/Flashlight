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
#import "GRMustacheTemplateASTVisitor_private.h"

@class GRMustacheExpression;

/**
 * The protocol for AST nodes.
 * 
 * When parsing a Mustache template, GRMustacheCompiler builds an abstract
 * tree of objects representing raw text and various mustache tags.
 * 
 * This abstract tree is made of objects conforming to the
 * GRMustacheTemplateASTNode protocol.
 * 
 * For example, the template string "hello {{name}}!" would give four AST nodes:
 *
 * - a GRMustacheTextNode that renders "hello ".
 * - a GRMustacheVariableTag that renders the value of the `name` key in the
 *   rendering context.
 * - a GRMustacheTextNode that renders "!".
 * - a GRMustachePartialNode that would contain the three previous nodes.
 * 
 * @see GRMustacheCompiler
 * @see GRMustacheContext
 */
@protocol GRMustacheTemplateASTNode<NSObject>
@required

/**
 * Has the visitor visit the receiver.
 */
- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor error:(NSError **)error GRMUSTACHE_API_INTERNAL;

/**
 * In the context of template inheritance, return the AST node that should be
 * rendered in lieu of the node argument.
 *
 * All classes conforming to the GRMustacheTemplateASTNode protocol return
 * the node argument, but GRMustacheInheritableSectionNode and
 * GRMustacheInheritablePartialNode.
 *
 * @param ASTNode  A node
 *
 * @return The resolution of the node in the context of Mustache template
 *         inheritance.
 *
 * @see GRMustacheSectionTag
 * @see GRMustacheTemplate
 * @see GRMustacheInheritablePartialNode
 */
- (id<GRMustacheTemplateASTNode>)resolveTemplateASTNode:(id<GRMustacheTemplateASTNode>)templateASTNode GRMUSTACHE_API_INTERNAL;
@end
