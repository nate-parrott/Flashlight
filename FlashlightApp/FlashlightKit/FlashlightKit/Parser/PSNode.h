//
//  PSNode.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSNode <NSObject, NSCopying>

- (NSString *)tag;
- (NSString *)externalTag;

@end
