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

#import "GRMustacheInheritablePartialNode_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheTemplateASTVisitor_private.h"

@implementation GRMustacheInheritablePartialNode
@synthesize overridingTemplateAST=_overridingTemplateAST;
@synthesize partialNode=_partialNode;

+ (instancetype)inheritablePartialNodeWithPartialNode:(GRMustachePartialNode *)partialNode overridingTemplateAST:(GRMustacheTemplateAST *)overridingTemplateAST
{
    return [[[self alloc] initWithPartialNode:partialNode overridingTemplateAST:overridingTemplateAST] autorelease];
}

- (void)dealloc
{
    [_partialNode release];
    [_overridingTemplateAST release];
    [super dealloc];
}


#pragma mark - GRMustacheTemplateASTNode

- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitInheritablePartialNode:self error:error];
}

- (id<GRMustacheTemplateASTNode>)resolveTemplateASTNode:(id<GRMustacheTemplateASTNode>)templateASTNode
{
    // look for the last inheritable ASTNode in inner templateAST
    for (id<GRMustacheTemplateASTNode> innerASTNode in _overridingTemplateAST.templateASTNodes) {
        templateASTNode = [innerASTNode resolveTemplateASTNode:templateASTNode];
    }
    return templateASTNode;
}


#pragma mark - Private

- (instancetype)initWithPartialNode:(GRMustachePartialNode *)partialNode overridingTemplateAST:(GRMustacheTemplateAST *)overridingTemplateAST
{
    self = [super init];
    if (self) {
        _partialNode = [partialNode retain];
        _overridingTemplateAST = [overridingTemplateAST retain];
    }
    return self;
}

@end
