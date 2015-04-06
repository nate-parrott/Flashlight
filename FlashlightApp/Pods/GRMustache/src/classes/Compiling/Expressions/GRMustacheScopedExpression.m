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

#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheExpressionVisitor_private.h"


@implementation GRMustacheScopedExpression
@synthesize baseExpression=_baseExpression;
@synthesize identifier=_identifier;

+ (instancetype)expressionWithBaseExpression:(GRMustacheExpression *)baseExpression identifier:(NSString *)identifier
{
    return [[[self alloc] initWithBaseExpression:baseExpression identifier:identifier] autorelease];
}

- (void)dealloc
{
    [_baseExpression release];
    [_identifier release];
    [super dealloc];
}


#pragma mark - GRMustacheExpression

- (void)setToken:(GRMustacheToken *)token
{
    [super setToken:token];
    _baseExpression.token = token;
}

- (BOOL)isEqual:(id)expression
{
    if (![expression isKindOfClass:[GRMustacheScopedExpression class]]) {
        return NO;
    }
    if (![_baseExpression isEqual:((GRMustacheScopedExpression *)expression).baseExpression]) {
        return NO;
    }
    return [_identifier isEqual:((GRMustacheScopedExpression *)expression).identifier];
}

- (NSUInteger)hash
{
    return [_baseExpression hash] ^ [_identifier hash];
}

- (BOOL)acceptVisitor:(id<GRMustacheExpressionVisitor>)visitor error:(NSError **)error
{
    return [visitor visitScopedExpression:self error:error];
}


#pragma mark - Private

- (instancetype)initWithBaseExpression:(GRMustacheExpression *)baseExpression identifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _baseExpression = [baseExpression retain];
        _identifier = [identifier retain];
    }
    return self;
}

@end
