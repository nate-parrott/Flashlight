
#import "RTIvar.h"


@interface _RTObjCIvar : RTIvar
{
    Ivar _ivar;
}
@end

@implementation _RTObjCIvar

- (id)initWithObjCIvar: (Ivar)ivar
{
    if((self = [self init]))
    {
        _ivar = ivar;
    }
    return self;
}
- (NSString *)name
{
    return [NSString stringWithUTF8String: ivar_getName(_ivar)];
}

- (NSString *)typeEncoding
{
    return [NSString stringWithUTF8String: ivar_getTypeEncoding(_ivar)];
}

- (ptrdiff_t)offset
{
    return ivar_getOffset(_ivar);
}

@end

@interface _RTComponentsIvar : RTIvar
{
    NSString *_name;
    NSString *_typeEncoding;
}
@end

@implementation _RTComponentsIvar

- (id)initWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding
{
    if((self = [self init]))
    {
        _name = [name copy];
        _typeEncoding = [typeEncoding copy];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_typeEncoding release];
    [super dealloc];
}

- (NSString *)name
{
    return _name;
}

- (NSString *)typeEncoding
{
    return _typeEncoding;
}

- (ptrdiff_t)offset
{
    return -1;
}

@end

@implementation RTIvar

+ (id)ivarWithObjCIvar: (Ivar)ivar
{
    return [[[self alloc] initWithObjCIvar: ivar] autorelease];
}

+ (id)ivarWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding
{
    return [[[self alloc] initWithName: name typeEncoding: typeEncoding] autorelease];
}

+ (id)ivarWithName: (NSString *)name encode: (const char *)encodeStr
{
    return [self ivarWithName: name typeEncoding: [NSString stringWithUTF8String: encodeStr]];
}

- (id)initWithObjCIvar: (Ivar)ivar
{
    [self release];
    return [[_RTObjCIvar alloc] initWithObjCIvar: ivar];
}

- (id)initWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding
{
    [self release];
    return [[_RTComponentsIvar alloc] initWithName: name typeEncoding: typeEncoding];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ %p: %@ %@ %ld>", [self class], self, [self name], [self typeEncoding], (long)[self offset]];
}

- (BOOL)isEqual: (id)other
{
    return [other isKindOfClass: [RTIvar class]] &&
           [[self name] isEqual: [other name]] &&
           [[self typeEncoding] isEqual: [other typeEncoding]];
}

- (NSUInteger)hash
{
    return [[self name] hash] ^ [[self typeEncoding] hash];
}

- (NSString *)name
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)typeEncoding
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (ptrdiff_t)offset
{
    [self doesNotRecognizeSelector: _cmd];
    return 0;
}

@end
