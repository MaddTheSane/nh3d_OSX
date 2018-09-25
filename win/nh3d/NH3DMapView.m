/* NH3DMapView */
//
//  NH3DMapView.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

#include "C99Bool.h"
#import "NH3DMapView.h"

#import "winnh3d.h"
#import "NetHack3D-Swift.h"

#define SMALL_MAP_BORDER 3

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
@property (strong) NSImage *mapBase;
@property (strong) NSImage *trMapImage;
@property (strong) NSImage *posCursor;
@property (strong) NSImage *mapRestrictedBezel;
@property (copy) NSImage *petIcon;
@property (copy) NSImage *stackIcon;
@property int centerX;
@property int centerY;
- (void)drawTraditionalMapInContextAtX:(int)x atY:(int)y;
- (void)clipSmallMap;
@end

@implementation NH3DMapView
@synthesize posCursor;
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
@synthesize bgColor;

- (instancetype)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		bgColor = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0];
			
		isReady = NO;
		enemyCatch = 0;
		
		viewCursX = 0;
		viewCursY = 0;
										
		self.posCursor = [NSImage imageNamed:@"nh3dPosCursor"];
		self.mapRestrictedBezel = [NSImage imageNamed:@"asciiMapMaskLimited"];
		self.petIcon = [NSImage imageNamed:@"petMark"];
		self.stackIcon = [NSImage imageNamed:@"pileMark"];

		cursOpacity = 1.0;
		keyBuffer = '0';
		extendKey = -1;
		modKeyFlag = MODKEY_NONE;
		//cursPos = NSZeroPoint;
		plDepth = 0;
		
		lock = [[NSRecursiveLock alloc] init];
		
		//NSLog(@"%f,%f,%f,%f",frameRect.origin.x,frameRect.origin.y,frameRect.size.width,frameRect.size.height);
		
		if (TRADITIONAL_MAP) {
			self.mapBase = [NSImage imageNamed:@"trBase"];
			self.trMapImage = nil;
		} else {
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
					name:NSUserDefaultsDidChangeNotification
				  object:nil];
	if (TRADITIONAL_MAP) {
		self.frame = NSMakeRect(0, 0, 440.0, 320.0);
		[self removeFromSuperview];
		[_bindController.majorMapView addSubview:self];
	}
}

- (void)defaultDidChange:(NSNotification *)notification
{
	if (!CocoaPortIsReady) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (TRADITIONAL_MAP) {
				self.frame = NSMakeRect(0, 0, 440.0, 320.0);
				[self removeFromSuperview];
				[self->_bindController.majorMapView addSubview:self];
				self.mapBase = [NSImage imageNamed:@"trBase"];
			} else {
				[self removeFromSuperview];
				[self->_bindController.minorMapView addSubview:self];
				self.frame = NSMakeRect(0, 0, 176.0, 176.0);
				self.mapBase = [NSImage imageNamed:@"asciiMapBase"];
			}
		});
		return;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		if (TRADITIONAL_MAP) {
			if (self->isReady) {
				[self lockFocusIfCanDraw];
				NSEraseRect(self.bounds);
				[[NSColor windowBackgroundColor] set];
				[NSBezierPath fillRect:self.bounds];
				[self unlockFocus];
			}
			
			[self removeFromSuperview];
			[self->_bindController.majorMapView addSubview:self];
			
			self.frame = NSMakeRect(0, 0, 440.0, 320.0) ;
			
			self.mapBase = [NSImage imageNamed:@"trBase"];
			
			[self makeTraditionalMap];
			
			[self updateMap];
			[self setNeedsDisplay:YES];
			[self->_bindController.mainWindow displayIfNeeded];
		} else if (!TRADITIONAL_MAP) {
			if (self->isReady) {
				if ([self lockFocusIfCanDraw]) {
					NSEraseRect(self.bounds);
					[[NSColor windowBackgroundColor] set];
					[NSBezierPath fillRect:self.bounds];
					[self unlockFocus];
				}
			}
			
			[self removeFromSuperview];
			[self->_bindController.minorMapView addSubview:self];
			
			self.frame = NSMakeRect(0, 0, 176.0, 176.0);
			
			self.mapBase = [NSImage imageNamed:@"asciiMapBase"];
			
			self.trMapImage = nil;
			
			[self updateMap];
			[self setNeedsDisplay:YES];
			[self->_bindController.mainWindow displayIfNeeded];
		}
	});
}

- (void) dealloc {
	for (int x = 0; x<MAPVIEWSIZE_COLUMN; x++) {
		for (int y = 0; y<MAPVIEWSIZE_ROW; y++) {
			mapItemValue[x][y] = nil;
		}
	}
}

- (void)drawRect:(NSRect)rect
{
	[self clipSmallMap];
	NSRect bounds = self.bounds;
	
	[mapBase drawInRect:bounds
			   fromRect:NSZeroRect
			  operation:NSCompositeSourceOver
			   fraction:1.0];
	
	if (isReady) {
		if (TRADITIONAL_MAP) {
			[self updateMap];
		} else {
			[self reloadMap];
		}
	}
	
	[self drawMask];
}

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
	NSRect rect = self.bounds;
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
	if (TRADITIONAL_MAP_TILE) {
		self.trMapImage = [[NSImage alloc] initWithSize:NSMakeSize(TILE_SIZE_X*MAPSIZE_COLUMN,
																   TILE_SIZE_Y*MAPSIZE_ROW)];
	} else {
		self.trMapImage = [[NSImage alloc] initWithSize:NSMakeSize(NH3DMAPFONTSIZE*MAPSIZE_COLUMN,
																   NH3DMAPFONTSIZE*MAPSIZE_ROW)];
	}
	
	[trMapImage lockFocus];
	for (int x = MAP_MARGIN; x < MAPSIZE_COLUMN - MAP_MARGIN; x++) {
		for (int y = MAP_MARGIN; y < MAPSIZE_ROW - MAP_MARGIN; y++) {
			@autoreleasepool {
				[self drawTraditionalMapInContextAtX:x atY:y];
			}
		}
	}
	[trMapImage unlockFocus];
}

- (void)drawTraditionalMapAtX:(int)x atY:(int)y
{
	// oops, we're not ready.
	if (!trMapImage) {
		return;
	}

	[trMapImage lockFocus];
	[self drawTraditionalMapInContextAtX:x atY:y];
	[trMapImage unlockFocus];
}

- (void)drawTraditionalMapInContextAtX:(int)x atY:(int)y
{
	NSRect bounds = NSMakeRect(0, 0, trMapImage.size.width, trMapImage.size.height);
	NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
	
	if (TRADITIONAL_MAP_TILE && mapItem != nil) {
		NSImage *tileImg = mapItem.tile;
		NSSize tileSize = tileImg.size;
		
		if (tileImg != nil) {
			[[NSColor clearColor] set];
			NSRectFill(NSMakeRect(bounds.origin.x + (x*TILE_SIZE_X),
								  (NSMaxY(bounds) - (y*TILE_SIZE_Y)),
								  (CGFloat)TILE_SIZE_X, (CGFloat)TILE_SIZE_Y));
			
			[tileImg drawInRect:NSMakeRect(bounds.origin.x+(x*TILE_SIZE_X),
										   (NSMaxY(bounds)-(y*TILE_SIZE_Y)),
										   (CGFloat)TILE_SIZE_X , (CGFloat)TILE_SIZE_Y)
					   fromRect:NSMakeRect(0, 0,
										   tileSize.width, tileSize.height)
					  operation:NSCompositeSourceOver
					   fraction:1.0];
		}
	} else if (mapItem != nil) {
		NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		CGFloat fontsize = NH3DMAPFONTSIZE;
		CGFloat drawMargin = fontsize/4;
		
		attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: fontsize];
		
		attributes[NSForegroundColorAttributeName] = mapItem.color;
		

		if (fontsize > 12.0) {
			//set shadow 
			NSShadow *lshadow = [[NSShadow alloc] init];
			
			lshadow.shadowOffset = NSMakeSize(0.8, 1.8);
			lshadow.shadowBlurRadius = drawMargin ;
			
			if (mapItem.special > 0) {
				lshadow.shadowColor = mapItem.color;
			} else {
				lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
			}
			
			attributes[NSShadowAttributeName] = lshadow;
		}
		
		[[NSColor clearColor] set];
		NSRectFill(NSMakeRect(bounds.origin.x+(x*fontsize),
							  (NSMaxY(bounds)-(y*fontsize)),
							  fontsize+drawMargin, fontsize+drawMargin));
		
		NSString *symbol = mapItem.symbol;
		if (mapItemValue[x][y].hasAlternateSymbol && [mapItem alternateSymbolForDirection:_mapModel.playerDirection]) {
			symbol = [mapItem alternateSymbolForDirection:_mapModel.playerDirection];
		}
		
		[symbol drawInRect:NSMakeRect(bounds.origin.x+drawMargin+(x*fontsize),
									  (NSMaxY(bounds)+drawMargin-(y*fontsize)),
									  fontsize, fontsize)
			withAttributes:attributes];
	}
	
	//[_mapModel mapArrayAtX:x atY:y];
}

- (void)updateMap
{
	if (!isReady) {
		return;
	} else {
		//Get MapItems(Tiles,Symbol,glyph,etc...) with direction.
		 
		int x,y;
		int localx = 0;
		int localy = 0;
		
		if (TRADITIONAL_MAP) {
			CGFloat trCenterX,trCenterY,tsizeX,tsizeY,trColumn,trRow,trcpX,trcpY;
			NSRect bounds = self.bounds;
			
			if (needClear) {
				[self lockFocusIfCanDraw];
				NSEraseRect(bounds);
				[mapBase drawInRect:bounds
						   fromRect:NSZeroRect
						  operation:NSCompositeCopy
						   fraction:1.0];
				[self unlockFocus];
				needClear = NO;
			}
			
			tsizeX = (TRADITIONAL_MAP_TILE) ? TILE_SIZE_X : NH3DMAPFONTSIZE;
			tsizeY = (TRADITIONAL_MAP_TILE) ? TILE_SIZE_Y : NH3DMAPFONTSIZE;
			

				trColumn = bounds.size.width / 2;
				trRow = bounds.size.height / 2;
				trCenterX = (centerX * tsizeX) - trColumn;
				trCenterY = trMapImage.size .height - (centerY * tsizeY) - trRow;
				trcpX = (centerX - _mapModel.cursX - MAP_MARGIN) * -1;
				trcpY = (centerY - _mapModel.cursY - MAP_MARGIN) * -1;
				
			if ([self lockFocusIfCanDraw]) {
				[trMapImage drawAtPoint:bounds.origin
							   fromRect:NSMakeRect(trCenterX,
												   trCenterY,
												   bounds.size.width, bounds.size.height)
							  operation:NSCompositeSourceOver
							   fraction:1.0];

				[posCursor drawInRect:NSMakeRect(bounds.origin.x + ((trcpX * tsizeX) + trColumn) ,
												 NSMaxY(bounds) - ((trcpY * tsizeY) + trRow) ,
												 tsizeX , tsizeY)
							 fromRect:NSMakeRect(0, 0, 16.0, 16.0)
							operation:NSCompositeSourceOver
							 fraction:cursOpacity];
			}
			[self unlockFocus];
		} else {
			switch (_mapModel.playerDirection) {
				case NH3DPlayerDirectionForward:
					for (x = centerX - MAP_MARGIN; x < centerX + 1 + MAP_MARGIN; x++) {
						for (y = centerY - MAP_MARGIN; y < centerY + 1 + MAP_MARGIN; y++) {
							[lock lock];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localx][localy] = mapItem;
							[lock unlock];
							[self drawAsciiItemAtX:localx atY:localy];
							localy++;
						}
						localx++;
						localy=0;
					}
					[self setNeedsDisplay:YES];
					[self enemyCheck];
					break;
					
				case NH3DPlayerDirectionRight:
					for (x = centerX + MAP_MARGIN; x > centerX - 1 - MAP_MARGIN; x--) {
						for (y = centerY - MAP_MARGIN; y < centerY + 1 + MAP_MARGIN; y++) {
							[lock lock];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localy][localx] = mapItem;
							[lock unlock];
							[self drawAsciiItemAtX:localy atY:localx];
							localy++;
						}
						localx++;
						localy=0;
					}
					[self setNeedsDisplay:YES];
					[self enemyCheck];
					break;
					
				case NH3DPlayerDirectionBack:
					for (x = centerX + MAP_MARGIN; x > centerX-1-MAP_MARGIN; x--) {
						for (y = centerY + MAP_MARGIN; y > centerY-1-MAP_MARGIN; y--) {
							[lock lock];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localx][localy] = mapItem;
							[lock unlock];
							[self drawAsciiItemAtX:localx atY:localy];
							localy++;
						}
						localx++;
						localy=0;
					}
					[self setNeedsDisplay:YES];
					[self enemyCheck];
					break;
					
				case NH3DPlayerDirectionLeft:
					for (x = centerX-MAP_MARGIN; x < centerX+1+MAP_MARGIN; x++) {
						for (y = centerY+MAP_MARGIN; y > centerY-1-MAP_MARGIN; y--) {
							[lock lock];
							NH3DMapItem *mapItem = [_mapModel mapArrayAtX:x atY:y];
							mapItemValue[localy][localx] = mapItem;
							[lock unlock];
							[self drawAsciiItemAtX:localy atY:localx];
							localy++;
						}
						localx++;
						localy=0;
					}
					[self setNeedsDisplay:YES];
					[self enemyCheck];
					break;
			}
		}
	}
}

- (void)drawAsciiItemAtX:(int)x atY:(int)y
{
	if (!CocoaPortIsReady) {
		return;
	}
	@autoreleasepool {
		NSRect bounds = self.bounds;
		NSShadow *lshadow = [[NSShadow alloc] init];
		NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		
		lshadow.shadowOffset = NSMakeSize(0.8, 1.8);
		lshadow.shadowBlurRadius = 3.5;
		
		attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: 16];
		
		//setColor and shadow for special-flag
		attributes[NSForegroundColorAttributeName] = [mapItemValue[x][y].color highlightWithLevel:0.2];
		
		if (mapItemValue[x][y].special > 0) {
			lshadow.shadowColor = mapItemValue[x][y].color;
		} else {
			lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
		}
		
		attributes[NSShadowAttributeName] = lshadow;
		
		// Replace Wall/OpenDoor charctor for Right,Left direction
		if (!mapItemValue[x][y].hasAlternateSymbol) {
			switch (mapItemValue[x][y].glyph) {
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
					[mapItemValue[x][y] setHasAlternateSymbol:YES];
					break;
				default:
					break;
			}
		}
		
		//Draw view
		if ([self lockFocusIfCanDraw]) {
			[self clipSmallMap];
			if (needClear) {
				NSEraseRect(bounds);
				[mapBase drawInRect:bounds
						   fromRect:NSZeroRect
						  operation:NSCompositeSourceOver
						   fraction:1.0];
				needClear = NO;
			}
			
			NSString *symbol = mapItemValue[x][y].symbol;
			if (mapItemValue[x][y].hasAlternateSymbol && [mapItemValue[x][y] alternateSymbolForDirection:_mapModel.playerDirection]) {
				symbol = [mapItemValue[x][y] alternateSymbolForDirection:_mapModel.playerDirection];
			}
			
			[symbol drawWithRect:NSMakeRect(bounds.origin.x+(x*16.0),
											(NSMaxY(bounds) - ((y+1)*16.0)),
											16.0, 16.0)
						 options:NSStringDrawingUsesDeviceMetrics
					  attributes:attributes];
			
			if (mapItemValue[x][y].hasCursor) {
				[posCursor drawAtPoint:NSMakePoint((bounds.origin.x+(x*16.0))-3.0,((NSMaxY(bounds)-((y+1)*16.0)))-3.0)
							  fromRect:NSZeroRect
							 operation:NSCompositeSourceOver
							  fraction:cursOpacity];
				
				viewCursX = x;
				viewCursY = MAPVIEWSIZE_ROW-y-1;
			}
			
			NSRect petRect = NSMakeRect(bounds.origin.x+(x*16.0),
										(NSMaxY(bounds) - ((y+1)*16.0)),
										16.0, 16.0);
			
			if (iflags.wc_hilite_pet && mapItemValue[x][y].pet) {
				//draw pet icon
				[_petIcon drawInRect:petRect
							fromRect:NSZeroRect
						   operation:NSCompositeSourceOver
							fraction:1.0];
			}
			
			if (iflags.hilite_pile && mapItemValue[x][y].pile) {
				//draw pile icon
				[_stackIcon drawInRect:petRect
							  fromRect:NSZeroRect
							 operation:NSCompositeSourceOver
							  fraction:1.0];
			}
			
			[self unlockFocus];
		}
	}
}

- (void)reloadMap
{
	if (!CocoaPortIsReady) {
		return;
	}
	if (TRADITIONAL_MAP)
		return;
	
	NSRect bounds = self.bounds;
	NSShadow *lshadow = [[NSShadow alloc] init];
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
	
	lshadow.shadowOffset = NSMakeSize(0.8, 1.8);
	lshadow.shadowBlurRadius = 3.5;
	
	attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: 16];
	
	//Draw view
	if ([self lockFocusIfCanDraw]) {
		[self clipSmallMap];
		
		if (needClear) {
			NSEraseRect(bounds);
			[mapBase drawInRect:bounds
					   fromRect:NSZeroRect
					  operation:NSCompositeSourceOver
					   fraction:1.0];
			needClear = NO;
		}
		
		for (int x = 0; x < MAPVIEWSIZE_COLUMN - 1; x++) @autoreleasepool {
			for (int y = 0; y < MAPVIEWSIZE_ROW - 1; y++) {
				//setColor and shadow for special-flag
				attributes[NSForegroundColorAttributeName] = [mapItemValue[x][y].color highlightWithLevel:0.2];
				
				if (mapItemValue[x][y].special > 0) {
					lshadow.shadowColor = mapItemValue[x][y].color;
				} else {
					lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
				}
				attributes[NSShadowAttributeName] = lshadow;
				
				NSString *symbol = mapItemValue[x][y].symbol;
				if (mapItemValue[x][y].hasAlternateSymbol && [mapItemValue[x][y] alternateSymbolForDirection:_mapModel.playerDirection]) {
					symbol = [mapItemValue[x][y] alternateSymbolForDirection:_mapModel.playerDirection];
				}

				[symbol drawWithRect:NSMakeRect(bounds.origin.x+(x*16.0),
												(NSMaxY(bounds)-((y+1)*16.0)),
												16.0,16.0)
							 options:NSStringDrawingUsesDeviceMetrics
						  attributes:attributes];
				
				if (mapItemValue[x][y].hasCursor) {
					[posCursor drawAtPoint:NSMakePoint((bounds.origin.x+(x*16.0))-3.0,((NSMaxY(bounds)-((y+1)*16.0)))-3.0)
								  fromRect:NSZeroRect
								 operation:NSCompositeSourceOver
								  fraction:cursOpacity];
					viewCursX = x;
					viewCursY = MAPVIEWSIZE_ROW-y-1;
				}
			} // end for y
		} // end for x
		
		[self unlockFocus];
	}
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
	if (!CocoaPortIsReady) {
		return;
	}
	NSMutableDictionary *attributes_alt = [[NSMutableDictionary alloc] init];
	attributes_alt[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: NH3DMAPFONTSIZE - 2.0];
	attributes_alt[NSForegroundColorAttributeName] = [NSColor whiteColor];
		
	if ([self lockFocusIfCanDraw]) {
		[self clipSmallMap];
		if (RESTRICTED_VIEW && !TRADITIONAL_MAP) {
			[mapRestrictedBezel drawAtPoint:NSZeroPoint
								   fromRect:NSZeroRect
								  operation:NSCompositeSourceOver
								   fraction:1.0];
		}
		
		if (!TRADITIONAL_MAP) {
			if (39 - (centerX - MAP_MARGIN) == 0 && 10 - (centerY-MAP_MARGIN) == 0) {
				[NSLocalizedString(@"Center of Map", @"Center of Map") drawAtPoint:NSMakePoint(46.0,2.0) withAttributes:attributes_alt];
			} else if (39 - (centerX - MAP_MARGIN) >= 0 && 10 - (centerY - MAP_MARGIN) >= 0) {
				[[NSString stringWithFormat:@"E:%d N:%d", 39 - (centerX - MAP_MARGIN), 10 - (centerY - MAP_MARGIN)]
				 drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt];
			} else if (39 - (centerX - MAP_MARGIN) >= 0 && 10 - (centerY - MAP_MARGIN) <= 0) {
				[[NSString stringWithFormat:@"E:%d S:%d", 39 - (centerX - MAP_MARGIN), -(11 - (centerY - MAP_MARGIN))]
				 drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt];
			} else if (39 - (centerX - MAP_MARGIN) <= 0 && 10 - (centerY - MAP_MARGIN) >= 0) {
				[[NSString stringWithFormat:@"W:%d N:%d", -(39 - (centerX - MAP_MARGIN)), 10 - (centerY - MAP_MARGIN)]
				 drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt];
			} else {
				[[NSString stringWithFormat:@"W:%d S:%d", -(39-(centerX-MAP_MARGIN)),-(10-(centerY-MAP_MARGIN))]
				 drawAtPoint:NSMakePoint(57.0,2.0) withAttributes:attributes_alt];
			}
		}
		
		[self unlockFocus];
	}
}

- (void)enemyCheck
{
	enemyCatch = 0;
	
	if (!isReady || TRADITIONAL_MAP) {
		return;
	} else {
		for (int x = 0; x<MAPVIEWSIZE_COLUMN; x++) {
			for (int y = 0; y<MAPVIEWSIZE_ROW; y++) {
				//check enemy
				
				int posx = mapItemValue[x][y].posX - MAP_MARGIN;
				int posy = mapItemValue[x][y].posY - MAP_MARGIN;
				
				if ((posx >= 0 && posx <=78) && (posy >= 0 && posy <= 20)) {
					if (MON_AT(posx, posy) && (!mapItemValue[x][y].player && mapItemValue[x][y].special != 8)) {
						enemyCatch++;
					}
				}
			} // end y
		} // end x
	
		if (enemyCatch && _mapModel.enemyWarnBase != 10 + (enemyCatch*8)) {
			_mapModel.enemyWarnBase = 10 + (enemyCatch*8);
		} else if (_mapModel.enemyWarnBase != 10) {
			_mapModel.enemyWarnBase = 10;
		}
	}
}

//-----------------------------------------------------
//
//	controller
//-----------------------------------------------------


- (void)setKeyBuffer:(int)value
{	 
	switch (modKeyFlag) {
		case MODKEY_SHIFT:
			keyBuffer = (islower(value)) ? toupper(value) : value;
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
	int ret = -1;
	for (int i = 0; extcmdlist[i].ef_txt; i++) {
		if (strstr(extcmdlist[i].ef_txt, excmd) != NULL) {
			ret = i;
			break;
		} else {
			ret = -1;
		}
	}
	return ret;
}

- (IBAction)controllerActions:(id)sender
{
	keyBuffer = 0;
	int lkey = 0;
	
	if ([sender tag] < 50) {
		switch (_mapModel.playerDirection) {
			case NH3DPlayerDirectionForward:
				switch ([sender tag]) {
					case 1:
						lkey = (iflags.num_pad) ? '1' : 'b';
						_messenger.lastAttackDirection = 0;
						break;
					case 2: 
						lkey = (iflags.num_pad) ? '2' : 'j';
						_messenger.lastAttackDirection = 0;
						break;
					case 3: 
						lkey = (iflags.num_pad) ? '3' : 'n';
						_messenger.lastAttackDirection = 0;
						break;
					case 4:
						lkey = (iflags.num_pad) ? '4' : 'h';
						_messenger.lastAttackDirection = 0;
						break;
					case 5:
						lkey = '.';
						_messenger.lastAttackDirection = 0;
						break;
					case 6: 
						lkey = (iflags.num_pad) ? '6' : 'l';
						_messenger.lastAttackDirection = 0;
						break;
					case 7: 
						lkey = (iflags.num_pad) ? '7' : 'y';
						_messenger.lastAttackDirection = 1;
						break;
					case 8: 
						lkey = (iflags.num_pad) ? '8' : 'k';
						_messenger.lastAttackDirection = 2;
						break;
					case 9:
						lkey = (iflags.num_pad) ? '9' : 'u';
						_messenger.lastAttackDirection = 3;
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
			case NH3DPlayerDirectionRight:
				switch ([sender tag]) {
					case 1:
						lkey = (iflags.num_pad) ? '7' : 'y';
						_messenger.lastAttackDirection = 0;
						break;
					case 2: 
						lkey = (iflags.num_pad) ? '4' : 'h';
						_messenger.lastAttackDirection = 0;
						break;
					case 3: 
						lkey = (iflags.num_pad) ? '1' : 'b';
						_messenger.lastAttackDirection = 0;
						break;
					case 4:
						lkey = (iflags.num_pad) ? '8' : 'k';
						_messenger.lastAttackDirection = 0;
						break;
					case 5:
						lkey = '.';
						_messenger.lastAttackDirection = 0;
						break;
					case 6: 
						lkey = (iflags.num_pad) ? '2' : 'j';
						_messenger.lastAttackDirection = 0;
						break;
					case 7: 
						lkey = (iflags.num_pad) ? '9' : 'u';
						_messenger.lastAttackDirection = 4;
						break;
					case 8: 
						lkey = (iflags.num_pad) ? '6' : 'l';
						_messenger.lastAttackDirection = 5;
						break;
					case 9: 
						lkey = (iflags.num_pad) ? '3' : 'n';
						_messenger.lastAttackDirection = 6;
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
			case NH3DPlayerDirectionBack:
				switch ([sender tag]) {
					case 1: 
						lkey = (iflags.num_pad) ? '9' : 'u';
						_messenger.lastAttackDirection = 0;
						break;
					case 2: 
						lkey = (iflags.num_pad) ? '8' : 'k';
						_messenger.lastAttackDirection = 0;
						break;
					case 3: 
						lkey = (iflags.num_pad) ? '7' : 'y';
						_messenger.lastAttackDirection = 0;
						break;
					case 4: 
						lkey = (iflags.num_pad) ? '6' : 'l';
						_messenger.lastAttackDirection = 0;
						break;
					case 5:
						lkey = '.';
						_messenger.lastAttackDirection = 0;
						break;
					case 6: 
						lkey = (iflags.num_pad) ? '4' : 'h';
						_messenger.lastAttackDirection = 0;
						break;
					case 7: 
						lkey = (iflags.num_pad) ? '3' : 'n';
						_messenger.lastAttackDirection = 7;
						break;
					case 8: 
						lkey = (iflags.num_pad) ? '2' : 'j';
						_messenger.lastAttackDirection = 8;
						break;
					case 9: 
						lkey = (iflags.num_pad) ? '1' : 'b';
						_messenger.lastAttackDirection = 9;
						break;
				}
				//[ self setKeyBuffer:lkey ];
				break;
			case NH3DPlayerDirectionLeft:
				switch ([sender tag]) {
					case 1: 
						lkey = (iflags.num_pad) ? '3' : 'n';
						_messenger.lastAttackDirection = 0;
						break;
					case 2: 
						lkey = (iflags.num_pad) ? '6' : 'l';
						_messenger.lastAttackDirection = 0;
						break;
					case 3: 
						lkey = (iflags.num_pad) ? '9' : 'u';
						_messenger.lastAttackDirection = 0;
						break;
					case 4: 
						lkey = (iflags.num_pad) ? '2' : 'j';
						_messenger.lastAttackDirection = 0;
						break;
					case 5:
						lkey = '.';
						_messenger.lastAttackDirection = 0;
						break;
					case 6: 
						lkey = (iflags.num_pad) ? '8' : 'k';
						_messenger.lastAttackDirection = 0;
						break;
					case 7: 
						lkey = (iflags.num_pad) ? '1' : 'b';
						_messenger.lastAttackDirection = 10;
						break;
					case 8: 
						lkey = (iflags.num_pad) ? '4' : 'h';
						_messenger.lastAttackDirection = 11;
						break;
					case 9: 
						lkey = (iflags.num_pad) ? '7' : 'y';
						_messenger.lastAttackDirection = 12;
						break;
				}
				//[self setKeyBuffer:lkey];
				break;
		}
	} else if ([sender tag] < 70) {
		switch ([sender tag]) {
			//ButtonMatrix 1 (window rightside)
			case 51:
				lkey = lastKeyBuffer;
				break;
			case 52:
				lkey = 's';
				break;
			case 53:
				lkey = ',';
				break;
			//ButtonMatrix 2 (window leftside)
			case 61:
				lkey = 'f';
				break;
			case 62:
				lkey = C('d');
				break;
			case 63:
				lkey = 'Z';
				break;
			case 64:
				lkey = 't';
				break;
			case 65:
				lkey = 'o';
				break;
		}
	} else {
		switch ([sender selectedTag]) {
			//Help Buttons
			case 71:
				lkey = ':';
				break;
			case 72:
				lkey = ';';
				break;
		}
	}
	
	self.keyBuffer = lkey;
	lastKeyBuffer = keyBuffer;
	[self setNeedClear:YES];
	[self setKeyUpdated:YES];
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
	switch ([sender tag]) {
		case 0:		/* Remove Many */
			keyBuffer = 'A';
			break;
		case 1:		/* Wield Weapon */
			keyBuffer = 'w';
			break;
		case 2:		/* Exchange Weapon */
			keyBuffer = 'x';
			break;
		case 3:		/* Two Weapon Combat */
			keyBuffer = '#';
			extendKey = [self checkExtendCmdList:"twoweapon"];
			break;
		case 4:		/* Load quiver */
			keyBuffer = 'Q';
			break;
		case 5:		/* Wear Armour */
			keyBuffer = 'W';
			break;
		case 6:		/* Take off Armour */
			keyBuffer = 'T';
			break;
		case 7:		/* Put on non-Armour */
			keyBuffer = 'P';
			break;
		case 8:		/* Remove non-Armour */
			keyBuffer = 'R';
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
		case 0:		/* Again */
			keyBuffer = lastKeyBuffer;
			break;
		case 1:		/* Fight */
			keyBuffer = 'F';
			break;
		case 2:		/* Fire from Quiver */
			keyBuffer = 'f';
			break;
		case 3:		/* Throw */
			keyBuffer = 't';
			break;
		case 4:		/* kick */
			keyBuffer = C('d');
			break;
		case 5:		/* Rest */
			keyBuffer = '.';
			break;
		case 6:		/* Chat */
			keyBuffer = M('c');
			break;
		case 7:		/* Eat */
			keyBuffer = 'e';
			break;
		case 8:		/* Search */
			keyBuffer = 's';
			break;
		case 9:		/* Untrap */
			keyBuffer = M('u');
			break;
		case 10:	/* Force */
			keyBuffer = M('f');
			break;
		case 11:	/* Drop many */
			keyBuffer = 'D';
			break;
		case 12:	/* Drop */
			keyBuffer = 'd';
			break;
		case 13:	/* Get */
			keyBuffer = ',';
			break;
		case 14:	/* Loot */
			keyBuffer = M('l');
			break;
		case 15:	/* Cloase Door */
			keyBuffer = 'c';
			break;
		case 16:	/* Open Door */
			keyBuffer = 'o';
			break;
		case 17:	/* Down */
			keyBuffer = '>';
			break;
		case 18:	/* UP */
			keyBuffer = '<';
			break;
		case 19:	/* Jump */
			keyBuffer = M('j');
			break;
		case 20:	/* Sit */
			keyBuffer = M('s');
			break;
		case 21:	/* Ride */
			keyBuffer = '#';
			extendKey = [self checkExtendCmdList:"ride"];
			break;
		case 22:	/* Pay */
			keyBuffer = 'p';
			break;
		case 23:	/* Wipe Face */
			keyBuffer = M('w');
			break;
		case 24:	/* Apply */
			keyBuffer = 'a';
			break;
		case 25:	/* Engrave */
			keyBuffer = 'E';
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
		case 0:		/* Quaff Potion */
			keyBuffer = 'q';
			break;
		case 1:		/* Read Scroll/Book */
			keyBuffer = 'r';
			break;
		case 2:		/* Zap wand */
			keyBuffer = 'z';
			break;
		case 3:		/* Zap Spell */
			keyBuffer = 'Z';
			break;
		case 4:		/* Dip */
			keyBuffer = M('d');
			break;
		case 5:		/* Rub */
			keyBuffer = M('r');
			break;
		case 6:		/* Invoke */
			keyBuffer = M('i');
			break;
		case 7:		/* Offer */
			keyBuffer = M('o');
			break;
		case 8:		/* Pray */
			keyBuffer = M('p');
			break;
		case 9:		/* Telport */
			keyBuffer = C('t');
			break;
		case 10:	/* Monster Action */
			keyBuffer = M('m');
			break;
		case 11:	/* Turn undead */
			keyBuffer = M('t');
			break;
	}
	
	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}

- (IBAction)infoMenuActions:(id)sender
{
	keyBuffer = 0;
	switch ([sender tag]) {
		case 0: 	/* Inventory */
			keyBuffer = 'i';
			break;
		case 1:		/* Conduct */
			keyBuffer = '#';
			extendKey = [self checkExtendCmdList:"conduct"];
			break;
		case 2:		/* Discoveries */
			keyBuffer = '\\';
			break;
		case 3:		/* list/Reorder spell */
			keyBuffer = '+';
			break;
		case 4:		/* Adjust Letters */
			keyBuffer = M('a');
			break;
		case 5:		/* Name Object */
			keyBuffer = M('n');
			break;
		case 6:		/* Name Object Type */
			keyBuffer = M('n');
			break;
		case 7:		/* Name Creature */
			keyBuffer = 'C';
			break;
		case 8:		/* Qualifications */
			keyBuffer = M('e');
			break;
		case 9:		/* Dungeon Overview */
			keyBuffer = C('o');
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
		case 0:		/* Help */
			keyBuffer = '?';
			break;
		case 1:		/* What is here */
			keyBuffer = ':';
			break;
		case 2:		/* What is there */
			keyBuffer = ';';
			break;
		case 3:		/* What is ... */
			keyBuffer = '/';
			break;
		case 4:		/* NetHack Preferences… */
			keyBuffer = 'O';
			break;
		case 5:		/* Save game */
			keyBuffer = 'S';
			break;
		case 6:		/* Version */
			keyBuffer = 'v';
			break;
		case 7:		/* Compile Info */
			keyBuffer = M('v');
			break;
		case 8:		/* History */
			keyBuffer = 'V';
			break;
		//
		case 20 : 
			if (!iflags.window_inited)
				[NSApp terminate:self]; // early Quit //
			else
				keyBuffer = M('q');  /* Quit without Save */
	}
	
	lastKeyBuffer = keyBuffer;
	self.needClear = YES;
	self.keyUpdated = YES;
}

- (IBAction)setRestrictedView:(id)sender
{	
	[[NSUserDefaults standardUserDefaults] setBool:!((NSCell*)sender).state forKey:NH3DUseSightRestrictionKey];
	[[NSUserDefaultsController sharedUserDefaultsController].values setValue:@(!((NSCell*)sender).state)
																	  forKey:NH3DUseSightRestrictionKey];
	[self setNeedClear:YES];
	[self setNeedsDisplay:YES];
}

- (IBAction)setUseTileInGlobalMap:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:!((NSCell*)sender).state forKey:NH3DUseTileInLevelMapKey];
	[[NSUserDefaultsController sharedUserDefaultsController].values setValue:@(!((NSCell*)sender).state)
																	  forKey:NH3DUseTileInLevelMapKey];
}

- (void)nh3dEventHandlerLoopWithMask:(NSEventMask)mask
{
	//Prevent buffer overflows: pad the character store a bit if strcpy is used.
	char ch[3] = {0};
	
	while (!keyUpdated) {
		@autoreleasepool {
			NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.1];
			
			NSEvent *event = [NSApp nextEventMatchingMask:mask
												untilDate:date
												   inMode:NSDefaultRunLoopMode
												  dequeue:YES];
			
			if (event) {
				if (!_bindController.mainWindow.keyWindow) {
					[NSApp sendEvent:event];
					continue;
				} else {
					switch (event.type) {
						case NSKeyDown:
							if (strlen(event.charactersIgnoringModifiers.UTF8String) < 2) {
								strcpy(ch, event.charactersIgnoringModifiers.UTF8String);
							}
							
							keyBuffer = 0;
							modKeyFlag = MODKEY_NONE;
							
							if (event.keyCode == kVK_LeftArrow) {
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
								ch[0] = (isupper((int)ch[0])) ? tolower((int)ch[0]) : ch[0];
							} else if (event.modifierFlags & NSControlKeyMask) {
								if (ch[0]=='d') {
									[_kickButton performClick:self];
									continue;
								} else {
									modKeyFlag = MODKEY_CTRL;
								}
							}
							
							if (event.modifierFlags & NSEventModifierFlagOption) {
								switch (ch[0]) {
									case 'a':
										[_againButton performClick:self];
										break;
										
									default:
										modKeyFlag = MODKEY_COMMAND;
										self.keyBuffer = (int)ch[0];
										break;
								}
							} else if (getCharMode) {
								self.keyBuffer = (int)ch[0];
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
											[_num2 performClick:self];
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
										if (!iflags.num_pad) {
											self.keyBuffer = (int)ch[0];
											break;
										}
										//fall-though
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
										if (iflags.num_pad) {
											[_num8 performClick:self];
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
										[_fireArrowButton performClick:self];
										break;
										
									case 'Z':
										[_zapSpellButton performClick:self];
										break;
										
									case 't':
										[_throwButton performClick:self];
										break;
										
									case 'o':
										[_openButton performClick:self];
										break;
										
									case 's':
										[_searchButton performClick:self];
										break;
										
									case ',':
										[_pickUpButton performClick:self];
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
										self.keyBuffer = (int)ch[0];
										break;
										
								} // end switch (ch[0])
							}
							lastKeyBuffer = keyBuffer;
							
							[self setNeedClear:YES];
							[self setKeyUpdated:YES];
							break;
							
						case NSLeftMouseUp:
						{
							NSPoint p = event.locationInWindow;
							NSRect bounds = self.bounds;
							downPoint = [self convertPoint:p fromView:nil];
							
							if (!NSPointInRect(downPoint, bounds)) {
								[NSApp sendEvent:event];
								continue;
							} else {
								keyBuffer = 0;
							}
							
							clickType = 1;
							
							if (TRADITIONAL_MAP) {
								int tsizeX,tsizeY,trcpX,trcpY;
								
								tsizeX = (TRADITIONAL_MAP_TILE) ? TILE_SIZE_X : NH3DMAPFONTSIZE;
								tsizeY = (TRADITIONAL_MAP_TILE) ? TILE_SIZE_Y : NH3DMAPFONTSIZE;
								
								trcpX = (centerX - _mapModel.cursX - MAP_MARGIN) + (int)(downPoint.x/tsizeX) - (int)((bounds.size.width/tsizeX) / 2);
								trcpY = (centerY - _mapModel.cursY - MAP_MARGIN) + (int)(downPoint.y/tsizeY) - (int)((bounds.size.height/tsizeY) / 2);
								
								[_mapModel setPosCursorAtX:_mapModel.cursX + trcpX - 1
													   atY:_mapModel.cursY + trcpY  * -1];
								
							} else {
								switch (_mapModel.playerDirection) {
									case NH3DPlayerDirectionForward:
										[_mapModel setPosCursorAtX:_mapModel.cursX+((int)(downPoint.x/16) - viewCursX)
															   atY:_mapModel.cursY+(((int)(downPoint.y/16) - viewCursY)* -1)];
										break;
									case NH3DPlayerDirectionRight:
										[_mapModel setPosCursorAtX:_mapModel.cursX+((int)(downPoint.y/16) - viewCursY)
																atY:_mapModel.cursY+((int)(downPoint.x/16) - viewCursX)];
										break;
									case NH3DPlayerDirectionBack:
										[_mapModel setPosCursorAtX:_mapModel.cursX+(((int)(downPoint.x/16) - viewCursX)* -1)
															   atY:_mapModel.cursY+((int)(downPoint.y/16) - viewCursY)];
										break;
									case NH3DPlayerDirectionLeft:
										[_mapModel setPosCursorAtX:_mapModel.cursX+(((int)(downPoint.y/16) - viewCursY)* -1)
															   atY:_mapModel.cursY+(((int)(downPoint.x/16) - viewCursX)* -1)];
										break;
								}
							}
							
							[self setNeedClear:YES];
							[self setKeyUpdated:YES];
							
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
		NSShadow* sd = [[NSShadow alloc] init];
		sd.shadowOffset = NSMakeSize(2, -2);
		sd.shadowBlurRadius = 3;
		sd.shadowColor = [NSColor blackColor];
		//reset magnification
		_mapLview.enclosingScrollView.magnification = 1;
		int cusx, cusy;
		NSRect mapwindowRect = NSMakeRect(0,0,_mapLpanel.maxSize.width,_mapLpanel.maxSize.height);
		NSSize drawSize;
		NSSize imgSize;
		
		_mapLpanel.backgroundColor = [NSColor clearColor];
		_mapLpanel.opaque = NO;
		
		[_mapLpanel setFrame:mapwindowRect display:NO];
		
		if (TILED_LEVELMAP) {
			mapImage = [[NSImage alloc] initWithSize:NSMakeSize(TILE_SIZE_X * MAPSIZE_COLUMN, TILE_SIZE_Y * MAPSIZE_ROW)];
		} else {
			mapImage = [[NSImage alloc] initWithSize:NSMakeSize(NH3DMAPFONTSIZE * MAPSIZE_COLUMN, NH3DMAPFONTSIZE * MAPSIZE_ROW)];
		}
		
		imgSize = mapImage.size;
		_mapLview.frame = NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height);
		[mapImage lockFocus];
		
		for (int x = 0; x < MAPSIZE_COLUMN; x++) {
			for (int y = 0; y < MAPSIZE_ROW; y++) {
				NH3DMapItem *mapcell = [_mapModel mapArrayAtX:x atY:y];
				
				if (TILED_LEVELMAP) { // Draw Tiled Map.
					NSImage *tileImg;
					if (mapcell.hasBackground) {
						tileImg = mapcell.backgroundTile;
						drawSize = tileImg.size;
						
						[tileImg drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)x,
														 imgSize.height - (drawSize.height * (CGFloat)y))
									fromRect:NSZeroRect
								   operation:NSCompositeSourceOver
									fraction:1.0];
					}
					
					tileImg = mapcell.foregroundTile;
					drawSize = tileImg.size;
					
					[tileImg drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)x,
													 imgSize.height - (drawSize.height * (CGFloat)y))
								fromRect:NSZeroRect
							   operation:NSCompositeSourceOver
								fraction:1.0];
				} else { // Draw ASCII Map.
					NSShadow *lshadow = [[NSShadow alloc] init];
					NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
					
					attributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMAPFONT size: NH3DMAPFONTSIZE];
					
					attributes[NSForegroundColorAttributeName] = [mapcell.color highlightWithLevel:0.2];
					NSString *symbol = mapcell.symbol;
					if (mapcell.hasAlternateSymbol && [mapcell alternateSymbolForDirection:_mapModel.playerDirection]) {
						symbol = [mapcell alternateSymbolForDirection:_mapModel.playerDirection];
					}
					drawSize = [symbol sizeWithAttributes:attributes];
					
					lshadow.shadowOffset = NSMakeSize(0.8, 0.8);
					lshadow.shadowBlurRadius = 5.5;
					lshadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.5];
					
					attributes[NSShadowAttributeName] = lshadow;
					
					[symbol drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)x,
													imgSize.height - (drawSize.height * (CGFloat)y))
						 withAttributes:attributes];
					
					[attributes removeAllObjects];
				}
				
				if (mapcell.hasCursor) { // Check cursor postion and drawing.
					NSSize cursOrigin = posCursor.size;
					cusx = x;
					cusy = y;
					[NSGraphicsContext saveGraphicsState];
					[sd set];
					posCursor.size = drawSize;
					[posCursor drawAtPoint:NSMakePoint(drawSize.width * (CGFloat)x,
													   imgSize.height - (drawSize.height * (CGFloat)y))
								  fromRect:NSZeroRect
								 operation:NSCompositeSourceOver
								  fraction:1.0];
					posCursor.size = cursOrigin;
					[NSGraphicsContext restoreGraphicsState];
				}
				
				if (!(iflags.wc_hilite_pet && mapcell.pet) && !(iflags.hilite_pile && mapcell.pile)) {
					continue;
				}
				
				NSRect petRect = NSMakeRect(drawSize.width * (CGFloat)x,
											imgSize.height - (drawSize.height * (CGFloat)y),
											drawSize.width,
											drawSize.height);
				
				[NSGraphicsContext saveGraphicsState];
				[sd set];
				
				if (iflags.wc_hilite_pet && mapcell.pet) { //draw pet icon
					[_petIcon drawInRect:petRect
								fromRect:NSZeroRect
							   operation:NSCompositeSourceOver
								fraction:1.0];
				}
				
				if (iflags.hilite_pile && mapcell.pile) { //draw pile icon
					[_stackIcon drawInRect:petRect
								  fromRect:NSZeroRect
								 operation:NSCompositeSourceOver
								  fraction:1.0];
				}
				
				[NSGraphicsContext restoreGraphicsState];
			} // end for y
		} // end for x

		drawSize = NSMakeSize((TILED_LEVELMAP) ? TILE_SIZE_X : NH3DMAPFONTSIZE, (TILED_LEVELMAP) ? TILE_SIZE_Y : NH3DMAPFONTSIZE);
		
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
		NSPoint newpt = NSMakePoint(drawSize.width * (CGFloat)(cusx - 7),
									imgSize.height - (drawSize.height * (CGFloat)(cusy + 7)));
		[_mapLview scrollPoint:newpt];
	}
	
	// Sheet is Up.
	[self.window beginSheet:_mapLpanel completionHandler:^(NSModalResponse returnCode) {
		//[self->_mapLview setImage:nil];
	}];
	
	[NSApp runModalForWindow:_mapLpanel];
	
	// Sheet is Over.
	[self.window endSheet:_mapLpanel];
	[self->_mapLview setImage:nil];
}

- (IBAction)closeModalDialog:(id)sender
{
	[NSApp stopModal];
}

- (IBAction)zoomLevelMap:(id)sender
{
	if ([sender tag]) {
		[_mapLview.enclosingScrollView animator].magnification *= 0.75;
	} else {
		[_mapLview.enclosingScrollView animator].magnification *= 1.25;
	}
}

- (void)clipSmallMap
{
	if (TRADITIONAL_MAP) {
		return;
	}
	NSRect inset;
	inset.origin = NSZeroPoint;
	inset.size = self.bounds.size;
	inset = NSInsetRect(inset, SMALL_MAP_BORDER, SMALL_MAP_BORDER);
	NSBezierPath *bPath = [NSBezierPath bezierPathWithRoundedRect:inset xRadius: 48 yRadius: 48];
	[bPath setClip];
}

@end
