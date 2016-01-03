/* NH3DMapView */
//
//  NH3DMapView.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DMapView.h"

#import "winnh3d.h"
#import "NetHack3D-Swift.h"

//for key codes
#include <Carbon/Carbon.h>

#ifndef M
# ifndef NHSTDC
#  define M(c)          (0x80 | (c))
# else
#  define M(c)          ((c) - 128)
# endif /* NHSTDC */
#endif
#ifndef C
#define C(c)            (0x1f & (c))
#endif

#define MODKEY_NONE 0
#define MODKEY_SHIFT 1
#define MODKEY_CTRL 2
#define MODKEY_COMMAND 3

@interface NH3DMapView ()
@property (strong) NSImage *mapBezel;
@property (strong) NSImage *mapBase;
@property (strong) NSImage *trMapImage;
@property (strong) NSImage *posCursor;
@property (strong) NSImage *mapRestrictedBezel;
@property int centerX;
@property int centerY;
@end

@implementation NH3DMapView
@synthesize posCursor;
@synthesize mapBezel;
@synthesize mapBase;
@synthesize trMapImage;
@synthesize mapRestrictedBezel;
@synthesize keyBuffer;
@synthesize extendKey;
@synthesize keyUpdated;
@synthesize getCharMode;
@synthesize isReady;
@synthesize needClear;
@synthesize clickType;
@synthesize cursorOpacity = cursOpacity;
@synthesize centerX;
@synthesize centerY;

- (instancetype)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		self.bgColor = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0];
			
		isReady = NO;
		enemyCatch = 0;
		
		viewCursX = 0;
		viewCursY = 0;
										
		self.posCursor = [NSImage imageNamed:@"nh3dPosCursor"];
		self.mapRestrictedBezel = [NSImage imageNamed:@"asciiMapMaskLimited"];

		cursOpacity = 1.0;
		keyBuffer = '0';
		extendKey = -1 ;
		modKeyFlag = MODKEY_NONE;
//		cursPos = NSZeroPoint;
		plDepth = 0;
		
		lock = [[NSRecursiveLock alloc] init];
		
		//NSLog(@"%f,%f,%f,%f",frameRect.origin.x,frameRect.origin.y,frameRect.size.width,frameRect.size.height);
		
		if (TRADITIONAL_MAP) {
			self.frame = NSMakeRect(183.0, 222.0, 440.0, 320.0);
			self.mapBezel = nil;
			self.mapBase = [NSImage imageNamed:@"trBase"];
			self.trMapImage = nil;
		} else {
			self.mapBezel = [NSImage imageNamed:@"asciiMapMask"];
			self.mapBase = [NSImage imageNamed:@"asciiMapBase"];
			self.trMapImage = nil;
		}

	}
	
	return self;
}


- (void)awakeFromNib
{
	[super awakeFromNib];
	NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
	[nCenter addObserver:self
				selector:@selector(defaultDidChange:)
					name:@"NSUserDefaultsDidChangeNotification"
				  object:nil];
}


- (void)defaultDidChange:(NSNotification *)notification
{
	if (TRADITIONAL_MAP) {
		if (isReady) {
			[ self lockFocusIfCanDraw ];
			NSEraseRect( self.bounds );
			[ [NSColor windowBackgroundColor] set ];
			[ NSBezierPath fillRect:self.bounds ];
			[ self unlockFocus ];
		}
		
		self.frame = NSMakeRect(183.0, 222.0, 440.0, 320.0) ;
		
		self.mapBezel = nil;
		self.mapBase = [NSImage imageNamed:@"trBase"];
		
		[ self makeTraditionalMap ];
		
		[ self updateMap ];
		[ self setNeedsDisplay:YES ];
		[ [_bindController mainWindow] displayIfNeeded ];
		
	} else if ( !TRADITIONAL_MAP ) {
		if (isReady) {
			[ self lockFocusIfCanDraw ];
			NSEraseRect( self.bounds );
			[ [NSColor windowBackgroundColor] set ];
			[ NSBezierPath fillRect:self.bounds ];
			[ self unlockFocus ];
		}
		
		self.frame = NSMakeRect(4.0, 366.0, 176.0, 176.0);
		
		self.mapBezel = [ NSImage imageNamed:@"asciiMapMask"];
		self.mapBase = [ NSImage imageNamed:@"asciiMapBase"];
		
		self.trMapImage = nil;
		
		[ self updateMap ];
		[ self setNeedsDisplay:YES ];
		[[_bindController mainWindow] displayIfNeeded];
	}
}

- (void) dealloc {
	int x,y;
	
	for ( x=0 ; x<MAPVIEWSIZE_COLUMN ; x++ ) {
		for ( y=0 ; y<MAPVIEWSIZE_ROW ; y++ ) {
			mapItemValue[x][y] = nil;
		}
	}
}


- (void)drawRect:(NSRect)rect
{
	NSRect bounds = self.bounds;
	
	[mapBase drawInRect:bounds
			   fromRect:NSZeroRect
			  operation:NSCompositeSourceOver
			   fraction:1.0 ];
	
	if (isReady) {
		if (TRADITIONAL_MAP)
			[self updateMap];
		else
			[self reloadMap];
	}
	
	[self drawMask];
}

@synthesize bgColor;
- (void)setBgColor:(NSColor *)colr
{
	bgColor = [colr copy];
	[self setNeedsDisplay:YES];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self setNeedsDisplay:YES];
	return YES;
}

- (BOOL)becomeFirstResponder
{
	[self setNeedsDisplay:YES];
	return YES;
}


 - (void)resetCursorRects
{
	NSRect rect = self.bounds ;
	NSCursor* cursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"nh3dCursor"]
											   hotSpot:NSMakePoint(7, 7)];
	[self addCursorRect:rect cursor:cursor];
}

- (void)setCenterAtX:(int)x y:(int)y depth:(int)depth
{
	if (depth != plDepth && (TRADITIONAL_MAP || trMapImage != nil))
		[self makeTraditionalMap];
	plDepth = depth;
	centerX = x;
	centerY = y;
	isReady = YES;
}

- (void)makeTraditionalMap
{
	int x,y;

	if ( TRADITIONAL_MAP_TILE ) {
		self.trMapImage = [ [NSImage alloc] initWithSize:NSMakeSize( TILE_SIZE_X*MAPSIZE_COLUMN,
																TILE_SIZE_Y*MAPSIZE_ROW) ];
	} else {
		self.trMapImage = [ [NSImage alloc] initWithSize:NSMakeSize( NH3DMAPFONTSIZE*MAPSIZE_COLUMN,
																NH3DMAPFONTSIZE*MAPSIZE_ROW) ];
	}
	
	for ( x = MAP_MARGIN ; x < MAPSIZE_COLUMN-MAP_MARGIN ; x++ ) {
		for ( y = MAP_MARGIN ; y < MAPSIZE_ROW-MAP_MARGIN ; y++ ) {
			
			[ self drawTraditionalMapAtX:x atY:y ];
			
		}
	}
}


- (void)drawTraditionalMapAtX:(int)x atY:(int)y
{
	
	NSRect bounds = NSMakeRect( 0, 0, trMapImage.size .width, trMapImage.size .height);
	NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
	
	if ( TRADITIONAL_MAP_TILE && mapItem != nil ) {
		NSImage *tileImg = mapItem.tile ;
		NSSize tileSize = tileImg.size ;
		
		if ( tileImg != nil ) {
			[ trMapImage lockFocus ];
			
			[ [NSColor clearColor] set ];
			NSRectFill( NSMakeRect( bounds.origin.x+(x*TILE_SIZE_X),
									(NSMaxY(bounds)-(y*TILE_SIZE_Y)),
									(float)TILE_SIZE_X , (float)TILE_SIZE_Y ) );
			
			[ tileImg drawInRect:NSMakeRect( bounds.origin.x+(x*TILE_SIZE_X),
											 (NSMaxY(bounds)-(y*TILE_SIZE_Y)),
											 (float)TILE_SIZE_X , (float)TILE_SIZE_Y )
						fromRect:NSMakeRect( 0,0,
											 tileSize.width , tileSize.height )
					   operation:NSCompositeSourceOver
						fraction:1.0 ];
										
			[ trMapImage unlockFocus ];
		}
		
	} else if ( mapItem != nil ) {
		NSMutableDictionary *attributes = [ [NSMutableDictionary alloc] init ];
		float fontsize = NH3DMAPFONTSIZE;
		float drawMargin = fontsize/4;
		
		if ( [ [mapItem symbol] isEqualToString:@"-" ] && mapItem.hasAlternateSymbol ) {
			mapItem.cSymbol = '|';
			mapItem.hasAlternateSymbol = NO;
		} else if ( [ [mapItem symbol] isEqualToString:@"|" ] && mapItem.hasAlternateSymbol ) {
			mapItem.cSymbol = '-';
			mapItem.hasAlternateSymbol = NO;
		}
		
		attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: fontsize];
		
		attributes[NSForegroundColorAttributeName] = [ mapItem color ];
		

		
		if ( fontsize > 12.0 ) {
			//set shadow 
			NSShadow *lshadow = [ [NSShadow alloc] init ];
			
			lshadow.shadowOffset = NSMakeSize(0.8, 1.8) ;
			lshadow.shadowBlurRadius = drawMargin ;
			
			if ( [ mapItem special ] > 0 ) lshadow.shadowColor = [ mapItem color ] ;
			else lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0] ;
			
			attributes[NSShadowAttributeName] = lshadow;
		}
		
		
		[ trMapImage lockFocus ];
		
		[ [NSColor clearColor] set ];
		NSRectFill( NSMakeRect( bounds.origin.x+(x*fontsize),
								(NSMaxY(bounds)-(y*fontsize)),
								fontsize+drawMargin , fontsize+drawMargin) );
		
		[ [mapItem symbol] drawInRect:NSMakeRect( bounds.origin.x+drawMargin+(x*fontsize),
												  (NSMaxY(bounds)+drawMargin-(y*fontsize)),
												  fontsize , fontsize )
					   withAttributes:attributes ];
		
						
		[ trMapImage unlockFocus ];
		
		
	}
	
	[_mapModel mapArrayAtX:x atY:y];
}

- (void)updateMap
{
	if ( !isReady ) {
		return;
	} else {
		//Get MapItems(Tiles,Symbol,glyph,etc...) with direction.
		 
		int x,y;
		int localx = 0;
		int localy = 0;
		
		if ( TRADITIONAL_MAP ) {
			
			float trCenterX,trCenterY,tsizeX,tsizeY,trColumn,trRow,trcpX,trcpY;
			NSRect bounds = self.bounds ;
			
			if ( needClear ) {
				[ self lockFocusIfCanDraw ];
				NSEraseRect( bounds );
				[ mapBase drawInRect:bounds
							fromRect:NSZeroRect
						   operation:NSCompositeCopy
							fraction:1.0 ];
				[ self unlockFocus ];
				needClear = NO;
			}
			
			tsizeX = ( TRADITIONAL_MAP_TILE ) ? TILE_SIZE_X : NH3DMAPFONTSIZE;
			tsizeY = ( TRADITIONAL_MAP_TILE ) ? TILE_SIZE_Y : NH3DMAPFONTSIZE;
			

				trColumn = bounds.size.width / 2;
				trRow = bounds.size.height / 2;
				trCenterX = (centerX * tsizeX) - trColumn;
				trCenterY = trMapImage.size .height - ( centerY * tsizeY) - trRow;
				trcpX = (centerX - _mapModel.cursX - MAP_MARGIN) * -1 ;
				trcpY = (centerY - _mapModel.cursY - MAP_MARGIN) * -1 ;
				
			[self lockFocusIfCanDraw];
			{
				[trMapImage drawAtPoint:bounds.origin
							   fromRect:NSMakeRect(trCenterX,
												   trCenterY,
												   bounds.size.width, bounds.size.height)
							  operation:NSCompositeSourceOver
							   fraction:1.0];

				/*
				[ trMapImage compositeToPoint:bounds.origin
									 fromRect:NSMakeRect(  trCenterX,
														   trCenterY,
														   bounds.size.width, bounds.size.height )
									operation:NSCompositeSourceOver ];*/
				
				[posCursor drawInRect:NSMakeRect(bounds.origin.x + ((trcpX * tsizeX) + trColumn) ,
												 NSMaxY(bounds) - ((trcpY * tsizeY) + trRow) ,
												 tsizeX , tsizeY)
							 fromRect:NSMakeRect(0, 0, 16.0, 16.0)
							operation:NSCompositeSourceOver
							 fraction:cursOpacity];
			}
			[ self unlockFocus ];
		} else {
			switch ( _mapModel.playerDirection ) {
				case PL_DIRECTION_FORWARD:
					for ( x = centerX-MAP_MARGIN ; x < centerX+1+MAP_MARGIN ; x++ ) {
						for ( y = centerY-MAP_MARGIN ; y < centerY+1+MAP_MARGIN ; y++ ) {
							[ lock lock ];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localx][localy] = mapItem;
							[ lock unlock ];
							[ self drawAsciiItemAtX:localx atY:localy ];
							localy++;
						}
						localx++;
						localy=0;
					}
					[ self drawMask ];
					[ self enemyCheck ];
					break;
				case PL_DIRECTION_RIGHT:
					for ( x = centerX+MAP_MARGIN ; x > centerX-1-MAP_MARGIN ; x-- ) {
						for ( y = centerY-MAP_MARGIN ; y < centerY+1+MAP_MARGIN ; y++ ) {
							[ lock lock ];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localy][localx] = mapItem;
							[ lock unlock ];
							[ self drawAsciiItemAtX:localy atY:localx ];
							localy++;
						}
						localx++;
						localy=0;
					}
					[ self drawMask ];
					[ self enemyCheck ];
					break;
				case PL_DIRECTION_BACK:
					for ( x = centerX+MAP_MARGIN ; x > centerX-1-MAP_MARGIN ; x-- ) {
						for ( y = centerY+MAP_MARGIN ; y > centerY-1-MAP_MARGIN ; y-- ) {
							[ lock lock ];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localx][localy] = mapItem;
							[ lock unlock ];
							[ self drawAsciiItemAtX:localx atY:localy ];
							localy++;
						}
						localx++;
						localy=0;
					}
					[ self drawMask ];
					[ self enemyCheck ];
					break;
				case PL_DIRECTION_LEFT:
					for ( x = centerX-MAP_MARGIN ; x < centerX+1+MAP_MARGIN ; x++) {
						for ( y = centerY+MAP_MARGIN ; y > centerY-1-MAP_MARGIN ; y--) {
							[ lock lock ];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localy][localx] = mapItem;
							[ lock unlock ];
							[ self drawAsciiItemAtX:localy atY:localx ];
							localy++;
						}
						localx++;
						localy=0;
					}
					[ self drawMask ];
					[ self enemyCheck ];
					break;
			}
		}
	}
}

- (void)drawAsciiItemAtX:(int)x atY:(int)y
{
	@autoreleasepool {
		NSRect bounds = self.bounds ;
		NSShadow *lshadow = [ [NSShadow alloc] init ];
		NSMutableDictionary *attributes = [ [NSMutableDictionary alloc] init ];
			
		lshadow.shadowOffset = NSMakeSize(0.8, 1.8) ;
		lshadow.shadowBlurRadius = 3.5 ;
		
		attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: 16];
			 
		//setColor and shadow for special-flag
		attributes[NSForegroundColorAttributeName] = [[mapItemValue[x][y] color]  highlightWithLevel:0.2];
		
		if ( [ mapItemValue[x][y] special ] > 0 ) {
			lshadow.shadowColor = [ mapItemValue[x][y] color ] ;
		} else {
			lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0] ;
		}
		
		attributes[NSShadowAttributeName] = lshadow;
		

		// Replace Wall/OpenDoor charctor for Right,Left direction
		switch ( _mapModel.playerDirection ) {
			case PL_DIRECTION_RIGHT:
			case PL_DIRECTION_LEFT:
				if ( ! mapItemValue[x][y].hasAlternateSymbol ) {
					switch ( [ mapItemValue[x][y] glyph ] ) {
						case S_vwall+GLYPH_CMAP_OFF:			/* vwall */
						case S_tlwall+GLYPH_CMAP_OFF:			/* tlwall */
						case S_trwall+GLYPH_CMAP_OFF:			/* trwall */
						case S_hodoor+GLYPH_CMAP_OFF:			/* hodoor */
						case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM:			/* vbeam */
						case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM:
						case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM:
						case NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_VBEAM:
						case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM:
						case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM:
						case NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_VBEAM:
						case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM:
							(mapItemValue[x][y]).cSymbol = '-';
							[ mapItemValue[x][y] setHasAlternateSymbol:YES ];
							break;
						case S_hwall+GLYPH_CMAP_OFF:			/* hwall */
						case S_tlcorn+GLYPH_CMAP_OFF:			/* tlcorn */
						case S_trcorn+GLYPH_CMAP_OFF:			/* trcorn */
						case S_blcorn+GLYPH_CMAP_OFF:			/* blcorn */
						case S_brcorn+GLYPH_CMAP_OFF:			/* brcorn */
						case S_crwall+GLYPH_CMAP_OFF:			/* crwall */
						case S_tuwall+GLYPH_CMAP_OFF:			/* tuwall */
						case S_tdwall+GLYPH_CMAP_OFF:			/* tdwall */
						case S_vodoor+GLYPH_CMAP_OFF:			/* vodoor */
						case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM:			/* hbeam */
						case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM:
						case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM:
						case NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_HBEAM:
						case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM:
						case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM:
						case NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_HBEAM:
						case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM:
							(mapItemValue[x][y]).cSymbol = '|';
							[ mapItemValue[x][y] setHasAlternateSymbol:YES ];
							break;
					}
				}
				break;
			default:
				if ( [ [mapItemValue[x][y] symbol] isEqualToString:@"-" ] && mapItemValue[x][y].hasAlternateSymbol ) {
						(mapItemValue[x][y]).cSymbol = '|';
						[ mapItemValue[x][y] setHasAlternateSymbol:NO ];
					} else if ( [ [mapItemValue[x][y] symbol] isEqualToString:@"|" ] && mapItemValue[x][y].hasAlternateSymbol ) {
						(mapItemValue[x][y]).cSymbol = '-';
						[ mapItemValue[x][y] setHasAlternateSymbol:NO ];
					}

				break;
		}

		//Draw view
		[ self lockFocusIfCanDraw ];
		
		if ( needClear ) {
			NSEraseRect( bounds );
			//[ mapBase dissolveToPoint:NSMakePoint(bounds.origin.x,bounds.origin.y) fraction:1.0 ];
			[ mapBase drawInRect:bounds
						fromRect:NSZeroRect
					   operation:NSCompositeSourceOver
						fraction:1.0 ];
			needClear = NO;
		}
		
		[ [mapItemValue[x][y] symbol] drawWithRect:NSMakeRect(bounds.origin.x+(x*16.0),
															  (NSMaxY(bounds)-((y+1)*16.0)),
															   16.0,16.0)
										   options:NSStringDrawingUsesDeviceMetrics
										attributes:attributes ];
		
		if (mapItemValue[x][y].hasCursor) {
			[posCursor drawAtPoint:NSMakePoint((bounds.origin.x+(x*16.0))-3.0,((NSMaxY(bounds)-((y+1)*16.0)))-3.0)
						  fromRect:NSZeroRect
						 operation:NSCompositeSourceOver
						  fraction:cursOpacity];

			/*
			[ posCursor dissolveToPoint:NSMakePoint((bounds.origin.x+(x*16.0))-3.0,((NSMaxY(bounds)-((y+1)*16.0)))-3.0)
							   fraction:cursOpacity ];*/
			viewCursX = x;
			viewCursY = MAPVIEWSIZE_ROW-y-1;
		}
			
		[ self unlockFocus ];
	
	
	}
}

- (void)reloadMap
{
	if (TRADITIONAL_MAP)
		return;
	
	NSRect bounds = self.bounds ;
	NSShadow *lshadow = [ [NSShadow alloc] init ];
	NSMutableDictionary *attributes = [ [NSMutableDictionary alloc] init ];
	int x,y;
	
	lshadow.shadowOffset = NSMakeSize(0.8, 1.8) ;
	lshadow.shadowBlurRadius = 3.5 ;
	
	attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: 16];
	
	//Draw view
	[ self lockFocusIfCanDraw ];
	
	if ( needClear ) {
		NSEraseRect(bounds);
		//[ mapBase dissolveToPoint:NSMakePoint(bounds.origin.x,bounds.origin.y) fraction:1.0 ];
		[ mapBase drawInRect:bounds
					fromRect:NSZeroRect
				   operation:NSCompositeSourceOver
					fraction:1.0 ];
		needClear = NO;
	}
				
	for ( x=0 ; x<MAPVIEWSIZE_COLUMN-1 ; x++ ) {
		for ( y=0 ; y<MAPVIEWSIZE_ROW-1 ; y++ ) {
			@autoreleasepool {
			//setColor and shadow for special-flag
				attributes[NSForegroundColorAttributeName] = [[mapItemValue[x][y] color]  highlightWithLevel:0.2];
				
				if ( [ mapItemValue[x][y] special ] > 0 ) {
					lshadow.shadowColor = [mapItemValue[x][y] color] ;
				} else {
					lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0] ;
				}
				attributes[NSShadowAttributeName] = lshadow;
				
				
				[ [mapItemValue[x][y] symbol] drawWithRect:NSMakeRect(bounds.origin.x+(x*16.0),
																	  (NSMaxY(bounds)-((y+1)*16.0)),
																	  16.0,16.0)
												   options:NSStringDrawingUsesDeviceMetrics
												attributes:attributes ];
				
				if ( mapItemValue[x][y].hasCursor ) {
					[posCursor drawAtPoint:NSMakePoint((bounds.origin.x+(x*16.0))-3.0,((NSMaxY(bounds)-((y+1)*16.0)))-3.0)
								  fromRect:NSZeroRect
								 operation:NSCompositeSourceOver
								  fraction:cursOpacity];
					/*
					[ posCursor dissolveToPoint:NSMakePoint((bounds.origin.x+(x*16.0))-3.0,((NSMaxY(bounds)-((y+1)*16.0)))-3.0)
									   fraction:cursOpacity ];*/
					viewCursX = x;
					viewCursY = MAPVIEWSIZE_ROW-y-1;
				}
			
			}
			
		} // end for y
	} // end for x
	
	//[ self drawMask ];
	
	[ self unlockFocus ];
}


- (void)setCursorOpacity:(CGFloat)opaq
{
	cursOpacity = opaq;
	if (isReady) {
		[self setNeedsDisplay:YES];
	}
}

- (void)drawMask
{
	NSMutableDictionary *attributes_alt = [ [NSMutableDictionary alloc] init ];
	attributes_alt[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: NH3DMAPFONTSIZE - 2.0];
	attributes_alt[NSForegroundColorAttributeName] = [NSColor whiteColor];
		
	[ self lockFocusIfCanDraw ];
	
	if ( RESTRICTED_VIEW && !TRADITIONAL_MAP ) {
		//[ mapRestrictedBezel compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver ];
		[mapRestrictedBezel drawAtPoint:NSZeroPoint
							   fromRect:NSZeroRect
							  operation:NSCompositeSourceOver
							   fraction:1.0];
	} else {
		//[ mapBezel compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver ];
		[mapBezel drawInRect:self.bounds
					fromRect:NSZeroRect
				   operation:NSCompositeSourceOver
					fraction:1.0];
	}
	
	if ( !TRADITIONAL_MAP ) {		
		if ( 39-(centerX-MAP_MARGIN) == 0 && 10-(centerY-MAP_MARGIN) == 0 ) {
			[ @"Center of Map" drawAtPoint:NSMakePoint(46.0,2.0) withAttributes:attributes_alt ];
		} else if ( 39-(centerX-MAP_MARGIN) >= 0 && 10-(centerY-MAP_MARGIN) >= 0 ) {
			[ [NSString stringWithFormat:@"E:%d N:%d",39-(centerX-MAP_MARGIN),10-(centerY-MAP_MARGIN)]
									drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt ];
		} else if ( 39-(centerX-MAP_MARGIN) >= 0 && 10-(centerY-MAP_MARGIN) <= 0 ) {
			[ [NSString stringWithFormat:@"E:%d S:%d",39-(centerX-MAP_MARGIN),-(11-(centerY-MAP_MARGIN))]
									drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt ];
		} else if ( 39-(centerX-MAP_MARGIN) <= 0 && 10-(centerY-MAP_MARGIN) >= 0 ) {
			[ [NSString stringWithFormat:@"W:%d N:%d",-(39-(centerX-MAP_MARGIN)),10-(centerY-MAP_MARGIN)]
									drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt ];
		} else {
			[ [NSString stringWithFormat:@"W:%d S:%d",-(39-(centerX-MAP_MARGIN)),-(10-(centerY-MAP_MARGIN))]
									drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt ];
		}
	}
	
	[ self unlockFocus ];
}


- (void)enemyCheck
{
	int x,y =0;
	enemyCatch = 0;
	
	if ( !isReady || TRADITIONAL_MAP ) {
		return;
	} else {
	
		for ( x=0 ; x<MAPVIEWSIZE_COLUMN ; x++ ) {
			for ( y=0 ; y<MAPVIEWSIZE_ROW ; y++ ) {
	//check enemy
				
				int posx = mapItemValue[x][y].posX - MAP_MARGIN;
				int posy = mapItemValue[x][y].posY - MAP_MARGIN;
				
				if ( (posx >= 0 && posx <=78) && (posy >= 0 && posy <= 20) ) {
				
					if ( MON_AT(posx , posy) && (! mapItemValue[x][y].player && [ mapItemValue[x][y] special ] != 8) ) {
						enemyCatch++;
					}
				}
			} // end y
		} // end x
	
		if ( enemyCatch && [ _mapModel enemyWarnBase ] != 10+(enemyCatch*8) ) {
			[ _mapModel setEnemyWarnBase:10+(enemyCatch*8) ];
		} else if ( [ _mapModel enemyWarnBase ] != 10 ) {
			[ _mapModel setEnemyWarnBase:10 ];
		}
	}
}	





//-----------------------------------------------------
//
//	controller
//-----------------------------------------------------


- (void)setKeyBuffer:(int)value
{	 
	switch ( modKeyFlag ) {
		
		case MODKEY_SHIFT:
			keyBuffer = ( islower(value) ) ? toupper(value) : value;
			//NSLog(@"%c",keyBuffer);
			break;
		case MODKEY_CTRL:
			keyBuffer = C(value);
			break;
		case MODKEY_COMMAND:
			keyBuffer = M(value);
			break;
		default:
			keyBuffer = value;
			break;
	}
	
	modKeyFlag = MODKEY_NONE;
}



- (int)checkExtendCmdList:(const char*)excmd
{
	int i,ret = -1;
	for ( i=0 ; extcmdlist[i].ef_txt ; i++) { 
		if ( strstr( extcmdlist[i].ef_txt , excmd) != NULL ) {
			ret = i;
			break;
		} else ret = -1;
	}
	return ret;
}


- (IBAction)controllerActions:(id)sender
{
	keyBuffer = 0;
	int lkey = 0;
	
	if ([ sender tag ] < 50) {
		switch (_mapModel.playerDirection) {
			case PL_DIRECTION_FORWARD:
				switch ( [ sender tag ] ) {
					case 1:
						lkey = ( iflags.num_pad ) ? '1' : 'b';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 2: 
						lkey = ( iflags.num_pad ) ? '2' : 'j';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 3: 
						lkey = ( iflags.num_pad ) ? '3' : 'n';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 4:
						lkey = ( iflags.num_pad ) ? '4' : 'h';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 5: lkey = '.';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 6: 
						lkey = ( iflags.num_pad ) ? '6' : 'l';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 7: 
						lkey = ( iflags.num_pad ) ? '7' : 'y';
						[ _messenger setLastAttackDirection:1 ];
						break;
					case 8: 
						lkey = ( iflags.num_pad ) ? '8' : 'k';
						[ _messenger setLastAttackDirection:2 ];
						break;
					case 9:
						lkey = ( iflags.num_pad ) ? '9' : 'u';
						[ _messenger setLastAttackDirection:3 ];
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
			case PL_DIRECTION_RIGHT:
				switch ( [ sender tag ] ) {
					case 1:
						lkey = ( iflags.num_pad ) ? '7' : 'y';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 2: 
						lkey = ( iflags.num_pad ) ? '4' : 'h';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 3: 
						lkey = ( iflags.num_pad ) ? '1' : 'b';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 4:
						lkey = ( iflags.num_pad ) ? '8' : 'k';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 5: lkey = '.';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 6: 
						lkey = ( iflags.num_pad ) ? '2' : 'j';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 7: 
						lkey = ( iflags.num_pad ) ? '9' : 'u';
						[ _messenger setLastAttackDirection:4 ];
						break;
					case 8: 
						lkey = ( iflags.num_pad ) ? '6' : 'l';
						[ _messenger setLastAttackDirection:5 ];
						break;
					case 9: 
						lkey = ( iflags.num_pad ) ? '3' : 'n';
						[ _messenger setLastAttackDirection:6 ];
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
			case PL_DIRECTION_BACK:
				switch ([sender tag]) {
					case 1: 
						lkey = ( iflags.num_pad ) ? '9' : 'u';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 2: 
						lkey = ( iflags.num_pad ) ? '8' : 'k';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 3: 
						lkey = ( iflags.num_pad ) ? '7' : 'y';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 4: 
						lkey = ( iflags.num_pad ) ? '6' : 'l';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 5: lkey = '.';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 6: 
						lkey = ( iflags.num_pad ) ? '4' : 'h';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 7: 
						lkey = ( iflags.num_pad ) ? '3' : 'n';
						[ _messenger setLastAttackDirection:7 ];
						break;
					case 8: 
						lkey = ( iflags.num_pad ) ? '2' : 'j';
						[ _messenger setLastAttackDirection:8 ];
						break;
					case 9: 
						lkey = ( iflags.num_pad ) ? '1' : 'b';
						[ _messenger setLastAttackDirection:9 ];
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
			case PL_DIRECTION_LEFT:
				switch ( [ sender tag ] ) {
					case 1: 
						lkey = ( iflags.num_pad ) ? '3' : 'n';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 2: 
						lkey = ( iflags.num_pad ) ? '6' : 'l';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 3: 
						lkey = ( iflags.num_pad ) ? '9' : 'u';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 4: 
						lkey = ( iflags.num_pad ) ? '2' : 'j';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 5: lkey = '.';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 6: 
						lkey = ( iflags.num_pad ) ? '8' : 'k';
						[ _messenger setLastAttackDirection:0 ];
						break;
					case 7: 
						lkey = ( iflags.num_pad ) ? '1' : 'b';
						[ _messenger setLastAttackDirection:10 ];
						break;
					case 8: 
						lkey = ( iflags.num_pad ) ? '4' : 'h';
						[ _messenger setLastAttackDirection:11 ];
						break;
					case 9: 
						lkey = ( iflags.num_pad ) ? '7' : 'y';
						[ _messenger setLastAttackDirection:12 ];
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
		}
	} else {
		switch ([sender selectedTag]) {
			//ButtonMatrix 1 (window rightside)
			case 51: lkey = lastKeyBuffer;
				break;
			case 52: lkey = 's';
				break;
			case 53: lkey = ',';
				break;
			//ButtonMatrix 2 (window leftside)
			case 61: lkey = 'f';
				break;
			case 62: lkey = C('d');
				break;
			case 63: lkey = 'Z';
				break;
			case 64: lkey = 't';
				break;
			case 65: lkey = 'o';
				break;
			//Help Buttons
			case 71: lkey = ':';
				break;
			case 72: lkey = ';';
				break;
		}
	}
	
	self.keyBuffer = lkey;
	lastKeyBuffer = keyBuffer;
	[ self setNeedClear:YES ];
	[ self setKeyUpdated:YES ];
}


- (void)keyDown:(NSEvent*)event
{
	//Dummy
}


- (void)mouseUp:(NSEvent *)event
{	
	//Dummy
}

//-----------------------------------------------------------//
// NOTE
// extendKey is set row position of extcmdlist[startis0] (see cmd.c)
// ----------------------------------------------------------//

- (IBAction)gearMenuActions:(id)sender
{

	keyBuffer = 0;
	switch ( [ sender tag ] ) {
		case 0:	keyBuffer = 'A';	/* Remove Many */
			break;
		case 1: keyBuffer = 'w';	/* Wield Weapon */
			break;
		case 2: keyBuffer = 'x';	/* Exchange Weapon */
			break;
		case 3: keyBuffer = '#';	/* Two Weapon Combat */
			extendKey = [ self checkExtendCmdList:"twoweapon" ];
			break;
		case 4: keyBuffer = 'Q';	/* Load quiver */
			break;
		case 5: keyBuffer = 'W';	/* Wear Armour */
			break;
		case 6: keyBuffer = 'T';	/* Take off Armour */
			break;
		case 7: keyBuffer = 'P';	/* Put on non-Armour */
			break;
		case 8: keyBuffer = 'R';	/* Remove non-Armour */
			break;
	
	}
	
	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}

- (IBAction)actionMenuActions:(id)sender
{
	 
	keyBuffer = 0;
	switch ([sender tag]) {
		case 0: keyBuffer = lastKeyBuffer;	/* Again */
			break;
		case 1: keyBuffer = 'F';	/* Fight */
			break;
		case 2: keyBuffer = 'f';	/* Fire from Quiver */
			break;
		case 3: keyBuffer = 't';	/* Throw */
			break;
		case 4: keyBuffer = C('d');	/* kick */
			break;
		case 5: keyBuffer = '.';	/* Rest */
			break;
		case 6: keyBuffer = '\343';	/* Chat */
			break;
		case 7: keyBuffer = 'e';	/* Eat */
			break;
		case 8: keyBuffer = 's';	/* Search */
			break;
		case 9: keyBuffer = M('u');	/* Untrap */
			break;
		case 10: keyBuffer = '\346';	/* Force */
			break;
		case 11: keyBuffer = 'D';	/* Drop many */
			break;
		case 12: keyBuffer = 'd';	/* Drop */
			break;
		case 13: keyBuffer = ',';	/* Get */
			break;
		case 14: keyBuffer = '\354'; /* Loot */
			break;
		case 15: keyBuffer = 'c';	/* Cloase Door */
			break;
		case 16: keyBuffer = 'o';	/* Open Door */
			break;
		case 17: keyBuffer = '>';	/* Down */
			break;
		case 18: keyBuffer = '<';	/* UP */
			break;
		case 19: keyBuffer = '\352';	/* Jump */
			break;
		case 20: keyBuffer = '\363';	/* Sit */
			break;
		case 21: keyBuffer = '#';	/* Ride */
				 extendKey = [ self checkExtendCmdList:"ride" ];
			break;
		case 22: keyBuffer = 'p';	/* Pay */
			break;
		case 23: keyBuffer = '\367'; /* Wipe Face */
			break;
		case 24: keyBuffer = 'a';	/* Apply */
			break;
		case 25: keyBuffer = 'E';	/* Engrave */
			break;
	}

	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}

- (IBAction)magicMenuActions:(id)sender
{
	keyBuffer = 0;
	switch ([sender tag]) {
		case 0: keyBuffer = 'q';	/* Quaff Potion */
			break;
		case 1: keyBuffer = 'r';	/* Read Scroll/Book */
			break;
		case 2: keyBuffer = 'z';	/* Zap wand */
			break;
		case 3: keyBuffer = 'Z';	/* Zap Spell */
			break;
		case 4: keyBuffer = '\344';	/* Dip */
			break;
		case 5: keyBuffer = '\362';	/* Rub */
			break;
		case 6: keyBuffer = '\351'; /* Invoke */
			break;
		case 7: keyBuffer = '\357';	/* Offer */
			break;
		case 8: keyBuffer = '\360';	/* Pray */
			break;
		case 9: keyBuffer = '\024';	/* Telport */
			break;
		case 10: keyBuffer = '\355';	/* Monster Action */
			break;
		case 11: keyBuffer = '\364';	/* Turn undead */
			break;
	
	}
	
	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}

- (IBAction)infoMenuActions:(id)sender
{
	keyBuffer = 0;
	switch ( [ sender tag ] ) {
		case 0: keyBuffer = 'i';	/* Inventory */
			break;
		case 1: keyBuffer = '#';	/* Conduct */
				extendKey = [ self checkExtendCmdList:"conduct" ];
			break;
		case 2: keyBuffer = '\\';	/* Discoveries */
			break;
		case 3: keyBuffer = '+';	/* list/Reorder spell */
			break;
		case 4: keyBuffer = '\341';	/* Adjust Letters */
			break;
		case 5: keyBuffer = '\356';	/* Name Object */
			break;
		case 6: keyBuffer = '\356'; /* Name Object Type */
			break;
		case 7: keyBuffer = 'C';	/* Name Creature */
			break;
		case 8: keyBuffer = M('e'); /* Qualificatuons */
			break;
	}
		
	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}

- (IBAction)otherMenuActions:(id)sender
{
	keyBuffer = 0;
	switch ([sender tag]) {
		case 0: keyBuffer = '?';	/* Help */
			break;
		case 1: keyBuffer = ':';	/* What is here */
			break;
		case 2: keyBuffer = ';';	/* What is there */
			break;
		case 3: keyBuffer = '/';	/* What is ... */
			break;
		case 4: keyBuffer = 'O';	/* Preferences… */
			break;
		case 5: keyBuffer = 'S';	/* Save game */
			break;
		case 6: keyBuffer = 'v';	/* Version */
			break;
		case 7: keyBuffer = '\366';	/* Compile Info */
			break;
		case 8: keyBuffer = 'V';	/* History */
			break;
		//
		case 20 : 
			if ( !iflags.window_inited ) [ NSApp terminate:self ]; // early Quit //
			else keyBuffer = M('q');  /* Quit without Save */
	}
	
	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}


- (IBAction)setRestrictedView:(id)sender
{	
	[[NSUserDefaults standardUserDefaults] setBool:!((NSCell*)sender).state forKey:NH3DUseSightRestrictionKey];
	[[NSUserDefaultsController sharedUserDefaultsController].values setValue:[ NSNumber numberWithBool:!((NSCell*)sender).state]
																		 forKey:NH3DUseSightRestrictionKey];
	[self setNeedClear:YES];
	[self setNeedsDisplay:YES];
}

- (IBAction)setUseTileInGlobalMap:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:! ((NSCell*)sender).state forKey:NH3DUseTileInLevelMapKey ];
	[[NSUserDefaultsController sharedUserDefaultsController].values setValue:[ NSNumber numberWithBool:! ((NSCell*)sender).state ]
																		forKey:NH3DUseTileInLevelMapKey];
}

//TODO: re-do this to work with OS X's run-loop!
- (void)nh3dEventHandlerLoopWithMask:(NSUInteger)mask
{
	char ch[3] = {0};
	
	while (!keyUpdated) {
		@autoreleasepool {
			NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.1];
			
			NSEvent *event = [NSApp nextEventMatchingMask:mask
												untilDate:date
												   inMode:NSDefaultRunLoopMode
												  dequeue:YES];
			
			if (event) {
				if (![_bindController mainWindow].keyWindow ) {
					[ NSApp sendEvent:event ];
					continue;
				} else {
					
					switch (event.type) {
						case NSKeyDown:
							strcpy(ch, event.charactersIgnoringModifiers.UTF8String );
							
							keyBuffer = 0;
							modKeyFlag = MODKEY_NONE;
							
							if ( event.keyCode == kVK_LeftArrow ) {
								if (TRADITIONAL_MAP)
									[_num4 performClick:self];
								else
									[_turnLeft performClick:self];
								continue;
							} else if (event.keyCode == kVK_RightArrow) {
								if (TRADITIONAL_MAP) {
									[_num6 performClick:self];
								} else {
									[_turnRight performClick:self];
								}
								continue;
							} else if (event.keyCode == kVK_DownArrow) {
								[_num2 performClick:self];
								continue;
							} else if (event.keyCode == kVK_UpArrow) {
								[_num8 performClick:self];
								continue;
								
							} else if (event.modifierFlags & NSCommandKeyMask) {
								[NSApp sendEvent:event];
								continue;
							} else if (event.modifierFlags & NSShiftKeyMask) {
								modKeyFlag = MODKEY_SHIFT;
								ch[0] = ( isupper( (int)ch[0] ) ) ? tolower( (int)ch[0] ) : ch[0];
							} else if ( event.modifierFlags & NSControlKeyMask ) {
								if ( ch[0]=='d' ) {
									[ [_cmdGroup2 cellWithTag:62] performClick:self ];
									continue;
								} else {
									modKeyFlag = MODKEY_CTRL;
								}
							} else if (getCharMode) {
								self.keyBuffer = (int)ch[0];
							}
							
							if ( event.modifierFlags & NSAlternateKeyMask ) {
								switch ( ch[0] ) {
									case 'a': [ [_cmdGroup1 cellWithTag:51] performClick:self ];
										break;
									default:
										modKeyFlag = MODKEY_COMMAND;
										self.keyBuffer = (int)ch[0];
										break;
								}
							} else {
								switch (ch[0]) {
									case '1':
										if (iflags.num_pad) {
											[_num1 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case '2':
										if (iflags.num_pad) {
											[ _num2 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case '3':
										if (iflags.num_pad) {
											[_num3 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case '4':
										if (iflags.num_pad) {
											[_num4 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case '5':
									case '.':
										[_num5 performClick:self];
										break;
										
									case '6':
										if (iflags.num_pad) {
											[_num6 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case '7':
										if (iflags.num_pad) {
											[_num7 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
									case '8':
										if ( iflags.num_pad ) {
											[ _num8 performClick:self ];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case '9':
										if (iflags.num_pad) {
											[_num9 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'f':
										[[_cmdGroup2 cellWithTag:61] performClick:self];
										break;
										
									case 'Z':
										[[_cmdGroup2 cellWithTag:63] performClick:self];
										break;
										
									case 't':
										[[_cmdGroup2 cellWithTag:64] performClick:self];
										break;
										
									case 'o':
										[[_cmdGroup2 cellWithTag:65] performClick:self];
										break;
										
									case 's':
										[[_cmdGroup1 cellWithTag:52] performClick:self];
										break;
										
									case ',':
										[[_cmdGroup1 cellWithTag:53] performClick:self];
										break;
										
									case ';':
										[_help1 performClick:self];
										break;
									case ':':
										[_help2 performClick:self];
										break;
										
									case 'b':
										if (!iflags.num_pad) {
											[_num1 performClick:self];
										} else {
										self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'j':
										if (!iflags.num_pad) {
											[_num2 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'n':
										if (!iflags.num_pad) {
											[_num3 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'h':
										if (!iflags.num_pad) {
											[_num4 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'l':
										if (!iflags.num_pad) {
											[_num6 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'y':
										if (!iflags.num_pad) {
											[_num7 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									case 'k':
										if ( !iflags.num_pad ) {
											[_num8 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
									case 'u':
										if (!iflags.num_pad) {
											[_num9 performClick:self];
										} else {
											self.keyBuffer = (int)ch[0];
										}
										break;
										
									default:
										self.keyBuffer = (int)ch[0] ;
										
										break;
								} // end switch (ch[0])
							}
							lastKeyBuffer = keyBuffer;
							
							[ self setNeedClear:YES ];
							[ self setKeyUpdated:YES ];
							break;
							
						case NSLeftMouseUp:
						{
							NSPoint p = event.locationInWindow ;
							NSRect bounds = self.bounds ;
							downPoint = [ self convertPoint:p fromView:nil ];
							
							if ( !NSPointInRect(downPoint,bounds) ) {
								[ NSApp sendEvent:event ];
								continue;
							} else
								
								
								keyBuffer = 0;
							clickType = 1;
							
							if ( TRADITIONAL_MAP ) {
								int tsizeX,tsizeY,trcpX,trcpY;
								
								tsizeX = ( TRADITIONAL_MAP_TILE ) ? TILE_SIZE_X : NH3DMAPFONTSIZE;
								tsizeY = ( TRADITIONAL_MAP_TILE ) ? TILE_SIZE_Y : NH3DMAPFONTSIZE;
								
								trcpX = (centerX - _mapModel.cursX - MAP_MARGIN) + (int)(downPoint.x/tsizeX) - (int)((bounds.size.width/tsizeX) / 2 );
								trcpY = (centerY - _mapModel.cursY - MAP_MARGIN) + (int)(downPoint.y/tsizeY) - (int)((bounds.size.height/tsizeY) / 2 );
								
								[ _mapModel setPosCursorAtX:_mapModel.cursX + trcpX -1
														atY:_mapModel.cursY + trcpY  * -1 ];
								
							} else {
								switch ( _mapModel.playerDirection ) {
									case PL_DIRECTION_FORWARD:
										[ _mapModel setPosCursorAtX:_mapModel.cursX+((int)(downPoint.x/16) - viewCursX)
																atY:_mapModel.cursY+(((int)(downPoint.y/16) - viewCursY)* -1) ];
										break;
									case PL_DIRECTION_RIGHT:
										[ _mapModel setPosCursorAtX:_mapModel.cursX+((int)(downPoint.y/16) - viewCursY)
																atY:_mapModel.cursY+((int)(downPoint.x/16) - viewCursX)];
										break;
									case PL_DIRECTION_BACK:
										[ _mapModel setPosCursorAtX:_mapModel.cursX+(((int)(downPoint.x/16) - viewCursX)* -1)
																atY:_mapModel.cursY+((int)(downPoint.y/16) - viewCursY) ];
										break;
									case PL_DIRECTION_LEFT:
										[ _mapModel setPosCursorAtX:_mapModel.cursX+(((int)(downPoint.y/16) - viewCursY)* -1)
																atY:_mapModel.cursY+(((int)(downPoint.x/16) - viewCursX)* -1) ];
										break;
								}
							}
							
							[ self setNeedClear:YES ];
							[ self setKeyUpdated:YES ];
							
						} // end case NSLeftMouseDown:
							
						default :
							[NSApp sendEvent:event];
							continue;
							
					} //end switch ([event type])
				}
			}// end if (event)
			else {
				//NSEvent
			}
		}
		
	} // end while (keyUpdated == NO)
}	


- (IBAction)showGlobalMap:(id)sender
{
	@autoreleasepool {
	int x,y,cusx,cusy;
	NSRect mapwindowRect = NSMakeRect(0,0,_mapLpanel.maxSize.width,_mapLpanel.maxSize.height);
	NSSize drawSize;
	NSSize imgSize;
	
	_mapLpanel.backgroundColor = [NSColor clearColor];
	_mapLpanel.opaque = NO;
	
	[_mapLpanel setFrame:mapwindowRect display:NO];
	
	if (TILED_LEVELMAP) {
		mapImage = [[NSImage alloc] initWithSize:NSMakeSize(TILE_SIZE_X * MAPSIZE_COLUMN , TILE_SIZE_Y * MAPSIZE_ROW)];
	} else {
		mapImage = [[NSImage alloc] initWithSize:NSMakeSize(NH3DMAPFONTSIZE * MAPSIZE_COLUMN , NH3DMAPFONTSIZE * MAPSIZE_ROW)];
	}
	
	imgSize = mapImage.size;
	_mapLview.frame = NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height);
	[mapImage lockFocus];
	
	for ( x=0 ; x<MAPSIZE_COLUMN ; x++ ) {
		for ( y=0 ; y<MAPSIZE_ROW ; y++ ) {

			NH3DMapItem *mapcell = [_mapModel mapArrayAtX:x atY:y];
			
			if ( TILED_LEVELMAP ) { // Draw Tiled Map.
				NSImage *tileImg = mapcell.tile ;
				drawSize = tileImg.size ;
				
				/*
				[tileImg dissolveToPoint:NSMakePoint(drawSize.width * (float)x,
												   imgSize.height - (drawSize.height * (float)y) )
									    fraction:1.0 ];
				 */
				[tileImg drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)x,
												 imgSize.height - (drawSize.height * (CGFloat)y))
							fromRect:NSZeroRect
						   operation:NSCompositeSourceOver
							fraction:1.0];
			} else { // Draw ASCII Map.
				NSShadow *lshadow = [[NSShadow alloc] init];
				NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
				
				attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: NH3DMAPFONTSIZE];
				
				
				if ([[mapcell symbol] isEqualToString:@"-"] && mapcell.hasAlternateSymbol) {
					mapcell.cSymbol = '|';
					mapcell.hasAlternateSymbol = NO;
				} else if ( [ [mapcell symbol] isEqualToString:@"|" ] && mapcell.hasAlternateSymbol ) {
					mapcell.cSymbol = '-';
					mapcell.hasAlternateSymbol = NO;
				}
				
				attributes[NSForegroundColorAttributeName] = [[mapcell color] highlightWithLevel:0.2];

				
				drawSize = [[mapcell symbol] sizeWithAttributes:attributes];
				
				lshadow.shadowOffset = NSMakeSize(0.8, 0.8) ;
				lshadow.shadowBlurRadius = 5.5 ;
				lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.5] ;
				
				attributes[NSShadowAttributeName] = lshadow;
				
				
				[[mapcell symbol] drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)x,
														 imgSize.height - (drawSize.height * (CGFloat)y))
							    withAttributes:attributes];
				
				[attributes removeAllObjects];
			}
			
			if (mapcell.hasCursor) { // Check cursor postion and drawing.
				NSShadow* sd = [[NSShadow alloc] init];
				NSSize cursOrigin = posCursor.size;
				cusx = x;
				cusy = y;
				[NSGraphicsContext saveGraphicsState];
				sd.shadowOffset = NSMakeSize( 2, -2 ) ; 
				sd.shadowBlurRadius = 3 ;
				sd.shadowColor = [NSColor blackColor];
				[ sd set ];
				posCursor.size = drawSize ;
				[posCursor drawAtPoint:NSMakePoint(drawSize.width * (float)x,
												   imgSize.height - (drawSize.height * (float)y))
							  fromRect:NSZeroRect
							 operation:NSCompositeSourceOver
							  fraction:1.0];
				/*
				[ posCursor dissolveToPoint:NSMakePoint(drawSize.width * (float)x,
													   imgSize.height - (drawSize.height * (float)y))
								   fraction:1.0 ];*/
				posCursor.size = cursOrigin;
				[NSGraphicsContext restoreGraphicsState];
				
			}
			
		} // end for y
	} // end for x
	
	// draw direction symbol
	[[NSImage imageNamed:@"direction"] drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)(cusx + 8) ,
															   imgSize.height - (drawSize.height * (CGFloat)cusy))
										  fromRect:NSZeroRect
										 operation:NSCompositeSourceOver
										  fraction:0.5];
	
	[mapImage unlockFocus];
	//[ putImg setCacheMode:NSImageCacheNever ];
	
	_mapLview.image = mapImage;
	
	// Scroll to Cursor Postion (shift 7 tiles added to Right)
	[_mapLview scrollPoint:NSMakePoint(drawSize.width * (CGFloat)(cusx - 7),
									   imgSize.height - (drawSize.height * (CGFloat)(cusy + 7)))];
	}
	
	// Sheet is Up.
	//@try {
		[_window beginSheet:_mapLpanel completionHandler:^(NSModalResponse returnCode) {
			[_mapLview setImage:nil];
		}];
		
		[NSApp runModalForWindow:_mapLpanel];
		
		// Sheet is Over.
		[_window endSheet:_mapLpanel];
	//}
	//} @catch(NSException *e) {
	//	NSLog(@"%@", e);
	//	NSBeep();
	//}
}


- (IBAction)closeModalDialog:(id)sender
{
	[NSApp stopModal];
}

- (IBAction)zoomLevelMap:(id)sender
{
	NSImage *newImg;
	NSSize	mapSize = mapImage.size ;
	NSSize	newSize = _mapLview.image.size ;
	
	if ( newSize.height > mapSize.height*1.5 ) {
		newSize.height = mapSize.height*1.5;
		newSize.width = mapSize.width*1.5;
	} else if ( newSize.height < mapSize.height*0.5 ) {
		newSize.height = mapSize.height*0.5;
		newSize.width = mapSize.width*0.5;
	}
		
	if ([sender tag]) {
		// zoom in
		newSize = NSMakeSize( newSize.width*0.75 , newSize.height*0.75 );
	} else {
		// zoom out
		newSize = NSMakeSize( newSize.width*1.25 , newSize.height*1.25 );
	}
	
	newImg = [ [NSImage alloc] initWithSize:newSize ];
	NSGraphicsContext* gc = [NSGraphicsContext currentContext];
	gc.imageInterpolation = NSImageInterpolationHigh;
	
	[newImg lockFocus ];
	[mapImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
				 fromRect:NSZeroRect
				operation:NSCompositeSourceOver
				 fraction:1.0];
	[newImg unlockFocus ];
	
	_mapLview.frame = NSMakeRect(0.0, 0.0, newSize.width, newSize.height);
	_mapLview.image = newImg;
	
	[_mapLview setNeedsDisplay];
}

@end
