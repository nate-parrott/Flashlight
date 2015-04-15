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

#import "GRMustacheJavascriptLibrary_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheContext_private.h"


// =============================================================================
#pragma mark - GRMustacheJavascriptEscaper

@implementation GRMustacheJavascriptEscaper

#pragma mark <GRMustacheFilter>

/**
 * Support for {{ javascript.escape(value) }}
 */
- (id)transformedValue:(id)object
{
    // Specific case for [NSNull null]
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    // Turns other objects into strings, and escape
    
    NSString *string = [object description];
    return [self escape:string];
}


#pragma mark - <GRMustacheRendering>

/**
 * Support for {{# javascript.escape }}...{{ value }}...{{ value }}...{{/ javascript.escape }}
 */
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ javascript.escape }}
            // Behave as a regular object: render self's description
            if (HTMLSafe != NULL) { *HTMLSafe = NO; }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# javascript.escape }}...{{/ javascript.escape }}
            // {{^ javascript.escape }}...{{/ javascript.escape }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            context = [context contextByAddingTagDelegate:self];
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}


#pragma mark - <GRMustacheTagDelegate>

/**
 * Support for {{# javascript.escape }}...{{ value }}...{{ value }}...{{/ javascript.escape }}
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
                return [self escape:rendering];
            }];
            
        case GRMustacheTagTypeSection:
            // {{# value }}
            // {{^ value }}
            return object;
    }
}


#pragma mark - Private

- (NSString *)escape:(NSString *)string
{
    NSUInteger length = [string length];
    if (length == 0) {
        return string;
    }
    
    
    // Extract characters
    
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)string);
    if (!characters) {
        NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
        [string getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
        characters = [data bytes];
    }
    
    
    // Set up the translation table
    
    static const NSString *escapeForCharacter[] = {
        // This table comes from https://github.com/django/django/commit/8c4a525871df19163d5bfdf5939eff33b544c2e2#django/template/defaultfilters.py
        //
        // Quoting Malcolm Tredinnick:
        // > Added extra robustness to the escapejs filter so that all invalid
        // > characters are correctly escaped. This avoids any chance to inject
        // > raw HTML inside <script> tags. Thanks to Mike Wiacek for the patch
        // > and Collin Grady for the tests.
        //
        // Quoting Mike Wiacek from https://code.djangoproject.com/ticket/7177
        // > The escapejs filter currently escapes a small subset of characters
        // > to prevent JavaScript injection. However, the resulting strings can
        // > still contain valid HTML, leading to XSS vulnerabilities. Using hex
        // > encoding as opposed to backslash escaping, effectively prevents
        // > Javascript injection and also helps prevent XSS. Attached is a
        // > small patch that modifies the _js_escapes tuple to use hex encoding
        // > on an expanded set of characters.
        //
        // The initial django commit used `\xNN` syntax. The \u syntax was
        // introduced later for JSON compatibility.
        
        [0x00] = @"\\u0000",
        [0x01] = @"\\u0001",
        [0x02] = @"\\u0002",
        [0x03] = @"\\u0003",
        [0x04] = @"\\u0004",
        [0x05] = @"\\u0005",
        [0x06] = @"\\u0006",
        [0x07] = @"\\u0007",
        [0x08] = @"\\u0008",
        [0x09] = @"\\u0009",
        [0x0A] = @"\\u000A",
        [0x0B] = @"\\u000B",
        [0x0C] = @"\\u000C",
        [0x0D] = @"\\u000D",
        [0x0E] = @"\\u000E",
        [0x0F] = @"\\u000F",
        [0x10] = @"\\u0010",
        [0x11] = @"\\u0011",
        [0x12] = @"\\u0012",
        [0x13] = @"\\u0013",
        [0x14] = @"\\u0014",
        [0x15] = @"\\u0015",
        [0x16] = @"\\u0016",
        [0x17] = @"\\u0017",
        [0x18] = @"\\u0018",
        [0x19] = @"\\u0019",
        [0x1A] = @"\\u001A",
        [0x1B] = @"\\u001B",
        [0x1C] = @"\\u001C",
        [0x1D] = @"\\u001D",
        [0x1E] = @"\\u001E",
        [0x1F] = @"\\u001F",
        ['\\'] = @"\\u005C",
        ['\''] = @"\\u0027",
        ['"'] = @"\\u0022",
        ['>'] = @"\\u003E",
        ['<'] = @"\\u003C",
        ['&'] = @"\\u0026",
        ['='] = @"\\u003D",
        ['-'] = @"\\u002D",
        [';'] = @"\\u003B",
        
        // 0x2028 and 0x2029 are not included in this table, that would be too
        // big. See below.
    };
    static const int escapeForCharacterLength = sizeof(escapeForCharacter) / sizeof(NSString *);
    
    
    // Translate
    
    NSMutableString *buffer = nil;
    const UniChar *unescapedStart = characters;
    CFIndex unescapedLength = 0;
    for (NSUInteger i=0; i<length; ++i, ++characters) {
        const NSString *escape = nil;
        if (*characters == 0x2028)
        {
            escape = @"\\u2028";
        }
        else if (*characters == 0x2029)
        {
            escape = @"\\u2029";
        }
        else
        {
            escape = (*characters < escapeForCharacterLength) ? escapeForCharacter[*characters] : nil;
        }
        if (escape) {
            if (!buffer) {
                buffer = [NSMutableString stringWithCapacity:length];
            }
            CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
            CFStringAppend((CFMutableStringRef)buffer, (CFStringRef)escape);
            unescapedStart = characters+1;
            unescapedLength = 0;
        } else {
            ++unescapedLength;
        }
    }
    if (!buffer) {
        return string;
    }
    if (unescapedLength > 0) {
        CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
    }
    return buffer;
}

@end
