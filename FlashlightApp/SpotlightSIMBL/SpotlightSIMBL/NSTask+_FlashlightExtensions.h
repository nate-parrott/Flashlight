//
//  NSTask+_FlashlightExtensions.h
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (_FlashlightExtensions)

- (void)launchWithTimeout:(NSTimeInterval)timeout consoleLabelForErrorDump:(NSString *)label;

@end
