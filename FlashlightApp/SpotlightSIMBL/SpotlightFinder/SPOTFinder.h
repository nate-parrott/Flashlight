//
//  SPFinder.h
//  SpotlightFinder
//
//  Created by Josip Cavar on 09/12/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SPOTResult : NSObject

@property __weak NSString *filePath;

@end

@interface SPSearchField : NSTextField

@end

@interface SPSearchPanel : NSPanel

@property struct CGSize contentMaxSizeWhenExpanded; // @synthesize contentMaxSizeWhenExpanded=_contentMaxSizeWhenExpanded;
@property BOOL collapsedState; // @synthesize collapsedState=_collapsedState;
@property BOOL internalCollapsed; // @synthesize internalCollapsed=_internalCollapsed;
@property(retain) NSView *mainView; // @synthesize mainView=_mainView;
@property __weak NSView *resultsView; // @synthesize resultsView=_resultsView;
@property __weak SPSearchField *searchField; // @synthesize searchField=_searchField;
@property __weak NSView *topView; // @synthesize topView=_topView;

@end

@interface SPAppDelegate : NSObject

@property __weak SPSearchPanel *window; // @synthesize window=_window;
- (id)selectedResult;

@end

@interface SPOTFinder : NSObject

@property (strong, nonatomic) NSButton *buttonShowInFinder;

@end
