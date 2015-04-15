//
//  PSTaggedText+ParseExample.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "PSTaggedText.h"

@interface PSTaggedText (ParseExample)

+ (PSTaggedText *)withExampleString:(NSString *)example rootTag:(NSString *)rootTag;

@end
