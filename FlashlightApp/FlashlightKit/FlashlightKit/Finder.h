/*
 * Finder.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class FinderApplication, FinderItem, FinderContainer, FinderComputerObject, FinderDisk, FinderFolder, FinderDesktopObject, FinderTrashObject, FinderFile, FinderAliasFile, FinderApplicationFile, FinderDocumentFile, FinderInternetLocationFile, FinderClipping, FinderPackage, FinderWindow, FinderFinderWindow, FinderDesktopWindow, FinderInformationWindow, FinderPreferencesWindow, FinderClippingWindow, FinderProcess, FinderApplicationProcess, FinderDeskAccessoryProcess, FinderPreferences, FinderLabel, FinderIconFamily, FinderIconViewOptions, FinderColumnViewOptions, FinderListViewOptions, FinderColumn, FinderAliasList;

enum FinderPriv {
	FinderPrivReadOnly = 'read',
	FinderPrivReadWrite = 'rdwr',
	FinderPrivWriteOnly = 'writ',
	FinderPrivNone = 'none'
};
typedef enum FinderPriv FinderPriv;

enum FinderEdfm {
	FinderEdfmMacOSFormat = 'dfhf',
	FinderEdfmMacOSExtendedFormat = 'dfh+',
	FinderEdfmUFSFormat = 'dfuf',
	FinderEdfmNFSFormat = 'dfnf',
	FinderEdfmAudioFormat = 'dfau',
	FinderEdfmProDOSFormat = 'dfpr',
	FinderEdfmMSDOSFormat = 'dfms',
	FinderEdfmNTFSFormat = 'dfnt',
	FinderEdfmISO9660Format = 'df96',
	FinderEdfmHighSierraFormat = 'dfhs',
	FinderEdfmQuickTakeFormat = 'dfqt',
	FinderEdfmApplePhotoFormat = 'dfph',
	FinderEdfmAppleShareFormat = 'dfas',
	FinderEdfmUDFFormat = 'dfud',
	FinderEdfmWebDAVFormat = 'dfwd',
	FinderEdfmFTPFormat = 'dfft',
	FinderEdfmPacketWrittenUDFFormat = 'dfpu',
	FinderEdfmXsanFormat = 'dfac',
	FinderEdfmUnknownFormat = 'df\?\?'
};
typedef enum FinderEdfm FinderEdfm;

enum FinderIpnl {
	FinderIpnlGeneralInformationPanel = 'gpnl',
	FinderIpnlSharingPanel = 'spnl',
	FinderIpnlMemoryPanel = 'mpnl',
	FinderIpnlPreviewPanel = 'vpnl',
	FinderIpnlApplicationPanel = 'apnl',
	FinderIpnlLanguagesPanel = 'pklg',
	FinderIpnlPluginsPanel = 'pkpg',
	FinderIpnlNameExtensionPanel = 'npnl',
	FinderIpnlCommentsPanel = 'cpnl',
	FinderIpnlContentIndexPanel = 'cinl',
	FinderIpnlBurningPanel = 'bpnl',
	FinderIpnlMoreInfoPanel = 'minl',
	FinderIpnlSimpleHeaderPanel = 'shnl'
};
typedef enum FinderIpnl FinderIpnl;

enum FinderPple {
	FinderPpleGeneralPreferencesPanel = 'pgnp',
	FinderPpleLabelPreferencesPanel = 'plbp',
	FinderPpleSidebarPreferencesPanel = 'psid',
	FinderPpleAdvancedPreferencesPanel = 'padv'
};
typedef enum FinderPple FinderPple;

enum FinderEcvw {
	FinderEcvwIconView = 'icnv',
	FinderEcvwListView = 'lsvw',
	FinderEcvwColumnView = 'clvw',
	FinderEcvwGroupView = 'grvw',
	FinderEcvwFlowView = 'flvw'
};
typedef enum FinderEcvw FinderEcvw;

enum FinderEarr {
	FinderEarrNotArranged = 'narr',
	FinderEarrSnapToGrid = 'grda',
	FinderEarrArrangedByName = 'nama',
	FinderEarrArrangedByModificationDate = 'mdta',
	FinderEarrArrangedByCreationDate = 'cdta',
	FinderEarrArrangedBySize = 'siza',
	FinderEarrArrangedByKind = 'kina',
	FinderEarrArrangedByLabel = 'laba'
};
typedef enum FinderEarr FinderEarr;

enum FinderEpos {
	FinderEposRight = 'lrgt',
	FinderEposBottom = 'lbot'
};
typedef enum FinderEpos FinderEpos;

enum FinderSodr {
	FinderSodrNormal = 'snrm',
	FinderSodrReversed = 'srvs'
};
typedef enum FinderSodr FinderSodr;

enum FinderElsv {
	FinderElsvNameColumn = 'elsn',
	FinderElsvModificationDateColumn = 'elsm',
	FinderElsvCreationDateColumn = 'elsc',
	FinderElsvSizeColumn = 'elss',
	FinderElsvKindColumn = 'elsk',
	FinderElsvLabelColumn = 'elsl',
	FinderElsvVersionColumn = 'elsv',
	FinderElsvCommentColumn = 'elsC'
};
typedef enum FinderElsv FinderElsv;

enum FinderLvic {
	FinderLvicSmallIcon = 'smic',
	FinderLvicLargeIcon = 'lgic'
};
typedef enum FinderLvic FinderLvic;



/*
 * Finder Basics
 */

// The Finder
@interface FinderApplication : SBApplication

- (SBElementArray *) items;
- (SBElementArray *) containers;
- (SBElementArray *) disks;
- (SBElementArray *) folders;
- (SBElementArray *) files;
- (SBElementArray *) aliasFiles;
- (SBElementArray *) applicationFiles;
- (SBElementArray *) documentFiles;
- (SBElementArray *) internetLocationFiles;
- (SBElementArray *) clippings;
- (SBElementArray *) packages;
- (SBElementArray *) windows;
- (SBElementArray *) FinderWindows;
- (SBElementArray *) clippingWindows;

@property (copy, readonly) SBObject *clipboard;  // (NOT AVAILABLE YET) the Finder’s clipboard window
@property (copy, readonly) NSString *name;  // the Finder’s name
@property BOOL visible;  // Is the Finder’s layer visible?
@property BOOL frontmost;  // Is the Finder the frontmost process?
@property (copy) SBObject *selection;  // the selection in the frontmost Finder window
@property (copy, readonly) SBObject *insertionLocation;  // the container in which a new folder would appear if “New Folder” was selected
@property (copy, readonly) NSString *productVersion;  // the version of the System software running on this computer
@property (copy, readonly) NSString *version;  // the version of the Finder
@property (copy, readonly) FinderDisk *startupDisk;  // the startup disk
@property (copy, readonly) FinderDesktopObject *desktop;  // the desktop
@property (copy, readonly) FinderTrashObject *trash;  // the trash
@property (copy, readonly) FinderFolder *home;  // the home directory
@property (copy, readonly) FinderComputerObject *computerContainer;  // the computer location (as in Go > Computer)
@property (copy, readonly) FinderPreferences *FinderPreferences;  // Various preferences that apply to the Finder as a whole

- (void) quit;  // Quit the Finder
- (void) activate;  // Activate the specified window (or the Finder)
- (void) copy NS_RETURNS_NOT_RETAINED;  // (NOT AVAILABLE YET) Copy the selected items to the clipboard (the Finder must be the front application)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) restart;  // Restart the computer
- (void) shutDown;  // Shut Down the computer
- (void) sleep;  // Put the computer to sleep

@end



/*
 * Finder items
 */

// An item
@interface FinderItem : SBObject

@property (copy) NSString *name;  // the name of the item
@property (copy, readonly) NSString *displayedName;  // the user-visible name of the item
@property (copy) NSString *nameExtension;  // the name extension of the item (such as “txt”)
@property BOOL extensionHidden;  // Is the item's extension hidden from the user?
@property (readonly) NSInteger index;  // the index in the front-to-back ordering within its container
@property (copy, readonly) SBObject *container;  // the container of the item
@property (copy, readonly) SBObject *disk;  // the disk on which the item is stored
@property NSPoint position;  // the position of the item within its parent window (can only be set for an item in a window viewed as icons or buttons)
@property NSPoint desktopPosition;  // the position of the item on the desktop
@property NSRect bounds;  // the bounding rectangle of the item (can only be set for an item in a window viewed as icons or buttons)
@property NSInteger labelIndex;  // the label of the item
@property BOOL locked;  // Is the file locked?
@property (copy, readonly) NSString *kind;  // the kind of the item
@property (copy, readonly) NSString *objectDescription;  // a description of the item
@property (copy) NSString *comment;  // the comment of the item, displayed in the “Get Info” window
@property (readonly) long long size;  // the logical size of the item
@property (readonly) long long physicalSize;  // the actual space used by the item on disk
@property (copy, readonly) NSDate *creationDate;  // the date on which the item was created
@property (copy) NSDate *modificationDate;  // the date on which the item was last modified
@property (copy) FinderIconFamily *icon;  // the icon bitmap of the item
@property (copy, readonly) NSString *URL;  // the URL of the item
@property (copy) NSString *owner;  // the user that owns the container
@property (copy) NSString *group;  // the user or group that has special access to the container
@property FinderPriv ownerPrivileges;
@property FinderPriv groupPrivileges;
@property FinderPriv everyonesPrivileges;
@property (copy, readonly) SBObject *informationWindow;  // the information window for the item
@property (copy) NSDictionary *properties;  // every property of an item

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end



/*
 * Containers and folders
 */

// An item that contains other items
@interface FinderContainer : FinderItem

- (SBElementArray *) items;
- (SBElementArray *) containers;
- (SBElementArray *) folders;
- (SBElementArray *) files;
- (SBElementArray *) aliasFiles;
- (SBElementArray *) applicationFiles;
- (SBElementArray *) documentFiles;
- (SBElementArray *) internetLocationFiles;
- (SBElementArray *) clippings;
- (SBElementArray *) packages;

@property (copy, readonly) SBObject *entireContents;  // the entire contents of the container, including the contents of its children
@property (readonly) BOOL expandable;  // (NOT AVAILABLE YET) Is the container capable of being expanded as an outline?
@property BOOL expanded;  // (NOT AVAILABLE YET) Is the container opened as an outline? (can only be set for containers viewed as lists)
@property BOOL completelyExpanded;  // (NOT AVAILABLE YET) Are the container and all of its children opened as outlines? (can only be set for containers viewed as lists)
@property (copy, readonly) SBObject *containerWindow;  // the container window for this folder


@end

// the Computer location (as in Go > Computer)
@interface FinderComputerObject : FinderItem


@end

// A disk
@interface FinderDisk : FinderContainer

- (SBElementArray *) items;
- (SBElementArray *) containers;
- (SBElementArray *) folders;
- (SBElementArray *) files;
- (SBElementArray *) aliasFiles;
- (SBElementArray *) applicationFiles;
- (SBElementArray *) documentFiles;
- (SBElementArray *) internetLocationFiles;
- (SBElementArray *) clippings;
- (SBElementArray *) packages;

- (NSInteger) id;  // the unique id for this disk (unchanged while disk remains connected and Finder remains running)
@property (readonly) long long capacity;  // the total number of bytes (free or used) on the disk
@property (readonly) long long freeSpace;  // the number of free bytes left on the disk
@property (readonly) BOOL ejectable;  // Can the media be ejected (floppies, CDs, and so on)?
@property (readonly) BOOL localVolume;  // Is the media a local volume (as opposed to a file server)?
@property (readonly) BOOL startup;  // Is this disk the boot disk?
@property (readonly) FinderEdfm format;  // the filesystem format of this disk
@property (readonly) BOOL journalingEnabled;  // Does this disk do file system journaling?
@property BOOL ignorePrivileges;  // Ignore permissions on this disk?


@end

// A folder
@interface FinderFolder : FinderContainer

- (SBElementArray *) items;
- (SBElementArray *) containers;
- (SBElementArray *) folders;
- (SBElementArray *) files;
- (SBElementArray *) aliasFiles;
- (SBElementArray *) applicationFiles;
- (SBElementArray *) documentFiles;
- (SBElementArray *) internetLocationFiles;
- (SBElementArray *) clippings;
- (SBElementArray *) packages;


@end

// Desktop-object is the class of the “desktop” object
@interface FinderDesktopObject : FinderContainer

- (SBElementArray *) items;
- (SBElementArray *) containers;
- (SBElementArray *) disks;
- (SBElementArray *) folders;
- (SBElementArray *) files;
- (SBElementArray *) aliasFiles;
- (SBElementArray *) applicationFiles;
- (SBElementArray *) documentFiles;
- (SBElementArray *) internetLocationFiles;
- (SBElementArray *) clippings;
- (SBElementArray *) packages;


@end

// Trash-object is the class of the “trash” object
@interface FinderTrashObject : FinderContainer

- (SBElementArray *) items;
- (SBElementArray *) containers;
- (SBElementArray *) folders;
- (SBElementArray *) files;
- (SBElementArray *) aliasFiles;
- (SBElementArray *) applicationFiles;
- (SBElementArray *) documentFiles;
- (SBElementArray *) internetLocationFiles;
- (SBElementArray *) clippings;
- (SBElementArray *) packages;

@property BOOL warnsBeforeEmptying;  // Display a dialog when emptying the trash?


@end



/*
 * Files
 */

// A file
@interface FinderFile : FinderItem

@property (copy) NSNumber *fileType;  // the OSType identifying the type of data contained in the item
@property (copy) NSNumber *creatorType;  // the OSType identifying the application that created the item
@property BOOL stationery;  // Is the file a stationery pad?
@property (copy, readonly) NSString *productVersion;  // the version of the product (visible at the top of the “Get Info” window)
@property (copy, readonly) NSString *version;  // the version of the file (visible at the bottom of the “Get Info” window)


@end

// An alias file (created with “Make Alias”)
@interface FinderAliasFile : FinderFile

@property (copy) SBObject *originalItem;  // the original item pointed to by the alias


@end

// An application's file on disk
@interface FinderApplicationFile : FinderFile

- (NSString *) id;  // the bundle identifier or creator type of the application
@property (readonly) NSInteger suggestedSize;  // (AVAILABLE IN 10.1 TO 10.4) the memory size with which the developer recommends the application be launched
@property NSInteger minimumSize;  // (AVAILABLE IN 10.1 TO 10.4) the smallest memory size with which the application can be launched
@property NSInteger preferredSize;  // (AVAILABLE IN 10.1 TO 10.4) the memory size with which the application will be launched
@property (readonly) BOOL acceptsHighLevelEvents;  // Is the application high-level event aware? (OBSOLETE: always returns true)
@property (readonly) BOOL hasScriptingTerminology;  // Does the process have a scripting terminology, i.e., can it be scripted?
@property BOOL opensInClassic;  // (AVAILABLE IN 10.1 TO 10.4) Should the application launch in the Classic environment?


@end

// A document file
@interface FinderDocumentFile : FinderFile


@end

// A file containing an internet location
@interface FinderInternetLocationFile : FinderFile

@property (copy, readonly) NSString *location;  // the internet location


@end

// A clipping
@interface FinderClipping : FinderFile

@property (copy, readonly) SBObject *clippingWindow;  // (NOT AVAILABLE YET) the clipping window for this clipping


@end

// A package
@interface FinderPackage : FinderItem


@end



/*
 * Window classes
 */

// A window
@interface FinderWindow : SBObject

- (id) id;  // the unique id for this window
@property NSPoint position;  // the upper left position of the window
@property NSRect bounds;  // the boundary rectangle for the window
@property (readonly) BOOL titled;  // Does the window have a title bar?
@property (copy, readonly) NSString *name;  // the name of the window
@property NSInteger index;  // the number of the window in the front-to-back layer ordering
@property (readonly) BOOL closeable;  // Does the window have a close box?
@property (readonly) BOOL floating;  // Does the window have a title bar?
@property (readonly) BOOL modal;  // Is the window modal?
@property (readonly) BOOL resizable;  // Is the window resizable?
@property (readonly) BOOL zoomable;  // Is the window zoomable?
@property BOOL zoomed;  // Is the window zoomed?
@property (readonly) BOOL visible;  // Is the window visible (always true for open Finder windows)?
@property BOOL collapsed;  // Is the window collapsed
@property (copy) NSDictionary *properties;  // every property of a window

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// A file viewer window
@interface FinderFinderWindow : FinderWindow

@property (copy) SBObject *target;  // the container at which this file viewer is targeted
@property FinderEcvw currentView;  // the current view for the container window
@property (copy, readonly) FinderIconViewOptions *iconViewOptions;  // the icon view options for the container window
@property (copy, readonly) FinderListViewOptions *listViewOptions;  // the list view options for the container window
@property (copy, readonly) FinderColumnViewOptions *columnViewOptions;  // the column view options for the container window
@property BOOL toolbarVisible;  // Is the window's toolbar visible?
@property BOOL statusbarVisible;  // Is the window's status bar visible?
@property NSInteger sidebarWidth;  // the width of the sidebar for the container window


@end

// the desktop window
@interface FinderDesktopWindow : FinderFinderWindow


@end

// An inspector window (opened by “Show Info”)
@interface FinderInformationWindow : FinderWindow

@property (copy, readonly) SBObject *item;  // the item from which this window was opened
@property FinderIpnl currentPanel;  // the current panel in the information window


@end

// The Finder Preferences window
@interface FinderPreferencesWindow : FinderWindow

@property FinderPple currentPanel;  // The current panel in the Finder preferences window


@end

// The window containing a clipping
@interface FinderClippingWindow : FinderWindow


@end



/*
 * Legacy suite
 */

// The Finder
@interface FinderApplication (LegacySuite)

@property (copy) FinderFile *desktopPicture;  // the desktop picture of the main monitor

@end

// A process running on this computer
@interface FinderProcess : SBObject

@property (copy, readonly) NSString *name;  // the name of the process
@property BOOL visible;  // Is the process' layer visible?
@property BOOL frontmost;  // Is the process the frontmost process?
@property (copy, readonly) SBObject *file;  // the file from which the process was launched
@property (copy, readonly) NSNumber *fileType;  // the OSType of the file type of the process
@property (copy, readonly) NSNumber *creatorType;  // the OSType of the creator of the process (the signature)
@property (readonly) BOOL acceptsHighLevelEvents;  // Is the process high-level event aware (accepts open application, open document, print document, and quit)?
@property (readonly) BOOL acceptsRemoteEvents;  // Does the process accept remote events?
@property (readonly) BOOL hasScriptingTerminology;  // Does the process have a scripting terminology, i.e., can it be scripted?
@property (readonly) NSInteger totalPartitionSize;  // the size of the partition with which the process was launched
@property (readonly) NSInteger partitionSpaceUsed;  // the number of bytes currently used in the process' partition

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// A process launched from an application file
@interface FinderApplicationProcess : FinderProcess

@property (copy, readonly) FinderApplicationFile *applicationFile;  // the application file from which this process was launched


@end

// A process launched from a desk accessory file
@interface FinderDeskAccessoryProcess : FinderProcess

@property (copy, readonly) SBObject *deskAccessoryFile;  // the desk accessory file from which this process was launched


@end



/*
 * Type Definitions
 */

// The Finder Preferences
@interface FinderPreferences : SBObject

@property (copy, readonly) FinderPreferencesWindow *window;  // the window that would open if Finder preferences was opened
@property (copy, readonly) FinderIconViewOptions *iconViewOptions;  // the default icon view options
@property (copy, readonly) FinderListViewOptions *listViewOptions;  // the default list view options
@property (copy, readonly) FinderColumnViewOptions *columnViewOptions;  // the column view options for all windows
@property BOOL foldersSpringOpen;  // Spring open folders after the specified delay?
@property double delayBeforeSpringing;  // the delay before springing open a container in seconds (from 0.167 to 1.169)
@property BOOL desktopShowsHardDisks;  // Hard disks appear on the desktop?
@property BOOL desktopShowsExternalHardDisks;  // External hard disks appear on the desktop?
@property BOOL desktopShowsRemovableMedia;  // CDs, DVDs, and iPods appear on the desktop?
@property BOOL desktopShowsConnectedServers;  // Connected servers appear on the desktop?
@property (copy) SBObject *newWindowTarget;  // target location for a newly-opened Finder window
@property BOOL foldersOpenInNewWindows;  // Folders open into new windows?
@property BOOL foldersOpenInNewTabs;  // Folders open into new tabs?
@property BOOL newWindowsOpenInColumnView;  // Open new windows in column view?
@property BOOL allNameExtensionsShowing;  // Show name extensions, even for items whose “extension hidden” is true?

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// (NOT AVAILABLE YET) A Finder label (name and color)
@interface FinderLabel : SBObject

@property (copy) NSString *name;  // the name associated with the label
@property NSInteger index;  // the index in the front-to-back ordering within its container
@property (copy) id color;  // the color associated with the label

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// (NOT AVAILABLE YET) A family of icons
@interface FinderIconFamily : SBObject

@property (copy, readonly) id largeMonochromeIconAndMask;  // the large black-and-white icon and the mask for large icons
@property (copy, readonly) id large8BitMask;  // the large 8-bit mask for large 32-bit icons
@property (copy, readonly) id large32BitIcon;  // the large 32-bit color icon
@property (copy, readonly) id large8BitIcon;  // the large 8-bit color icon
@property (copy, readonly) id large4BitIcon;  // the large 4-bit color icon
@property (copy, readonly) id smallMonochromeIconAndMask;  // the small black-and-white icon and the mask for small icons
@property (copy, readonly) id small8BitMask;  // the small 8-bit mask for small 32-bit icons
@property (copy, readonly) id small32BitIcon;  // the small 32-bit color icon
@property (copy, readonly) id small8BitIcon;  // the small 8-bit color icon
@property (copy, readonly) id small4BitIcon;  // the small 4-bit color icon

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// the icon view options
@interface FinderIconViewOptions : SBObject

@property FinderEarr arrangement;  // the property by which to keep icons arranged
@property NSInteger iconSize;  // the size of icons displayed in the icon view
@property BOOL showsItemInfo;  // additional info about an item displayed in icon view
@property BOOL showsIconPreview;  // displays a preview of the item in icon view
@property NSInteger textSize;  // the size of the text displayed in the icon view
@property FinderEpos labelPosition;  // the location of the label in reference to the icon
@property (copy) FinderFile *backgroundPicture;  // the background picture of the icon view
@property (copy) id backgroundColor;  // the background color of the icon view

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// the column view options
@interface FinderColumnViewOptions : SBObject

@property NSInteger textSize;  // the size of the text displayed in the column view
@property BOOL showsIcon;  // displays an icon next to the label in column view
@property BOOL showsIconPreview;  // displays a preview of the item in column view
@property BOOL showsPreviewColumn;  // displays the preview column in column view
@property BOOL disclosesPreviewPane;  // discloses the preview pane of the preview column in column view

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// the list view options
@interface FinderListViewOptions : SBObject

- (SBElementArray *) columns;

@property BOOL calculatesFolderSizes;  // Are folder sizes calculated and displayed in the window?
@property BOOL showsIconPreview;  // displays a preview of the item in list view
@property FinderLvic iconSize;  // the size of icons displayed in the list view
@property NSInteger textSize;  // the size of the text displayed in the list view
@property (copy) FinderColumn *sortColumn;  // the column that the list view is sorted on
@property BOOL usesRelativeDates;  // Are relative dates (e.g., today, yesterday) shown in the list view?

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// a column of a list view
@interface FinderColumn : SBObject

@property NSInteger index;  // the index in the front-to-back ordering within its container
@property (readonly) FinderElsv name;  // the column name
@property FinderSodr sortDirection;  // The direction in which the window is sorted
@property NSInteger width;  // the width of this column
@property (readonly) NSInteger minimumWidth;  // the minimum allowed width of this column
@property (readonly) NSInteger maximumWidth;  // the maximum allowed width of this column
@property BOOL visible;  // is this column visible

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

// A list of aliases.  Use ‘as alias list’ when a list of aliases is needed (instead of a list of file system item references).
@interface FinderAliasList : SBObject

- (void) openUsing:(SBObject *)using_ withProperties:(NSDictionary *)withProperties;  // Open the specified object(s)
- (void) printWithProperties:(NSDictionary *)withProperties;  // Print the specified object(s)
- (void) activate;  // Activate the specified window (or the Finder)
- (void) close;  // Close an object
- (NSInteger) dataSizeAs:(NSNumber *)as;  // Return the size in bytes of an object
- (SBObject *) delete;  // Move an item from its container to the trash
- (SBObject *) duplicateTo:(SBObject *)to replacing:(BOOL)replacing routingSuppressed:(BOOL)routingSuppressed exactCopy:(BOOL)exactCopy;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (SBObject *) moveTo:(SBObject *)to replacing:(BOOL)replacing positionedAt:(NSArray *)positionedAt routingSuppressed:(BOOL)routingSuppressed;  // Move object(s) to a new location
- (void) select;  // Select the specified object(s)
- (SBObject *) sortBy:(SEL)by;  // Return the specified object(s) in a sorted list
- (void) cleanUpBy:(SEL)by;  // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
- (void) eject;  // Eject the specified disk(s)
- (void) emptySecurity:(BOOL)security;  // Empty the trash
- (void) erase;  // (NOT AVAILABLE) Erase the specified disk(s)
- (void) reveal;  // Bring the specified object(s) into view
- (void) updateNecessity:(BOOL)necessity registeringApplications:(BOOL)registeringApplications;  // Update the display of the specified object(s) to match their on-disk representation

@end

