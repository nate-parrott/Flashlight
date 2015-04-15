//
//  PSTaggedText.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSNonterminalNode;

@interface PSTaggedText : NSObject

@property (nonatomic) NSString *tag;
@property (nonatomic) NSArray *contents;

- (PSNonterminalNode *)toNode;

- (NSString *)getText;
- (PSTaggedText *)findChild:(NSString *)childTag;

@end

PSTaggedText *Tagged(NSString *tag, NSArray *contents);
