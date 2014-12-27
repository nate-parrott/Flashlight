//
//  PSParsnipSource.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PSParsnipSourceDataParsnipKey; // contains the source's standalone parsnip

typedef void (^PSParsnipDataCallback)(NSString *identifier, NSDictionary *data);

@interface PSParsnipSource : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier callback:(PSParsnipDataCallback)callback;
@property (nonatomic,readonly) NSString *identifier;

@end
