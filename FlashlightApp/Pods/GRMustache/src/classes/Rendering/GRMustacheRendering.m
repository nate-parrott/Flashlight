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

#import <objc/runtime.h>
#import <pthread.h>
#import "GRMustacheRendering_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheBuffer_private.h"


// =============================================================================
#pragma mark - Rendering declarations


// GRMustacheNilRendering renders for nil

@interface GRMustacheNilRendering : NSObject<GRMustacheRenderingWithIterationSupport>
@end
static GRMustacheNilRendering *nilRendering;


// GRMustacheBlockRendering renders with a block

@interface GRMustacheBlockRendering : NSObject<GRMustacheRenderingWithIterationSupport> {
@private
    NSString *(^_renderingBlock)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
}
- (instancetype)initWithRenderingBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock;
@end


// NSNull, NSNumber, NSString, NSObject, NSFastEnumeration rendering

typedef NSString *(*GRMustacheRenderIMP)(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderGeneric(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);

typedef NSString *(*GRMustacheRenderWithIterationSupportIMP)(id self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderWithIterationSupportGeneric(id self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderWithIterationSupportNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderWithIterationSupportNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderWithIterationSupportNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderWithIterationSupportNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderWithIterationSupportNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);

typedef BOOL (*GRMustacheBoolValueIMP)(id self, SEL _cmd);
static BOOL GRMustacheBoolValueGeneric(id self, SEL _cmd);
static BOOL GRMustacheBoolValueNSNull(NSNull *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSNumber(NSNumber *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSString(NSString *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSObject(NSObject *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd);


// =============================================================================
#pragma mark - Current Template Repository

static pthread_key_t GRCurrentTemplateRepositoryStackKey;
void freeCurrentTemplateRepositoryStack(void *objects) {
    [(NSMutableArray *)objects release];
}
#define setupCurrentTemplateRepositoryStack() pthread_key_create(&GRCurrentTemplateRepositoryStackKey, freeCurrentTemplateRepositoryStack)
#define getCurrentThreadCurrentTemplateRepositoryStack() (NSMutableArray *)pthread_getspecific(GRCurrentTemplateRepositoryStackKey)
#define setCurrentThreadCurrentTemplateRepositoryStack(classes) pthread_setspecific(GRCurrentTemplateRepositoryStackKey, classes)


// =============================================================================
#pragma mark - Current Content Type

static pthread_key_t GRCurrentContentTypeStackKey;
void freeCurrentContentTypeStack(void *objects) {
    [(NSMutableArray *)objects release];
}
#define setupCurrentContentTypeStack() pthread_key_create(&GRCurrentContentTypeStackKey, freeCurrentContentTypeStack)
#define getCurrentThreadCurrentContentTypeStack() (NSMutableArray *)pthread_getspecific(GRCurrentContentTypeStackKey)
#define setCurrentThreadCurrentContentTypeStack(classes) pthread_setspecific(GRCurrentContentTypeStackKey, classes)


// =============================================================================
#pragma mark - GRMustacheRendering

@implementation GRMustacheRendering

+ (void)initialize
{
    setupCurrentTemplateRepositoryStack();
    setupCurrentContentTypeStack();
    
    nilRendering = [[GRMustacheNilRendering alloc] init];
    
    // We could have declared categories on NSNull, NSNumber, NSString and
    // NSDictionary.
    //
    // We do not, because many GRMustache users use the static library, and
    // we don't want to force them adding the `-ObjC` option to their
    // target's "Other Linker Flags" (which is required for code declared by
    // categories to be loaded).
    //
    // Instead, dynamically alter the classes whose rendering implementation
    // is already known.
    //
    // Other classes will be dynamically attached their rendering implementation
    // in the GRMustacheRenderWithIterationSupportGeneric implementation
    // attached to NSObject.
    [self registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSNull   boolValueIMP:GRMustacheBoolValueNSNull   forClass:[NSNull class]];
    [self registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSNumber boolValueIMP:GRMustacheBoolValueNSNumber forClass:[NSNumber class]];
    [self registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSString boolValueIMP:GRMustacheBoolValueNSString forClass:[NSString class]];
    [self registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSObject boolValueIMP:GRMustacheBoolValueNSObject forClass:[NSDictionary class]];
    [self registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportGeneric  boolValueIMP:GRMustacheBoolValueGeneric  forClass:[NSObject class]];
    
    // Besides, provide all objects the ability to render as an enumeration item
    // or not through GRMustacheRenderGeneric:
    [self registerRenderIMP:GRMustacheRenderGeneric forClass:[NSObject class]];

}

+ (id<GRMustacheRenderingWithIterationSupport>)renderingObjectForObject:(id)object
{
    // All objects but nil know how to render (see setupRendering).
    return object ?: nilRendering;
}

+ (id<GRMustacheRenderingWithIterationSupport>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock
{
    return [[[GRMustacheBlockRendering alloc] initWithRenderingBlock:renderingBlock] autorelease];
}


#pragma mark - Current Template Repository

+ (void)pushCurrentTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    if (!stack) {
        stack = [[NSMutableArray alloc] init];
        setCurrentThreadCurrentTemplateRepositoryStack(stack);
    }
    [stack addObject:templateRepository];
}

+ (void)popCurrentTemplateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    NSAssert(stack, @"Missing currentTemplateRepositoryStack");
    NSAssert(stack.count > 0, @"Empty currentTemplateRepositoryStack");
    [stack removeLastObject];
}

+ (GRMustacheTemplateRepository *)currentTemplateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    return [stack lastObject];
}


#pragma mark - Current Content Type

+ (void)pushCurrentContentType:(GRMustacheContentType)contentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    if (!stack) {
        stack = [[NSMutableArray alloc] init];
        setCurrentThreadCurrentContentTypeStack(stack);
    }
    [stack addObject:[NSNumber numberWithUnsignedInteger:contentType]];
}

+ (void)popCurrentContentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    NSAssert(stack, @"Missing currentContentTypeStack");
    NSAssert(stack.count > 0, @"Empty currentContentTypeStack");
    [stack removeLastObject];
}

+ (GRMustacheContentType)currentContentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    if (stack.count > 0) {
        return [(NSNumber *)[stack lastObject] unsignedIntegerValue];
    }
    return ([self currentTemplateRepository].configuration ?: [GRMustacheConfiguration defaultConfiguration]).contentType;
}


#pragma mark - Private

/**
 * Have the class _aClass_ conform to the
 * GRMustacheRenderingWithIterationSupport protocol.
 *
 * @param renderIMP     the implementation of the
 *                      renderForMustacheTag:asEnumerationItem:context:HTMLSafe:error:
 *                      method.
 * @param boolValueIMP  the implementation of the mustacheBoolValue method.
 * @param aClass        the class to modify.
 */
+ (void)registerRenderWithIterationSupportIMP:(GRMustacheRenderWithIterationSupportIMP)renderIMP boolValueIMP:(GRMustacheBoolValueIMP)boolValueIMP forClass:(Class)klass
{
    Protocol *protocol = @protocol(GRMustacheRenderingWithIterationSupport);
    
    // Add method implementations
    
    {
        SEL selector = @selector(renderForMustacheTag:asEnumerationItem:context:HTMLSafe:error:);
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, YES);
        class_addMethod(klass, selector, (IMP)renderIMP, methodDescription.types);
    }
    
    {
        SEL selector = @selector(mustacheBoolValue);
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, YES);
        class_addMethod(klass, selector, (IMP)boolValueIMP, methodDescription.types);
    }

    // Add protocol conformance
    class_addProtocol(klass, protocol);
}

/**
 * Have the class _aClass_ conform to the GRMustacheRendering protocol.
 *
 * @param renderIMP     the implementation of the
 *                      renderForMustacheTag:context:HTMLSafe:error: method.
 * @param aClass        the class to modify.
 */
+ (void)registerRenderIMP:(GRMustacheRenderIMP)renderIMP forClass:(Class)klass
{
    Protocol *protocol = @protocol(GRMustacheRendering);
    
    // Add method implementations
    
    {
        SEL selector = @selector(renderForMustacheTag:context:HTMLSafe:error:);
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, YES);
        class_addMethod(klass, selector, (IMP)renderIMP, methodDescription.types);
    }
    
    // Add protocol conformance
    class_addProtocol(klass, protocol);
}

@end


// =============================================================================
#pragma mark - Rendering Implementations

@implementation GRMustacheNilRendering

- (BOOL)mustacheBoolValue
{
    return NO;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return [self renderForMustacheTag:tag asEnumerationItem:NO context:context HTMLSafe:HTMLSafe error:error];
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag asEnumerationItem:(BOOL)enumerationItem context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ nil }}
            return @"";
            
        case GRMustacheTagTypeSection:
            // {{# nil }}...{{/}}
            // {{^ nil }}...{{/}}
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}

@end


@implementation GRMustacheBlockRendering

- (void)dealloc
{
    [_renderingBlock release];
    [super dealloc];
}

- (instancetype)initWithRenderingBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock
{
    if (renderingBlock == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Can't build a rendering object with a nil rendering block."];
    }
    
    self = [super init];
    if (self) {
        _renderingBlock = [renderingBlock copy];
    }
    return self;
}

- (BOOL)mustacheBoolValue
{
    return YES;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return _renderingBlock(tag, context, HTMLSafe, error);
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag asEnumerationItem:(BOOL)enumerationItem context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return _renderingBlock(tag, context, HTMLSafe, error);
}

@end


static BOOL GRMustacheBoolValueGeneric(id self, SEL _cmd)
{
    // Self doesn't know (yet) its mustache boolean value
    
    Class klass = object_getClass(self);
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)])
    {
        // Future invocations will use GRMustacheBoolValueNSFastEnumeration
        [GRMustacheRendering registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSFastEnumeration boolValueIMP:GRMustacheBoolValueNSFastEnumeration forClass:klass];
        return GRMustacheBoolValueNSFastEnumeration(self, _cmd);
    }
    
    if (klass != [NSObject class])
    {
        // Future invocations will use GRMustacheRenderNSObject
        [GRMustacheRendering registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSObject boolValueIMP:GRMustacheBoolValueNSObject forClass:klass];
    }
    
    return GRMustacheBoolValueNSObject(self, _cmd);
}

static NSString *GRMustacheRenderGeneric(id<GRMustacheRenderingWithIterationSupport> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    return [self renderForMustacheTag:tag asEnumerationItem:NO context:context HTMLSafe:HTMLSafe error:error];
}

static NSString *GRMustacheRenderWithIterationSupportGeneric(id self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // Self doesn't know (yet) how to render as an enumeration item
    
    Class klass = object_getClass(self);
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)])
    {
        // Future invocations will use GRMustacheRenderNSFastEnumeration
        [GRMustacheRendering registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSFastEnumeration boolValueIMP:GRMustacheBoolValueNSFastEnumeration forClass:klass];
        return GRMustacheRenderWithIterationSupportNSFastEnumeration(self, _cmd, tag, enumerationItem, context, HTMLSafe, error);
    }
    
    if (klass != [NSObject class])
    {
        // Future invocations will use GRMustacheRenderWithIterationSupportNSObject
        [GRMustacheRendering registerRenderWithIterationSupportIMP:GRMustacheRenderWithIterationSupportNSObject boolValueIMP:GRMustacheBoolValueNSObject forClass:klass];
    }
    
    return GRMustacheRenderWithIterationSupportNSObject(self, _cmd, tag, enumerationItem, context, HTMLSafe, error);
}

static BOOL GRMustacheBoolValueNSNull(NSNull *self, SEL _cmd)
{
    return NO;
}

static NSString *GRMustacheRenderWithIterationSupportNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ null }}
            return @"";
            
        case GRMustacheTagTypeSection:
            if (enumerationItem) {
                context = [context newContextByAddingObject:self];
                NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                [context release];
                return rendering;
            } else {
                // {{^ null }}...{{/}}
                // {{# null }}...{{/}}
                
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }
    }
}

static BOOL GRMustacheBoolValueNSNumber(NSNumber *self, SEL _cmd)
{
    return [self boolValue];
}

static NSString *GRMustacheRenderWithIterationSupportNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ number }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return [self description];
            
        case GRMustacheTagTypeSection:
            if (enumerationItem) {
                context = [context newContextByAddingObject:self];
                NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                [context release];
                return rendering;
            } else {
                // {{^ number }}...{{/}}
                // {{# number }}...{{/}}
                //
                // janl/mustache.js and defunkt/mustache don't push bools in the
                // context stack. Follow their path, and avoid the creation of a
                // useless context nobody cares about.
                //
                // GRMustache 7.2.0 broke this behavior (see issue
                // https://github.com/groue/GRMustache/issues/83). This behavior
                // must stay!
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }
    }
}

static BOOL GRMustacheBoolValueNSString(NSString *self, SEL _cmd)
{
    return (self.length > 0);
}

static NSString *GRMustacheRenderWithIterationSupportNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ string }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return self;
            
        case GRMustacheTagTypeSection:
            if (tag.isInverted) {
                // {{^ number }}...{{/}}
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            } else {
                // {{# string }}...{{/}}
                context = [context newContextByAddingObject:self];
                NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                [context release];
                return rendering;
            }
    }
}

static BOOL GRMustacheBoolValueNSObject(NSObject *self, SEL _cmd)
{
    return YES;
}

static NSString *GRMustacheRenderWithIterationSupportNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ object }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# object }}...{{/}}
            // {{^ object }}...{{/}}
            context = [context newContextByAddingObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
    }
}

static BOOL GRMustacheBoolValueNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd)
{
    for (id _ __attribute__((unused)) in self) {
        return YES;
    }
    return NO;
}

static NSString *GRMustacheRenderWithIterationSupportNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, BOOL enumerationItem, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    if (enumerationItem) {
        context = [context newContextByAddingObject:self];
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        [context release];
        return rendering;
    }
    
    // {{ list }}
    // {{# list }}...{{/}}
    // {{^ list }}...{{/}}
    
    BOOL success = YES;
    BOOL bufferCreated = NO;
    GRMustacheBuffer buffer;
    BOOL anyItemHTMLSafe = NO;
    BOOL anyItemHTMLUnsafe = NO;
    
    for (id item in self) {
        if (!bufferCreated) {
            buffer = GRMustacheBufferCreate(1024);
            bufferCreated = YES;
        }
        @autoreleasepool {
            // Render item
            
            BOOL itemHTMLSafe = NO; // always assume unsafe rendering
            NSError *renderingError = nil;
            NSString *rendering = [[GRMustacheRendering renderingObjectForObject:item] renderForMustacheTag:tag asEnumerationItem:YES context:context HTMLSafe:&itemHTMLSafe error:&renderingError];
            
            if (!rendering) {
                if (!renderingError) {
                    // Rendering is nil, but rendering error is not set.
                    //
                    // Assume a rendering object coded by a lazy programmer,
                    // whose intention is to render nothing.
                    
                    rendering = @"";
                } else {
                    if (error != NULL) {
                        // make sure error is not released by autoreleasepool
                        *error = renderingError;
                        [*error retain];
                    }
                    success = NO;
                    break;
                }
            }
            
            // check consistency of HTML escaping
            
            if (itemHTMLSafe) {
                anyItemHTMLSafe = YES;
                if (anyItemHTMLUnsafe) {
                    [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                }
            } else {
                anyItemHTMLUnsafe = YES;
                if (anyItemHTMLSafe) {
                    [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                }
            }
            
            // appending the rendering to the buffer
            
            GRMustacheBufferAppendString(&buffer, rendering);
        }
    }
    
    if (!success) {
        if (error != NULL) [*error autorelease];
        GRMustacheBufferRelease(&buffer);
        return nil;
    }
    
    if (bufferCreated) {
        // Non-empty list
        
        if (HTMLSafe != NULL) {
            *HTMLSafe = !anyItemHTMLUnsafe;
        }
        return GRMustacheBufferGetStringAndRelease(&buffer);
    } else {
        // Empty list
        
        switch (tag.type) {
            case GRMustacheTagTypeVariable:
                // {{ emptyList }}
                return @"";
                
            case GRMustacheTagTypeSection:
                // {{^ emptyList }}...{{/}}
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }
    }
}
