/*
 DDHotKey -- DDHotKeyTextField.m
 
 Copyright (c) Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the author(s) or copyright holder(s) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Carbon/Carbon.h>

#import "DDHotKeyTextField.h"
#import "DDHotKeyUtilities.h"

@interface DDHotKeyTextFieldEditor : NSTextView

@property (nonatomic, weak) DDHotKeyTextField *hotKeyField;

@end

static DDHotKeyTextFieldEditor *DDFieldEditor(void);
static DDHotKeyTextFieldEditor *DDFieldEditor(void) {
    static DDHotKeyTextFieldEditor *editor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        editor = [[DDHotKeyTextFieldEditor alloc] initWithFrame:NSMakeRect(0, 0, 100, 32)];
        [editor setFieldEditor:YES];
    });
    return editor;
}

@implementation DDHotKeyTextFieldCell

- (NSTextView *)fieldEditorForView:(NSView *)view {
    if ([view isKindOfClass:[DDHotKeyTextField class]]) {
        DDHotKeyTextFieldEditor *editor = DDFieldEditor();
        editor.insertionPointColor = editor.backgroundColor;
        editor.hotKeyField = (DDHotKeyTextField *)view;
        return editor;
    }
    return nil;
}

@end

@implementation DDHotKeyTextField

+ (Class)cellClass {
    return [DDHotKeyTextFieldCell class];
}

- (void)setHotKey:(DDHotKey *)hotKey {
    if (_hotKey != hotKey) {
        _hotKey = hotKey;
        [super setStringValue:[DDStringFromKeyCode(hotKey.keyCode, hotKey.modifierFlags) uppercaseString]];
    }
}

- (void)setStringValue:(NSString *)aString {
    NSLog(@"-[DDHotKeyTextField setStringValue:] is not what you want. Use -[DDHotKeyTextField setHotKey:] instead.");
    [super setStringValue:aString];
}

- (NSString *)stringValue {
    NSLog(@"-[DDHotKeyTextField stringValue] is not what you want. Use -[DDHotKeyTextField hotKey] instead.");
    return [super stringValue];
}

@end

@implementation DDHotKeyTextFieldEditor {
    BOOL _hasSeenKeyDown;
    id _globalMonitor;
    DDHotKey *_originalHotKey;
}

- (void)setHotKeyField:(DDHotKeyTextField *)hotKeyField {
    _hotKeyField = hotKeyField;
    _originalHotKey = _hotKeyField.hotKey;
}

- (void)processHotkeyEvent:(NSEvent *)event {
    NSUInteger flags = event.modifierFlags;
    BOOL hasModifier = (flags & (NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask | NSFunctionKeyMask)) > 0;
    
    if (event.type == NSKeyDown) {
        _hasSeenKeyDown = YES;
        unichar character = [event.charactersIgnoringModifiers characterAtIndex:0];
        

        if (hasModifier == NO && ([[NSCharacterSet newlineCharacterSet] characterIsMember:character] || event.keyCode == kVK_Escape)) {
            if (event.keyCode == kVK_Escape) {
                self.hotKeyField.hotKey = _originalHotKey;
                
                NSString *str = DDStringFromKeyCode(_originalHotKey.keyCode, _originalHotKey.modifierFlags);
                self.textStorage.mutableString.string = [str uppercaseString];
            }
            [self.hotKeyField sendAction:self.hotKeyField.action to:self.hotKeyField.target];
            [self.window makeFirstResponder:nil];
            return;
        }
    }
    
    if ((event.type == NSKeyDown || (event.type == NSFlagsChanged && _hasSeenKeyDown == NO)) && hasModifier) {
        self.hotKeyField.hotKey = [DDHotKey hotKeyWithKeyCode:event.keyCode modifierFlags:flags task:_originalHotKey.task];
        NSString *str = DDStringFromKeyCode(event.keyCode, flags);
        [self.textStorage.mutableString setString:[str uppercaseString]];
        [self.hotKeyField sendAction:self.hotKeyField.action to:self.hotKeyField.target];
    }
}

- (BOOL)becomeFirstResponder {
    BOOL ok = [super becomeFirstResponder];
    if (ok) {
        _hasSeenKeyDown = NO;
        _globalMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask | NSFlagsChangedMask) handler:^NSEvent*(NSEvent *event){
            [self processHotkeyEvent:event];
            return nil;
        }];
    }
    return ok;
}

- (BOOL)resignFirstResponder {
    BOOL ok = [super resignFirstResponder];
    if (ok) {
        self.hotKeyField = nil;
        if (_globalMonitor) {
            [NSEvent removeMonitor:_globalMonitor];
            _globalMonitor = nil;
        }
    }
    
    return ok;
}

@end
