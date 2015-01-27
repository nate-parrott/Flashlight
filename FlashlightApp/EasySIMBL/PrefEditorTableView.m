//
//  PrefEditorTableView.m
//  PrefEditor
//
//  Created by Nate Parrott on 1/11/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PrefEditorTableView.h"

@interface PrefEditorTableView () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic) NSScrollView *scrollView;
@property (nonatomic) NSTableView *tableView;
@property (nonatomic) NSMutableArray *mutableObjects;
@property (nonatomic) NSSegmentedControl *plusMinusRow;

@end

@implementation PrefEditorTableView

- (instancetype)initWithOptions:(NSDictionary *)options {
    self = [super initWithFrame:NSMakeRect(0, 0, 200, 200)];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.borderType = NSBezelBorder;
    self.scrollView.hasVerticalScroller = YES;
    [self addSubview:self.scrollView];
    
    self.tableView = [[NSTableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setUsesAlternatingRowBackgroundColors:YES];
    self.mutableObjects = [NSMutableArray new];
    self.scrollView.documentView = self.tableView;
    
    self.plusMinusRow = [[NSSegmentedControl alloc] init];
    self.plusMinusRow.segmentStyle = NSSegmentStyleSmallSquare;
    [self.plusMinusRow setSegmentCount:3];
    [self.plusMinusRow setImage:[NSImage imageNamed:@"NSAddTemplate"] forSegment:0];
    [self.plusMinusRow setImage:[NSImage imageNamed:@"NSRemoveTemplate"] forSegment:1];
    [self addSubview:self.plusMinusRow];
    [self.plusMinusRow setTarget:self];
    [self.plusMinusRow setAction:@selector(addOrRemoveClicked:)];
    
    for (NSDictionary *column in options[@"columns"]) {
        NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:column[@"key"]];
        [col setTitle:column[@"text"]];
        [self.tableView addTableColumn:col];
    }
    
    return self;
}

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy] ? : [NSMutableArray new];
    [self.tableView reloadData];
}

- (NSArray *)objects {
    return self.mutableObjects.copy;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.mutableObjects.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id obj = self.mutableObjects[row][tableColumn.identifier];
    return [obj isKindOfClass:[NSString class]] ? obj : @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *dict = self.mutableObjects[row] ? : @{};
    NSMutableDictionary *mDict = dict.mutableCopy;
    if (tableColumn.identifier) {
        mDict[tableColumn.identifier] = object;
    }
    [self.mutableObjects replaceObjectAtIndex:row withObject:mDict];
    [self changed];
}

/*- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!cellView) {
        cellView = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        cellView.bezeled = NO;
        cellView.drawsBackground = NO;
        cellView.delegate = self;
    }
    cellView.stringValue = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    return cellView;
}*/

- (NSSize)intrinsicContentSize {
    return NSMakeSize(150, 100);
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout:YES];
}

- (void)layout {
    const CGFloat addRemoveButtonHeight = 24;
    const CGFloat addRemoveWidth = 30;
    self.scrollView.frame = NSMakeRect(0, addRemoveButtonHeight, self.bounds.size.width, self.bounds.size.height - addRemoveButtonHeight);
    self.plusMinusRow.frame = NSMakeRect(0, 0, self.bounds.size.width, addRemoveButtonHeight + 4);
    [self.plusMinusRow setWidth:addRemoveWidth forSegment:0];
    [self.plusMinusRow setWidth:addRemoveWidth forSegment:1];
    [self.plusMinusRow setWidth:self.plusMinusRow.frame.size.width - addRemoveWidth * 2 - 4 forSegment:2];
    [super layout];
}

- (void)addOrRemoveClicked:(id)sender {
    [self.tableView beginUpdates];
    NSInteger indexToStartEditing = -1;
    if (self.plusMinusRow.selectedSegment == 0) {
        // add
        [self.mutableObjects addObject:@{}];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.mutableObjects.count - 1] withAnimation:NSTableViewAnimationSlideDown];
        indexToStartEditing = self.mutableObjects.count - 1;
    } else if (self.plusMinusRow.selectedSegment == 1) {
        // remove
        NSInteger selection = self.tableView.selectedRow;
        if (selection != -1) {
            [self.mutableObjects removeObjectAtIndex:selection];
            [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selection] withAnimation:NSTableViewAnimationSlideUp];
        }
    }
    [self.tableView endUpdates];
    self.plusMinusRow.selectedSegment = -1;
    if (indexToStartEditing != -1) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToStartEditing] byExtendingSelection:NO];
    }
    [self changed];
}

- (void)changed {
    if (self.onChange) self.onChange(self);
}

@end
