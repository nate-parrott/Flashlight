//
//  PSSpecialDateField.m
//  FlashlightKit
//
//  Created by Nate Parrott on 1/6/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PSSpecialDateField.h"
#import "TimeParser.h"
#import "PSTaggedText.h"

@implementation PSSpecialDateField

+ (NSString *)name {
    return @"@date";
}

+ (id)getJsonObjectFromTaggedText:(PSTaggedText *)taggedText {
    NSString *text = [taggedText getText];
    double timestamp;
    if ([text rangeOfString:@"/"].location != NSNotFound) {
        // HACK: parseDateTimeString doesn't seem to work for dates like 12/30/15, so use NSDate instead:
        timestamp = [[NSDate dateWithNaturalLanguageString:text] timeIntervalSince1970];
    } else {
        timestamp = parseDateTimeString([text UTF8String]);
    }
    return @{@"timestamp": @(timestamp), @"resolution": @1, @"text": text};
}

+ (NSArray *)getExamples {
    return @[
                @"today",
                @"tomorrow",
                @"yesterday",
                @"tonight",
                @"january 1",
                @"february 2",
                @"march 3",
                @"april 4",
                @"may 5",
                @"june 6",
                @"july 7",
                @"august 8",
                @"september 9",
                @"october 10",
                @"november 11",
                @"december 12",
                @"next monday",
                @"last tuesday",
                @"this wednesday",
                @"thursday night",
                @"friday evening",
                @"saturday morning",
                @"sunday afternoon",
                @"monday january 21st",
                @"tuesday february 23rd at 8:30",
                @"tomorrow at 9:15 PM",
                @"four months ago",
                @"1/2",
                @"2/3",
                @"4/5",
                @"a week from now",
                @"three days from now",
                @"yesterday at 4 AM" ];
}

@end
