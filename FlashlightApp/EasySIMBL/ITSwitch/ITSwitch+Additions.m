//
//  ITSwitch+Additions.m
//  Flashlight
//
//  Created by Nate Parrott on 11/14/14.
//
//

#import "ITSwitch+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation ITSwitch (Additions)

- (void)setOnWithoutAnimation:(BOOL)on {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.on = on;
    [CATransaction commit];
}

@end
