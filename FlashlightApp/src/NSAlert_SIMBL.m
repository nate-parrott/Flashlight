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

#import "NSAlert_SIMBL.h"

@implementation NSAlert (SIMBLAlert)

+ (void) errorAlert:(NSString*)_message withDetails:(NSString*)_details, ...
{
	va_list ap;
	va_start(ap, _details);
    
	NSString* detailsFormatted = [[NSString alloc] initWithFormat:_details arguments:ap];
	va_end(ap);
    
	NSBeginAlertSheet(
                      _message,         // sheet message
                      nil,              // default button label
                      nil,              // alternate button label
                      nil,              // no third button
                      nil,              // window sheet is attached to fixme: should i attach to the front-most window
                      nil,              // we don't need a delegate
                      nil,              // did-end selector
                      nil,              // no need for did-dismiss selector
                      nil,              // context info
                      detailsFormatted,	// additional text
                      nil);             // no parameters in message
#if !__has_feature(objc_arc)
    [detailsFormatted release];
#endif
}

@end
