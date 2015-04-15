//
//  NSImage+Resize.h
//  SIMBL
//
//  Created by Nate Parrott on 4/1/15.
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Resize)

- (NSImage*) resizeImageToSize:(NSSize)size;
- (NSImage *)resizeImageWithMaxDimension:(NSSize)size;

@end
