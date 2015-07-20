//
//  NH3DTileCache.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/29.
//  Copyright 2005 Haruumi Yoshino.
//

//#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "config.h"
#import "global.h"
#import "NH3DUserDefaultsExtern.h"

@interface NH3DTileCache : NSObject {
	
	NSBitmapImageRep	*bitMap;
		
	int					tileSize_X;
	int					tileSize_Y;
}


- (id)initWithNamed:(NSString *)imageName; /* This is designated initializer. */

- (NSImage *)tileImageFromGlyph:(int)glyph;
- (int)tileSize_X;
- (int)tileSize_Y;

@end
