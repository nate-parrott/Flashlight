/**
 * Copyright 2003-2009, Mike Solomon <mas63@cornell.edu>
 * SIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */
/**
 * Copyright 2012, Norio Nomura
 * EasySIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

@interface SIMBLAgent : NSObject<SBApplicationDelegate> {
}

@property (assign,atomic) NSUInteger waitingInjectionNumber;
@property (nonatomic) NSString *scriptingAdditionsPath;
@property (nonatomic) NSString *osaxPath;
@property (nonatomic) NSString *linkedOsaxPath;
@property (nonatomic) NSString *applicationSupportPath;
@property (nonatomic) NSString *plistPath;
@property (atomic) NSMutableArray *runningSandboxedApplications;

@end
