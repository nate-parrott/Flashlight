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

#import "GRMustacheExpression_private.h"

/**
 * The GRMustacheFilteredExpression represents expressions such as
 * `<expression>(<expression>)`.
 */
@interface GRMustacheFilteredExpression : GRMustacheExpression {
@private
    GRMustacheExpression *_filterExpression;
    GRMustacheExpression *_argumentExpression;
    BOOL _curried;
}

@property (nonatomic, retain, readonly) GRMustacheExpression *filterExpression GRMUSTACHE_API_INTERNAL;
@property (nonatomic, retain, readonly) GRMustacheExpression *argumentExpression GRMUSTACHE_API_INTERNAL;
@property (nonatomic, getter=isCurried, readonly) BOOL curried GRMUSTACHE_API_INTERNAL;

/**
 * Returns a filtered expression, given an expression that returns a filter, and
 * an expression that return the filter argument.
 *
 * For example, the Mustache tag `{{ f(x) }}` contains a filtered expression,
 * whose filterExpression is a GRMustacheIdentifierExpression (for the
 * identifier `f`), and whose argumentExpression is a
 * GRMustacheIdentifierExpression (for the identifier `x`).
 *
 * @param filterExpression    An expression whose value is an object conforming
 *                            to the <GRMustacheFilter> protocol.
 * @param argumentExpression  An expression whose value is the argument of the
 *                            filter.
 * @param curried             If YES, this expression must evaluate to a filter.
 *
 * @return A GRMustacheFilteredExpression.
 */
+ (instancetype)expressionWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curried:(BOOL)curried GRMUSTACHE_API_INTERNAL;
@end
