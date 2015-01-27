//
//  NSObject+InternationalizedValueForKey.m
//  Flashlight
//
//  Created by Nate Parrott on 11/20/14.
//
//

#import "NSObject+InternationalizedValueForKey.h"

@implementation NSDictionary (InternationalizedValueForKey)

- (id)internationalizedValueForKey:(NSString *)key {
    __block id val = nil;
    [[self class] enumerateLocalizedVariantsOfKey:key block:^(NSString *key, BOOL *stop) {
        val = self[key];
        *stop = !!val;
    }];
    return val;
}

@end

@implementation NSObject (Internationalization)

+ (void)enumerateLocalizedVariantsOfKey:(NSString *)key block:(void(^)(NSString *key, BOOL *stop))block {
    BOOL stop = NO;
    for (NSString *fullLang in [NSLocale preferredLanguages]) {
        if (stop) return;
        NSString *lang = fullLang;
        while (1) {
            NSString *localKey = [lang isEqualToString:@"en"] ? key : [NSString stringWithFormat:@"%@_%@", key, lang];
            block(localKey, &stop);
            if (stop) {
                break;
            } else if ([lang rangeOfString:@"-" options:NSBackwardsSearch].location != NSNotFound) {
                lang = [lang substringToIndex:[lang rangeOfString:@"-" options:NSBackwardsSearch].location];
            } else {
                break;
            }
        }
    }
    if (!stop) block(key, &stop); // fallback to just the plain key
}

@end
