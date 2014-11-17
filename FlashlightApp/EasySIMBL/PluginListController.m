//
//  PluginListController.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginListController.h"
#import "PluginModel.h"
#import "PluginCellView.h"
#import "PluginInstallTask.h"
#import "ConvenienceCategories.h"
#import "PluginEditorWindowController.h"

@interface PluginListController () <NSTableViewDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, NSWindowDelegate>

@property (nonatomic) NSArray *pluginsFromWeb;
@property (nonatomic) NSArray *installedPlugins;
@property (nonatomic) NSSet *installTasksInProgress;

@property (nonatomic) dispatch_source_t dispatchSource;
@property (nonatomic) int fileDesc;

@property (nonatomic) BOOL waitingToReloadFromDisk;

@property (nonatomic) BOOL initializedYet;

@property (nonatomic) BOOL failedToLoadWebPlugins;

@property (nonatomic) NSString *selectedCategory;

@property (nonatomic) NSString *selectedPluginName;

@end

@implementation PluginListController

#pragma mark Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.initializedYet) {
        self.selectedCategory = @"Featured";
        
        [self.toolbarItem setView:self.toggleView];
        
        self.sourceList.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;
        
        [self.tableView setDoubleAction:@selector(doubleClickedPlugin:)];
        [self.tableView setTarget:self];
        
        self.initializedYet = YES;
        self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]];
        
        [self startWatchingPluginsDir];
        [self reloadFromDisk];
        [self reloadPluginsFromWeb:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resized) name:NSViewFrameDidChangeNotification object:self.view];
        [self.view setPostsFrameChangedNotifications:YES];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopWatchingPluginsDir];
}

#pragma mark UI
- (void)updateUI {
    __weak PluginListController* weakSelf = self;
    if (self.failedToLoadWebPlugins) {
        self.errorText.stringValue = @"Couldn't load the list of available online plugins.";
        self.errorButton.title = @"Try again";
        self.errorButtonAction = ^{
            [weakSelf reloadPluginsFromWeb:nil];
        };
        self.errorBanner.hidden = NO;
    } else {
        self.errorBanner.hidden = YES;
    }
}

- (IBAction)errorButtonAction:(id)sender {
    if (self.errorButtonAction) self.errorButtonAction();
}

- (void)setFailedToLoadWebPlugins:(BOOL)failedToLoadWebPlugins {
    _failedToLoadWebPlugins = failedToLoadWebPlugins;
    [self updateUI];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    ((PluginCellView *)[rowView viewAtColumn:0]).listController = self;
}

- (void)resized {
    [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.arrayController.arrangedObjects count])]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat xInset = 72 + 6;
    CGFloat yInset = 14;
    return [[[self.arrayController.arrangedObjects objectAtIndex:row] attributedString] boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-xInset, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin].size.height + yInset;
}

- (NSIndexSet *)tableView:(NSTableView *)tableView
selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
    if (proposedSelectionIndexes.firstIndex == NSNotFound) {
        self.selectedPluginName = nil;
        return proposedSelectionIndexes;
    } else {
        self.selectedPluginName = [self.arrayController.arrangedObjects[proposedSelectionIndexes.firstIndex] name];
        return [NSIndexSet indexSetWithIndex:proposedSelectionIndexes.firstIndex];
    }
}
- (IBAction)doubleClickedPlugin:(id)sender {
    PluginModel *plugin = [(PluginCellView *)[self.tableView viewAtColumn:[self.tableView clickedColumn] row:[self.tableView clickedRow] makeIfNecessary:YES] plugin];
    if (!plugin.installed) return;
    if (plugin.isAutomatorWorkflow) {
        [self editPluginNamed:plugin.name];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"This plugin has no additional options." defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    }
}

#pragma mark Data
- (IBAction)reloadPluginsFromWeb:(id)sender {
    self.failedToLoadWebPlugins = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/nate-parrott/flashlight/master/PluginDirectories/1/index.json"]];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *plugins = [NSMutableArray new];
        if (data) {
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *dict in d[@"plugins"]) {
                [plugins addObject:[PluginModel fromJson:dict baseURL:url]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setPluginsFromWeb:plugins];
            self.failedToLoadWebPlugins = plugins.count==0;
        });
    }] resume];
}

- (void)setPluginsFromWeb:(NSArray *)pluginsFromWeb {
    _pluginsFromWeb = pluginsFromWeb;
    [self updateControllers];
}

- (void)setInstalledPlugins:(NSArray *)installedPlugins {
    _installedPlugins = installedPlugins;
    [self updateControllers];
}

- (void)setInstallTasksInProgress:(NSSet *)installTasksInProgress {
    _installTasksInProgress = installTasksInProgress;
    [self updateControllers];
}

- (void)updateControllers {
    [self.sourceList reloadData];
    self.selectedCategory = self.selectedCategory;
     ;
}

- (void)updateArrayController {
    [self.arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.arrayController.arrangedObjects count])]];
    
    NSMutableArray *allPlugins = [NSMutableArray new];
    if (self.installedPlugins) {
        [allPlugins addObjectsFromArray:self.installedPlugins];
    }
    if (self.pluginsFromWeb) {
        [allPlugins addObjectsFromArray:self.pluginsFromWeb];
    }
    
    NSArray *plugins = [PluginModel mergeDuplicates:allPlugins];
    for (PluginModel *plugin in plugins) {
        plugin.installing = [self isPluginCurrentlyBeingInstalled:plugin];
    }
    plugins = [plugins map:^id(PluginModel *p) {
        return [p.allCategories containsObject:self.selectedCategory] ? p : nil;
    }];
    [self.arrayController addObjects:plugins];
    [self.arrayController rearrangeObjects];
    [self.tableView reloadData];
    
    if (self.selectedPluginName) {
        NSArray *objects = self.arrayController.arrangedObjects;
        BOOL found = false;
        for (NSInteger i=0; i<objects.count; i++) {
            PluginModel *model = objects[i];
            if ([model.name isEqualToString:self.selectedPluginName]) {
                [self.tableView selectColumnIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                [self.tableView scrollRowToVisible:i];
                found = true;
                break;
            }
        }
        //if (!found) self.selectedPluginName = nil;
    }
}

#pragma mark Local plugin files
- (void)startWatchingPluginsDir {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self localPluginsPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self localPluginsPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.fileDesc = open([[self localPluginsPath] fileSystemRepresentation], O_EVTONLY);
    
    // watch the file descriptor for writes
    self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, self.fileDesc, DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    
    // call the passed block if the source is modified
    __weak PluginListController *weakSelf = self;
    dispatch_source_set_event_handler(self.dispatchSource, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // work around some bug when reloading after install
            if (!weakSelf.waitingToReloadFromDisk) {
                weakSelf.waitingToReloadFromDisk = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.waitingToReloadFromDisk = NO;
                    [weakSelf reloadFromDisk];
                });
            }
        });
    });
    
    // close the file descriptor when the dispatch source is cancelled
    dispatch_source_set_cancel_handler(self.dispatchSource, ^{
        close(self.fileDesc);
    });
    
    // at this point the dispatch source is paused, so start watching
    dispatch_resume(self.dispatchSource);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFromDisk) name:PluginDidChangeOnDiskNotification object:nil];
}

- (void)stopWatchingPluginsDir {
    dispatch_cancel(self.dispatchSource);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PluginDidChangeOnDiskNotification object:nil];
}

- (void)reloadFromDisk {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self localPluginsPath] error:nil];
    NSMutableArray *models = [NSMutableArray new];
    for (NSString *itemName in contents) {
        NSString *ext = [itemName pathExtension];
        if ([@[@"bundle", @"disabled-bundle"] containsObject:ext]) {
            NSData *data = [NSData dataWithContentsOfFile:[[[self localPluginsPath] stringByAppendingPathComponent:itemName] stringByAppendingPathComponent:@"info.json"]];
            if (data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                PluginModel *model = [PluginModel fromJson:json baseURL:nil];
                if ([ext isEqualToString:@"bundle"]) {
                    model.installed = YES;
                } else {
                    model.disabledPluginPath = [[self localPluginsPath] stringByAppendingPathComponent:itemName];
                }
                [models addObject:model];
            }
        }
    }
    self.installedPlugins = models;
}

- (NSString *)localPluginsPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"FlashlightPlugins"];
}

#pragma mark (Un)?installation
- (BOOL)isPluginCurrentlyBeingInstalled:(PluginModel *)plugin {
    for (PluginInstallTask *task in self.installTasksInProgress) {
        if ([task.plugin.name isEqualToString:plugin.name]) {
            return YES;
        }
    }
    return NO;
}
- (void)installPlugin:(PluginModel *)plugin {
    if ([self isPluginCurrentlyBeingInstalled:plugin]) return;
    
    PluginInstallTask *task = [[PluginInstallTask alloc] initWithPlugin:plugin];
    self.installTasksInProgress = self.installTasksInProgress ? [self.installTasksInProgress setByAddingObject:task] : [NSSet setWithObject:task];
    [task startInstallationIntoPluginsDirectory:[self localPluginsPath] withCallback:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                NSAlert *alert = error ? [NSAlert alertWithError:error] : [NSAlert alertWithMessageText:@"Couldn't install plugin." defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
                alert.alertStyle = NSWarningAlertStyle;
                [alert runModal];
            }
            NSMutableSet *tasks = self.installTasksInProgress.mutableCopy;
            [tasks removeObject:task];
            self.installTasksInProgress = tasks;
        });
    }];
}
- (void)uninstallPlugin:(PluginModel *)plugin {
    if ([self isPluginCurrentlyBeingInstalled:plugin]) return;
    
    NSString *path = [[self localPluginsPath] stringByAppendingPathComponent:[plugin.name stringByAppendingPathExtension:@"bundle"]];
    NSString *disabledPath = [[self localPluginsPath] stringByAppendingPathComponent:[plugin.name stringByAppendingPathExtension:@"disabled-bundle"]];
    [[NSFileManager defaultManager] moveItemAtPath:path toPath:disabledPath error:nil];
}

#pragma mark Categorization
- (NSArray *)categoriesForDisplay {
    // returns category names or NSNull's for section breaks
    NSMutableSet *categories = [NSMutableSet new];
    for (PluginModel *p in self.pluginsFromWeb) {
        for (NSString *c in p.allCategories) {
            [categories addObject:c];
        }
    }
    for (PluginModel *p in self.installedPlugins) {
        for (NSString *c in p.allCategories) {
            [categories addObject:c];
        }
    }
    NSMutableArray *ordered = categories.allObjects.mutableCopy;
    [ordered sortUsingSelector:@selector(compare:)];
    [ordered removeObject:@"Installed"];
    [ordered removeObject:@"Featured"];
    [ordered removeObject:@"Unknown"];
    
    [ordered insertObject:[NSNull null] atIndex:0];
    [ordered insertObject:@"Installed" atIndex:1];
    [ordered insertObject:[NSNull null] atIndex:2];
    [ordered insertObject:@"Featured" atIndex:3];
    [ordered insertObject:[NSNull null] atIndex:4];
    [ordered addObject:@"Unknown"];
    return ordered;
}
- (NSImage *)iconForCategory:(NSString *)category {
    NSDictionary *imageNamesForCategories = @{
                            @"Installed": @"download",
                            @"Featured": @"star",
                            @"Information": @"info",
                            @"Language": @"translate",
                            @"Search": @"search",
                            @"System": @"cog",
                            @"Utilities": @"wrench",
                            @"Weather": @"cloud",
                            @"News": @"newspaper",
                            @"Unknown": @"plugin"
                            };
    NSString *imageName = imageNamesForCategories[category] ? : @"plugin";
    return [NSImage imageNamed:imageName];
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item==nil) {
        return [self categoriesForDisplay].count;
    } else {
        return 0;
    }
}
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([item isKindOfClass:[NSNull class]]) {
        NSTableCellView *view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        view.textField.stringValue = @"";
        return view;
    } else {
        NSTableCellView *view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        view.textField.stringValue = item;
        view.imageView.image = [self iconForCategory:item];
        view.imageView.alphaValue = 0.47;
        return view;
    }
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [self categoriesForDisplay][index];
    } else {
        return nil;
    }
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![item isKindOfClass:[NSNull class]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSString *category = [self categoriesForDisplay][[self.sourceList selectedRow]];
    if (![self.selectedCategory isEqualToString:category]) {
        self.selectedCategory = category;
        self.selectedPluginName = nil;
    }
}

- (void)setSelectedCategory:(NSString *)selectedCategory {
    _selectedCategory = selectedCategory;
    NSInteger i = [[self categoriesForDisplay] indexOfObject:self.selectedCategory];
    if (i != NSNotFound) {
        [self.sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
    }
    [self updateArrayController];
}
#pragma mark WIndow delegate
- (void)windowDidBecomeMain:(NSNotification *)notification {
    // [self reloadFromDisk];
}

#pragma mark Creation/Editing
- (IBAction)newPlugin:(id)sender {
    NSString *name = [[NSUUID UUID] UUIDString];
    NSString *path = [[[self localPluginsPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"];
    [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"WorkflowTemplate" ofType:@"bundle"] toPath:path error:nil];
    // rename the template:
    NSString *infoJsonPath = [path stringByAppendingPathComponent:@"info.json"];
    NSMutableDictionary *d = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:infoJsonPath] options:0 error:nil] mutableCopy];
    d[@"name"] = name;
    [[NSJSONSerialization dataWithJSONObject:d options:0 error:nil] writeToFile:infoJsonPath atomically:YES];
    self.selectedCategory = @"Installed";
    self.selectedPluginName = name;
    [self reloadFromDisk];
    [self editPluginNamed:name];
}

- (void)editPluginNamed:(NSString *)name {
    PluginEditorWindowController *editor = [[PluginEditorWindowController alloc] initWithWindowNibName:@"PluginEditorWindowController"];
    editor.pluginPath = [[[self localPluginsPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"];
    [editor showWindow:nil];
}

@end
