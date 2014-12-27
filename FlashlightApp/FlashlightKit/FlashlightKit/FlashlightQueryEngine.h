//
//  FlashlightQueryEngine.h
//  FlashlightKit
//
//  Created by Nate Parrott on 12/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSHelpers.h"

@interface FlashlightQueryEngine : NSObject

- (void)updateQuery:(NSString *)query;
@property (nonatomic, readonly) NSArray *results;
@property (nonatomic, copy) PSVoidBlock resultsDidChangeBlock;

@end
