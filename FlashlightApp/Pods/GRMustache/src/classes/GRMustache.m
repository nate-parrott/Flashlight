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

#import "GRMustache_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheVersion.h"
#import "GRMustacheRendering_private.h"
#import "GRMustacheStandardLibrary_private.h"
#import "GRMustacheJavascriptLibrary_private.h"
#import "GRMustacheHTMLLibrary_private.h"
#import "GRMustacheURLLibrary_private.h"
#import "GRMustacheEachFilter_private.h"
#import "GRMustacheLocalizer.h"


// =============================================================================
#pragma mark - GRMustache

@implementation GRMustache

// =============================================================================
#pragma mark - Global services

+ (void)preventNSUndefinedKeyExceptionAttack
{
    [GRMustacheKeyAccess preventNSUndefinedKeyExceptionAttack];
}

+ (GRMustacheVersion)libraryVersion
{
    return (GRMustacheVersion){
        .major = GRMUSTACHE_MAJOR_VERSION,
        .minor = GRMUSTACHE_MINOR_VERSION,
        .patch = GRMUSTACHE_PATCH_VERSION };
}

+ (NSObject *)standardLibrary
{
    static NSObject *standardLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardLibrary = [[NSDictionary dictionaryWithObjectsAndKeys:
                            // {{ capitalized(value) }}
                            [[[GRMustacheCapitalizedFilter alloc] init] autorelease], @"capitalized",
                            
                            // {{ lowercase(value) }}
                            [[[GRMustacheLowercaseFilter alloc] init] autorelease], @"lowercase",
                            
                            // {{ uppercase(value) }}
                            [[[GRMustacheUppercaseFilter alloc] init] autorelease], @"uppercase",
                            
                            // {{# isBlank(value) }}...{{/}}
                            [[[GRMustacheBlankFilter alloc] init] autorelease], @"isBlank",
                            
                            // {{# isEmpty(value) }}...{{/}}
                            [[[GRMustacheEmptyFilter alloc] init] autorelease], @"isEmpty",
                            
                            // {{ localize(value) }}
                            // {{# localize }}...{{/}}
                            [[[GRMustacheLocalizer alloc] initWithBundle:nil tableName:nil] autorelease], @"localize",
                            
                            // {{# each(collection) }}...{{/}}
                            [[[GRMustacheEachFilter alloc] init] autorelease], @"each",
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // {{ HTML.escape(value) }}
                             // {{# HTML.escape }}...{{/}}
                             [[[GRMustacheHTMLEscapeFilter alloc] init] autorelease], @"escape",
                             nil], @"HTML",
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // {{ javascript.escape(value) }}
                             // {{# javascript.escape }}...{{/}}
                             [[[GRMustacheJavascriptEscaper alloc] init] autorelease], @"escape",
                             nil], @"javascript",
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // {{ URL.escape(value) }}
                             // {{# URL.escape }}...{{/}}
                             [[[GRMustacheURLEscapeFilter alloc] init] autorelease], @"escape",
                             nil], @"URL",
                            nil] retain];
    });
    
    return standardLibrary;
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    return [GRMustacheRendering renderingObjectForObject:object];
}

+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    return [GRMustacheRendering renderingObjectWithBlock:block];
}

@end
