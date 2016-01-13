//
//  NH3DTileCache.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/29.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DTileCache.h"

/* from tile.c */
extern short glyph2tile[];
extern int total_tiles_used;


@implementation NH3DTileCache
@synthesize tileSize_X;
@synthesize tileSize_Y;


- (instancetype) init 
{
	return [self initWithNamed:TILE_FILE_NAME];
}

- (instancetype) initWithNamed:(NSString *)imageName   /* This is designated initializer. */
{
	if (self = [super init]) {
		NSImage	*tileSource = [NSImage imageNamed:imageName];
		if (tileSource == nil) {
			tileSource = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:imageName]];
		}
		NSData  *tiffData;
		
		if ( tileSource == nil ) {
			tileSource = [[NSImage alloc] initWithContentsOfFile:imageName];
			if ( tileSource == nil ) {
				NSRunCriticalAlertPanel(@"Tile Load Error!",
										@"Can't find Tilefile: %@!!",
										@"OK",nil,nil, imageName);
				NSLog(@"Can't find Tilefile: %@!!",imageName);
				return nil; 
			}
		}
		
		tiffData = tileSource.TIFFRepresentation;
		bitMap = [[NSBitmapImageRep alloc] initWithData: tiffData];
		
		if ((bitMap.pixelsWide % TILES_PER_LINE) && (bitMap.pixelsHigh % NUMBER_OF_TILES_ROW)) {
			NSRunCriticalAlertPanel(@"Tile Format Error!",
									@"%@: Does not support this TILE Pattern.",
									@"OK",nil,nil, imageName);
				NSLog(@"%@: Does not support this TILE Pattern.", imageName);
				return nil;
		} else {
			tileSize_X = bitMap.pixelsWide / TILES_PER_LINE;
			tileSize_Y = bitMap.pixelsHigh / NUMBER_OF_TILES_ROW;	
		}
		
	}
	return self;
}

#define GET_RAW_PIXELS 1
- (NSImage *)tileImageFromGlyph:(int)glyph
{
	NSImage *tileImg = [[NSImage alloc] initWithSize:NSMakeSize(tileSize_X,tileSize_Y)];
#if GET_RAW_PIXELS
	NSUInteger p[10];
	NSBitmapImageRep *bmpRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																	   pixelsWide:tileSize_X
																	   pixelsHigh:tileSize_Y
																	bitsPerSample:bitMap.bitsPerSample
																  samplesPerPixel:bitMap.samplesPerPixel
																		 hasAlpha:bitMap.alpha
																		 isPlanar:bitMap.planar
																   colorSpaceName:NSDeviceRGBColorSpace
																	  bytesPerRow:bitMap.bytesPerRow
																	 bitsPerPixel:bitMap.bitsPerPixel];
#endif
	
#if GET_RAW_PIXELS
	int x,y;
#endif
	int tile = glyph2tile[glyph];
	int t_x,t_y;
	
	if (tile >= total_tiles_used || tile < 0) {
		NSLog(@"ERROR:Asked for a TILE %d outside the allowed range.",tile);
		return nil;
	}
	
	t_x = ( tile % TILES_PER_LINE ) * tileSize_X;
	t_y = ( tile / TILES_PER_LINE ) * tileSize_Y;

#if GET_RAW_PIXELS
	for (x = 0; x <= tileSize_X; x++) {
		for (y = 0; y <= tileSize_Y; y++) {
			[bitMap getPixel:p atX:(t_x + x) y:(t_y + y)];
			[bmpRep setPixel:p atX:x y:y];
		}
	}
#else
	[tileImg lockFocusFlipped:NO];
	[bitMap drawInRect:NSMakeRect(0, 0, tileSize_X, tileSize_Y) fromRect:NSMakeRect(t_x, t_y, tileSize_X, tileSize_Y) operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
	[tileImg unlockFocus];
#endif
	
#if GET_RAW_PIXELS
	[tileImg addRepresentation:bmpRep];
#endif
	tileImg.cacheMode = NSImageCacheNever;
	return tileImg;
}

@end
