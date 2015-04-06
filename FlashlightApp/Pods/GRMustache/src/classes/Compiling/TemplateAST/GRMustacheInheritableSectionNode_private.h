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
#import "GRMustacheTemplateASTNode_private.h"

@class GRMustacheTemplateAST;

/**
 * A GRMustacheInheritableSection is an AST node that represents inheritable
 * sections as `{{$name}}...{{/name}}`.
 */
@interface GRMustacheInheritableSectionNode : NSObject<GRMustacheTemplateASTNode> {
@private
    NSString *_name;
    GRMustacheTemplateAST *_templateAST;
}

/**
 * The AST of the inner content of the section
 *
 *     {{$ ... }} AST {{/ }}
 */
@property (nonatomic, retain, readonly) GRMustacheTemplateAST *templateAST GRMUSTACHE_API_INTERNAL;

/**
 * The name of the inheritable section:
 *
 *     {{$ name }} ... {{/ }}
 */
@property (nonatomic, readonly) NSString *name GRMUSTACHE_API_INTERNAL;

/**
 * Returns a new inheritable section.
 *
 * @param name         The name of the inheritable section
 * @param templateAST  The AST of the inner content of the section
 *
 * @return a new GRMustacheInheritableSection.
 *
 * @see GRMustacheTemplateASTNode
 */
+ (instancetype)inheritableSectionNodeWithName:(NSString *)name templateAST:(GRMustacheTemplateAST *)templateAST GRMUSTACHE_API_INTERNAL;

@end
