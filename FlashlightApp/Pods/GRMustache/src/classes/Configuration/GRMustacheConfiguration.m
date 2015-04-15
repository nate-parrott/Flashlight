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

#import "GRMustacheConfiguration_private.h"
#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"

@implementation GRMustacheConfiguration
@synthesize contentType=_contentType;
@synthesize tagStartDelimiter=_tagStartDelimiter;
@synthesize tagEndDelimiter=_tagEndDelimiter;
@synthesize baseContext=_baseContext;
@synthesize locked=_locked;

+ (GRMustacheConfiguration *)defaultConfiguration
{
    static GRMustacheConfiguration *defaultConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultConfiguration = [[GRMustacheConfiguration alloc] init];
    });
    return defaultConfiguration;
}

+ (GRMustacheConfiguration *)configuration
{
    return [[[GRMustacheConfiguration alloc] init] autorelease];
}

- (void)dealloc
{
    [_tagStartDelimiter release];
    [_tagEndDelimiter release];
    [_baseContext release];
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentType = GRMustacheContentTypeHTML;
        _tagStartDelimiter = [@"{{" retain];    // useless retain that matches the release in dealloc
        _tagEndDelimiter = [@"}}" retain];      // useless retain that matches the release in dealloc
        _baseContext = [[GRMustacheContext contextWithObject:[GRMustache standardLibrary]] retain];
    }
    return self;
}

- (void)lock
{
    _locked = YES;
}

- (void)setContentType:(GRMustacheContentType)contentType
{
    [self assertNotLocked];
    
    _contentType = contentType;
}

- (void)setTagStartDelimiter:(NSString *)tagStartDelimiter
{
    [self assertNotLocked];
    
    if (tagStartDelimiter.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid tagStartDelimiter:%@", tagStartDelimiter];
        return;
    }
    
    if (_tagStartDelimiter != tagStartDelimiter) {
        [_tagStartDelimiter release];
        _tagStartDelimiter = [tagStartDelimiter copy];
    }
}

- (void)setTagEndDelimiter:(NSString *)tagEndDelimiter
{
    [self assertNotLocked];
    
    if (tagEndDelimiter.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid tagEndDelimiter:%@", tagEndDelimiter];
        return;
    }
    
    if (_tagEndDelimiter != tagEndDelimiter) {
        [_tagEndDelimiter release];
        _tagEndDelimiter = [tagEndDelimiter copy];
    }
}

- (void)setBaseContext:(GRMustacheContext *)baseContext
{
    [self assertNotLocked];
    
    if (!baseContext) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid baseContext:nil"];
        return;
    }
    
    if (_baseContext != baseContext) {
        [_baseContext release];
        _baseContext = [baseContext retain];
    }
}

- (void)extendBaseContextWithObject:(id)object
{
    self.baseContext = [self.baseContext contextByAddingObject:object];
}

- (void)extendBaseContextWithProtectedObject:(id)object
{
    self.baseContext = [self.baseContext contextByAddingProtectedObject:object];
}

- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    self.baseContext = [self.baseContext contextByAddingTagDelegate:tagDelegate];
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    GRMustacheConfiguration *configuration = [[GRMustacheConfiguration alloc] init];
    configuration.contentType = _contentType;
    configuration.tagStartDelimiter = _tagStartDelimiter;
    configuration.tagEndDelimiter = _tagEndDelimiter;
    configuration.baseContext = _baseContext;
    // Do not copy the _locked flag, so that the copy is mutable.
    return configuration;
}


#pragma mark - Private

- (void)assertNotLocked
{
    if (_locked) {
        [NSException raise:NSGenericException format:@"%@ was mutated after template compilation", self];
    }
}

@end
