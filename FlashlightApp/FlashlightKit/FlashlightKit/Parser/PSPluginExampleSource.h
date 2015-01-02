//
//  PSPluginExampleSource.h
//  Parsnip2
//
//  Created by Nate Parrott on 12/24/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <FlashlightKit/PSParsnipSource.h>
#import <FlashlightKit/PSHelpers.h>

extern NSString * const PSParsnipSourceDataPluginPathForIntentDictionaryKey;

@interface PSPluginExampleSource : PSParsnipSource

@property (nonatomic) NSString *parserInfoOutput; // warnings, errors for `example.txt` files
@property (nonatomic, copy) PSVoidBlock parserOutputChangedBlock;

- (void)reload;

@property (nonatomic) NSSet *pathsOfPluginsToAlwaysInvoke;

@end
