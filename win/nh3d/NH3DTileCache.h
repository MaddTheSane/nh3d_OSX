//
//  NH3DTileCache.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/29.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "config.h"
#import "global.h"
#import "NH3DUserDefaultsExtern.h"

NS_ASSUME_NONNULL_BEGIN

@interface NH3DTileCache : NSObject {
@private
	NSBitmapImageRep	*bitMap;
		
	int					tileSize_X;
	int					tileSize_Y;
}

/// Creates a tile cache of the default one specified by preferences.
- (nullable instancetype)init;
/// Creates a tile cache from a file path or an image in the app bundle.
- (nullable instancetype)initWithNamed:(NSString *)imageName NS_DESIGNATED_INITIALIZER;

/// Returns a tile image for the specified glyph
- (nullable NSImage *)tileImageFromGlyph:(int)glyph;
/// The width, in pixels, of a tile in the current tile set
@property (readonly) int tileSize_X;
/// The height, in pixels, of a tile in the current tile set
@property (readonly) int tileSize_Y;

@end

NS_ASSUME_NONNULL_END
