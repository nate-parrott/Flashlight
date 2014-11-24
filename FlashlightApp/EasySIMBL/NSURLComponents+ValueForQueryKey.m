//
//  NSURLComponents+ValueForQueryKey.m
//  Flashlight
//
//  Created by Nate Parrott on 11/21/14.
//
//

#import "NSURLComponents+ValueForQueryKey.h"

@implementation NSURLComponents (ValueForQueryKey)

- (NSString *)valueForQueryKey:(NSString *)key {
    for (NSURLQueryItem *q in self.queryItems) {
        if ([[q name] isEqualToString:key]) {
            return q.value;
        }
    }
    return nil;
}

@end
