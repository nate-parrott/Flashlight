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

#import "GRMustacheHTMLLibrary_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTranslateCharacters_private.h"

// =============================================================================
#pragma mark - GRMustacheHTMLEscapeFilter

@implementation GRMustacheHTMLEscapeFilter

#pragma mark <GRMustacheFilter>

/**
 * Support for {{ HTML.escape(value) }}
 */
- (id)transformedValue:(id)object
{
    // Specific case for [NSNull null]
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    // Turns other objects into strings, and escape
    
    NSString *string = [object description];
    return GRMustacheTranslateHTMLCharacters(string);
}


#pragma mark - <GRMustacheRendering>

/**
 * Support for {{# HTML.escape }}...{{ value }}...{{ value }}...{{/ HTML.escape }}
 */
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ HTML.escape }}
            // Behave as a regular object: render self's description
            if (HTMLSafe != NULL) { *HTMLSafe = NO; }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# HTML.escape }}...{{/ HTML.escape }}
            // {{^ HTML.escape }}...{{/ HTML.escape }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            context = [context contextByAddingTagDelegate:self];
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}


#pragma mark - <GRMustacheTagDelegate>

/**
 * Support for {{# HTML.escape }}...{{ value }}...{{ value }}...{{/ HTML.escape }}
 */
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ value }}
            //
            // We can not escape `object`, because it is not a string.
            // We want to escape its rendering.
            // So return a rendering object that will eventually render `object`,
            // and escape its rendering.
            return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                id<GRMustacheRendering> renderingObject = [GRMustacheRendering renderingObjectForObject:object];
                NSString *rendering = [renderingObject renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
                return GRMustacheTranslateHTMLCharacters(rendering);
            }];
            
        case GRMustacheTagTypeSection:
            // {{# value }}
            // {{^ value }}
            return object;
    }
}

@end
