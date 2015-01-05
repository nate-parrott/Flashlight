//
//  PSTaggedText+FromNodes.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText.h"
@class PSNonterminalNode;

@interface PSTaggedText (FromNodes)

+ (PSTaggedText *)withNode:(PSNonterminalNode *)node;

@end
