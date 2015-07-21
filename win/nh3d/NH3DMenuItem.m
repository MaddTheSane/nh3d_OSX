//
//  NH3DMenuItem.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DMenuItem.h"

extern id _NH3DTileCache;

@implementation NH3DMenuItem
@synthesize stringSize;
@synthesize strLength;
@synthesize selectable;
@synthesize selected;

//Over wride NSObject designated initializer. this is not work!! don't use this.
- (id)init
{
	return nil;
}


// This is designated initializer.
-(id)initWithParameter:(const char*)cName
			identifier:(const anything *)ident
		   accelerator:(char)accel
		   group_accel:(char)gaccel
				 glyph:(int)glf
			 attribute:(int)attr
			 preSelect:(boolean)presel
{
	self = [ super init ];
	if ( self != nil ) {
		
		name = [ [NSString alloc] initWithCString:cName
										 encoding:NH3DTEXTENCODING ];
		identifier = *ident;
		if ( ident->a_void == 0 ) {
			[ self setSelectable:NO ];
		} else {
			[ self setSelectable:YES ];
		}
		accelerator = accel;
		group_accel = gaccel;
		glyph = glf;
		attribute = attr;
		preselect = presel;
	}
	return self;
}



- (void)dealloc
{
	//[ img release ];
	[ name release ];
	[ super dealloc ];
}


- (NSAttributedString *)name
{
	NSAttributedString *aStr = nil;
	NSMutableDictionary *strAttributes = [ [NSMutableDictionary alloc] init ];
	
	[ strAttributes setObject:[NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE]
					   forKey:NSFontAttributeName ];
		
	
	switch ( attribute )
	{
		case ATR_NONE:
		break;
		case ATR_ULINE:
			[ strAttributes setObject:[NSNumber numberWithInt:1]
							   forKey:NSUnderlineStyleAttributeName ];
		break;
		case ATR_BOLD:
			[ strAttributes setObject:[NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE]
							   forKey:NSFontAttributeName ];
		break;
		default:
		break;
	}
	
	if ( ![ self isSelectable ] ) {
		
		NSShadow *darkShadow = [ [NSShadow alloc] init ];
		[ darkShadow setShadowColor:[NSColor blackColor] ];
		[ darkShadow setShadowOffset:NSMakeSize(0,0) ];
		[ darkShadow setShadowBlurRadius:6.0 ];
		
		
		[ strAttributes setObject:[NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE]
						   forKey:NSFontAttributeName ];
		[ strAttributes setObject:darkShadow
						   forKey:NSShadowAttributeName ];
		
		[ darkShadow release ];
	
	} 

// Set shadow for Cursed/Blessed item.	
		
	if ( [ name isLike:NSLocalizedString(@"*blessed*",@"") ] 
		 || ( ![ name isLike:NSLocalizedString(@"*called*",@"") ] && [ name isLike:NSLocalizedString(@"*holy water*",@"") ]) ) {
		
		NSShadow *lightShadow = [ [NSShadow alloc] init ];
		[ lightShadow setShadowColor:[NSColor cyanColor] ];
		[ lightShadow setShadowOffset:NSMakeSize(0, 0) ];
		[ lightShadow setShadowBlurRadius:6.0 ];
				
		[ strAttributes setObject:lightShadow
						   forKey:NSShadowAttributeName ];
		
		[ lightShadow release ];
		
	} else if ( ([ name isLike:NSLocalizedString(@"*cursed*",@"") ] || [ name isLike:NSLocalizedString(@"*cursed *",@"") ])
				&& ( ![ name isLike:NSLocalizedString(@"*uncursed*",@"") ] && ![ name isLike:NSLocalizedString(@"*called*",@"") ]) ) {

		NSShadow *cursedShadow = [ [NSShadow alloc] init ];
		[ cursedShadow setShadowColor:[NSColor redColor] ];
		[ cursedShadow setShadowOffset:NSMakeSize(0,0) ];
		[ cursedShadow setShadowBlurRadius:6.0 ];
		
		[ strAttributes setObject:cursedShadow
		  				   forKey:NSShadowAttributeName ];
		
		[ cursedShadow release ];

	}

	[ strAttributes setObject:[NSColor whiteColor]
					   forKey:NSForegroundColorAttributeName ];

	aStr = [ [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ .",name]
											 attributes:strAttributes] autorelease ];
	
	stringSize = [ aStr size ];
	strLength = [ name length ];
		
	[ strAttributes release ];
	
	return aStr;
}

- (NSAttributedString *)accelerator
{
	
	if ( accelerator ) {
		
		NSAttributedString *aStr = nil;
		NSShadow *lightShadow = [ [NSShadow alloc] init ];
		NSMutableDictionary *strAttributes = [ [NSMutableDictionary alloc] init ];
		
		[ lightShadow setShadowColor:[NSColor cyanColor] ];
		[ lightShadow setShadowOffset:NSMakeSize(0,0) ];
		[ lightShadow setShadowBlurRadius:3.6 ];

		[ strAttributes setObject:[NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE - 2.0]
						   forKey:NSFontAttributeName ];
		[ strAttributes setObject:lightShadow
						   forKey:NSShadowAttributeName ];
		[ strAttributes setObject:[NSColor blueColor]
						   forKey:NSForegroundColorAttributeName ];
		
		switch ( attribute )
		{
			case ATR_NONE:
				break;
			case ATR_ULINE:
				[ strAttributes setObject:[NSNumber numberWithInt:1]
								   forKey:NSUnderlineStyleAttributeName ];
				break;
			case ATR_BOLD:
				[ strAttributes setObject:[NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE - 2.0]
								   forKey:NSFontAttributeName ];
				break;
			case ATR_BLINK:
			case ATR_INVERSE:
				[ strAttributes setObject:[NSColor alternateSelectedControlTextColor]
								   forKey:NSForegroundColorAttributeName ];
				[ strAttributes setObject:[NSColor alternateSelectedControlColor]
								   forKey:NSBackgroundColorAttributeName ];
		}
		
		aStr = [ [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",accelerator]
												 attributes:strAttributes] autorelease ];
		
		[ lightShadow release ];
		[ strAttributes release ];
		
		return aStr;
		
	} else 
		return nil;
}


- (NSImage *)glyph
{
	if ( glyph == NO_GLYPH ) {
		return nil;
	} else {

		return [_NH3DTileCache tileImageFromGlyph:glyph];
	}
}


- (NSImage *)smallGlyph
{
	if ( glyph == NO_GLYPH ) {
		return nil;
	} else if ( [ _NH3DTileCache tileSize_X ] == 16 && [ _NH3DTileCache tileSize_Y ] == 16 ) {
		return [_NH3DTileCache tileImageFromGlyph:glyph];
	} else {
		NSImage *smallTile = [ [[NSImage alloc] initWithSize:NSMakeSize(16.0, 16.0)] autorelease ];
		
		[ smallTile lockFocus ];
		[ [_NH3DTileCache tileImageFromGlyph:glyph] drawInRect:NSMakeRect( 0, 0, 16.0 , 16.0 )
													  fromRect:NSZeroRect
													 operation:NSCompositeSourceOver
													  fraction:1.0 ];
		[ smallTile unlockFocus ];
		
		return smallTile;
	}
	
}


- (anything)identifier
{
	return identifier;
}


- (BOOL)isPreSelected
{
	if ( preselect == MENU_SELECTED ) {
		return YES;
	} else
		return NO;
}


- (void)setName:(const char*)nameStr
{
	name = [ NSString stringWithCString:nameStr
							   encoding:NH3DTEXTENCODING ];
}


- (void)setIdentifier:(const ANY_P *)identifierValue
{
	identifier = *identifierValue;
	if ( identifierValue->a_void == 0 ) {
		[ self setSelectable:NO ];
	} else {
		[ self setSelectable:YES ];
	}
}


- (void)setAccelerator:(CHAR_P)acceleratorValue
{
	accelerator = acceleratorValue;
}


- (void)setGroup_accel:(CHAR_P)group_accelValue
{
	group_accel = group_accelValue;
}


- (void)setGlyph:(int)glyphValue
{
	glyph = glyphValue;
}

- (void)setAttribute:(int)attrValue
{
	attribute = attrValue;
}


- (void)setPreselect:(BOOLEAN_P)preselectValue
{
	preselect = preselectValue;
}

@end
