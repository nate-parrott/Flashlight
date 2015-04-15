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

#import "GRMustacheEachFilter_private.h"
#import "GRMustacheRendering_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheError.h"

@implementation GRMustacheEachFilter

/**
 * The transformedValue: method is required by the GRMustacheFilter protocol.
 */

- (id)transformedValue:(id)object
{
    /**
     * Check that parameter can be iterated.
     */
    
    if (![object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        
        /**
         * Filters have no way to directly return an error.
         *
         * So let's return a rendering object that will complain when it
         * eventually gets rendered.
         */
        
        return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            if (error) {
                *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"each filter in tag %@ expects its arguments to conform to the NSFastEnumeration protocol. %@ is not.", tag, object] }];
            }
            return nil;
        }];
    }
    
    
    /**
     * Index-based collections and key-based collections are not iterated in the
     * same way.
     */
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self transformedDictionary:object];
    } else {
        return [self transformedArray:object];
    }
}

- (id)transformedArray:(id<NSFastEnumeration>)array
{
    /**
     * Let's return an array containing as many objects as in the original
     * collection.
     *
     * Returning an array is important: it allows the `each` filter to be
     * chained with other collection-processing filters, as in
     * {{# reverse(each(list)) }}...{{/}} for example.
     *
     * The new array contains objects that perform custom rendering by enqueuing
     * in the context stack the positional keys before rendering just like the
     * original objects.
     *
     * Those objects which perform custom rendering conform to the
     * GRMustacheRendering protocol:
     */
    
    NSMutableArray *replacementRenderingObjects = [NSMutableArray array];
    __block NSUInteger indexOfLastObject = 0;
    NSUInteger index = 0;
    for (id object in array) {
        
        /**
         * Build the replacement rendering object.
         *
         * It enqueues the positional keys, and then renders the same as the
         * original object.
         */
        
        indexOfLastObject = index;
        id<GRMustacheRendering> replacementRenderingObject = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            
            /**
             * Add our positional keys in the rendering context
             */
            
            context = [context contextByAddingObject:@{@"@index": @(index),
                                                       @"@indexPlusOne": @(index + 1),
                                                       @"@indexIsEven": @(index % 2 == 0),
                                                       @"@first": @(index == 0),
                                                       @"@last": @(index == indexOfLastObject),    // When this is evaluated, on rendering, the filter will have been long executed. The __block variable indexOfLastObject will have the value of the last index.
                                                       }];
            
            /**
             * We want to render just like the original object.
             */
            
            id<GRMustacheRenderingWithIterationSupport> originalRenderingObject = [GRMustacheRendering renderingObjectForObject:object];
            return [originalRenderingObject renderForMustacheTag:tag asEnumerationItem:YES context:context HTMLSafe:HTMLSafe error:error];
        }];
        
        [replacementRenderingObjects addObject:replacementRenderingObject];
        ++index;
    }
    
    return replacementRenderingObjects;
}

- (id)transformedDictionary:(NSDictionary *)dictionary
{
    /**
     * Let's return an array containing as many objects as in the original
     * dictionary.
     *
     * The new array contains objects that perform custom rendering by enqueuing
     * in the context stack the positional keys before rendering just like the
     * original dictionary values.
     *
     * Those objects which perform custom rendering conform to the
     * GRMustacheRendering protocol:
     */
    
    NSMutableArray *replacementRenderingObjects = [NSMutableArray array];
    NSUInteger indexOfLastObject = dictionary.count - 1;
    NSUInteger index = 0;
    for (id key in dictionary) {
        
        /**
         * Build the replacement rendering object.
         *
         * It enqueues the positional keys, and then renders the same as the
         * original object.
         */
        
        id object = [dictionary objectForKey:key];
        id<GRMustacheRendering> replacementRenderingObject = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            
            /**
             * Add our positional keys in the rendering context
             */
            
            context = [context contextByAddingObject:@{@"@key": key,
                                                       @"@index": @(index),
                                                       @"@indexPlusOne": @(index + 1),
                                                       @"@indexIsEven": @(index % 2 == 0),
                                                       @"@first": @(index == 0),
                                                       @"@last": @(index == indexOfLastObject),
                                                       }];
            
            /**
             * We want to render just like the original object.
             */
            
            id<GRMustacheRenderingWithIterationSupport> originalRenderingObject = [GRMustacheRendering renderingObjectForObject:object];
            return [originalRenderingObject renderForMustacheTag:tag asEnumerationItem:YES context:context HTMLSafe:HTMLSafe error:error];
        }];
        
        [replacementRenderingObjects addObject:replacementRenderingObject];
        ++index;
    }
    
    return replacementRenderingObjects;
}

@end
