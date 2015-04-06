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

#import "GRMustacheVariableTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"

@implementation GRMustacheVariableTag
@synthesize expression=_expression;
@synthesize escapesHTML=_escapesHTML;

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}

+ (instancetype)variableTagWithExpression:(GRMustacheExpression *)expression escapesHTML:(BOOL)escapesHTML contentType:(GRMustacheContentType)contentType
{
    return [[[self alloc] initWithExpression:expression escapesHTML:escapesHTML contentType:contentType] autorelease];
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

- (GRMustacheTagType)type
{
    return GRMustacheTagTypeVariable;
}

- (BOOL)isInverted
{
    return NO;
}

- (NSString *)innerTemplateString
{
    return @"";
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (HTMLSafe) {
        *HTMLSafe = (_contentType == GRMustacheContentTypeHTML);
    }
    return @"";
}


#pragma mark - <GRMustacheTemplateASTNode>

- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitVariableTag:self error:error];
}


#pragma mark - Private

- (instancetype)initWithExpression:(GRMustacheExpression *)expression escapesHTML:(BOOL)escapesHTML contentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        _expression = [expression retain];
        _escapesHTML = escapesHTML;
        _contentType = contentType;
    }
    return self;
}

@end
