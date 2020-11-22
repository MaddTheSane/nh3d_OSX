//
//  NH3DMapItem.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/06.
//  Copyright 2005 Haruumi Yoshino.
//

#include "C99Bool.h"
#import "NH3DMapItem.h"
#import <QuartzCore/QuartzCore.h>
#import "NetHack3D-Swift.h"
#include <simd/simd.h>

@implementation NH3DMapItem {
	NSRecursiveLock *lock;
	NSImage *tile;
}

@synthesize player;
@synthesize hasAlternateSymbol;
@synthesize hasCursor;
@synthesize position;
@synthesize glyph;
@synthesize cSymbol = symbol;
@synthesize modelDrawingType;
@synthesize special;
@synthesize material = color;
@synthesize bgGlyph;

- (int)posX
{
	return position.x;
}

- (int)posY
{
	return position.y;
}

- (nullable NSString*)alternateSymbolForDirection:(NH3DPlayerDirection)direction;
{
	if (!hasAlternateSymbol) {
		return nil;
	}
	if (SYMHANDLING(H_IBM)) {
		switch (symbol) {
			case -77://179: //│
				if (direction == NH3DPlayerDirectionRight || direction == NH3DPlayerDirectionLeft) {
					return @"─";
				}
				return nil;
				break;
				
			case -60://196: //─
				if (direction == NH3DPlayerDirectionRight || direction == NH3DPlayerDirectionLeft) {
					return @"│";
				}
				return nil;
				break;
				
			case -65://191: //┐
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"┌";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"└";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"┘";
						//return @"\u2518";
						break;

					default:
						break;
				}
				break;
				
			case -64://192: //└
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"┘";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"┐";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"┌";
						break;
						
					default:
						break;
				}
				break;

			case -39://217: //┘
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"┐";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"┌";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"└";
						break;
						
					default:
						break;
				}
				break;

			case -38://218: //┌
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"└";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"┘";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"┐";
						break;
						
					default:
						break;
				}
				break;

			case -63://193: //┴
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"┤";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"┬";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"├";
						break;
						
					default:
						break;
				}
				break;
				
			case -61://195: //├
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"┴";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"┤";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"┬";
						break;
						
					default:
						break;
				}
				break;

			case -62://194: //┬
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"├";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"┴";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"┤";
						break;
						
					default:
						break;
				}
				break;

			case -76://180: //┤
				switch (direction) {
					case NH3DPlayerDirectionForward:
						return nil;
						break;
						
					case NH3DPlayerDirectionRight:
						return @"┬";
						break;
						
					case NH3DPlayerDirectionBack:
						return @"├";
						break;
						
					case NH3DPlayerDirectionLeft:
						return @"┴";
						break;
						
					default:
						break;
				}
				break;

			default:
				return nil;
				break;
		}
	}
	if (direction == NH3DPlayerDirectionForward || direction == NH3DPlayerDirectionBack) {
		return nil;
	}
	switch (symbol) {
		case '-':
			return @"|";
			break;
			
		case '|':
			return @"-";
			break;
			
		default:
			break;
	}
	return nil;
}

- (void)checkDrawingType
{
	// Quiet undefined behavior warnings
	if ((position.x-MAP_MARGIN) < 0 || (position.y-MAP_MARGIN) < 0 || position.y-MAP_MARGIN >= ROWNO || position.x-MAP_MARGIN >= COLNO) {
		modelDrawingType = NH3DModelDrawingBlackWall;
		return;
	}
	
	if (glyph ==  S_stone+GLYPH_CMAP_OFF &&
		(!IS_ROOM(levl[position.x-MAP_MARGIN][position.y-MAP_MARGIN].typ) && !IS_WALL(levl[position.x-MAP_MARGIN][position.y-MAP_MARGIN].typ))) {
		// draw type is corrwall object (10 = stone wall type / 0 = black wall type)
		modelDrawingType = NH3DModelDrawingBlackWall;
	} else if (player) {
		// draw type is playerpositon
		modelDrawingType = NH3DModelDrawingPlayerPosition;
	} else {
		switch (glyph) {
			case S_stone + GLYPH_CMAP_OFF:
				modelDrawingType = (IS_WALL(levl[position.x-MAP_MARGIN][position.y-MAP_MARGIN].typ)
									|| IS_STWALL(levl[position.x-MAP_MARGIN][position.y-MAP_MARGIN].typ)
									|| IS_DOOR(levl[position.x-MAP_MARGIN][position.y-MAP_MARGIN].typ)) ? NH3DModelDrawingBlackWall : NH3DModelDrawingPlayerPosition;
				break;
			case S_room + GLYPH_CMAP_OFF:
			case S_corr + GLYPH_CMAP_OFF:
			case S_litcorr  + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingCorridor;
				break;
			case S_pool + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingPool;
				break;
				
			case S_ice + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingIce;
				break;
				
			case S_lava + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingLava;
				break;
				
			case S_air + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingAir;
				break;
				
			case S_cloud + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingCloud;
				break;
				
			case S_water + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingWater;
				break;
				
			case S_dnstair + GLYPH_CMAP_OFF:
			case S_dnladder + GLYPH_CMAP_OFF:
			case S_pit + GLYPH_CMAP_OFF:
			case S_spiked_pit + GLYPH_CMAP_OFF:
			case S_trap_door + GLYPH_CMAP_OFF:
			case S_hole + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingHole;
				break;
				
			case PM_HIGH_PRIEST + GLYPH_MON_OFF:
			case PM_MEDUSA + GLYPH_MON_OFF:
			case PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF:
			case PM_CROESUS + GLYPH_MON_OFF:
			case PM_JUIBLEX + GLYPH_MON_OFF:
			case PM_YEENOGHU + GLYPH_MON_OFF:
			case PM_ORCUS + GLYPH_MON_OFF:
			case PM_GERYON + GLYPH_MON_OFF:
			case PM_DISPATER + GLYPH_MON_OFF:
			case PM_BAALZEBUB + GLYPH_MON_OFF:
			case PM_ASMODEUS + GLYPH_MON_OFF:
			case PM_DEMOGORGON + GLYPH_MON_OFF:
			case PM_DEATH + GLYPH_MON_OFF:
			case PM_PESTILENCE + GLYPH_MON_OFF:
			case PM_FAMINE + GLYPH_MON_OFF:
				
			case S_sink + GLYPH_CMAP_OFF:
			case S_fountain + GLYPH_CMAP_OFF:
			case S_sleeping_gas_trap + GLYPH_CMAP_OFF:
			case S_rust_trap + GLYPH_CMAP_OFF:
			case S_fire_trap + GLYPH_CMAP_OFF:
			case S_teleportation_trap + GLYPH_CMAP_OFF:
			case S_level_teleporter + GLYPH_CMAP_OFF:
			case S_magic_portal + GLYPH_CMAP_OFF:
			case S_magic_trap + GLYPH_CMAP_OFF:
			case S_anti_magic_trap + GLYPH_CMAP_OFF:
			case S_polymorph_trap + GLYPH_CMAP_OFF:
			case S_vibrating_square + GLYPH_CMAP_OFF:
			case S_digbeam + GLYPH_CMAP_OFF:
			case S_flashbeam + GLYPH_CMAP_OFF:
			case S_ss1 + GLYPH_CMAP_OFF:
			case S_ss2 + GLYPH_CMAP_OFF:
			case S_ss3 + GLYPH_CMAP_OFF:
			case S_ss4 + GLYPH_CMAP_OFF:
				modelDrawingType = NH3DModelDrawingModel3D;
				break;
				
			default :
				modelDrawingType = ((glyph >= PM_LORD_CARNARVON + GLYPH_MON_OFF && glyph <= PM_DARK_ONE + GLYPH_MON_OFF)
									|| (glyph >= GLYPH_EXPLODE_OFF && glyph < GLYPH_SWALLOW_OFF)) ? NH3DModelDrawingModel3D : NH3DModelDrawingCorridor;
				break;
		}
	}
}


/// Override NSObject designated initializer. Normally don't use this.
- (instancetype) init {
	return [self initWithParameter:' '
							 glyph:S_stone+GLYPH_CMAP_OFF
							 color:0
							  posX:0
							  posY:0
						   special:0
						   bgGlyph:NO_GLYPH];
}

// This is designated initializer.
- (instancetype)initWithParameter:(char)ch 
							glyph:(int)glf
							color:(int)col
							 posX:(int)x
							 posY:(int)y
						  special:(int)sp
						  bgGlyph:(int)bg
{
	if (self = [super init]) {
		lock = [[NSRecursiveLock alloc] init];
		
		[lock lock];
		
		symbol = ch;
		glyph = glf;
		color = col;
        position = simd_make_int2(x, y);
		special = sp;
		player = NO;
		hasAlternateSymbol = NO;
		hasCursor = NO;
		bgGlyph = bg;
		
		[self checkDrawingType];
		
		[lock unlock];
	}
	return self;
}

- (BOOL)isCorpse
{
	return (special & MG_CORPSE) == MG_CORPSE;
}

- (BOOL)isInvis
{
	return (special & MG_INVIS) == MG_INVIS;
}

- (BOOL)isDetected
{
	return (special & MG_DETECT) == MG_DETECT;
}

- (BOOL)isPet
{
	return (special & MG_PET) == MG_PET;
}

- (BOOL)wasRidden
{
	return (special & MG_RIDDEN) == MG_RIDDEN;
}

- (BOOL)isStatue
{
	return (special & MG_STATUE) == MG_STATUE;
}

- (BOOL)isPile
{
	return (special & MG_OBJPILE) == MG_OBJPILE;
}

- (NSString *)symbol
{
	if (SYMHANDLING(H_IBM)) {
		const char tinyStr[] = {symbol, 0};
		NSString *toRet = CFBridgingRelease(CFStringCreateWithCString(kCFAllocatorDefault, tinyStr, kCFStringEncodingDOSLatinUS));
		return toRet;
	} else {
		return [NSString stringWithFormat:@"%c", symbol];
	}
}

- (NSColor *)color
{
	NSColor *aColor;
	
	switch (color) {
		case CLR_BLACK:
			aColor = [NSColor darkGrayColor];
			break;
		case CLR_RED:
			aColor = [NSColor redColor];
			break;
		case CLR_GREEN:
			aColor = [NSColor greenColor];
			break;
		case CLR_BROWN:
			aColor = [NSColor brownColor];
			break;
		case CLR_BLUE:
			aColor = [NSColor blueColor];
			break;
		case CLR_MAGENTA:
			aColor = [NSColor magentaColor];
			break;
		case CLR_CYAN:
			aColor = [NSColor cyanColor];
			break;
		case CLR_GRAY:
			aColor = [NSColor grayColor];
			break;
		case NO_COLOR:
			aColor = [[NSColor grayColor] highlightWithLevel:0.5];
			break;
		case CLR_ORANGE:
			aColor = [NSColor orangeColor];
			break;
		case CLR_BRIGHT_GREEN:
			aColor = [[NSColor greenColor] highlightWithLevel:0.5];
			break;
		case CLR_YELLOW:
			aColor = [NSColor yellowColor];
			break;
		case CLR_BRIGHT_BLUE:
			aColor = [[NSColor blueColor] highlightWithLevel:0.5];
			break;
		case CLR_BRIGHT_MAGENTA:
			aColor = [[NSColor magentaColor] highlightWithLevel:0.5];
			break;
		case CLR_BRIGHT_CYAN:
			aColor = [[NSColor cyanColor] highlightWithLevel:0.5];
			break;
		case CLR_WHITE:
			aColor = [NSColor whiteColor];
			break;
		default:
			aColor = [NSColor windowBackgroundColor];
			break;
	}

	return aColor;
}

- (void)setPlayer:(BOOL)flag
{
	[lock lock];
	player = flag;
	[self checkDrawingType];
	[lock unlock];
}

- (void)setCSymbol:(char)chr
{
	[lock lock];
	symbol = chr;
	[self checkDrawingType];
	//[self clearTileCache];
	tile = nil;
	[lock unlock];
}

- (void)setHasAlternateSymbol:(BOOL)flag
{
	[lock lock];
	hasAlternateSymbol = flag;
	[lock unlock];
}

- (void)setHasCursor:(BOOL)flag
{
	[lock lock];
	hasCursor = flag;
	[lock unlock];
}

- (BOOL)hasBackground
{
	return bgGlyph != NO_GLYPH && bgGlyph != glyph;
}

- (NSImage *)tile
{
	if (tile) {
		return tile;
	}
	NSImage *tmpTile = self.foregroundTile;
	if (!tmpTile) {
		return nil;
	}
	
	NSImage *bgtile = nil;
	if ([self hasBackground]) {
		bgtile = self.backgroundTile;
	}
	if (bgtile != nil) {
		NSImage *tmpFG = tmpTile;
		tmpTile = [bgtile copy];
		[tmpTile lockFocus];
		[tmpFG drawInRect:NSMakeRect(0, 0, tmpTile.size.width, tmpTile.size.height)];
		[tmpTile unlockFocus];
	}
	
	[lock lock];
	tile = tmpTile;
	[lock unlock];
	return tmpTile;
}

- (NSImage *)foregroundTile
{
	if (glyph != S_stone + GLYPH_CMAP_OFF)
		return [TileSet.instance imageForGlyph:glyph];
	else 
		return nil;
}

- (NSImage *)backgroundTile
{
	if ((bgGlyph != (S_stone + GLYPH_CMAP_OFF)) && bgGlyph != NO_GLYPH)
		return [TileSet.instance imageForGlyph:bgGlyph];
	else
		return nil;
}

- (void)clearTileCache
{
	[lock lock];
	tile = nil;
	[lock unlock];
}

@end
