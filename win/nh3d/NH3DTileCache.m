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


- (id) init 
{
	return [self initWithNamed:TILE_FILE_NAME];
}


- (id) initWithNamed:(NSString *)imageName   /* This is designated initializer. */
{
	self = [super init];
	if (self != nil) {
		
		NSImage	*tileSource = [ [NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],imageName] ];
		NSData  *tiffData;
		
		if ( tileSource == nil ) {
			tileSource = [ [NSImage alloc] initWithContentsOfFile:imageName ];
			if ( tileSource == nil ) {
				NSRunCriticalAlertPanel(@"Tile Load Error!",
										[ NSString stringWithFormat:@"Can't find Tilefile: %@!!",imageName ],
										@"OK",nil,nil);
				NSLog(@"Can't find Tilefile: %@!!",imageName);
				return nil; 
			}
			
		}
		
		tiffData = [ tileSource TIFFRepresentation ];
		bitMap = [ [ NSBitmapImageRep alloc ]  initWithData : tiffData ];
		
		[ tileSource release ];
		//[ tiffData release ];
		
		if ( ([ bitMap pixelsWide ] % TILES_PER_LINE) && ([ bitMap pixelsHigh ] % NUMBER_OF_TILES_ROW) ) {
			NSRunCriticalAlertPanel(@"Tile Format Error!",
									[ NSString stringWithFormat:@"%@: Does not support this TILE Pattern.",imageName ],
									@"OK",nil,nil);
				NSLog( @"%@: Does not support this TILE Pattern.",imageName );
				return nil;
		} else {
			tileSize_X = [ bitMap pixelsWide ] / TILES_PER_LINE;
			tileSize_Y = [ bitMap pixelsHigh ] / NUMBER_OF_TILES_ROW;	
		}
		
	}
	return self;
}

	


- (void) dealloc {

	[ bitMap release ];
	[ super dealloc ];
}


- (NSImage *)tileImageFromGlyph:(int)glyph
{
	unsigned int p[tileSize_X*tileSize_Y];
	NSImage *tileImg = [ [[NSImage alloc] initWithSize:NSMakeSize(tileSize_X,tileSize_Y)] autorelease ];
	NSBitmapImageRep *bmpRep = [ [NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																		pixelsWide:tileSize_X
																		pixelsHigh:tileSize_Y
																	 bitsPerSample:[bitMap bitsPerSample]
																   samplesPerPixel:[bitMap samplesPerPixel]
																		  hasAlpha:[bitMap hasAlpha]
																		  isPlanar:[bitMap isPlanar]
																	colorSpaceName:NSDeviceRGBColorSpace
																	   bytesPerRow:[bitMap bytesPerRow]
																	  bitsPerPixel:[bitMap bitsPerPixel] ];
	
	int tile = glyph2tile[glyph];
	int x,y,t_x,t_y;
	
	if ( tile >= total_tiles_used || tile < 0 )
	{
		NSLog(@"ERROR:Asked for a TILE %d outside the allowed range.",tile);
		return nil;
	}
	
	t_x = ( tile % TILES_PER_LINE ) * tileSize_X;
	t_y = ( tile / TILES_PER_LINE ) * tileSize_Y;

	for ( x=0 ; x<=tileSize_X ; x++ ) {
		for ( y=0 ; y<=tileSize_Y ; y++ ) {
			
			[ bitMap getPixel:p atX:(t_x + x) y:(t_y + y) ];
			[ bmpRep setPixel:p atX:x y:y ];
		}
	}
	
	[ tileImg addRepresentation:bmpRep ];
	[ bmpRep release ];
	
	[ tileImg setCacheMode:NSImageCacheNever ];

	return tileImg;
	
}


- (int)tileSize_X
{
	return tileSize_X;
}
	

- (int)tileSize_Y
{
	return tileSize_Y;
}



@end
