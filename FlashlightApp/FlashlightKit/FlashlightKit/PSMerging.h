//
//  PSMerging.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSMerging <NSObject>

- (void)ps_mergeWith:(id)other allowUnmergeableTypes:(BOOL)allowUnmergeableTypes;

@end

@interface NSMutableDictionary (PSMerging) <PSMerging>

@end

@interface NSMutableSet (PSMerging) <PSMerging>

@end
