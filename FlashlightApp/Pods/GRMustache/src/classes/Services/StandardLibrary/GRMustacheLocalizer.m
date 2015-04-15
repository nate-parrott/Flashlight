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

#import "GRMustacheLocalizer.h"
#import "GRMustacheContext.h"
#import "GRMustacheTag.h"
#import "GRMustacheTagDelegate.h"

static NSString *const GRMustacheLocalizerValuePlaceholder = @"GRMustacheLocalizerValuePlaceholder";

@interface GRMustacheLocalizer()<GRMustacheTagDelegate>
@property (nonatomic, strong) NSMutableArray *formatArguments;
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)stringWithFormat:(NSString *)format argumentArray:(NSArray *)arguments;
@end

@implementation GRMustacheLocalizer
@synthesize formatArguments=_formatArguments;
@synthesize bundle=_bundle;
@synthesize tableName=_tableName;

- (void)dealloc
{
    [_bundle release];
    [_tableName release];
    [super dealloc];
}

- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName
{
    self = [super init];
    if (self) {
        _bundle = [(bundle ?: [NSBundle mainBundle]) retain];
        _tableName = [tableName retain];
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key
{
    return [_bundle localizedStringForKey:key value:@"" table:_tableName];
}


#pragma mark - GRMustacheFilter

/**
 * Support for {{ localize(value) }}
 */
- (id)transformedValue:(id)object
{
    // Specific case for [NSNull null]
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    // Turns other objects into strings, and localize
    
    NSString *string = [object description];
    return [self localizedStringForKey:string];
}


#pragma mark - GRMustacheRendering

/**
 * Support for {{# localize }}...{{ value }}...{{ value }}...{{/ localize }}
 */
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    /**
     * Perform a first rendering of the section tag, that will turn variable
     * tags into a custom placeholder.
     *
     * "...{{name}}..." will get turned into "...GRMustacheLocalizerValuePlaceholder...".
     *
     * For that, we make sure we are notified of tag rendering, so that our
     * mustacheTag:willRenderObject: implementation tells the tags to render
     * GRMustacheLocalizerValuePlaceholder instead of the regular values,
     * "Arthur" or "Barbara". This behavior is trigerred by the nil value of
     * self.formatArguments.
     */
    
    // Set up first pass behavior
    self.formatArguments = nil;
    
    // Get notified of tag rendering
    context = [context contextByAddingTagDelegate:self];
    
    // Render the localizable format
    NSString *localizableFormat = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    
    
    /**
     * Perform a second rendering that will fill our formatArguments array with
     * HTML-escaped tag renderings.
     *
     * Now our mustacheTag:willRenderObject: implementation will let the regular
     * values go through normal rendering ("Arthur" or "Barbara"). Our
     * mustacheTag:didRenderObject:as: method will fill self.formatArguments.
     *
     * This behavior is not the same as the previous one, and is trigerred by
     * the non-nil value of self.formatArguments.
     */
    
    // Set up second pass behavior
    self.formatArguments = [NSMutableArray array];
    
    // Fill formatArguments
    [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    
    
    /**
     * Localize the format, and render.
     */
    
    NSString *rendering = nil;
    if (self.formatArguments.count == 0)
    {
        // Don't format anything if there is no format argument.
        rendering = [self localizedStringForKey:localizableFormat];
    }
    else
    {
        /**
         * When rendering {{#localize}}%d {{name}}{{/localize}},
         * The localizableFormat string we have just built is
         * "%d GRMustacheLocalizerValuePlaceholder".
         *
         * In order to get an actual format string, we have to:
         * - turn GRMustacheLocalizerValuePlaceholder into %@
         * - escape % into %%.
         *
         * The format string will then be "%%d %@".
         */
        
        localizableFormat = [localizableFormat stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
        localizableFormat = [localizableFormat stringByReplacingOccurrencesOfString:GRMustacheLocalizerValuePlaceholder withString:@"%@"];
        NSString *localizedFormat = [self localizedStringForKey:localizableFormat];
        rendering = [self stringWithFormat:localizedFormat argumentArray:self.formatArguments];
    }
    
    
    /**
     * Cleanup and return
     */
    
    self.formatArguments = nil;
    return rendering;
}


#pragma mark - GRMustacheTagDelegate

/**
 * Support for {{# localize }}...{{ value }}...{{ value }}...{{/ localize }}
 */
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ value }}
            //
            // We behave as stated in renderForMustacheTag:context:HTMLSafe:error:
            
            if (self.formatArguments) {
                return object;
            }
            return GRMustacheLocalizerValuePlaceholder;
            
        case GRMustacheTagTypeSection:
            // {{# value }}
            // {{^ value }}
            //
            // We do not want to mess with Mustache handling of boolean sections
            // such as {{#true}}...{{/}}.
            return object;
    }
}

/**
 * Support for {{# localize }}...{{ value }}...{{ value }}...{{/ localize }}
 */
- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object as:(NSString *)rendering
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ value }}
            //
            // We behave as stated in renderForMustacheTag:context:HTMLSafe:error:
            
            [self.formatArguments addObject:rendering];
            break;
            
        case GRMustacheTagTypeSection:
            // {{# value }}
            // {{^ value }}
            break;
    }
}


#pragma mark - Private

- (NSString *)stringWithFormat:(NSString *)format argumentArray:(NSArray *)arguments
{
    /**
     * NSString formatting methods do not accept an array of format arguments.
     *
     * Faking va_list as in http://stackoverflow.com/questions/688070/is-there-any-way-to-pass-an-nsarray-to-a-method-that-expects-a-variable-number-o
     * used to compile, but it does no longer:
     *
     *     id fake_va_list[arguments.count];
     *     [arguments getObjects:fake_va_list];
     *     rendering = [[[NSString alloc] initWithFormat:format arguments:(va_list)fake_va_list] autorelease];
     *                                                                    ^        ~~~~~~~~~~~~
     *     error: used type 'va_list' (aka '__builtin_va_list') where arithmetic or pointer type is required
     *
     * Removing the (va_list) cast only generates a warning, but the code crashes when run.
     *
     * NSInvocation? NSInvocation does not support variadic functions.
     *
     * So I guess we have to do it by hand :-(
     */
    
    NSUInteger count = arguments.count;

    id args[] = {
        (count > 0) ? [arguments objectAtIndex:0] : nil,
        (count > 1) ? [arguments objectAtIndex:1] : nil,
        (count > 2) ? [arguments objectAtIndex:2] : nil,
        (count > 3) ? [arguments objectAtIndex:3] : nil,
        (count > 4) ? [arguments objectAtIndex:4] : nil,
        (count > 5) ? [arguments objectAtIndex:5] : nil,
        (count > 6) ? [arguments objectAtIndex:6] : nil,
        (count > 7) ? [arguments objectAtIndex:7] : nil,
        (count > 8) ? [arguments objectAtIndex:8] : nil,
        (count > 9) ? [arguments objectAtIndex:9] : nil,
    };
    
    if (count > 10) {
        [NSException raise:NSGenericException format:@"Not implemented: format with %ld parameters", (unsigned long)count];
        return nil;
    }
    
    return [NSString stringWithFormat:format,
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5],
            args[6],
            args[7],
            args[8],
            args[9]];
}

@end
