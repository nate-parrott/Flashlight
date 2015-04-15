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

@class GRMustacheTemplateAST;
@class GRMustacheTemplate;
@class GRMustacheTemplateRepository;
@class GRMustacheConfiguration;

// Documented in GRMustacheTemplateRepository.h
@protocol GRMustacheTemplateRepositoryDataSource <NSObject>

// Documented in GRMustacheTemplateRepository.h
- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)error GRMUSTACHE_API_PUBLIC;
@end

// Documented in GRMustacheTemplateRepository.h
@interface GRMustacheTemplateRepository : NSObject {
@private
    id<GRMustacheTemplateRepositoryDataSource> _dataSource;
    NSMutableDictionary *_templateASTForTemplateID;
    GRMustacheConfiguration *_configuration;
}

// Documented in GRMustacheTemplateRepository.h
@property (nonatomic, assign) id<GRMustacheTemplateRepositoryDataSource> dataSource GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
@property (nonatomic, copy) GRMustacheConfiguration *configuration GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithBaseURL:(NSURL *)URL GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithDirectory:(NSString *)path GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithBundle:(NSBundle *)bundle GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepositoryWithDictionary:(NSDictionary *)partialsDictionary GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (instancetype)templateRepository GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (GRMustacheTemplate *)templateNamed:(NSString *)name error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (void)reloadTemplates GRMUSTACHE_API_PUBLIC;

/**
 * TODO
 */
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString contentType:(GRMustacheContentType)contentType error:(NSError **)error GRMUSTACHE_API_INTERNAL;

/**
 * Returns an AST, given its name.
 *
 * @param name            The name of the template
 * @param baseTemplateID  The template ID of the enclosing template, or nil.
 * @param error           If there is an error loading or parsing template and
 *                        partials, upon return contains an NSError object that
 *                        describes the problem.
 *
 * @return an AST
 */
- (GRMustacheTemplateAST *)templateASTNamed:(NSString *)name relativeToTemplateID:(id)baseTemplateID error:(NSError **)error GRMUSTACHE_API_INTERNAL;

@end
