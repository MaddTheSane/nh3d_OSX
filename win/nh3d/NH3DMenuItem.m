//
//  NH3DMenuItem.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DMenuItem.h"

extern NH3DTileCache *_NH3DTileCache;

@implementation NH3DMenuItem
@synthesize stringSize;
@synthesize strLength;
@synthesize selectable;
@synthesize selected;

//Override NSObject designated initializer. this is not work!! don't use this.
- (instancetype)init
{
	anything anyChar;
	anyChar.a_char = ' ';
	self = [self initWithParameter:"" identifier:&anyChar accelerator:0 group_accel:0 glyph:0 attribute:0 preSelect:false];
	return nil;
}


// This is designated initializer.
-(instancetype)initWithParameter:(const char*)cName
			identifier:(const anything *)ident
		   accelerator:(char)accel
		   group_accel:(char)gaccel
				 glyph:(int)glf
			 attribute:(int)attr
			 preSelect:(boolean)presel
{
	if (self = [super init]) {
		
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


- (NSAttributedString *)name
{
	NSAttributedString *aStr = nil;
	NSMutableDictionary *strAttributes = [ [NSMutableDictionary alloc] init ];
	
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE];
	
	
	switch ( attribute ) {
		case ATR_NONE:
			break;
		case ATR_ULINE:
			strAttributes[NSUnderlineStyleAttributeName] = @1;
			break;
		case ATR_BOLD:
			strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE];
			break;
		default:
			break;
	}
	
	if ( ! self.selectable ) {
		
		NSShadow *darkShadow = [ [NSShadow alloc] init ];
		darkShadow.shadowColor = [NSColor blackColor] ;
		darkShadow.shadowOffset = NSMakeSize(0,0) ;
		darkShadow.shadowBlurRadius = 6.0 ;
		
		
		strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE];
		strAttributes[NSShadowAttributeName] = darkShadow;
	}
	
	// Set shadow for Cursed/Blessed item.
	
	if ( [ name isLike:NSLocalizedString(@"*blessed*",@"") ]
		|| ( ![ name isLike:NSLocalizedString(@"*called*",@"") ] && [ name isLike:NSLocalizedString(@"*holy water*",@"") ]) ) {
		
		NSShadow *lightShadow = [ [NSShadow alloc] init ];
		lightShadow.shadowColor = [NSColor cyanColor] ;
		lightShadow.shadowOffset = NSMakeSize(0, 0) ;
		lightShadow.shadowBlurRadius = 6.0 ;
		
		strAttributes[NSShadowAttributeName] = lightShadow;
		
		
	} else if ( ([ name isLike:NSLocalizedString(@"*cursed*",@"") ] || [ name isLike:NSLocalizedString(@"*cursed *",@"") ])
			   && ( ![ name isLike:NSLocalizedString(@"*uncursed*",@"") ] && ![ name isLike:NSLocalizedString(@"*called*",@"") ]) ) {
		
		NSShadow *cursedShadow = [[NSShadow alloc] init];
		cursedShadow.shadowColor = [NSColor redColor];
		cursedShadow.shadowOffset = NSMakeSize(0,0);
		cursedShadow.shadowBlurRadius = 6.0;
		
		strAttributes[NSShadowAttributeName] = cursedShadow;
	}
	
	strAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];
	
	aStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ .",name]
										   attributes:strAttributes];
	
	stringSize = [aStr size];
	strLength = name.length;
	
	return aStr;
}

- (NSAttributedString *)accelerator
{
	
	if ( accelerator ) {
		
		NSAttributedString *aStr = nil;
		NSShadow *lightShadow = [ [NSShadow alloc] init ];
		NSMutableDictionary *strAttributes = [ [NSMutableDictionary alloc] init ];
		
		lightShadow.shadowColor = [NSColor cyanColor] ;
		lightShadow.shadowOffset = NSMakeSize(0,0) ;
		lightShadow.shadowBlurRadius = 3.6 ;

		strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE - 2.0];
		strAttributes[NSShadowAttributeName] = lightShadow;
		strAttributes[NSForegroundColorAttributeName] = [NSColor blueColor];
		
		switch ( attribute )
		{
			case ATR_NONE:
				break;
			case ATR_ULINE:
				strAttributes[NSUnderlineStyleAttributeName] = @1;
				break;
			case ATR_BOLD:
				strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE - 2.0];
				break;
			case ATR_BLINK:
			case ATR_INVERSE:
				strAttributes[NSForegroundColorAttributeName] = [NSColor alternateSelectedControlTextColor];
				strAttributes[NSBackgroundColorAttributeName] = [NSColor alternateSelectedControlColor];
		}
		
		aStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",accelerator]
												 attributes:strAttributes];
		
		
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
		NSImage *smallTile = [[NSImage alloc] initWithSize:NSMakeSize(16.0, 16.0)];
		
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
		self.selectable = NO;
	} else {
		self.selectable = YES;
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
