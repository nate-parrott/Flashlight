
#import <Foundation/Foundation.h>


@class RTProtocol;
@class RTIvar;
@class RTMethod;
@class RTProperty;

@interface RTUnregisteredClass : NSObject
{
    Class _class;
}

+ (id)unregisteredClassWithName: (NSString *)name withSuperclass: (Class)superclass;
+ (id)unregisteredClassWithName: (NSString *)name;

- (id)initWithName: (NSString *)name withSuperclass: (Class)superclass;
- (id)initWithName: (NSString *)name;

- (void)addProtocol: (RTProtocol *)protocol;
- (void)addIvar: (RTIvar *)ivar;
- (void)addMethod: (RTMethod *)method;
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
- (void)addProperty: (RTProperty *)property;
#endif

- (Class)registerClass;

@end
