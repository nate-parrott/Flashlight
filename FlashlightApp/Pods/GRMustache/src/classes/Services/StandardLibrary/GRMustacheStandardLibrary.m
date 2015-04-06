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

#import "GRMustacheStandardLibrary_private.h"


// =============================================================================
#pragma mark - GRMustacheCapitalizedFilter

@implementation GRMustacheCapitalizedFilter

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    // Specific case for [NSNull null]
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    // Turns other objects into strings, and transform
    
    NSString *string = [object description];
    return [string capitalizedString];
}

@end


// =============================================================================
#pragma mark - GRMustacheLowercaseFilter

@implementation GRMustacheLowercaseFilter

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    // Specific case for [NSNull null]
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    // Turns other objects into strings, and transform
    
    NSString *string = [object description];
    return [string lowercaseString];
}

@end


// =============================================================================
#pragma mark - GRMustacheUppercaseFilter

@implementation GRMustacheUppercaseFilter

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    // Specific case for [NSNull null]
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    // Turns other objects into strings, and transform
    
    NSString *string = [object description];
    return [string uppercaseString];
}

@end


// =============================================================================
#pragma mark - GRMustacheBlankFilter

@implementation GRMustacheBlankFilter

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithBool:YES];
    }
    
    if (![object isKindOfClass:[NSDictionary class]] && [object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        for (id _ __attribute__((unused)) in object) {
            return [NSNumber numberWithBool:NO];
        }
        return [NSNumber numberWithBool:YES];
    }
    
    NSString *trimmedDescription = [[object description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [NSNumber numberWithBool:trimmedDescription.length == 0];
}

@end


// =============================================================================
#pragma mark - GRMustacheEmptyFilter

@implementation GRMustacheEmptyFilter

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithBool:YES];
    }
    
    if (![object isKindOfClass:[NSDictionary class]] && [object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        for (id _ __attribute__((unused)) in object) {
            return [NSNumber numberWithBool:NO];
        }
        return [NSNumber numberWithBool:YES];
    }
    
    NSString *description = [object description];
    return [NSNumber numberWithBool:description.length == 0];
}

@end
