//
//  PopoverViewController.m
//  FlashlightStatusItem
//
//  Created by Nate Parrott on 10/12/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "PopoverViewController.h"
#import <FlashlightKit/FlashlightKit.h>

@interface PopoverViewController ()

@property (nonatomic,weak) IBOutlet NSPopover *parentPopover;
@property (nonatomic) NSString *lastQuery;
@property (nonatomic) FlashlightQueryEngine *queryEngine;
@property (nonatomic) FlashlightResult *result;
@property (weak) IBOutlet FlashlightResultView *resultView;
@property (nonatomic) NSButton *rightButton;
@property (nonatomic) IBOutlet NSTextField *searchField;

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak PopoverViewController *weakSelf = self;
    
    self.searchField.cell.focusRingType = NSFocusRingTypeNone;
    
    self.queryEngine = [FlashlightQueryEngine new];
    
    self.queryEngine.resultsDidChangeBlock = ^(NSString *query, NSArray *results){
        // weakSelf.resultTitle.stringValue = [weakSelf.queryEngine.results.firstObject json][@"title"] ? : @"None";
        weakSelf.result = weakSelf.queryEngine.results.firstObject;
        weakSelf.resultView.result = weakSelf.result;
        /*NSMutableDictionary *d = weakSelf.errorSections.mutableCopy;
        if (weakSelf.queryEngine.errorString) {
            d[@"Plugin.py Errors"] = weakSelf.queryEngine.errorString;
        } else {
            [d removeObjectForKey:@"Plugin.py Errors"];
        }
        [d removeObjectForKey:@"Plugin.py run() Errors"];
        weakSelf.errorSections = d;*/
    };
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.searchField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
    // [self.searchField becomeFirstResponder];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    if (![self.searchField.stringValue isEqualToString:self.lastQuery]) {
        self.lastQuery = self.searchField.stringValue;
        [self.queryEngine updateQuery:self.searchField.stringValue];
    }
}

- (IBAction)enterPressed:(id)sender {
    BOOL hasEnterAction = [self.resultView.result pressEnter:self.resultView errorCallback:^(NSString *error) {
        
    }];
    if (hasEnterAction) {
        [self.parentPopover performClose:sender];
    }
    
}

@end
