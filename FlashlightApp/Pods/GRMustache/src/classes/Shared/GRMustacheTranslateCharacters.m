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

#import "GRMustacheTranslateCharacters_private.h"
#import "GRMustacheBuffer_private.h"

NSString *GRMustacheTranslateCharacters(NSString *string, NSString **escapeForCharacter, size_t escapeForCharacterLength, NSUInteger capacity)
{
    NSUInteger length = [string length];
    if (length == 0) {
        return string;
    }
    
    // Assume most strings don't need escaping, and help performances: avoid
    // creating a NSMutableData instance if escaping in uncessary.
    
    BOOL needsEscaping = NO;
    for (NSUInteger i=0; i<length; ++i) {
        unichar character = [string characterAtIndex:i];
        if (character < escapeForCharacterLength && escapeForCharacter[character]) {
            needsEscaping = YES;
            break;
        }
    }
    
    if (!needsEscaping) {
        return string;
    }
    
    
    // Escape
    
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)string);
    if (!characters) {
        NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
        [string getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
        characters = [data bytes];
    }
    
    GRMustacheBuffer buffer = GRMustacheBufferCreate(capacity);
    const UniChar *unescapedStart = characters;
    CFIndex unescapedLength = 0;
    for (NSUInteger i=0; i<length; ++i, ++characters) {
        NSString *escape = (*characters < escapeForCharacterLength) ? escapeForCharacter[*characters] : nil;
        if (escape) {
            GRMustacheBufferAppendCharacters(&buffer, unescapedStart, unescapedLength);
            GRMustacheBufferAppendString(&buffer, escape);
            unescapedStart = characters+1;
            unescapedLength = 0;
        } else {
            ++unescapedLength;
        }
    }
    if (unescapedLength > 0) {
        GRMustacheBufferAppendCharacters(&buffer, unescapedStart, unescapedLength);
    }

    return GRMustacheBufferGetStringAndRelease(&buffer);
}

NSString *GRMustacheTranslateHTMLCharacters(NSString *string)
{
    static const NSString *escapeForCharacter[] = {
        ['&'] = @"&amp;",
        ['<'] = @"&lt;",
        ['>'] = @"&gt;",
        ['"'] = @"&quot;",
        ['\''] = @"&apos;",
    };
    static const size_t escapeForCharacterLength = sizeof(escapeForCharacter) / sizeof(NSString *);
    
    NSUInteger capacity = ([string length] + 20) * 1.2;
    return GRMustacheTranslateCharacters(string, escapeForCharacter, escapeForCharacterLength, capacity);
}
