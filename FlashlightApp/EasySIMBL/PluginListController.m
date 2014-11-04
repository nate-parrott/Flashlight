//
//  PluginListController.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginListController.h"
#import "PluginModel.h"

@interface PluginListController ()

@property (nonatomic) NSArray *pluginsFromWeb;
@property (nonatomic) NSArray *installedPlugins;

@property (nonatomic) dispatch_source_t dispatchSource;
@property (nonatomic) int fileDesc;

@property (nonatomic) BOOL needsReloadFromDisk;

@end

@implementation PluginListController

#pragma mark Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self startWatchingPluginsDir];
    self.needsReloadFromDisk = YES;
    [self reloadFromDiskIfNeeded];
}
- (void)dealloc {
    [self startWatchingPluginsDir];
}

#pragma mark Data
- (IBAction)reloadPluginsFromWeb:(id)sender {
    [self setPluginsFromWeb:@[]];
}

- (void)setPluginsFromWeb:(NSArray *)pluginsFromWeb {
    _pluginsFromWeb = pluginsFromWeb;
    [self updateArrayController];
}

- (void)setInstalledPlugins:(NSArray *)installedPlugins {
    _installedPlugins = installedPlugins;
    [self updateArrayController];
}

- (void)updateArrayController {
    [self.arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.arrayController.arrangedObjects count])]];
    for (PluginModel *p in self.installedPlugins) {
        [self.arrayController addObject:p];
    }
    for (PluginModel *p in self.pluginsFromWeb) {
        [self.arrayController addObject:p];
    }
}

#pragma mark Local plugin files
- (void)startWatchingPluginsDir {
    self.fileDesc = open([[self localPluginsPath] fileSystemRepresentation], O_EVTONLY);
    
    // watch the file descriptor for writes
    self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, self.fileDesc, DISPATCH_VNODE_WRITE, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    
    // call the passed block if the source is modified
    __weak PluginListController *weakSelf = self;
    dispatch_source_set_event_handler(self.dispatchSource, ^{
        if (!weakSelf.needsReloadFromDisk) {
            weakSelf.needsReloadFromDisk = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadFromDiskIfNeeded];
            });
        }
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

- (void)reloadFromDiskIfNeeded {
    self.needsReloadFromDisk = NO;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self localPluginsPath] error:nil];
    NSMutableArray *models = [NSMutableArray new];
    for (NSString *itemName in contents) {
        if ([[itemName pathExtension] isEqualToString:@"bundle"]) {
            NSBundle *bundle = [NSBundle bundleWithPath:[[self localPluginsPath] stringByAppendingPathComponent:itemName]];
            PluginModel *model = [PluginModel new];
            model.name = [bundle infoDictionary][@"CFBundleDisplayName"];
            model.pluginDescription = [bundle infoDictionary][@"Description"];
            model.installed = YES;
            [models addObject:model];
        }
    }
    self.installedPlugins = models;
}

- (NSString *)localPluginsPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"FlashlightPlugins"];
}

@end
