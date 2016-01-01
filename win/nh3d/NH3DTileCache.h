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

- (nullable instancetype)init;
/// This is designated initializer
- (nullable instancetype)initWithNamed:(NSString *)imageName NS_DESIGNATED_INITIALIZER;

- (nullable NSImage *)tileImageFromGlyph:(int)glyph;
@property (readonly) int tileSize_X;
@property (readonly) int tileSize_Y;

@end

NS_ASSUME_NONNULL_END
