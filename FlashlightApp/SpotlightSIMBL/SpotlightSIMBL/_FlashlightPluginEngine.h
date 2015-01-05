//
//  _FlashlightPluginEngine.h
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _FlashlightPluginEngine : NSObject

+ (_FlashlightPluginEngine *)shared;

@property (nonatomic) NSString *query;
@property (nonatomic,readonly) NSArray *results;

- (NSArray *)mergeFlashlightResultsWithSpotlightResults:(NSArray *)spotlightResults;

@property (nonatomic) BOOL spotlightWantsCollapsed;
- (BOOL)shouldBeCollapsed;

@end
