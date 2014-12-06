//
//  _SS_MetadataResponseDelayer.h
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 12/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPResponse;
typedef void (^SPQueryResponseHandler)(SPResponse* response);

@interface _SS_MetadataResponseDelayer : NSObject

+ (_SS_MetadataResponseDelayer *)shared;

- (void)setup;

- (void)registerCallback:(void(^)())handler forQuery:(NSString *)query;

- (void)sentPluginResponseForQuery:(NSString *)query;

@end
