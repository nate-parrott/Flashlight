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
#import "PluginDirectoryAPI.h"
#import "NSURLComponents+ValueForQueryKey.h"
#import "SearchPluginEditorWindowController.h"
#import "UpdateChecker.h"

NSString * const kCategoryInstalled = @"Installed";
NSString * const kCategoryFeatured = @"Featured";
NSString * const kCategorySearchResults = @"_SearchResults";
NSString * const kCategoryShowIndividualPlugin = @"_ShowIndividualPlugin";

@interface PluginListController () <NSTableViewDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, NSWindowDelegate>

@property (nonatomic) NSArray *installedPlugins;
@property (nonatomic) NSSet *installTasksInProgress;

@property (nonatomic) dispatch_source_t dispatchSource;
@property (nonatomic) int fileDesc;

@property (nonatomic) BOOL waitingToReloadFromDisk;

@property (nonatomic) BOOL initializedYet;

@property (nonatomic) BOOL failedToLoadCategories;

@property (nonatomic) NSArray *categories;

@property (nonatomic) NSString *selectedCategory;

@property (nonatomic) NSString *selectedPluginName;

@property (nonatomic) IBOutlet NSSearchField *searchField;

@property (nonatomic) NSView *rightPaneView;

@property (nonatomic) IBOutlet NSView *disabledPane;
@property (nonatomic) IBOutlet NSView *postEnabledPane;

@end

@implementation PluginListController

- (instancetype)init {
    self = [super init];
    _enabled = YES;
    return self;
}

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
        [self reloadCategoriesFromWeb:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resized) name:NSViewFrameDidChangeNotification object:self.view];
        [self.view setPostsFrameChangedNotifications:YES];
        
        [self.webView setDrawsBackground:NO];
        
        [self updateUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePluginStatuses) name:UpdateCheckerPluginsNeedingUpdatesDidChangeNotification object:self];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopWatchingPluginsDir];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self updateUI];
}

#pragma mark UI
- (void)updateUI {
    __weak PluginListController* weakSelf = self;
    if (self.failedToLoadCategories) {
        self.errorText.stringValue = NSLocalizedString(@"Couldn't load the online plugin directory.", @"");
        self.errorButton.title = NSLocalizedString(@"Try again", @"");
        self.errorButtonAction = ^{
            [weakSelf reloadCategoriesFromWeb:nil];
        };
        self.errorBanner.hidden = NO;
    } else {
        self.errorBanner.hidden = YES;
    }
    [self updateControllers];
    
    BOOL showingInstalled = [self.selectedCategory isEqualToString:kCategoryInstalled];
    
    if (self.enabled) {
        if (showingInstalled) {
            self.rightPaneView = self.tableContainer;
        } else {
            self.rightPaneView = self.webViewEffectView;
        }
        NSInteger i = [[self categoriesForDisplay] indexOfObject:self.selectedCategory];
        if (i != NSNotFound) {
            [self.sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
        }
        
    } else {
        self.rightPaneView = self.disabledPane;
        [self.sourceList selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    }
    
    [self updatePluginStatuses];
}

- (void)setRightPaneView:(NSView *)rightPaneView {
    if (rightPaneView == _rightPaneView) return;
    [_rightPaneView removeFromSuperview];
    _rightPaneView = rightPaneView;
    [self.rightPaneContainer addSubview:rightPaneView];
    rightPaneView.frame = self.rightPaneContainer.bounds;
    rightPaneView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

- (IBAction)errorButtonAction:(id)sender {
    if (self.errorButtonAction) self.errorButtonAction();
}

- (void)setFailedToLoadCategories:(BOOL)failedToLoadCategories {
    _failedToLoadCategories = failedToLoadCategories;
    [self updateUI];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    ((PluginCellView *)[rowView viewAtColumn:0]).listController = self;
}

- (void)resized {
    [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.arrayController.arrangedObjects count])]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat xInset = 449 - 443;
    CGFloat yInset = 94 - 56;
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
        [self editAutomatorPluginNamed:plugin.name];
    } else if (plugin.isSearchPlugin) {
        [self editSearchPluginNamed:plugin.name];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"This plugin has no additional options.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"Okay", @"")];
        
        [alert runModal];
    }
}

#pragma mark Data
- (IBAction)reloadCategoriesFromWeb:(id)sender {
    self.failedToLoadCategories = NO;
    
    [[PluginDirectoryAPI shared] loadCategoriesWithCallback:^(NSArray *categories, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (categories) {
                self.categories = categories;
            } else {
                self.failedToLoadCategories = YES;
            }
        });
    }];
}

- (void)setCategories:(NSArray *)categories {
    _categories = categories;
    [self updateUI];
}

- (void)setInstalledPlugins:(NSArray *)installedPlugins {
    _installedPlugins = installedPlugins;
    [self updateUI];
}

- (void)setInstallTasksInProgress:(NSSet *)installTasksInProgress {
    _installTasksInProgress = installTasksInProgress;
    [self updateUI];
}

- (void)updateControllers {
    [self.sourceList reloadData];
    [self updateArrayController];
}

- (void)updateArrayController {
    [self.arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.arrayController.arrangedObjects count])]];
    if (self.installedPlugins)
        [self.arrayController addObjects:self.installedPlugins];
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
    self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, self.fileDesc, DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE | DISPATCH_VNODE_ATTRIB, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    
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
}

- (void)stopWatchingPluginsDir {
    dispatch_cancel(self.dispatchSource);
}

- (void)reloadFromDisk {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self localPluginsPath] error:nil];
    NSMutableArray *models = [NSMutableArray new];
    for (NSString *itemName in contents) {
        NSString *ext = [itemName pathExtension];
        if ([@[@"bundle"] containsObject:ext]) {
            NSData *data = [NSData dataWithContentsOfFile:[[[self localPluginsPath] stringByAppendingPathComponent:itemName] stringByAppendingPathComponent:@"info.json"]];
            if (data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                PluginModel *model = [PluginModel fromJson:json baseURL:nil];
                model.installed = YES;
                [models addObject:model];
            }
        }
    }
    self.installedPlugins = models;
    [self updateUI];
}

- (NSString *)localPluginsPath {
    return [PluginModel pluginsDir];
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
                NSAlert *alert;
                if (error) {
                    alert = [NSAlert alertWithError:error];
                } else {
                    alert = [[NSAlert alloc] init];
                    [alert setMessageText:NSLocalizedString(@"Couldn't install plugin.", @"")];
                    [alert addButtonWithTitle:NSLocalizedString(@"Okay", @"")];
                }
                alert.alertStyle = NSWarningAlertStyle;
                [alert runModal];
            }
            NSMutableSet *tasks = self.installTasksInProgress.mutableCopy;
            [tasks removeObject:task];
            [self clearNLPModelCache];
            self.installTasksInProgress = tasks;
            [self reloadFromDisk];
            [self updatePluginStatuses];
        });
    }];
}
- (void)uninstallPlugin:(PluginModel *)plugin {
    if ([self isPluginCurrentlyBeingInstalled:plugin]) return;
    
    NSString *path = [[self localPluginsPath] stringByAppendingPathComponent:[plugin.name stringByAppendingPathExtension:@"bundle"]];
    NSString *disabledPath = [[self localPluginsPath] stringByAppendingPathComponent:[plugin.name stringByAppendingPathExtension:@"disabled-bundle"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:disabledPath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:disabledPath error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtPath:path toPath:disabledPath error:nil];
    [self clearNLPModelCache];
}

- (void)clearNLPModelCache {
    // TODO: get FlashlightKit to clear its cache somehow
}

#pragma mark Categorization
- (NSArray *)categoriesForDisplay {
    // returns category names or NSNull's for section breaks
    NSMutableArray *ordered = self.categories.mutableCopy ? : [NSMutableArray new];
    [ordered sortUsingSelector:@selector(compare:)];
    [ordered removeObject:kCategoryInstalled];
    [ordered removeObject:kCategoryFeatured];
    [ordered removeObject:@"Unknown"];
    
    [ordered insertObject:[NSNull null] atIndex:0];
    [ordered insertObject:kCategoryInstalled atIndex:1];
    [ordered insertObject:[NSNull null] atIndex:2];
    [ordered insertObject:kCategoryFeatured atIndex:3];
    [ordered insertObject:[NSNull null] atIndex:4];
    [ordered addObject:[NSNull null]];
    [ordered addObject:@"New"];
    return ordered;
}
- (NSImage *)iconForCategory:(NSString *)category {
    NSDictionary *imageNamesForCategories = @{
                            kCategoryInstalled: @"download",
                            kCategoryFeatured: @"star",
                            @"Information": @"info",
                            @"Language": @"translate",
                            @"Search": @"search",
                            @"System": @"cog",
                            @"Utilities": @"wrench",
                            @"Weather": @"cloud",
                            @"News": @"newspaper",
                            @"Unknown": @"plugin",
                            @"Art": @"palette",
                            @"Developer": @"console",
                            @"New": @"asterisk"
                            };
    NSString *imageName = imageNamesForCategories[category] ? : @"plugin";
    NSImage *image = [NSImage imageNamed:imageName];
    [image setTemplate:YES];
    return image;
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
        view.textField.stringValue = [self localizedNameForCategory:item];
        view.imageView.image = [self iconForCategory:item];
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
    [self updateUI];
    if (![selectedCategory isEqualToString:kCategoryInstalled]) {
        self.webView.alphaValue = 0;
        [self.webView.mainFrame loadHTMLString:@"" baseURL:nil];
        if ([selectedCategory isEqualToString:kCategorySearchResults]) {
            [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[[PluginDirectoryAPI shared] URLForSearchQuery:self.searchField.stringValue]]];
        } else if ([selectedCategory isEqualToString:kCategoryShowIndividualPlugin]) {
            [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[[PluginDirectoryAPI shared] URLForPluginNamed:self.selectedPluginName]]];
        } else {
            [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[[PluginDirectoryAPI shared] URLForCategory:selectedCategory]]];
        }
    }
}

- (NSString *)localizedNameForCategory:(NSString *)category {
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{
                 @"Installed": NSLocalizedString(@"Installed", @""),
                 @"Featured": NSLocalizedString(@"Featured", @""),
                 @"Information": NSLocalizedString(@"Information", @""),
                 @"Language": NSLocalizedString(@"Language", @""),
                 @"Search": NSLocalizedString(@"Search", @""),
                 @"System": NSLocalizedString(@"System", @""),
                 @"Utilities": NSLocalizedString(@"Utilities", @""),
                 @"Weather": NSLocalizedString(@"Weather", @""),
                 @"News": NSLocalizedString(@"News", @""),
                 @"Art": NSLocalizedString(@"Art", @""),
                 @"Developer": NSLocalizedString(@"Developer", @""),
                 @"Unknown": NSLocalizedString(@"Unknown", @""),
                 @"Media": NSLocalizedString(@"Media", @""),
                 @"New": NSLocalizedString(@"New", @"new plugins")
                 };
    });
    return dict[category] ? : category;
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
    self.selectedCategory = kCategoryInstalled;
    self.selectedPluginName = name;
    [self reloadFromDisk];
    [self editAutomatorPluginNamed:name];
}

- (void)editAutomatorPluginNamed:(NSString *)name {
    PluginEditorWindowController *editor = [[PluginEditorWindowController alloc] initWithWindowNibName:@"PluginEditorWindowController"];
    editor.pluginPath = [[[self localPluginsPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"];
    [editor showWindow:nil];
}

- (IBAction)newSearchPlugin:(id)sender {
    NSString *name = [[NSUUID UUID] UUIDString];
    NSString *path = [[[self localPluginsPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"];
    [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"SearchTemplate" ofType:@"bundle"] toPath:path error:nil];
    // rename the template:
    NSString *infoJsonPath = [path stringByAppendingPathComponent:@"info.json"];
    NSMutableDictionary *d = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:infoJsonPath] options:0 error:nil] mutableCopy];
    d[@"name"] = name;
    [[NSJSONSerialization dataWithJSONObject:d options:0 error:nil] writeToFile:infoJsonPath atomically:YES];
    self.selectedCategory = kCategoryInstalled;
    self.selectedPluginName = name;
    [self reloadFromDisk];
    [self editSearchPluginNamed:name];
}

- (void)editSearchPluginNamed:(NSString *)name {
    SearchPluginEditorWindowController *editor = [[SearchPluginEditorWindowController alloc] initWithWindowNibName:@"SearchPluginEditorWindowController"];
    editor.pluginPath = [[[self localPluginsPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"bundle"];
    [editor showWindow:nil];
}

#pragma mark Webview
- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    [self.webView.mainFrame.frameView.documentView.enclosingScrollView setVerticalScrollElasticity:NSScrollElasticityAutomatic];
    self.webView.alphaValue = 1;
}

- (void)updatePluginStatuses {
    NSMutableString *script = [NSMutableString new];
    [script appendFormat:@"var elements = document.querySelectorAll('#plugins > li');\n"];
    [script appendFormat:@"for (var i=0; i<elements.length; i++) elements[i].setAttribute('status', 'uninstalled')\n"];
    for (PluginModel *plugin in self.installedPlugins) {
        [script appendFormat:@"elements = document.getElementsByClassName('%@');\n", plugin.name];
        [script appendString:@"if (elements.length) elements[0].setAttribute('status', 'installed');\n"];
    }
    for (NSString *name in [UpdateChecker shared].pluginsNeedingUpdates) {
        [script appendFormat:@"elements = document.getElementsByClassName('%@');\n", name];
        [script appendString:@"if (elements.length) elements[0].setAttribute('status', 'needsUpdate');\n"];
    }
    for (PluginInstallTask *installation in self.installTasksInProgress) {
        [script appendFormat:@"elements = document.getElementsByClassName('%@');\n", installation.plugin.name];
        [script appendString:@"if (elements.length) elements[0].setAttribute('status', 'installing');\n"];
    }
    [self.webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if ([request.URL.scheme isEqualToString:@"domready"]) {
        [self updatePluginStatuses];
        [listener ignore];
    } else if ([request.URL.scheme isEqualToString:@"install"] || [request.URL.scheme isEqualToString:@"update"]) {
        NSURLComponents *comps = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
        PluginModel *model = [PluginModel new];
        model.name = [comps valueForQueryKey:@"name"];
        model.pluginDescription = @"";
        model.zipURL = [NSURL URLWithString:[comps valueForQueryKey:@"zip_url"]];
        [self installPlugin:model];
        [self updatePluginStatuses];
        [listener ignore];
    } else if ([request.URL.scheme isEqualToString:@"uninstall"]) {
        NSString *name = request.URL.host;
        PluginModel *plugin = [self.installedPlugins map:^id(PluginModel *p) {
            return [p.name isEqualToString:name] ? p : nil;
        }].firstObject;
        if (plugin) {
            [self uninstallPlugin:plugin];
        }
        [self reloadFromDisk];
        [listener ignore];
    } else if ([request.URL.scheme isEqualToString:@"open"]) {
        [listener ignore];
        NSURLComponents *comps = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
        comps.scheme = @"http";
        [[NSWorkspace sharedWorkspace] openURL:comps.URL];
    } else {
        [listener use];
    }
}

#pragma mark Search
- (IBAction)search:(id)sender {
    if (self.searchField.stringValue.length > 0) {
        self.selectedCategory = kCategorySearchResults;
    }
}
#pragma mark Revealing Individual Plugins
- (void)showPluginWithName:(NSString *)name {
    self.selectedPluginName = name;
    self.selectedCategory = kCategoryShowIndividualPlugin;
}

- (void)showInstalledPluginWithName:(NSString *)name {
    self.selectedCategory = @"Installed";
    self.selectedPluginName = name;
    PluginModel *model = [self.installedPlugins map:^id(id obj) {
        return [[obj name] isEqualToString:name] ? obj : nil;
    }].firstObject;
    NSUInteger index = model ? [self.installedPlugins indexOfObject:model] : NSNotFound;
    if (index != NSNotFound) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
}

- (void)showCategory:(NSString *)category {
    self.selectedCategory = category;
}

- (void)showSearch:(NSString *)search {
    self.searchField.stringValue = search;
    [self search:nil];
}

@end
