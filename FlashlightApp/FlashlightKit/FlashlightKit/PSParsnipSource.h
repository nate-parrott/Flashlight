//
//  PSParsnipSource.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSTaggedText;

extern NSString * const PSParsnipSourceDataParsnipKey; // contains the source's standalone parsnip
extern NSString * const PSParsnipSourceFieldProcessorsDictionaryKey;

typedef void (^PSParsnipDataCallback)(NSString *identifier, NSDictionary *data);
typedef id (^PSParsnipFieldProcessor)(PSTaggedText *field);

@interface PSParsnipSource : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback;
@property (nonatomic,readonly) NSString *identifier;

@end
