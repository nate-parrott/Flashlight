//
//  PSContactSource.m
//  FlashlightKit
//
//  Created by Nate Parrott on 1/23/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PSContactSource.h"
#import "PSTaggedText.h"
#import <AddressBook/AddressBook.h>
#import "PSHelpers.h"
#import "PSTaggedText+ParseExample.h"
#import "Parsnip.h"

@interface ABMultiValue (ToDict)

@end

@implementation ABMultiValue (ToDict)

- (NSDictionary *)toDict {
    NSMutableDictionary *d = [NSMutableDictionary new];
    for (NSInteger i=0; i<self.count; i++) {
        d[[self labelAtIndex:i]] = [self valueAtIndex:i];
    }
    return d;
}

@end


@interface PSContactSource ()

@property (nonatomic) ABAddressBook *addressBook;
@property (nonatomic,copy) PSParsnipDataCallback dataCallback;

@end

@implementation PSContactSource

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback {
    self = [super initWithIdentifier:identifier callback:callback];
    self.addressBook = [ABAddressBook addressBook];
    self.dataCallback = callback;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changed:) name:kABDatabaseChangedExternallyNotification object:self.addressBook];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changed:) name:kABDatabaseChangedExternallyNotification object:self.addressBook];
    [self changed:nil];
    return self;
}

- (void)changed:(NSNotification *)notif {
    Parsnip *parsnip = [Parsnip new];
    [parsnip learnExamples:[self examples]];
    self.dataCallback(self.identifier, @{
                                         PSParsnipSourceFieldProcessorsDictionaryKey: @{@"@contact": [[self class] fieldProcessor]},
                                         PSParsnipSourceDataParsnipKey: parsnip
                                         });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (PSParsnipFieldProcessor)fieldProcessor {
    return ^id(PSTaggedText *taggedText) {
        NSString *tag = taggedText.tag;
        if ([tag rangeOfString:@"/"].location == NSNotFound) return @{};
        NSString *uniqueId = [tag substringFromIndex:[tag rangeOfString:@"/"].location + 1];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"ID"] = uniqueId;
        ABPerson *person = (id)[[ABAddressBook sharedAddressBook] recordForUniqueId:uniqueId];
        if ([person isKindOfClass:[ABPerson class]]) {
            dict[@"displayName"] = person.displayName ? : @"";
            
            NSArray *props = @[kABAddressProperty, kABFirstNameProperty, kABLastNameProperty, kABJobTitleProperty, kABOrganizationProperty, kABBirthdayProperty, kABEmailProperty, kABPhoneProperty];
            for (NSString *prop in props) {
                id val = [person valueForKey:prop];
                if ([val isKindOfClass:[NSString class]] || [val isKindOfClass:[NSNumber class]]) {
                    dict[prop] = val;
                } else if ([val isKindOfClass:[ABMultiValue class]]) {
                    dict[prop] = [val toDict];
                }
            }
        }
        return dict;
    };
}

- (NSArray *)examples {
    static NSArray *examples = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ABAddressBook *addressBook = self.addressBook;
        NSArray *people = addressBook.people ? : @[];
        examples = [people mapFilter:^id(ABRecord *person) {
            NSString *name = [person displayName];
            if (name) {
                return [PSTaggedText withExampleString:name rootTag:[NSString stringWithFormat:@"@contact/%@", person.uniqueId]];
            } else {
                return nil;
            }
        }];
    });
    return examples;
}

@end
