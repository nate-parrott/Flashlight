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
#import "GRMustacheRendering_private.h"

@class GRMustacheContext;
@class GRMustacheTemplateAST;
@class GRMustacheTemplateRepository;
@protocol GRMustacheTagDelegate;

// Documented in GRMustacheTemplate.h
@interface GRMustacheTemplate: NSObject<GRMustacheRendering> {
@private
    GRMustacheTemplateRepository *_templateRepository;
    GRMustacheTemplateAST *_templateAST;
    GRMustacheContext *_baseContext;
}

@property (nonatomic, retain) GRMustacheTemplateAST *templateAST GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheTemplate.h
@property (nonatomic, retain) GRMustacheContext *baseContext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
@property (nonatomic, retain) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (void)extendBaseContextWithObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (void)extendBaseContextWithProtectedObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (instancetype)templateFromString:(NSString *)templateString error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (instancetype)templateFromContentsOfFile:(NSString *)path error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (instancetype)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (instancetype)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObject:(id)object error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObjectsFromArray:(NSArray *)objects error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error GRMUSTACHE_API_PUBLIC;

@end
