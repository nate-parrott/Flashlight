//
//  FlashlightSystemHelpers.m
//  FlashlightKit
//
//  Created by Nate Parrott on 3/24/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashlightSystemHelpers.h"

BOOL FlashlightIsDarkModeEnabled() {
    return [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain] objectForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];
}
