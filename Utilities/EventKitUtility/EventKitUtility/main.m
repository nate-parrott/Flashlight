//
//  main.m
//  EventKitUtility
//
//  Created by Nate Parrott on 3/27/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventKitUtility.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        BOOL test = NO;
        NSArray *events;
        if (test) {
            events = @[
                       @{@"type": @"event", @"title": @"TEst calendar event", @"date": @1427476049, @"endDate": @1427477049, @"location": @"test location"},
                       @{@"type": @"reminder", @"title": @"test reminder", @"date": @1427476049}
                       ];
        } else {
            NSData *payload = [NSData dataWithBytes:argv[1] length:strlen(argv[1])];
            events = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
        }
        NSArray *successes = [[EventKitUtility new] createEvents:events];
        printf("%s\n", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:successes options:0 error:nil] encoding:NSUTF8StringEncoding].UTF8String);
    }
    return 0;
}
