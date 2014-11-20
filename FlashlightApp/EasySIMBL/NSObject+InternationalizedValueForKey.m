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
    for (NSString *fullLang in [NSLocale preferredLanguages]) {
        NSString *lang = fullLang;
        while (1) {
            NSString *localKey = [lang isEqualToString:@"en"] ? key : [NSString stringWithFormat:@"%@_%@", key, lang];
            if ([self objectForKey:localKey]) {
                return [self objectForKey:localKey];
            } else if ([lang rangeOfString:@"-" options:NSBackwardsSearch].location != NSNotFound) {
                lang = [lang substringToIndex:[lang rangeOfString:@"-" options:NSBackwardsSearch].location];
            } else {
                break;
            }
        }
    }
    return [self objectForKey:key];
}

@end
