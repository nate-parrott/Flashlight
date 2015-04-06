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

@class GRMustacheToken;
@protocol GRMustacheExpressionVisitor;

/**
 * The GRMustacheExpression is the base class for objects that represent
 * Mustache expression such as `name`, `uppercase(name)`, or `user.name`.
 */
@interface GRMustacheExpression : NSObject {
@private
    GRMustacheToken *_token;
}

/**
 * This property stores a token whose sole purpose is to help the library user
 * debugging his templates, using the token's ability to output its location
 * (`{{ foo }}` at line 23 of /path/to/template).
 */
@property (nonatomic, retain) GRMustacheToken *token GRMUSTACHE_API_INTERNAL;

/**
 * Returns a Boolean value that indicates whether the receiver and a given
 * object are equal.
 *
 * Expressions are equal if and only if the result of their
 * `hasValue:withContext:protected:error:` implementation would return the same
 * value in a given rendering context.
 *
 * Default implementation is NSObject's one: subclasses must override.
 *
 * @param anObject  The object to be compared to the receiver.
 *
 * @return YES if the receiver and anObject are equal, otherwise NO.
 */
- (BOOL)isEqual:(id)anObject; // no availability macro for Foundation method declaration

/**
 * Has the visitor visit the expression.
 */
- (BOOL)acceptVisitor:(id<GRMustacheExpressionVisitor>)visitor error:(NSError **)error GRMUSTACHE_API_INTERNAL;

@end
