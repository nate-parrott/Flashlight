//
//  NSString+PSTokenize.h
//  Parsnip
//
//  Created by Nate Parrott on 12/19/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSToken : NSObject <NSCopying>

@property (nonatomic) NSArray *features;
@property (nonatomic) NSString *original;
@property (nonatomic) NSString *boundaryAfter;

@end


@interface NSString (PSTokenize)

- (NSArray *)ps_tokenize;
- (NSString *)stem;

@end
