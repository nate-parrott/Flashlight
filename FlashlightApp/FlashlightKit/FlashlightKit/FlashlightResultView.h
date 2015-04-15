//
//  FlashlightCustomPreviewController.h
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FlashlightResult;

@interface FlashlightResultView : NSView

@property (nonatomic,weak) FlashlightResult *result;
- (id)resultOfOutputFunction;

@end
