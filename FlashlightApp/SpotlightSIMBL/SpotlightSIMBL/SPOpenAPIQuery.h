//
//  SPOpenAPIQuery.h
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DummyInterface : NSObject
- (id)initWithQuery:(NSString *)query json:(id)json sourcePlugin:(NSString *)sourcePlugin;
@end

Class __SS_SPOpenAPIQueryClass();
