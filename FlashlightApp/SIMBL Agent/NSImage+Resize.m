//
//  NSImage+Resize.m
//  SIMBL
//
//  Created by Nate Parrott on 4/1/15.
//
//

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

#pragma mark Helpers

- (NSImage*) resizeImageToSize:(NSSize)size
{
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    
    [self drawInRect:targetFrame
                   fromRect:NSZeroRect       //portion of source image to draw
                  operation:NSCompositeCopy  //compositing operation
                   fraction:1.0              //alpha (transparency) value
             respectFlipped:YES              //coordinate system
                      hints:@{NSImageHintInterpolation:
                                  [NSNumber numberWithInt:NSImageInterpolationHigh]}];
    
    [targetImage unlockFocus];
    
    return targetImage;
}

- (NSImage *)resizeImageWithMaxDimension:(NSSize)size {
    CGFloat scale = MIN(size.width * 1.0 / self.size.width, size.height * 1.0 / self.size.height);
    return [self resizeImageToSize:NSMakeSize(self.size.width * scale, self.size.height * scale)];
}

@end
