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

// Inspired by https://github.com/fotonauts/handlebars-objc/blob/master/src/handlebars-objc/astVisitors/HBAstEvaluationVisitor.m

typedef struct {
    NSUInteger capacity;
    NSMutableString *string;
} GRMustacheBuffer;

static inline GRMustacheBuffer GRMustacheBufferCreate(CFIndex capacity)
{
    return (GRMustacheBuffer){
        .capacity = capacity,
        .string = (NSMutableString *)CFStringCreateMutable(0, capacity),
    };
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferAdjustCapacityForLength(GRMustacheBuffer *buffer, NSUInteger length)
{
// Maximum CFIndex value based on http://www.fefe.de/intof.html
#define CFINDEX_HALF_MAX ((CFIndex)1 << (sizeof(CFIndex)*8-2))
#define CFINDEX_MAX (CFINDEX_HALF_MAX - 1 + CFINDEX_HALF_MAX)
    if (length > buffer->capacity) {
        CFIndex newCapacity = (buffer->capacity >= CFINDEX_MAX / 2) ? CFINDEX_MAX : MAX(length, buffer->capacity * 2); // Avoid CFIndex overflow
        NSMutableString *newString = (NSMutableString *)CFStringCreateMutableCopy(NULL, newCapacity, (CFStringRef)buffer->string);
        [buffer->string release];
        buffer->string = newString;
        buffer->capacity = newCapacity;
    }
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferAppendString(GRMustacheBuffer *buffer, NSString *string)
{
    NSUInteger length = [string length];
    if (length) {
        CFIndex newLength = [buffer->string length] + length;
        GRMustacheBufferAdjustCapacityForLength(buffer, newLength);
        CFStringAppend((CFMutableStringRef)buffer->string, (CFStringRef)string);
    }
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferAppendCharacters(GRMustacheBuffer *buffer, const UniChar *chars, NSUInteger numChars)
{
    if (numChars) {
        CFIndex newLength = [buffer->string length] + numChars;
        GRMustacheBufferAdjustCapacityForLength(buffer, newLength);
        CFStringAppendCharacters((CFMutableStringRef)buffer->string, chars, numChars);
    }
} GRMUSTACHE_API_INTERNAL

static inline NSString *GRMustacheBufferGetString(GRMustacheBuffer *buffer)
{
    return [[buffer->string retain] autorelease];
} GRMUSTACHE_API_INTERNAL

static inline NSString *GRMustacheBufferGetStringAndRelease(GRMustacheBuffer *buffer)
{
    return [buffer->string autorelease];
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferRelease(GRMustacheBuffer *buffer)
{
    [buffer->string release];
} GRMUSTACHE_API_INTERNAL

