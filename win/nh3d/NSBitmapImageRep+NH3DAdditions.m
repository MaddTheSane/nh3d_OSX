//
//  NSBitmapImageRep+NH3DAdditions.m
//  NetHack3D
//
//  Created by C.W. Betts on 11/21/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

#import "NSBitmapImageRep+NH3DAdditions.h"

@implementation NSBitmapImageRep (NH3DAdditions)

- (NSBitmapImageRep*)forceRGBColorSpace
{
	if (self.colorSpace.colorSpaceModel != NSColorSpaceModelRGB) {
		NSBitmapImageRep *imgRep2 = [self bitmapImageRepByConvertingToColorSpace:NSColorSpace.sRGBColorSpace renderingIntent:NSColorRenderingIntentDefault];
		if (__builtin_expect(imgRep2 != nil, 1)) {
			return imgRep2;
		}
		NSInteger widePix = self.pixelsWide;
		imgRep2 = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:widePix pixelsHigh:self.pixelsHigh bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:4 * widePix bitsPerPixel:32];
		
		NSGraphicsContext *img2Ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:imgRep2];
		NSGraphicsContext *currentCtx = [NSGraphicsContext currentContext];
		[NSGraphicsContext setCurrentContext:img2Ctx];
		
		[self drawAtPoint:NSZeroPoint];
		
		[NSGraphicsContext setCurrentContext:currentCtx];
		return imgRep2;
	}

	return self;
}

@end
