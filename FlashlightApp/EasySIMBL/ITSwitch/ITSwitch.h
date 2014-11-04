//
//  ITSwitch.h
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 *  ITSwitch is a replica of UISwitch for Mac OS X
 */
@interface ITSwitch : NSControl

/**
 *  @property on - Gets or sets the switches state
 */
@property (nonatomic, getter=isOn) BOOL on;

/**
 *  @property tintColor - Gets or sets the switches tint
 */
@property (nonatomic, strong) NSColor *tintColor;

@end
