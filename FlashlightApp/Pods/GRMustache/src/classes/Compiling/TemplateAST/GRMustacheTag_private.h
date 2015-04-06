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
#import "GRMustacheTemplateASTNode_private.h"

@class GRMustacheContext;
@class GRMustacheTemplateRepository;

// Documented in GRMustacheTag.h
typedef NS_ENUM(NSUInteger, GRMustacheTagType) {
    GRMustacheTagTypeVariable = 1 << 1 GRMUSTACHE_API_PUBLIC,
    GRMustacheTagTypeSection = 1 << 2 GRMUSTACHE_API_PUBLIC,
} GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@interface GRMustacheTag: NSObject<GRMustacheTemplateASTNode>

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) GRMustacheTagType type GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

// Documented in GRMustacheTag.h
- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error GRMUSTACHE_API_PUBLIC;

/**
 * TODO
 */
@property (nonatomic, readonly, getter=isInverted) BOOL inverted GRMUSTACHE_API_INTERNAL;

@end
