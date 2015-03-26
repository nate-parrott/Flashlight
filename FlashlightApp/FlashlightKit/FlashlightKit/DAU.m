//
//  DAU.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 3/25/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "DAU.h"

/*
 Anonymous daily-active-user logging
 */

@implementation DAU

+ (dispatch_queue_t)loggingQueue {
    static dispatch_queue_t t;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        t = dispatch_queue_create("Logging queue", 0);
    });
    return t;
}

+ (void)logDailyAction:(NSString *)action {
    dispatch_async([self loggingQueue], ^{
        if (CFPreferencesGetAppBooleanValue(CFSTR("DisableDAULogging"), CFSTR("com.nateparrott.Flashlight"), NULL)) {
            return;
        }
        
        NSString *lastLogTimeKey = [NSString stringWithFormat:@"com.nateparrott.Flashlight.DAU.action.%@.lastLoggedTime", action];
        
        NSTimeInterval lastLogged = [[NSUserDefaults standardUserDefaults] doubleForKey:lastLogTimeKey];
        if ([self timeIntervalByRoundingToNearestDay:[NSDate timeIntervalSinceReferenceDate]] > [self timeIntervalByRoundingToNearestDay:lastLogged]) {
            [self sendLogForAction:action];
            [[NSUserDefaults standardUserDefaults] setDouble:[NSDate timeIntervalSinceReferenceDate] forKey:lastLogTimeKey];
        }
    });
}

+ (void)sendLogForAction:(NSString *)action {
    BOOL production = YES;
    NSString *url = production ? @"https://flashlightplugins.appspot.com/logging" : @"http://localhost:24080/logging";
    NSDictionary *payload = @{
                              @"user": [self anonymousId],
                              @"action": action
                              };
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    req.HTTPMethod = @"POST";
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }] resume];
}

+ (NSTimeInterval)timeIntervalByRoundingToNearestDay:(NSTimeInterval)t {
    NSTimeInterval daySize = 24 * 60 * 60;
    NSTimeInterval day;
    modf(t/daySize, &day);
    return day * daySize;
}

+ (NSString *)anonymousId {
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"AnonymousId"]) {
        [[NSUserDefaults standardUserDefaults] setValue:[[NSUUID UUID] UUIDString] forKey:@"AnonymousId"];
    }
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"AnonymousId"];
}

@end
