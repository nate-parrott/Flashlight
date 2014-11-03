
#import "RTMethod.h"

#import <stdarg.h>

#import "MARTNSObject.h"


@interface _RTObjCMethod : RTMethod
{
    Method _m;
}

@end

@implementation _RTObjCMethod

- (id)initWithObjCMethod: (Method)method
{
    if((self = [self init]))
    {
        _m = method;
    }
    return self;
}

- (SEL)selector
{
    return method_getName(_m);
}

- (IMP)implementation
{
    return method_getImplementation(_m);
}

- (NSString *)signature
{
    return [NSString stringWithUTF8String: method_getTypeEncoding(_m)];
}

- (void)setImplementation: (IMP)newImp
{
    method_setImplementation(_m, newImp);
}

@end

@interface _RTComponentsMethod : RTMethod
{
    SEL _sel;
    IMP _imp;
    NSString *_sig;
}

@end

@implementation _RTComponentsMethod

- (id)initWithSelector: (SEL)sel implementation: (IMP)imp signature: (NSString *)signature
{
    if((self = [self init]))
    {
        _sel = sel;
        _imp = imp;
        _sig = [signature copy];
    }
    return self;
}

- (void)dealloc
{
    [_sig release];
    [super dealloc];
}

- (SEL)selector
{
    return _sel;
}

- (IMP)implementation
{
    return _imp;
}

- (NSString *)signature
{
    return _sig;
}

- (void)setImplementation: (IMP)newImp
{
    _imp = newImp;
}

@end

@implementation RTMethod

+ (id)methodWithObjCMethod: (Method)method
{
    return [[[self alloc] initWithObjCMethod: method] autorelease];
}

+ (id)methodWithSelector: (SEL)sel implementation: (IMP)imp signature: (NSString *)signature
{
    return [[[self alloc] initWithSelector: sel implementation: imp signature: signature] autorelease];
}

- (id)initWithObjCMethod: (Method)method
{
    [self release];
    return [[_RTObjCMethod alloc] initWithObjCMethod: method];
}

- (id)initWithSelector: (SEL)sel implementation: (IMP)imp signature: (NSString *)signature
{
    [self release];
    return [[_RTComponentsMethod alloc] initWithSelector: sel implementation: imp signature: signature];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ %p: %@ %p %@>", [self class], self, NSStringFromSelector([self selector]), [self implementation], [self signature]];
}

- (BOOL)isEqual: (id)other
{
    return [other isKindOfClass: [RTMethod class]] &&
           [self selector] == [other selector] &&
           [self implementation] == [other implementation] &&
           [[self signature] isEqual: [other signature]];
}

- (NSUInteger)hash
{
    return (NSUInteger)(void *)[self selector] ^ (NSUInteger)[self implementation] ^ [[self signature] hash];
}

- (SEL)selector
{
    [self doesNotRecognizeSelector: _cmd];
    return NULL;
}

- (NSString *)selectorName
{
    return NSStringFromSelector([self selector]);
}

- (IMP)implementation
{
    [self doesNotRecognizeSelector: _cmd];
    return NULL;
}

- (NSString *)signature
{
    [self doesNotRecognizeSelector: _cmd];
    return NULL;
}

- (void)setImplementation: (IMP)newImp
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void)_returnValue: (void *)retPtr sendToTarget: (id)target arguments: (va_list)args
{
    NSMethodSignature *signature = [target methodSignatureForSelector: [self selector]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
    NSUInteger argumentCount = [signature numberOfArguments];
    
    [invocation setTarget: target];
    [invocation setSelector: [self selector]];
    for(NSUInteger i = 2; i < argumentCount; i++)
    {
        int cookie = va_arg(args, int);
        if(cookie != RT_ARG_MAGIC_COOKIE)
        {
            NSLog(@"%s: incorrect magic cookie %08x; did you forget to use RTARG() around your arguments?", __func__, cookie);
            abort();
        }
        const char *typeStr = va_arg(args, char *);
        void *argPtr = va_arg(args, void *);
        
        NSUInteger inSize;
        NSGetSizeAndAlignment(typeStr, &inSize, NULL);
        NSUInteger sigSize;
        NSGetSizeAndAlignment([signature getArgumentTypeAtIndex: i], &sigSize, NULL);
        
        if(inSize != sigSize)
        {
            NSLog(@"%s: size mismatch between passed-in argument and required argument; in type: %s (%lu) requested: %s (%lu)", __func__, typeStr, (long)inSize, [signature getArgumentTypeAtIndex: i], (long)sigSize);
            abort();
        }
        
        [invocation setArgument: argPtr atIndex: i];
    }
    
    [invocation invoke];
    
    if([signature methodReturnLength] && retPtr)
        [invocation getReturnValue: retPtr];
}

- (id)sendToTarget: (id)target, ...
{
    NSParameterAssert([[self signature] hasPrefix: [NSString stringWithUTF8String: @encode(id)]]);
    
    id retVal = nil;
    
    va_list args;
    va_start(args, target);
    [self _returnValue: &retVal sendToTarget: target arguments: args];
    va_end(args);
    
    return retVal;
}

- (void)returnValue: (void *)retPtr sendToTarget: (id)target, ...
{
    va_list args;
    va_start(args, target);
    [self _returnValue: retPtr sendToTarget: target arguments: args];
    va_end(args);
}

@end

@implementation NSObject (RTMethodSendingAdditions)

- (id)rt_sendMethod: (RTMethod *)method, ...
{
    NSParameterAssert([[method signature] hasPrefix: [NSString stringWithUTF8String: @encode(id)]]);
    
    id retVal = nil;
    
    va_list args;
    va_start(args, method);
    [method _returnValue: &retVal sendToTarget: self arguments: args];
    va_end(args);
    
    return retVal;
}

- (void)rt_returnValue: (void *)retPtr sendMethod: (RTMethod *)method, ...
{
    va_list args;
    va_start(args, method);
    [method _returnValue: retPtr sendToTarget: self arguments: args];
    va_end(args);
}

- (id)rt_sendSelector: (SEL)sel, ...
{
    RTMethod *method = [[self rt_class] rt_methodForSelector: sel];
    NSParameterAssert([[method signature] hasPrefix: [NSString stringWithUTF8String: @encode(id)]]);
    
    id retVal = nil;
    
    va_list args;
    va_start(args, sel);
    [method _returnValue: &retVal sendToTarget: self arguments: args];
    va_end(args);
    
    return retVal;
}

- (void)rt_returnValue: (void *)retPtr sendSelector: (SEL)sel, ...
{
    RTMethod *method = [[self rt_class] rt_methodForSelector: sel];
    va_list args;
    va_start(args, sel);
    [method _returnValue: retPtr sendToTarget: self arguments: args];
    va_end(args);
}

@end
