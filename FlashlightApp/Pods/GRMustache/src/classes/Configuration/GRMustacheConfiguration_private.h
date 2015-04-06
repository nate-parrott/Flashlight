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
#import "GRMustacheContentType.h"

@class GRMustacheContext;
@protocol GRMustacheTagDelegate;

// Documented in GRMustacheConfiguration.h
@interface GRMustacheConfiguration : NSObject<NSCopying> {
@private
    GRMustacheContentType _contentType;
    NSString *_tagStartDelimiter;
    NSString *_tagEndDelimiter;
    GRMustacheContext *_baseContext;
    BOOL _locked;
}


// Documented in GRMustacheConfiguration.h
+ (GRMustacheConfiguration *)defaultConfiguration GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
+ (GRMustacheConfiguration *)configuration GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
@property (nonatomic) GRMustacheContentType contentType GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
@property (nonatomic, copy) NSString *tagStartDelimiter GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
@property (nonatomic, copy) NSString *tagEndDelimiter GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
@property (nonatomic, retain) GRMustacheContext *baseContext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
- (void)extendBaseContextWithObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
- (void)extendBaseContextWithProtectedObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheConfiguration.h
- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate GRMUSTACHE_API_PUBLIC;

/**
 * Whether the receiver is locked or not.
 *
 * @see lock
 */
@property (nonatomic, getter = isLocked, readonly) BOOL locked GRMUSTACHE_API_INTERNAL;

/**
 * Locks the receiver.
 *
 * A locked configuration raises an exception when the user attempts to mutate
 * it. It is in effect an immutable object.
 *
 * The goal is to prevent the user to build template and alter the configuration
 * afterwards.
 *
 * @see locked
 */
- (void)lock GRMUSTACHE_API_INTERNAL;

@end
