//
//  NSObject+InternationalizedValueForKey.h
//  Flashlight
//
//  Created by Nate Parrott on 11/20/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (InternationalizedValueForKey)

- (id)internationalizedValueForKey:(NSString *)key;

@end


@interface NSObject (Internationalization)

+ (void)enumerateLocalizedVariantsOfKey:(NSString *)key block:(void(^)(NSString *key, BOOL *stop))block;

@end
