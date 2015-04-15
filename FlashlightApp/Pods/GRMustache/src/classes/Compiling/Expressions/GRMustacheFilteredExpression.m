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

#import <objc/runtime.h>
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheExpressionVisitor_private.h"

@implementation GRMustacheFilteredExpression
@synthesize filterExpression=_filterExpression;
@synthesize argumentExpression=_argumentExpression;
@synthesize curried=_curried;

+ (instancetype)expressionWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curried:(BOOL)curried
{
    return [[[self alloc] initWithFilterExpression:filterExpression argumentExpression:argumentExpression curried:curried] autorelease];
}

- (void)dealloc
{
    [_filterExpression release];
    [_argumentExpression release];
    [super dealloc];
}


#pragma mark - GRMustacheExpression

- (void)setToken:(GRMustacheToken *)token
{
    [super setToken:token];
    _filterExpression.token = token;
    _argumentExpression.token = token;
}

- (BOOL)isEqual:(id)expression
{
    if (![expression isKindOfClass:[GRMustacheFilteredExpression class]]) {
        return NO;
    }
    if (![_filterExpression isEqual:((GRMustacheFilteredExpression *)expression).filterExpression]) {
        return NO;
    }
    return [_argumentExpression isEqual:((GRMustacheFilteredExpression *)expression).argumentExpression];
}

- (NSUInteger)hash
{
    return [_filterExpression hash] ^ [_argumentExpression hash];
}

- (BOOL)acceptVisitor:(id<GRMustacheExpressionVisitor>)visitor error:(NSError **)error
{
    return [visitor visitFilteredExpression:self error:error];
}


#pragma mark - Private

- (instancetype)initWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curried:(BOOL)curried
{
    self = [super init];
    if (self) {
        _filterExpression = [filterExpression retain];
        _argumentExpression = [argumentExpression retain];
        _curried = curried;
    }
    return self;
}

@end
