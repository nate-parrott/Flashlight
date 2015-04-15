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

#import "GRMustacheExpressionInvocation_private.h"
#import "GRMustacheExpressionVisitor_private.h"
#import "GRMustacheFilter_private.h"
#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheError.h"

@interface GRMustacheExpressionInvocation()<GRMustacheExpressionVisitor>
@end

@implementation GRMustacheExpressionInvocation
@synthesize context=_context;
@synthesize expression=_expression;
@synthesize value=_value;
@synthesize valueIsProtected=_valueIsProtected;

- (BOOL)invokeReturningError:(NSError **)error
{
    return [_expression acceptVisitor:self error:error];
}


#pragma mark - <GRMustacheExpressionVisitor>

- (BOOL)visitFilteredExpression:(GRMustacheFilteredExpression *)expression error:(NSError **)error
{
    if (![expression.filterExpression acceptVisitor:self error:error]) {
        return NO;
    }
    id filter = _value;
    
    if (![expression.argumentExpression acceptVisitor:self error:error]) {
        return NO;
    }
    id argument = _value;
    
    if (filter == nil) {
        GRMustacheToken *token = expression.token;
        NSString *renderingErrorDescription = nil;
        if (token) {
            if (token.templateID) {
                renderingErrorDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu of template %@", token.templateSubstring, (unsigned long)token.line, token.templateID];
            } else {
                renderingErrorDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu", token.templateSubstring, (unsigned long)token.line];
            }
        } else {
            renderingErrorDescription = [NSString stringWithFormat:@"Missing filter"];
        }
        NSError *renderingError = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:renderingErrorDescription forKey:NSLocalizedDescriptionKey]];
        if (error != NULL) {
            *error = renderingError;
        }
        return NO;
    }
    
    if (![filter respondsToSelector:@selector(transformedValue:)]) {
        GRMustacheToken *token = expression.token;
        NSString *renderingErrorDescription = nil;
        if (token) {
            if (token.templateID) {
                renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol in tag `%@` at line %lu of template %@: %@", token.templateSubstring, (unsigned long)token.line, token.templateID, filter];
            } else {
                renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol in tag `%@` at line %lu: %@", token.templateSubstring, (unsigned long)token.line, filter];
            }
        } else {
            renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol: %@", filter];
        }
        NSError *renderingError = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:renderingErrorDescription forKey:NSLocalizedDescriptionKey]];
        if (error != NULL) {
            *error = renderingError;
        }
        return NO;
    }
    
    if (expression.isCurried && [filter respondsToSelector:@selector(filterByCurryingArgument:)]) {
        _value = [(id<GRMustacheFilter>)filter filterByCurryingArgument:argument];
    } else {
        _value = [(id<GRMustacheFilter>)filter transformedValue:argument];
    }
    
    _valueIsProtected = NO;
    return YES;
}

- (BOOL)visitIdentifierExpression:(GRMustacheIdentifierExpression *)expression error:(NSError **)error
{
    _value = [_context valueForMustacheKey:expression.identifier protected:&_valueIsProtected];
    return YES;
}

- (BOOL)visitScopedExpression:(GRMustacheScopedExpression *)expression error:(NSError **)error
{
    if (![expression.baseExpression acceptVisitor:self error:error]) {
        return NO;
    }
    
    _value = [GRMustacheKeyAccess valueForMustacheKey:expression.identifier inObject:_value unsafeKeyAccess:_context.unsafeKeyAccess];
    _valueIsProtected = NO;
    return YES;
}

- (BOOL)visitImplicitIteratorExpression:(GRMustacheImplicitIteratorExpression *)expression error:(NSError **)error
{
    _value = [_context topMustacheObject];
    _valueIsProtected = NO;
    return YES;
}

@end
