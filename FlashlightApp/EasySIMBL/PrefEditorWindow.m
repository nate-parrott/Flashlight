//
//  PrefEditorWindow.m
//  PrefEditor
//
//  Created by Nate Parrott on 1/10/15.
//  Copyright (c) 2015 Nate Parrott. All rights reserved.
//

#import "PrefEditorWindow.h"
#import "PrefEditorTableView.h"
#import "PluginModel.h"

typedef void (^PrefEditorWindowChangeFunction)(id sender);

@interface PrefEditorWindow () <NSTextFieldDelegate, NSWindowDelegate>

@property (nonatomic) IBOutlet NSView *settingsContainer;
@property (nonatomic) IBOutlet NSTextField *pluginName;
@property (nonatomic) IBOutlet NSImageView *iconView;

@property (nonatomic) NSMutableDictionary *mutablePreferences;

@property (nonatomic) NSMutableArray *changeFunctions;
@property (nonatomic) NSMutableArray *controlsWithChangeFunctions;

@end

@implementation PrefEditorWindow

- (NSView *)createView {
    NSData *prefData = [NSData dataWithContentsOfFile:self.preferencesPath];
    if (prefData) self.mutablePreferences = [[NSJSONSerialization JSONObjectWithData:prefData options:0 error:nil] mutableCopy];
    if (!self.mutablePreferences) self.mutablePreferences = [NSMutableDictionary new];
    
    self.changeFunctions = [NSMutableArray new];
    self.controlsWithChangeFunctions = [NSMutableArray new];
    
    NSData *optionsData = [NSData dataWithContentsOfFile:[[self.plugin path] stringByAppendingPathComponent:@"options.json"]];
    NSDictionary *optionsJson = optionsData ? [NSJSONSerialization JSONObjectWithData:optionsData options:0 error:nil] : nil;
    
    NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSView *lastControl = nil;
    for (NSDictionary *option in optionsJson[@"options"]) {
        BOOL fillWidth;
        NSView *optionView = [self viewForOption:option fillWidth:&fillWidth];
        NSView *labelView = [self labelViewForOption:option];
        
        optionView.translatesAutoresizingMaskIntoConstraints = NO;
        [optionView setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
        [view addSubview:optionView];
        if (labelView) {
            labelView.translatesAutoresizingMaskIntoConstraints = NO;
            [view addSubview:labelView];
        }
        NSMutableDictionary *views = [NSMutableDictionary new];
        views[@"option"] = optionView;
        if (labelView) views[@"label"] = labelView;
        if (lastControl) views[@"last"] = lastControl;
        
        if (lastControl) {
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]-[option]" options:0 metrics:nil views:views]];
            [view addConstraint:[NSLayoutConstraint constraintWithItem:lastControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:optionView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        } else {
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[option]" options:0 metrics:nil views:views]];
        }
        if (labelView) {
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=20-[label]-[option]" options:0 metrics:nil views:views]];
            [view addConstraint:[NSLayoutConstraint constraintWithItem:labelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:optionView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        } else {
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=20-[option]" options:0 metrics:nil views:views]];
        }
        if (fillWidth) {
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[option]-|" options:0 metrics:nil views:views]];
        } else {
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[option]->=20-|" options:0 metrics:nil views:views]];
        }
        
        lastControl = optionView;
    }
    if (lastControl) {
        NSLayoutConstraint *center = [NSLayoutConstraint constraintWithItem:lastControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:0];
        // center.priority = NSLayoutPriorityDefaultLow;
        [view addConstraint:center];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastControl]->=20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lastControl)]];
    } else {
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:20]];
    }
    //view.frame = NSMakeRect(0, 0, [view intrinsicContentSize].width, [view intrinsicContentSize].height);
    [view layoutSubtreeIfNeeded];
    return view;
}

- (NSView *)labelViewForOption:(NSDictionary *)option {
    if ([@[@"label", @"checkmark", @"hint"] containsObject:option[@"type"]]) {
        return nil;
    }
    NSString *text = option[@"text"];
    if (!text) return nil;
    NSTextField *label = [[NSTextField alloc] init];
    label.stringValue = text;
    label.bezeled = NO;
    label.editable = NO;
    label.selectable = NO;
    label.drawsBackground = NO;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.preferredMaxLayoutWidth = 150;
    return label;
}

- (NSView *)viewForOption:(NSDictionary *)option fillWidth:(BOOL*)fillWidth {
    *fillWidth = NO;
    NSString *type = option[@"type"];
    NSString *key = option[@"key"];
    NSMutableDictionary *mutablePrefs = self.mutablePreferences;
    
    if ([type isEqualToString:@"buttons"]) {
        NSView *buttons = [NSView new];
        NSButton *prevButton = nil;
        for (NSDictionary *buttonDict in option[@"buttons"]) {
            NSButton *button = [self createButton];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.title = buttonDict[@"text"];
            [buttons addSubview:button];
            [self registerControl:button changeCallback:^(id sender) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:buttonDict[@"url"]]];
            }];
            if (prevButton) {
                [buttons addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[prevButton]-[button]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(prevButton, button)]];
            } else {
                [buttons addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[button]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
            }
            [buttons addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
            prevButton = button;
        }
        if (prevButton) {
            [buttons addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[prevButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(prevButton)]];
        }
        return buttons;
    } else if ([type isEqualToString:@"checkmark"]) {
        NSButton *checkmark = [NSButton new];
        [checkmark setButtonType:NSSwitchButton];
        checkmark.title = option[@"text"];
        if (key) {
            checkmark.state = [self.mutablePreferences[key] boolValue] ? NSOnState : NSOffState;
            [self registerControl:checkmark changeCallback:^(id sender) {
                mutablePrefs[key] = @([sender state] == NSOnState);
            }];
        }
        return checkmark;
    } else if ([type isEqualToString:@"text"]) {
        Class fieldClass = [NSTextField class];
        if ([option[@"password"] boolValue]) {
            fieldClass = [NSSecureTextField class];
        }
        NSTextField *field = [fieldClass new];
        [field addConstraint:[NSLayoutConstraint constraintWithItem:field attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:200]];
        field.placeholderString = option[@"placeholder"];
        field.continuous = YES;
        if (key) {
            field.stringValue = mutablePrefs[key] ? : @"";
            field.delegate = self;
            [self registerControl:field changeCallback:^(NSTextField *sender) {
                mutablePrefs[key] = sender.stringValue ? : @"";
            }];
        }
        return field;
    } else if ([type isEqualToString:@"dropdown"]) {
        NSPopUpButton *button = [[NSPopUpButton alloc] init];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:150]];
        for (NSDictionary *item in option[@"options"]) {
            [button addItemWithTitle:item[@"text"]];
            if (key && [mutablePrefs[key] isEqualToString:item[@"value"]]) {
                [button selectItem:button.itemArray.lastObject];
            }
        }
        if (key) {
            [self registerControl:button changeCallback:^(NSPopUpButton *sender) {
                NSInteger selectedIndex = [sender.itemArray indexOfObject:sender.selectedItem];
                if (selectedIndex != -1) {
                    NSDictionary *selectedOption = option[@"options"][selectedIndex];
                    mutablePrefs[key] = selectedOption[@"value"] ? : [NSNull null];
                }
            }];
        }
        return button;
    } else if ([type isEqualToString:@"label"] || [type isEqualToString:@"hint"]) {
        NSTextField *label = [NSTextField new];
        label.stringValue = option[@"text"];
        label.bezeled = NO;
        label.editable = NO;
        label.selectable = NO;
        label.drawsBackground = NO;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.preferredMaxLayoutWidth = 300;
        if ([type isEqualToString:@"hint"]) {
            label.font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
        }
        return label;
    } else if ([type isEqualToString:@"table"]) {
        PrefEditorTableView *tableView = [[PrefEditorTableView alloc] initWithOptions:option];
        *fillWidth = YES;
        if (key) {
            tableView.objects = mutablePrefs[key];
            tableView.onChange = ^(PrefEditorTableView *tableView) {
                mutablePrefs[key] = tableView.objects;
            };
        }
        return tableView;
    } else if ([type isEqualToString:@"divider"]) {
        NSView *view = [NSView new];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:20]];
        return view;
    }
    NSButton *fallback = [self createButton];
    [fallback setTitle:option[@"text"]];
    return fallback;
}

- (void)registerControl:(NSControl *)control changeCallback:(PrefEditorWindowChangeFunction)callback {
    [self.controlsWithChangeFunctions addObject:control];
    [self.changeFunctions addObject:callback];
    [control setTarget:self];
    [control setAction:@selector(controlChanged:)];
}

- (void)controlChanged:(id)sender {
    NSUInteger index = [self.controlsWithChangeFunctions indexOfObject:sender];
    if (index != NSNotFound) {
        PrefEditorWindowChangeFunction changeFunction = self.changeFunctions[index];
        changeFunction(sender);
    }
}

- (void)controlTextDidChange:(NSNotification *)notif {
    [self controlChanged:notif.object];
}

- (NSButton *)createButton {
    NSButton *button = [[NSButton alloc] init];
    [button setBezelStyle:NSRoundedBezelStyle];
    [button setButtonType:NSMomentaryPushInButton];
    return button;
}

- (IBAction)done:(id)sender {
    [self.window.sheetParent endSheet:self.window];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.delegate = self;
    NSView *settings = [self createView];
    [self.settingsContainer addSubview:settings];
    [self.settingsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[settings]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(settings)]];
    [self.settingsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[settings]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(settings)]];
    self.pluginName.stringValue = self.plugin.displayName ? : @"Settings";
    self.iconView.image = [[NSImage alloc] initWithContentsOfFile:[self.plugin.path stringByAppendingPathComponent:@"Icon.png"]];
}

- (void)windowDidResignMain:(NSNotification *)notification {
    [self save];
}

- (void)windowDidEndSheet:(NSNotification *)notification {
    [self save];
}

- (NSString *)preferencesPath {
    return [self.plugin.path stringByAppendingPathComponent:@"preferences.json"];
}

- (void)save {
    [[NSJSONSerialization dataWithJSONObject:self.mutablePreferences options:NSJSONWritingPrettyPrinted error:nil] writeToFile:self.preferencesPath atomically:YES];
}

@end
