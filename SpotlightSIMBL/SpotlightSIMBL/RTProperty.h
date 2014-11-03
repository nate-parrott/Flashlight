
#import <Foundation/Foundation.h>
#import <objc/runtime.h>


typedef enum
{
    RTPropertySetterSemanticsAssign,
    RTPropertySetterSemanticsRetain,
    RTPropertySetterSemanticsCopy
}
RTPropertySetterSemantics;

@interface RTProperty : NSObject
{
}

+ (id)propertyWithObjCProperty: (objc_property_t)property;
+ (id)propertyWithName: (NSString *)name attributes:(NSDictionary *)attributes;

- (id)initWithObjCProperty: (objc_property_t)property;
- (id)initWithName: (NSString *)name attributes:(NSDictionary *)attributes;

- (NSDictionary *)attributes;
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
- (BOOL)addToClass:(Class)classToAddTo;
#endif

- (NSString *)attributeEncodings;
- (BOOL)isReadOnly;
- (RTPropertySetterSemantics)setterSemantics;
- (BOOL)isNonAtomic;
- (BOOL)isDynamic;
- (BOOL)isWeakReference;
- (BOOL)isEligibleForGarbageCollection;
- (SEL)customGetter;
- (SEL)customSetter;
- (NSString *)name;
- (NSString *)typeEncoding;
- (NSString *)oldTypeEncoding;
- (NSString *)ivarName;

@end

extern NSString * const RTPropertyTypeEncodingAttribute;
extern NSString * const RTPropertyBackingIVarNameAttribute;

extern NSString * const RTPropertyCopyAttribute;
extern NSString * const RTPropertyRetainAttribute;
extern NSString * const RTPropertyCustomGetterAttribute;
extern NSString * const RTPropertyCustomSetterAttribute;
extern NSString * const RTPropertyDynamicAttribute;
extern NSString * const RTPropertyEligibleForGarbageCollectionAttribute;
extern NSString * const RTPropertyNonAtomicAttribute;
extern NSString * const RTPropertyOldTypeEncodingAttribute;
extern NSString * const RTPropertyReadOnlyAttribute;
extern NSString * const RTPropertyWeakReferenceAttribute;