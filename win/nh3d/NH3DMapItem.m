//
//  NH3DMapItem.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/06.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DMapItem.h"
#import "NH3DTileCache.h"

#import "NetHack3D-Swift.h"

/*from winnh3d.m*/
extern NH3DTileCache *_NH3DTileCache;

@implementation NH3DMapItem
@synthesize player;
@synthesize hasAlternateSymbol;
@synthesize hasCursor;
@synthesize posX;
@synthesize posY;
@synthesize glyph;
@synthesize cSymbol = symbol;
@synthesize modelDrawingType;

- (void)checkDrawingType
{
	
	if ( glyph ==  S_stone+GLYPH_CMAP_OFF &&
		 (!IS_ROOM( levl[posX-MAP_MARGIN][posY-MAP_MARGIN].typ ) && !IS_WALL( levl[posX-MAP_MARGIN][posY-MAP_MARGIN].typ ) )
		 ) {	
	// draw type is corrwall object (10 = stone wall type / 0 = black wall type) 
		modelDrawingType = 0 ;	
	} else if ( player ) {
	// draw type is playerpositon
		modelDrawingType = 1;
		
	} else {
		
		switch (glyph) {
			case S_stone + GLYPH_CMAP_OFF:
				modelDrawingType = (    IS_WALL( levl[posX-MAP_MARGIN][posY-MAP_MARGIN].typ ) 
									 || IS_STWALL( levl[posX-MAP_MARGIN][posY-MAP_MARGIN].typ )
									 || IS_DOOR( levl[posX-MAP_MARGIN][posY-MAP_MARGIN].typ) ) ? 0 : 1 ;
				break;				
			case S_room + GLYPH_CMAP_OFF:
			case S_corr + GLYPH_CMAP_OFF:
			case S_litcorr  + GLYPH_CMAP_OFF:
				modelDrawingType = 3;
				break;
			case S_pool + GLYPH_CMAP_OFF: modelDrawingType = 4;
				break;
			
			case S_ice + GLYPH_CMAP_OFF: modelDrawingType = 5;
				break;
			
			case S_lava + GLYPH_CMAP_OFF: modelDrawingType = 6;
				break;
			
			case S_air + GLYPH_CMAP_OFF: modelDrawingType = 7;
				break;

			case S_cloud + GLYPH_CMAP_OFF: modelDrawingType = 8;
				break;

			case S_water + GLYPH_CMAP_OFF: modelDrawingType = 9;
				break;
				
			case S_dnstair + GLYPH_CMAP_OFF:
			case S_dnladder + GLYPH_CMAP_OFF:
			case S_pit + GLYPH_CMAP_OFF:
			case S_spiked_pit + GLYPH_CMAP_OFF:
			case S_trap_door + GLYPH_CMAP_OFF:
			case S_hole + GLYPH_CMAP_OFF:
				
				modelDrawingType = 2;
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
			case S_digbeam + GLYPH_CMAP_OFF:
			case S_flashbeam + GLYPH_CMAP_OFF:
			case S_ss1 + GLYPH_CMAP_OFF:
			case S_ss2 + GLYPH_CMAP_OFF:
			case S_ss3 + GLYPH_CMAP_OFF:
			case S_ss4 + GLYPH_CMAP_OFF:
				
				modelDrawingType = 10;
				break;
				
			default :
				modelDrawingType = ( (glyph >= PM_LORD_CARNARVON + GLYPH_MON_OFF && glyph <= PM_DARK_ONE + GLYPH_MON_OFF)
									 || (glyph >= GLYPH_EXPLODE_OFF && glyph < GLYPH_SWALLOW_OFF) ) ? 10 : 3 ;
				break;
		}
	}
				
}





//Over wride NSObject designated initializer. Normary dont use this.
- (instancetype) init {
	
	return [ self initWithParameter:' ' 
							  glyph:S_stone+GLYPH_CMAP_OFF 
							  color:0 
							   posX:0 
							   posY:0
						    special:0 ];
}


// This is designated initializer.
- (instancetype)initWithParameter:(char)ch 
				  glyph:(int)glf 
				  color:(int)col 
				   posX:(int)x 
				   posY:(int)y 
				special:(int)sp
{
	
	self = [ super init ];
	if ( self != nil ) {
		
		lock = [ [NSRecursiveLock alloc] init ];
		
		[ lock lock ];
		
		symbol = ch;
		glyph = glf;
		color = col;
		posX = x;
		posY = y;
		special = sp;
		player = NO;
		hasAlternateSymbol = NO;
		hasCursor = NO;
		
		//tile = nil;
		
		[ self checkDrawingType ];
		
		[ lock unlock ];
	}
	return self;
}




- (NSString *)symbol
{
	return [ NSString stringWithFormat:@"%c",symbol ];
}


- (NSColor *)color
{
	NSColor *aColor;
	
	switch (color) {
		case 0:
			aColor = [ NSColor darkGrayColor ];
			break;
		case 1:
			aColor = [ NSColor redColor ];
			break;
		case 2:	aColor = [ NSColor greenColor ];
			break;
		case 3:
			aColor = [ NSColor brownColor ];
			break;
		case 4:
			aColor = [ NSColor blueColor ];
			break;
		case 5:
			aColor = [ NSColor magentaColor ];
			break;
		case 6:
			aColor = [ NSColor cyanColor ];
			break;
		case 7:
			aColor = [ NSColor grayColor ];
			break;
		case 8:
			aColor = [ [NSColor grayColor] highlightWithLevel:0.5 ];
			break;
		case 9:
			aColor = [ NSColor orangeColor ];
			break;
		case 10:
			aColor = [ [NSColor greenColor] highlightWithLevel:0.5 ];
			break;
		case 11:
			aColor = [ NSColor yellowColor ];
			break;
		case 12:
			aColor = [ [NSColor blueColor] highlightWithLevel:0.5 ];
			break;
		case 13:
			aColor = [ [NSColor magentaColor] highlightWithLevel:0.5 ];
			break;
		case 14:
			aColor = [ [NSColor cyanColor] highlightWithLevel:0.5 ];
			break;
		case 15:
			aColor = [ NSColor whiteColor ];
			break;
		default:
			aColor = [ NSColor windowBackgroundColor ];
	}

	return aColor;
}

- (int)material
{
	return color;
}

- (unsigned)special
{
	return special;
}


- (void)setPlayer:(BOOL)flag
{
	[ lock lock ];
	player = flag;
	[ self checkDrawingType ];	
	[ lock unlock ];
	 
}


- (void)setSymbol:(char)chr
{
	[ lock lock ]; 
	symbol = chr;
	[ self checkDrawingType ];
	[ lock unlock ];
	 
}

- (void)setHasAlternateSymbol:(BOOL)flag
{
	 
	[ lock lock ];
	hasAlternateSymbol = flag;
	[ lock unlock ];
}

- (void)setHasCursor:(BOOL)flag
{
	[ lock lock ]; 
	hasCursor = flag;
	[ lock unlock ];
}

- (NSImage *)tile
{	
	
/*	if ( tile == nil && glyph != S_stone + GLYPH_CMAP_OFF ) {
		NSImage *img = [ [_NH3DTileCache tileImageFromGlyph:glyph] retain ];
		tile = [ img copy ];
		[ img release ]; 
	}*/
	if ( glyph != S_stone + GLYPH_CMAP_OFF )
		return [_NH3DTileCache tileImageFromGlyph:glyph];
	else 
		return nil;
}

@end
