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

#import "GRMustacheSectionTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheRenderingEngine_private.h"

@implementation GRMustacheSectionTag
@synthesize expression=_expression;
@synthesize templateAST=_templateAST;
@synthesize inverted=_inverted;

- (void)dealloc
{
    [_expression release];
    [_templateString release];
    [_templateAST release];
    [super dealloc];
}

+ (instancetype)sectionTagWithExpression:(GRMustacheExpression *)expression inverted:(BOOL)inverted templateString:(NSString *)templateString innerRange:(NSRange)innerRange templateAST:(GRMustacheTemplateAST *)templateAST
{
    return [[[self alloc] initWithExpression:expression inverted:inverted templateString:templateString innerRange:innerRange templateAST:templateAST] autorelease];
}


#pragma mark - GRMustacheTag

- (NSString *)description
{
    GRMustacheToken *token = _expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (GRMustacheTagType)type
{
    return GRMustacheTagTypeSection;
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    GRMustacheRenderingEngine *renderingEngine = [GRMustacheRenderingEngine renderingEngineWithContentType:_templateAST.contentType context:context];
    return [renderingEngine renderTemplateAST:_templateAST HTMLSafe:HTMLSafe error:error];
}


#pragma mark - <GRMustacheTemplateASTNode>

- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitSectionTag:self error:error];
}


#pragma mark - Private

- (instancetype)initWithExpression:(GRMustacheExpression *)expression inverted:(BOOL)inverted templateString:(NSString *)templateString innerRange:(NSRange)innerRange templateAST:(GRMustacheTemplateAST *)templateAST
{
    self = [super init];
    if (self) {
        _expression = [expression retain];
        _inverted = inverted;
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _templateAST = [templateAST retain];
    }
    return self;
}

@end
