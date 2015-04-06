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

#import <objc/message.h>
#import <pthread.h>
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheSafeKeyAccess.h"
#import "JRSwizzle.h"


#if !defined(NS_BLOCK_ASSERTIONS)
// For testing purpose
BOOL GRMustacheKeyAccessDidCatchNSUndefinedKeyException;
#endif


// =============================================================================
#pragma mark - Safe key access

static pthread_key_t GRSafeKeysForClassKey;
void freeSafeKeysForClass(void *objects) {
    CFRelease((CFMutableDictionaryRef)objects);
}
#define setupSafeKeysForClass() pthread_key_create(&GRSafeKeysForClassKey, freeSafeKeysForClass)
#define getCurrentThreadSafeKeysForClass() (CFMutableDictionaryRef)pthread_getspecific(GRSafeKeysForClassKey)
#define setCurrentThreadSafeKeysForClass(classes) pthread_setspecific(GRSafeKeysForClassKey, classes)


// =============================================================================
#pragma mark - Foundation declarations

static NSMutableSet *safeMustacheKeysForNSArray;
static NSMutableSet *safeMustacheKeysForNSAttributedString;
static NSMutableSet *safeMustacheKeysForNSData;
static NSMutableSet *safeMustacheKeysForNSDate;
static NSMutableSet *safeMustacheKeysForNSDateComponents;
static NSMutableSet *safeMustacheKeysForNSDecimalNumber;
static NSMutableSet *safeMustacheKeysForNSError;
static NSMutableSet *safeMustacheKeysForNSHashTable;
static NSMutableSet *safeMustacheKeysForNSIndexPath;
static NSMutableSet *safeMustacheKeysForNSIndexSet;
static NSMutableSet *safeMustacheKeysForNSMapTable;
static NSMutableSet *safeMustacheKeysForNSNotification;
static NSMutableSet *safeMustacheKeysForNSException;
static NSMutableSet *safeMustacheKeysForNSNumber;
static NSMutableSet *safeMustacheKeysForNSOrderedSet;
static NSMutableSet *safeMustacheKeysForNSPointerArray;
static NSMutableSet *safeMustacheKeysForNSSet;
static NSMutableSet *safeMustacheKeysForNSString;
static NSMutableSet *safeMustacheKeysForNSURL;
static NSMutableSet *safeMustacheKeysForNSValue;

static NSSet *safeMustacheKeys_NSArray(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSAttributedString(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSData(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSDate(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSDateComponents(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSDecimalNumber(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSError(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSHashTable(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSIndexPath(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSIndexSet(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSMapTable(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSNotification(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSException(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSNumber(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSOrderedSet(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSPointerArray(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSSet(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSString(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSURL(id self, SEL _cmd);
static NSSet *safeMustacheKeys_NSValue(id self, SEL _cmd);


// =============================================================================
#pragma mark - NSUndefinedKeyException prevention declarations

@interface NSObject(GRMustacheKeyAccessPreventionOfNSUndefinedKeyException)
- (id)GRMustacheKeyAccessValueForUndefinedKey_NSObject:(NSString *)key;
- (id)GRMustacheKeyAccessValueForUndefinedKey_NSManagedObject:(NSString *)key;
@end;


// =============================================================================
#pragma mark - GRMustacheKeyAccess

static Class NSOrderedSetClass;
static Class NSManagedObjectClass;

@interface NSObject(GRMustacheCoreDataMethods)
- (NSDictionary *)propertiesByName;
- (id)entity;
@end

@implementation GRMustacheKeyAccess

+ (void)initialize
{
    NSOrderedSetClass = NSClassFromString(@"NSOrderedSet");
    NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
    [self setupSafeKeyAccessForFoundationClasses];
    setupSafeKeysForClass();
}

+ (id)valueForMustacheKey:(NSString *)key inObject:(id)object unsafeKeyAccess:(BOOL)unsafeKeyAccess
{
    if (object == nil) {
        return nil;
    }
    
    
    // Try objectForKeyedSubscript: first (see https://github.com/groue/GRMustache/issues/66:)
    
    if ([object respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        return [object objectForKeyedSubscript:key];
    }
    
    
    // Then try valueForKey: for safe keys
    
    if (!unsafeKeyAccess && ![self isSafeMustacheKey:key forObject:object]) {
        return nil;
    }
    
    
    @try {
        
        // valueForKey: may throw NSUndefinedKeyException, and user may want to
        // prevent them.
        
        if (preventsNSUndefinedKeyException) {
            [GRMustacheKeyAccess startPreventingNSUndefinedKeyExceptionFromObject:object];
        }
        
        // We don't want to use NSArray, NSSet and NSOrderedSet implementation
        // of valueForKey:, because they return another collection: see issue
        // #21 and "anchored key should not extract properties inside an array"
        // test in src/tests/Public/v4.0/GRMustacheSuites/compound_keys.json
        //
        // Instead, we want the behavior of NSObject's implementation of valueForKey:.
        
        if ([self objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:object]) {
            return [self valueForMustacheKey:key inFoundationCollectionObject:object];
        } else {
            return [object valueForKey:key];
        }
    }
    
    @catch (NSException *exception) {
        
        // Swallow NSUndefinedKeyException only
        
        if (![[exception name] isEqualToString:NSUndefinedKeyException]) {
            [exception raise];
        }
#if !defined(NS_BLOCK_ASSERTIONS)
        else {
            // For testing purpose
            GRMustacheKeyAccessDidCatchNSUndefinedKeyException = YES;
        }
#endif
    }
    
    @finally {
        if (preventsNSUndefinedKeyException) {
            [GRMustacheKeyAccess stopPreventingNSUndefinedKeyExceptionFromObject:object];
        }
    }
    
    return nil;
}


// =============================================================================
#pragma mark - Foundation collections

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object
{
    if ([object isKindOfClass:[NSArray class]]) { return YES; }
    if ([object isKindOfClass:[NSSet class]]) { return YES; }
    if (NSOrderedSetClass && [object isKindOfClass:NSOrderedSetClass]) { return YES; }
    return NO;
}

+ (id)valueForMustacheKey:(NSString *)key inFoundationCollectionObject:(id)object
{
    // Ideally, we would use NSObject's implementation for collections, so that
    // we can access properties such as `count`, `anyObject`, etc.
    //
    // And so we did, until [issue #70](https://github.com/groue/GRMustache/issues/70)
    // revealed that the direct use of NSObject's imp crashes on arm64:
    //
    //     IMP imp = class_getMethodImplementation([NSObject class], @selector(valueForKey:));
    //     return imp(object, @selector(valueForKey:), key);    // crash on arm64
    //
    // objc_msgSendSuper fails on arm64 as well:
    //
    //     return objc_msgSendSuper(
    //              &(struct objc_super){ .receiver = object, .super_class = [NSObject class] },
    //              @selector(valueForKey:),
    //              key);    // crash on arm64
    //
    // So we have to implement NSObject's valueForKey: ourselves.
    //
    // Quoting Apple documentation:
    // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/SearchImplementation.html
    //
    // > Default Search Pattern for valueForKey:
    // >
    // > 1. Searches the class of the receiver for an accessor method whose
    // > name matches the pattern get<Key>, <key>, or is<Key>, in that order.
    //
    // The remaining of the search pattern goes into aggregates and ivars. Let's
    // ignore aggregates (until someone has a need for it), and ivars (since
    // they are private).
    
    NSString *keyWithUppercaseInitial = [NSString stringWithFormat:@"%@%@",
                                         [[key substringToIndex:1] uppercaseString],
                                         [key substringFromIndex:1]];
    NSArray *accessors = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"get%@", keyWithUppercaseInitial],
                          key,
                          [NSString stringWithFormat:@"is%@", keyWithUppercaseInitial],
                          nil];
    
    for (NSString *accessor in accessors) {
        SEL selector = NSSelectorFromString(accessor);
        if ([object respondsToSelector:selector]) {
            
            // Extract the raw value into a buffer
            
            NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.selector = selector;
            [invocation invokeWithTarget:object];
            NSUInteger methodReturnLength = [methodSignature methodReturnLength];
            if (methodReturnLength == 0) {
                // no value
                return nil;
            } else {
                void *buffer = malloc(methodReturnLength);
                if (buffer == NULL) {
                    // Allocation failed.
                    //
                    // This method is not supposed to allocate any object, so we
                    // can not behave like failing allocating methods and return
                    // nil.
                    //
                    // So let's raise an exception.
                    //
                    // NSMallocException is supposedly obsolete but there are
                    // evidences it is still used by Foundation:
                    // http://stackoverflow.com/search?q=NSMallocException
                    [NSException raise:NSMallocException format:@"Out of memory."];
                }
                [invocation getReturnValue:buffer];
                
                // Turn the raw value buffer into an object
                
                id result = nil;
                const char *objCType = [methodSignature methodReturnType];
                switch(objCType[0]) {
                    case 'c':
                        result = [NSNumber numberWithChar:*(char *)buffer];
                        break;
                    case 'i':
                        result = [NSNumber numberWithInt:*(int *)buffer];
                        break;
                    case 's':
                        result = [NSNumber numberWithShort:*(short *)buffer];
                        break;
                    case 'l':
                        result = [NSNumber numberWithLong:*(long *)buffer];
                        break;
                    case 'q':
                        result = [NSNumber numberWithLongLong:*(long long *)buffer];
                        break;
                    case 'C':
                        result = [NSNumber numberWithUnsignedChar:*(unsigned char *)buffer];
                        break;
                    case 'I':
                        result = [NSNumber numberWithUnsignedInt:*(unsigned int *)buffer];
                        break;
                    case 'S':
                        result = [NSNumber numberWithUnsignedShort:*(unsigned short *)buffer];
                        break;
                    case 'L':
                        result = [NSNumber numberWithUnsignedLong:*(unsigned long *)buffer];
                        break;
                    case 'Q':
                        result = [NSNumber numberWithUnsignedLongLong:*(unsigned long long *)buffer];
                        break;
                    case 'B':
                        result = [NSNumber numberWithBool:*(_Bool *)buffer];
                        break;
                    case 'f':
                        result = [NSNumber numberWithFloat:*(float *)buffer];
                        break;
                    case 'd':
                        result = [NSNumber numberWithDouble:*(double *)buffer];
                        break;
                    case '@':
                    case '#':
                        result = *(id *)buffer;
                        break;
                    default:
                        [NSException raise:NSInternalInconsistencyException format:@"Not implemented yet"];
                        break;
                }
                
                free(buffer);
                return result;
            }
        }
    }
    
    return nil;
}


// =============================================================================
#pragma mark - Foundation

+ (void)setupSafeKeyAccessForFoundationClasses
{
    // Safe key access prevents dangerous methods from being accessed by bad
    // templates through `valueForKey:`.
    //
    // By default, only declared properties can be accessed, unless classes
    // conform to the GRMustacheSafeKeyAccess protocol.
    //
    // We want to let users have a liberal use of KVC on Foundation classes:
    // `{{# array.count }}`, `{{ dateComponents.year }}`, etc. Those classes
    // do not always declare properties for those accessors.
    //
    // So let's setup safe keys for common Foundation classes, by allowing
    // all their non-mutating methods, plus a few safe NSObject methods,
    // minus dangerous NSObject methods.
    
    NSSet *safeMustacheNSObjectKeys = [NSSet setWithObjects:
                                       @"class",
                                       @"superclass",
                                       @"self",
                                       @"description",
                                       @"debugDescription",
                                       nil];
    NSSet *unsafeMustacheNSObjectKeys = [NSSet setWithObjects:
                                         @"init",
                                         @"dealloc",
                                         @"finalize",
                                         @"copy",
                                         @"mutableCopy",
                                         @"retain",
                                         @"release",
                                         @"autorelease",
                                         nil];
    
    SEL selector = @selector(safeMustacheKeys);
    Protocol *protocol = @protocol(GRMustacheSafeKeyAccess);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, NO);
    
#define setupSafeKeyAccessForClass(klassName) do {\
Class klass = NSClassFromString(@#klassName);\
if (klass) {\
Class metaKlass = object_getClass(klass);\
safeMustacheKeysFor ## klassName = [[self allPublicKeysForClass:klass] retain];\
[safeMustacheKeysFor ## klassName unionSet:safeMustacheNSObjectKeys];\
[safeMustacheKeysFor ## klassName minusSet:unsafeMustacheNSObjectKeys];\
class_addMethod(metaKlass, selector, (IMP)safeMustacheKeys_ ## klassName, methodDescription.types);\
class_addProtocol(klass, protocol);\
}\
} while(0);
    
    setupSafeKeyAccessForClass(NSArray);
    setupSafeKeyAccessForClass(NSAttributedString);
    setupSafeKeyAccessForClass(NSData);
    setupSafeKeyAccessForClass(NSDate);
    setupSafeKeyAccessForClass(NSDateComponents);
    setupSafeKeyAccessForClass(NSDecimalNumber);
    setupSafeKeyAccessForClass(NSError);
    setupSafeKeyAccessForClass(NSHashTable);
    setupSafeKeyAccessForClass(NSIndexPath);
    setupSafeKeyAccessForClass(NSIndexSet);
    setupSafeKeyAccessForClass(NSMapTable);
    setupSafeKeyAccessForClass(NSNotification);
    setupSafeKeyAccessForClass(NSException);
    setupSafeKeyAccessForClass(NSNumber);
    setupSafeKeyAccessForClass(NSOrderedSet);
    setupSafeKeyAccessForClass(NSPointerArray);
    setupSafeKeyAccessForClass(NSSet);
    setupSafeKeyAccessForClass(NSString);
    setupSafeKeyAccessForClass(NSURL);
    setupSafeKeyAccessForClass(NSValue);
}

/**
 * Return the set of methods without arguments, up to NSObject, non including NSObject.
 */
+ (NSMutableSet *)allPublicKeysForClass:(Class)klass
{
    NSMutableSet *keys = [NSMutableSet set];
    Class NSObjectClass = [NSObject class];
    while (klass && klass != NSObjectClass) {
        unsigned int methodCount;
        Method *methods = class_copyMethodList(klass, &methodCount);
        for (unsigned int i = 0; i < methodCount; ++i) {
            SEL selector = method_getName(methods[i]);
            const char *selectorName = sel_getName(selector);
            if (selectorName[0] != '_' && selectorName[strlen(selectorName) - 1] != '_' && strstr(selectorName, ":") == NULL) {
                [keys addObject:NSStringFromSelector(selector)];
            }
        }
        free (methods);
        klass = class_getSuperclass(klass);
    }
    
    return keys;
}


// =============================================================================
#pragma mark - Safe key access

+ (BOOL)isSafeMustacheKey:(NSString *)key forObject:(id)object
{
    NSSet *safeKeys = nil;
    {
        CFMutableDictionaryRef safeKeysForClass = getCurrentThreadSafeKeysForClass();
        if (!safeKeysForClass) {
            safeKeysForClass = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
            setCurrentThreadSafeKeysForClass(safeKeysForClass);
        }
        
        Class klass = [object class];
        safeKeys = (NSSet *)CFDictionaryGetValue(safeKeysForClass, klass);
        if (safeKeys == nil) {
            if ([klass respondsToSelector:@selector(safeMustacheKeys)]) {
                safeKeys = [klass safeMustacheKeys] ?: [NSSet set];
            } else {
                NSMutableSet *keys = [self propertyGettersForClass:klass];
                if (NSManagedObjectClass && [object isKindOfClass:NSManagedObjectClass]) {
                    [keys unionSet:[NSSet setWithArray:[[[object entity] propertiesByName] allKeys]]];
                }
                safeKeys = keys;
            }
            CFDictionarySetValue(safeKeysForClass, klass, safeKeys);
        }
    }
    
    return [safeKeys containsObject:key];
}

+ (NSMutableSet *)propertyGettersForClass:(Class)klass
{
    NSMutableSet *safeKeys = [NSMutableSet set];
    while (klass) {
        // Iterate properties
        
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(klass, &count);
        
        for (unsigned int i=0; i<count; ++i) {
            const char *attrs = property_getAttributes(properties[i]);
            
            // Safe Mustache keys are property name, and custom getter.
            
            const char *propertyNameCString = property_getName(properties[i]);
            NSString *propertyName = [NSString stringWithCString:propertyNameCString encoding:NSUTF8StringEncoding];
            [safeKeys addObject:propertyName];
            
            char *getterStart = strstr(attrs, ",G");            // ",GcustomGetter,..." or NULL if there is no custom getter
            if (getterStart) {
                getterStart += 2;                               // "customGetter,..."
                char *getterEnd = strstr(getterStart, ",");     // ",..." or NULL if customGetter is the last attribute
                size_t getterLength = (getterEnd ? getterEnd : attrs + strlen(attrs)) - getterStart;
                NSString *customGetter = [[[NSString alloc] initWithBytes:getterStart length:getterLength encoding:NSUTF8StringEncoding] autorelease];
                [safeKeys addObject:customGetter];
            }
        }
        
        free(properties);
        klass = class_getSuperclass(klass);
    }
    
    return safeKeys;
}


// =============================================================================
#pragma mark - NSUndefinedKeyException prevention

static BOOL preventsNSUndefinedKeyException = NO;

static pthread_key_t GRPreventedObjectsStorageKey;
void freePreventedObjectsStorage(void *objects) {
    [(NSMutableSet *)objects release];
}
#define setupPreventedObjectsStorage() pthread_key_create(&GRPreventedObjectsStorageKey, freePreventedObjectsStorage)
#define getCurrentThreadPreventedObjects() (NSMutableSet *)pthread_getspecific(GRPreventedObjectsStorageKey)
#define setCurrentThreadPreventedObjects(objects) pthread_setspecific(GRPreventedObjectsStorageKey, objects)

+ (void)preventNSUndefinedKeyExceptionAttack
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupNSUndefinedKeyExceptionPrevention];
    });
}

+ (void)setupNSUndefinedKeyExceptionPrevention
{
    preventsNSUndefinedKeyException = YES;
    
    // Swizzle [NSObject valueForUndefinedKey:]
    
    [NSObject jr_swizzleMethod:@selector(valueForUndefinedKey:)
                    withMethod:@selector(GRMustacheKeyAccessValueForUndefinedKey_NSObject:)
                         error:nil];
    
    
    // Swizzle [NSManagedObject valueForUndefinedKey:]
    
    if (NSManagedObjectClass) {
        [NSManagedObjectClass jr_swizzleMethod:@selector(valueForUndefinedKey:)
                                    withMethod:@selector(GRMustacheKeyAccessValueForUndefinedKey_NSManagedObject:)
                                         error:nil];
    }
    
    setupPreventedObjectsStorage();
}

+ (void)startPreventingNSUndefinedKeyExceptionFromObject:(id)object
{
    NSMutableSet *objects = getCurrentThreadPreventedObjects();
    if (objects == NULL) {
        objects = [[NSMutableSet alloc] init];
        setCurrentThreadPreventedObjects(objects);
    }
    
    [objects addObject:object];
}

+ (void)stopPreventingNSUndefinedKeyExceptionFromObject:(id)object
{
    [getCurrentThreadPreventedObjects() removeObject:object];
}

@end

@implementation NSObject(GRMustacheKeyAccessPreventionOfNSUndefinedKeyException)

// NSObject
- (id)GRMustacheKeyAccessValueForUndefinedKey_NSObject:(NSString *)key
{
    if ([getCurrentThreadPreventedObjects() containsObject:self]) {
        return nil;
    }
    return [self GRMustacheKeyAccessValueForUndefinedKey_NSObject:key];
}

// NSManagedObject
- (id)GRMustacheKeyAccessValueForUndefinedKey_NSManagedObject:(NSString *)key
{
    if ([getCurrentThreadPreventedObjects() containsObject:self]) {
        return nil;
    }
    return [self GRMustacheKeyAccessValueForUndefinedKey_NSManagedObject:key];
}

@end


// =============================================================================
#pragma mark - Foundation implementations

static NSSet *safeMustacheKeys_NSArray(id self, SEL _cmd)
{
    return safeMustacheKeysForNSArray;
}

static NSSet *safeMustacheKeys_NSAttributedString(id self, SEL _cmd)
{
    return safeMustacheKeysForNSAttributedString;
}

static NSSet *safeMustacheKeys_NSData(id self, SEL _cmd)
{
    return safeMustacheKeysForNSData;
}

static NSSet *safeMustacheKeys_NSDate(id self, SEL _cmd)
{
    return safeMustacheKeysForNSDate;
}

static NSSet *safeMustacheKeys_NSDateComponents(id self, SEL _cmd)
{
    return safeMustacheKeysForNSDateComponents;
}

static NSSet *safeMustacheKeys_NSDecimalNumber(id self, SEL _cmd)
{
    return safeMustacheKeysForNSDecimalNumber;
}

static NSSet *safeMustacheKeys_NSError(id self, SEL _cmd)
{
    return safeMustacheKeysForNSError;
}

static NSSet *safeMustacheKeys_NSHashTable(id self, SEL _cmd)
{
    return safeMustacheKeysForNSHashTable;
}

static NSSet *safeMustacheKeys_NSIndexPath(id self, SEL _cmd)
{
    return safeMustacheKeysForNSIndexPath;
}

static NSSet *safeMustacheKeys_NSIndexSet(id self, SEL _cmd)
{
    return safeMustacheKeysForNSIndexSet;
}

static NSSet *safeMustacheKeys_NSMapTable(id self, SEL _cmd)
{
    return safeMustacheKeysForNSMapTable;
}

static NSSet *safeMustacheKeys_NSNotification(id self, SEL _cmd)
{
    return safeMustacheKeysForNSNotification;
}

static NSSet *safeMustacheKeys_NSException(id self, SEL _cmd)
{
    return safeMustacheKeysForNSException;
}

static NSSet *safeMustacheKeys_NSNumber(id self, SEL _cmd)
{
    return safeMustacheKeysForNSNumber;
}

static NSSet *safeMustacheKeys_NSOrderedSet(id self, SEL _cmd)
{
    return safeMustacheKeysForNSOrderedSet;
}

static NSSet *safeMustacheKeys_NSPointerArray(id self, SEL _cmd)
{
    return safeMustacheKeysForNSPointerArray;
}

static NSSet *safeMustacheKeys_NSSet(id self, SEL _cmd)
{
    return safeMustacheKeysForNSSet;
}

static NSSet *safeMustacheKeys_NSString(id self, SEL _cmd)
{
    return safeMustacheKeysForNSString;
}

static NSSet *safeMustacheKeys_NSURL(id self, SEL _cmd)
{
    return safeMustacheKeysForNSURL;
}

static NSSet *safeMustacheKeys_NSValue(id self, SEL _cmd)
{
    return safeMustacheKeysForNSValue;
}
