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

#import "GRMustacheTemplateGenerator_private.h"
#import "GRMustacheExpressionGenerator_private.h"
#import "GRMustacheTemplateASTVisitor_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheInheritablePartialNode_private.h"
#import "GRMustacheInheritableSectionNode_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheVariableTag_private.h"
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheTextNode_private.h"


@interface GRMustacheTemplateGenerator() <GRMustacheTemplateASTVisitor>
@end

@implementation GRMustacheTemplateGenerator
@synthesize templateRepository=_templateRepository;

- (void)dealloc
{
    [_templateRepository release];
    [_expressionGenerator release];
    [super dealloc];
}

+ (instancetype)templateGeneratorWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    return [[[self alloc] initWithTemplateRepository:templateRepository] autorelease];
}

- (NSString *)stringWithTemplate:(GRMustacheTemplate *)template
{
    _templateString = [NSMutableString string];
    [self visitTemplateAST:template.templateAST error:NULL];
    return _templateString;
}


#pragma mark - <GRMustacheTemplateASTVisitor>

- (BOOL)visitTemplateAST:(GRMustacheTemplateAST *)templateAST error:(NSError **)error
{
    for (id<GRMustacheTemplateASTNode> ASTNode in templateAST.templateASTNodes) {
        [ASTNode acceptTemplateASTVisitor:self error:error];
    }
    
    return YES;
}

- (BOOL)visitInheritablePartialNode:(GRMustacheInheritablePartialNode *)inheritablePartialNode error:(NSError **)error
{
    NSString *tagStartDelimiter = _templateRepository.configuration.tagStartDelimiter;
    NSString *tagEndDelimiter = _templateRepository.configuration.tagEndDelimiter;
    NSString *partialName = inheritablePartialNode.partialNode.name;
    NSString *tagStartString = [NSString stringWithFormat:@"%@<%@%@", tagStartDelimiter, partialName, tagEndDelimiter];
    NSString *tagEndString = [NSString stringWithFormat:@"%@/%@%@", tagStartDelimiter, partialName, tagEndDelimiter];
    
    [_templateString appendString:tagStartString];
    [self visitTemplateAST:inheritablePartialNode.overridingTemplateAST error:error];
    [_templateString appendString:tagEndString];
    return YES;
}

- (BOOL)visitInheritableSectionNode:(GRMustacheInheritableSectionNode *)inheritableSectionNode error:(NSError **)error
{
    NSString *tagStartDelimiter = _templateRepository.configuration.tagStartDelimiter;
    NSString *tagEndDelimiter = _templateRepository.configuration.tagEndDelimiter;
    NSString *tagStartString = [NSString stringWithFormat:@"%@$%@%@", tagStartDelimiter, inheritableSectionNode.name, tagEndDelimiter];
    NSString *tagEndString = [NSString stringWithFormat:@"%@/%@%@", tagStartDelimiter, inheritableSectionNode.name, tagEndDelimiter];
    
    [_templateString appendString:tagStartString];
    [self visitTemplateAST:inheritableSectionNode.templateAST error:error];
    [_templateString appendString:tagEndString];
    return YES;
}

- (BOOL)visitPartialNode:(GRMustachePartialNode *)partialNode error:(NSError **)error
{
    NSString *tagStartDelimiter = _templateRepository.configuration.tagStartDelimiter;
    NSString *tagEndDelimiter = _templateRepository.configuration.tagEndDelimiter;
    NSString *partialName = partialNode.name;
    NSString *tagString = [NSString stringWithFormat:@"%@>%@%@", tagStartDelimiter, partialName, tagEndDelimiter];
    [_templateString appendString:tagString];
    return YES;
}

- (BOOL)visitVariableTag:(GRMustacheVariableTag *)variableTag error:(NSError **)error
{
    NSString *tagStartDelimiter = nil;
    NSString *tagEndDelimiter = nil;
    if (variableTag.escapesHTML) {
        tagStartDelimiter = _templateRepository.configuration.tagStartDelimiter;
        tagEndDelimiter = _templateRepository.configuration.tagEndDelimiter;
    } else {
        tagStartDelimiter = [NSString stringWithFormat:@"%@&", _templateRepository.configuration.tagStartDelimiter];
        tagEndDelimiter = _templateRepository.configuration.tagEndDelimiter;
    }
    NSString *expressionString = [_expressionGenerator stringWithExpression:variableTag.expression];
    NSString *tagString = [NSString stringWithFormat:@"%@%@%@", tagStartDelimiter, expressionString, tagEndDelimiter];
    [_templateString appendString:tagString];
    return YES;
}

- (BOOL)visitSectionTag:(GRMustacheSectionTag *)sectionTag error:(NSError **)error
{
    NSString *tagStartDelimiter = _templateRepository.configuration.tagStartDelimiter;
    NSString *tagEndDelimiter = _templateRepository.configuration.tagEndDelimiter;
    NSString *expressionString = [_expressionGenerator stringWithExpression:sectionTag.expression];
    NSString *sectionPrefix = sectionTag.isInverted ? @"^" : @"#";
    NSString *tagStartString = [NSString stringWithFormat:@"%@%@%@%@", tagStartDelimiter, sectionPrefix, expressionString, tagEndDelimiter];
    NSString *tagEndString = [NSString stringWithFormat:@"%@/%@%@", tagStartDelimiter, expressionString, tagEndDelimiter];
    
    [_templateString appendString:tagStartString];
    [self visitTemplateAST:sectionTag.templateAST error:error];
    [_templateString appendString:tagEndString];
    return YES;
}

- (BOOL)visitTextNode:(GRMustacheTextNode *)textNode error:(NSError **)error
{
    [_templateString appendString:textNode.text];
    return YES;
}


#pragma mark - Private

- (instancetype)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    self = [super init];
    if (self) {
        _templateRepository = [templateRepository retain];
        _expressionGenerator = [[GRMustacheExpressionGenerator alloc] init];
    }
    return self;
}

@end
