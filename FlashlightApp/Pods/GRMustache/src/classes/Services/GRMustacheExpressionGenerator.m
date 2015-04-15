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

#import "GRMustacheExpressionGenerator_private.h"
#import "GRMustacheExpressionVisitor_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheScopedExpression_private.h"


@interface GRMustacheExpressionGenerator() <GRMustacheExpressionVisitor>
@end

@implementation GRMustacheExpressionGenerator

- (NSString *)stringWithExpression:(GRMustacheExpression *)expression
{
    [expression acceptVisitor:self error:NULL];
    return _expressionString;
}


#pragma mark - <GRMustacheExpressionVisitor>

- (BOOL)visitFilteredExpression:(GRMustacheFilteredExpression *)expression error:(NSError **)error
{
    _expressionString = [NSString stringWithFormat:@"%@(%@)", [self stringWithExpression:expression.filterExpression], [self stringWithExpression:expression.argumentExpression]];
    return YES;
}

- (BOOL)visitIdentifierExpression:(GRMustacheIdentifierExpression *)expression error:(NSError **)error
{
    _expressionString = expression.identifier;
    return YES;
}

- (BOOL)visitImplicitIteratorExpression:(GRMustacheImplicitIteratorExpression *)expression error:(NSError **)error
{
    _expressionString = @".";
    return YES;
}

- (BOOL)visitScopedExpression:(GRMustacheScopedExpression *)expression error:(NSError **)error
{
    _expressionString = [NSString stringWithFormat:@"%@.%@", [self stringWithExpression:expression.baseExpression], expression.identifier];
    return YES;
}

@end
