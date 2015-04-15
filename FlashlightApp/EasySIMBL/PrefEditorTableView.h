//
//  PrefEditorTableView.h
//  PrefEditor
//
//  Created by Nate Parrott on 1/11/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefEditorTableView : NSView

- (instancetype)initWithOptions:(NSDictionary *)options;
@property (nonatomic) NSArray *objects;

@property (nonatomic, copy) void (^onChange)(PrefEditorTableView *tableView);

@end
