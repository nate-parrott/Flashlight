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
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheInheritablePartialNode_private.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheExpressionInvocation_private.h"

#define GRMUSTACHE_STACK_RELEASE(stackName) \
    [GRMUSTACHE_STACK_TOP_IVAR(stackName) release]; \
    [GRMUSTACHE_STACK_PARENT_IVAR(stackName) release]

#define GRMUSTACHE_STACK_INIT(stackName, context, object) \
    GRMUSTACHE_STACK_TOP(stackName, context) = [object retain]

#define GRMUSTACHE_STACK_COPY(stackName, sourceContext, targetContext) \
    GRMUSTACHE_STACK_TOP(stackName, targetContext) = [GRMUSTACHE_STACK_TOP(stackName, sourceContext) retain]; \
    GRMUSTACHE_STACK_PARENT(stackName, targetContext) = [GRMUSTACHE_STACK_PARENT(stackName, sourceContext) retain]

#define GRMUSTACHE_STACK_PUSH(stackName, sourceContext, targetContext, object) \
    NSAssert(object, @"WTF"); \
    if (GRMUSTACHE_STACK_TOP(stackName, sourceContext)) { \
        GRMUSTACHE_STACK_PARENT(stackName, targetContext) = [sourceContext retain]; \
    } \
    GRMUSTACHE_STACK_TOP(stackName, targetContext) = [object retain];

#define GRMUSTACHE_STACK_TOP(stackName, context) context->GRMUSTACHE_STACK_TOP_IVAR(stackName)

#define GRMUSTACHE_STACK_PARENT(stackName, context) context->GRMUSTACHE_STACK_PARENT_IVAR(stackName)

#define GRMUSTACHE_STACK_ENUMERATE(stackName, sourceContext, context) \
    if (GRMUSTACHE_STACK_TOP(stackName, sourceContext)) \
        for (GRMustacheContext *context = sourceContext; context; context = GRMUSTACHE_STACK_PARENT(stackName, context))

// =============================================================================
#pragma mark - GRMustacheTagDelegate conformance

static pthread_key_t GRTagDelegateClassesKey;
void freeTagDelegateClasses(void *objects) {
    CFRelease((CFMutableDictionaryRef)objects);
}
#define setupTagDelegateClasses() pthread_key_create(&GRTagDelegateClassesKey, freeTagDelegateClasses)
#define getCurrentThreadTagDelegateClasses() (CFMutableDictionaryRef)pthread_getspecific(GRTagDelegateClassesKey)
#define setCurrentThreadTagDelegateClasses(classes) pthread_setspecific(GRTagDelegateClassesKey, classes)

static BOOL objectConformsToTagDelegateProtocol(id object)
{
    if (object == nil) {
        return NO;
    }
    
    CFMutableDictionaryRef classes = getCurrentThreadTagDelegateClasses();
    if (!classes) {
        classes = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        setCurrentThreadTagDelegateClasses(classes);
    }
    
    Class klass = [object class];
    intptr_t conform = (intptr_t)CFDictionaryGetValue(classes, klass);
    if (conform == 0) {
        conform = [klass conformsToProtocol:@protocol(GRMustacheTagDelegate)] ? 1 : 2;
        CFDictionarySetValue(classes, klass, (void *)conform);
    }
    return (conform == 1);
}


// =============================================================================
#pragma mark - GRMustacheContext

@implementation GRMustacheContext

+ (void)initialize
{
    setupTagDelegateClasses();
}

- (id<GRMustacheTemplateASTNode>)resolveTemplateASTNode:(id<GRMustacheTemplateASTNode>)templateASTNode
{
    if (!GRMUSTACHE_STACK_TOP(inheritablePartialNodeStack, self)) {
        return templateASTNode;
    }
    
    NSMutableSet *usedTemplateASTs = [[NSMutableSet alloc] init];
    GRMUSTACHE_STACK_ENUMERATE(inheritablePartialNodeStack, self, context) {
        GRMustacheInheritablePartialNode *inheritablePartialNode = GRMUSTACHE_STACK_TOP(inheritablePartialNodeStack, context);
        GRMustacheTemplateAST *templateAST = inheritablePartialNode.partialNode.templateAST;
        if ([usedTemplateASTs containsObject:templateAST]) {
            continue;
        }
        id<GRMustacheTemplateASTNode> resolvedASTNode = [inheritablePartialNode resolveTemplateASTNode:templateASTNode];
        if (resolvedASTNode != templateASTNode) {
            [usedTemplateASTs addObject:templateAST];
        }
        templateASTNode = resolvedASTNode;
    }
    [usedTemplateASTs release];
    
    return templateASTNode;
}

- (BOOL)unsafeKeyAccess
{
    return _unsafeKeyAccess;
}


// =============================================================================
#pragma mark - Creating Contexts

+ (instancetype)context
{
    return [[[self alloc] init] autorelease];
}

+ (instancetype)contextWithUnsafeKeyAccess
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    context->_unsafeKeyAccess = YES;
    return context;
}

+ (instancetype)contextWithObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    GRMUSTACHE_STACK_INIT(contextStack, context, object);
    if (objectConformsToTagDelegateProtocol(object)) {
        GRMUSTACHE_STACK_INIT(tagDelegateStack, context, object);
    }
    return context;
}

+ (instancetype)contextWithProtectedObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    GRMUSTACHE_STACK_INIT(protectedContextStack, context, object);
    return context;
}

+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    GRMUSTACHE_STACK_INIT(tagDelegateStack, context, tagDelegate);
    return context;
}

- (void)dealloc
{
    GRMUSTACHE_STACK_RELEASE(contextStack);
    GRMUSTACHE_STACK_RELEASE(protectedContextStack);
    GRMUSTACHE_STACK_RELEASE(hiddenContextStack);
    GRMUSTACHE_STACK_RELEASE(tagDelegateStack);
    GRMUSTACHE_STACK_RELEASE(inheritablePartialNodeStack);
    [super dealloc];
}


// =============================================================================
#pragma mark - Deriving Contexts

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    GRMustacheContext *context = [GRMustacheContext context];
    context->_unsafeKeyAccess = _unsafeKeyAccess;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(inheritablePartialNodeStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(tagDelegateStack, self, context, tagDelegate);
    
    return context;
}

- (instancetype)newContextByAddingObject:(id)object
{
    if (object == nil) {
        return [self retain];
    }
    
    GRMustacheContext *context = [[GRMustacheContext alloc] init];
    context->_unsafeKeyAccess = _unsafeKeyAccess;
    
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(inheritablePartialNodeStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(contextStack, self, context, object);
    
    if (objectConformsToTagDelegateProtocol(object)) {
        GRMUSTACHE_STACK_PUSH(tagDelegateStack, self, context, object);
    } else {
        GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    }
    
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    return [[self newContextByAddingObject:object] autorelease];
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [GRMustacheContext context];
    context->_unsafeKeyAccess = _unsafeKeyAccess;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(inheritablePartialNodeStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(protectedContextStack, self, context, object);
    
    return context;
}

- (instancetype)contextByAddingHiddenObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [GRMustacheContext context];
    context->_unsafeKeyAccess = _unsafeKeyAccess;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(inheritablePartialNodeStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(hiddenContextStack, self, context, object);
    
    return context;
}

- (instancetype)contextByAddingInheritablePartialNode:(GRMustacheInheritablePartialNode *)inheritablePartialNode
{
    if (inheritablePartialNode == nil) {
        return self;
    }
    
    GRMustacheContext *context = [GRMustacheContext context];
    context->_unsafeKeyAccess = _unsafeKeyAccess;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(inheritablePartialNodeStack, self, context, inheritablePartialNode);
    
    return context;
}

- (instancetype)contextWithUnsafeKeyAccess
{
#define GRMUSTACHE_CREATE_DEEP_UNSAFE_CONTEXTS(stackName) \
    GRMUSTACHE_STACK_ENUMERATE(stackName, self, __context) { \
        GRMustacheContext *__unsafeContext = CFDictionaryGetValue(unsafeContextForContext, __context); \
        if (!__unsafeContext) { \
            __unsafeContext = [GRMustacheContext contextWithUnsafeKeyAccess]; \
            GRMUSTACHE_STACK_COPY(contextStack, __context, __unsafeContext); \
            GRMUSTACHE_STACK_COPY(protectedContextStack, __context, __unsafeContext); \
            GRMUSTACHE_STACK_COPY(hiddenContextStack, __context, __unsafeContext); \
            GRMUSTACHE_STACK_COPY(tagDelegateStack, __context, __unsafeContext); \
            GRMUSTACHE_STACK_COPY(inheritablePartialNodeStack, __context, __unsafeContext); \
            CFDictionarySetValue(unsafeContextForContext, __context, __unsafeContext); \
        } \
    }

#define GRMUSTACHE_UPDATE_UNSAFE_PARENT(stackName, context) { \
    GRMustacheContext *__safeParent = GRMUSTACHE_STACK_PARENT(stackName, context); \
    if (__safeParent) { \
        GRMustacheContext *__unsafeParent = CFDictionaryGetValue(unsafeContextForContext, __safeParent); \
        [__safeParent release]; \
        GRMUSTACHE_STACK_PARENT(stackName, context) = [__unsafeParent retain]; \
    } \
}

    // Duplicate contexts of all stacks into unsafe contexts.
    // The parents of unsafe contexts are still the safe ones, that we'll update later.
    
    CFMutableDictionaryRef unsafeContextForContext = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    
    GRMUSTACHE_CREATE_DEEP_UNSAFE_CONTEXTS(contextStack);
    GRMUSTACHE_CREATE_DEEP_UNSAFE_CONTEXTS(protectedContextStack);
    GRMUSTACHE_CREATE_DEEP_UNSAFE_CONTEXTS(hiddenContextStack);
    GRMUSTACHE_CREATE_DEEP_UNSAFE_CONTEXTS(tagDelegateStack);
    GRMUSTACHE_CREATE_DEEP_UNSAFE_CONTEXTS(inheritablePartialNodeStack);
    
    
    // Update safe parents of unsafe contexts with unsafe ones
    
    CFIndex count = CFDictionaryGetCount(unsafeContextForContext);
    GRMustacheContext **unsafeContexts = malloc(count * sizeof(GRMustacheContext *));
    if (unsafeContexts == NULL) {
        // Allocation failed.
        //
        // This method is supposed to return a newly created object, so we can
        // behave like failing allocating methods and return nil.
        //
        // And make sure we cleanup allocated memory before.
        CFRelease(unsafeContextForContext);
        return nil;
    }
    CFDictionaryGetKeysAndValues(unsafeContextForContext, NULL, (const void **)unsafeContexts);
    for (CFIndex i = 0; i < count; ++i) {
        GRMustacheContext *unsafeContext = unsafeContexts[i];
        GRMUSTACHE_UPDATE_UNSAFE_PARENT(contextStack, unsafeContext);
        GRMUSTACHE_UPDATE_UNSAFE_PARENT(protectedContextStack, unsafeContext);
        GRMUSTACHE_UPDATE_UNSAFE_PARENT(hiddenContextStack, unsafeContext);
        GRMUSTACHE_UPDATE_UNSAFE_PARENT(tagDelegateStack, unsafeContext);
        GRMUSTACHE_UPDATE_UNSAFE_PARENT(inheritablePartialNodeStack, unsafeContext);
    }
    free(unsafeContexts);
    
    
    // Done
    
    GRMustacheContext *unsafeContext = CFDictionaryGetValue(unsafeContextForContext, self);
    CFRelease(unsafeContextForContext);
    return unsafeContext;
}

// =============================================================================
#pragma mark - Context Stack

- (id)topMustacheObject
{
    return [[GRMUSTACHE_STACK_TOP(contextStack, self) retain] autorelease];
}

- (id)valueForMustacheKey:(NSString *)key
{
    return [self valueForMustacheKey:key protected:NULL];
}

- (id)valueForMustacheKey:(NSString *)key protected:(BOOL *)protected
{
    // First look for in the protected context stack
    
    GRMUSTACHE_STACK_ENUMERATE(protectedContextStack, self, context) {
        id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:GRMUSTACHE_STACK_TOP(protectedContextStack, context) unsafeKeyAccess:context->_unsafeKeyAccess];
        if (value != nil) {
            if (protected != NULL) {
                *protected = YES;
            }
            return value;
        }
    }
    
    
    // Then look for in the regular context stack
    
    GRMUSTACHE_STACK_ENUMERATE(contextStack, self, context) {
        // First check for contextObject:
        //
        // context = [GRMustacheContext contextWithObject:@{key:value}];
        // assert([context valueForKey:key] == value);
        id contextObject = GRMUSTACHE_STACK_TOP(contextStack, context);
        BOOL hidden = NO;
        GRMUSTACHE_STACK_ENUMERATE(hiddenContextStack, self, hiddenContext) {
            if (contextObject == GRMUSTACHE_STACK_TOP(hiddenContextStack, hiddenContext)) {
                hidden = YES;
                break;
            }
        }
        if (hidden) { continue; }
        id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:contextObject unsafeKeyAccess:context->_unsafeKeyAccess];
        if (value != nil) {
            if (protected != NULL) {
                *protected = NO;
            }
            return value;
        }
    }
    
    
    // OK give up now
    
    return nil;
}

- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)string error:(NSError **)error
{
    GRMustacheExpressionParser *parser = [[[GRMustacheExpressionParser alloc] init] autorelease];
    GRMustacheExpression *expression = [parser parseExpression:string empty:NULL error:error];
    
    GRMustacheExpressionInvocation *invocation = [[[GRMustacheExpressionInvocation alloc] init] autorelease];
    invocation.context = self;
    invocation.expression = expression;
    if (![invocation invokeReturningError:error]) {
        return NO;
    }
    
    if (value) {
        *value = invocation.value;
    }
    return YES;
}


// =============================================================================
#pragma mark - Tag Delegates Stack

- (NSArray *)tagDelegateStack
{
    NSMutableArray *tagDelegateStack = nil;

    GRMUSTACHE_STACK_ENUMERATE(tagDelegateStack, self, context) {
        if (!tagDelegateStack) {
            tagDelegateStack = [NSMutableArray array];
        }
        [tagDelegateStack insertObject:GRMUSTACHE_STACK_TOP(tagDelegateStack, context) atIndex:0];
    }
    
    return tagDelegateStack;
}

@end
