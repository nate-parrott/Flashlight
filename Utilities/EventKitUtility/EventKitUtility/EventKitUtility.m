//
//  EventKitUtility.m
//  EventKitUtility
//
//  Created by Nate Parrott on 3/27/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "EventKitUtility.h"
#import <EventKit/EventKit.h>

/*
 BOOL createEvent(NSDictionary *event) {
 EKEventStore *store = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskEvent];
 EKEvent *item = [EKEvent eventWithEventStore:store];
 item.calendar = [store defaultCalendarForNewEvents];
 populateCommonCalendarItemProperties(event, item);
 item.startDate = [NSDate dateWithTimeIntervalSince1970:[event[@"date"] doubleValue]];
 NSTimeInterval endDate = event[@"date"] ? [event[@"date"] doubleValue] : item.startDate.timeIntervalSince1970 + 60*60;
 item.endDate = [NSDate dateWithTimeIntervalSince1970:endDate];
 item.allDay = [event[@"allDay"] boolValue];
 item.location = event[@"location"];
 return [store saveEvent:item span:EKSpanThisEvent commit:YES error:nil];
 }
 
 BOOL createReminder(NSDictionary *event) {
 EKEventStore *store = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskReminder];
 EKReminder *reminder = [EKReminder reminderWithEventStore:store];
 reminder.calendar = store.defaultCalendarForNewReminders;
 populateCommonCalendarItemProperties(event, reminder);
 NSDate *dueDate = [NSDate dateWithTimeIntervalSince1970:[event[@"date"] doubleValue]];
 reminder.dueDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:dueDate];
 return [store saveReminder:reminder commit:YES error:nil];
 }
 */

typedef void (^EventCreationCallback)(BOOL success);

@interface EventKitUtility ()

@property (nonatomic) NSMutableArray *successes;

@end

@implementation EventKitUtility

- (NSArray *)createEvents:(NSArray *)eventDicts {
    self.successes = [NSMutableArray new];
    for (id _ in eventDicts) [self.successes addObject:[NSNull null]];
    
    NSInteger i = 0;
    for (NSDictionary *event in eventDicts) {
        NSString *type = event[@"type"];
        if ([type isEqualToString:@"event"]) {
            [self createEvent:event callback:^(BOOL success) {
                self.successes[i] = @(success);
            }];
        } else if ([type isEqualToString:@"reminder"]) {
            [self createReminder:event callback:^(BOOL success) {
                self.successes[i] = @(success);
            }];
        }
        i++;
    }
    [self doRunLoopUntilFinished];
    return self.successes;
}

#pragma mark Runloop

- (void)doRunLoopUntilFinished {
    while (![self finishedYet] && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        
    }
}

- (BOOL)finishedYet {
    for (id item in self.successes) {
        if ([item isKindOfClass:[NSNull class]]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark Event Creation

- (void)createReminder:(NSDictionary *)dict callback:(EventCreationCallback)callback {
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        EKReminder *reminder = [EKReminder reminderWithEventStore:store];
        reminder.calendar = store.defaultCalendarForNewReminders;
        [self populateCalendarItem:reminder withCommonPropertiesFromDict:dict];
        if (dict[@"date"]) {
            NSDate *dueDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"date"] doubleValue]];
            reminder.dueDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:dueDate];
            [reminder addAlarm:[EKAlarm alarmWithRelativeOffset:0]];
        }
        callback([store saveReminder:reminder commit:YES error:nil]);
    }];
}

- (void)createEvent:(NSDictionary *)dict callback:(EventCreationCallback)callback {
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        EKEvent *item = [EKEvent eventWithEventStore:store];
        item.calendar = [store defaultCalendarForNewEvents];
        [self populateCalendarItem:item withCommonPropertiesFromDict:dict];
        item.startDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"date"] doubleValue]];
        NSTimeInterval endDate = dict[@"endDate"] ? [dict[@"endDate"] doubleValue] : item.startDate.timeIntervalSince1970 + 60*60;
        item.endDate = [NSDate dateWithTimeIntervalSince1970:endDate];
        item.allDay = [dict[@"allDay"] boolValue];
        item.location = dict[@"location"];
        callback([store saveEvent:item span:EKSpanThisEvent commit:YES error:nil]);
    }];
}

- (void)populateCalendarItem:(EKCalendarItem *)item withCommonPropertiesFromDict:(NSDictionary *)dict {
    item.title = dict[@"title"];
}

@end
