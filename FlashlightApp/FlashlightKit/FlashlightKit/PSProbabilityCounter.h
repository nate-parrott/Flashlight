//
//  PSProbabilityCounter.h
//  Parsnip
//
//  Created by Nate Parrott on 12/20/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSMerging.h"

@interface PSProbabilityCounter : NSObject <PSMerging>

- (void)addItem:(id)item;
- (NSEnumerator *)allItems;
- (double)smoothedLogProbForItem:(id)item;
- (double)specialTextProbabilityForItem:(id)item;

@end
