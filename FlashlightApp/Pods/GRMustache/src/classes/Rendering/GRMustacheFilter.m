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

#import "GRMustacheFilter_private.h"

// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockFilter

/**
 * Private subclass of GRMustacheFilter that filters a single argument by
 * calling a block.
 */
@interface GRMustacheBlockFilter: GRMustacheFilter {
@private
    id(^_block)(id value);
}
- (instancetype)initWithBlock:(id(^)(id value))block;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockVariadicFilter

/**
 * Private subclass of GRMustacheFilter that filters an array of arguments by
 * calling a block.
 */
@interface GRMustacheBlockVariadicFilter: GRMustacheFilter {
@private
    NSArray *_arguments;
    id(^_block)(NSArray *arguments);
}
- (instancetype)initWithBlock:(id(^)(NSArray *arguments))block arguments:(NSArray *)arguments;
@end


// =============================================================================
#pragma mark - GRMustacheFilter

@implementation GRMustacheFilter

+ (id<GRMustacheFilter>)filterWithBlock:(id(^)(id value))block
{
    return [[[GRMustacheBlockFilter alloc] initWithBlock:block] autorelease];
}

+ (id<GRMustacheFilter>)variadicFilterWithBlock:(id(^)(NSArray *arguments))block
{
    return [[[GRMustacheBlockVariadicFilter alloc] initWithBlock:block arguments:[NSArray array]] autorelease];
}

- (id)transformedValue:(id)object
{
    return object;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockFilter

@implementation GRMustacheBlockFilter

- (instancetype)initWithBlock:(id(^)(id value))block
{
    if (block == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Can't build a filter with a nil block."];
    }
    
    self = [self init];
    if (self) {
        _block = [block copy];
    }
    return self;
}


- (void)dealloc
{
    [_block release];
    [super dealloc];
}

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    return _block(object);
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockVariadicFilter

@implementation GRMustacheBlockVariadicFilter

- (instancetype)initWithBlock:(id(^)(NSArray *arguments))block arguments:(NSArray *)arguments
{
    if (block == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Can't build a filter with a nil block."];
    }
    
    self = [self init];
    if (self) {
        _block = [block copy];
        _arguments = [arguments retain];
    }
    return self;
}

- (void)dealloc
{
    [_block release];
    [_arguments release];
    [super dealloc];
}


#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    NSArray *arguments = [_arguments arrayByAddingObject:(object ?: [NSNull null])];
    return _block(arguments);
}

- (id<GRMustacheFilter>)filterByCurryingArgument:(id)object
{
    NSArray *arguments = [_arguments arrayByAddingObject:(object ?: [NSNull null])];
    return [[[GRMustacheBlockVariadicFilter alloc] initWithBlock:_block arguments:arguments] autorelease];
}

@end
