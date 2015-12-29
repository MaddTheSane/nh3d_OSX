/* NH3DUserStatusModel */
//
//  NH3DUserStatusModel.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//


#import "NH3DUserStatusModel.h"

extern const char *enc_stat[ ]; /* from botl.c */
extern const char *hu_stat[ ]; /* from eat.c */

#define DIALOG_OK		 128
#define DIALOG_CANCEL	 129


//from nh3d_win.m
extern NH3DTileCache *_NH3DTileCache;


@implementation NH3DUserStatusModel
@synthesize playerDex;
@synthesize playerCon;
@synthesize playerInt;
@synthesize playerWis;
@synthesize playerCha;

@synthesize playerGold;
@synthesize playerScore;
@synthesize playerTime;
@synthesize playerExp;

@synthesize playerHp;
@synthesize playerMaxhp;
@synthesize playerPow;
@synthesize playerMaxpow;
@synthesize playerAc;
@synthesize playerLv;

- (instancetype)init
{
    if (self = [super init]) {
		shadow = [[NSShadow alloc] init];
		style = [[NSMutableParagraphStyle alloc] init];
		strAttributes = [[NSMutableDictionary alloc] init];
		
		[ self setPlayerCriticalHp: 0 ];
		[ self setPlayerCriticalPow:0 ];
		[ self setPlayerWaningHp: 0 ];
		[ self setPlayerWaningPow: 0 ];
		
		[ self setPlayerName:@"" ];
		[ self setPlayerClass:@"" ];
		[ self setPlayerMaxhp:9999 ];
		[ self setPlayerMaxpow:9999 ];
		[ self setPlayerHp:9999 ];
		[ self setPlayerPow:9999 ];
		[ self setPlayerStr:9999 ];
		[ self setPlayerDex:9999 ];
		[ self setPlayerCon:9999 ];
		[ self setPlayerInt:9999 ];
		[ self setPlayerWis:9999 ];
		[ self setPlayerCha:9999 ];
		[ self setPlayerGold:9999 ];
		[ self setPlayerScore:9999 ];
		[ self setPlayerTime:9999 ];
		[ self setPlayerExp:9999 ];
		[ self setPlayerAc:-9999 ];
		[ self setPlayerLv:9999 ];

		[ self setStrUpdate:NO ];
		[ self setHpUpdate:NO ];
		[ self setDexUpdate:NO ];
		[ self setConUpdate:NO ];
		[ self setIntUpdate:NO ];
		[ self setWisUpdate:NO ];
		[ self setChaUpdate:NO ];
		[ self setLvUpdate:NO ];
		[ self setPowUpdate:NO ];
		[ self setAcUpdate:NO ];
				
		firstTime = YES;
    }
    return self;
}

- (void)prepareAttributes
{
	shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.1 alpha:0.8];
	shadow.shadowOffset = NSMakeSize(2, -2);
	shadow.shadowBlurRadius = 0.5;
			
	style.alignment = NSCenterTextAlignment;
			
	
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT size: 14];
	strAttributes[NSShadowAttributeName] = shadow;
	strAttributes[NSParagraphStyleAttributeName] = style;
}
/*
- ( id )initWithCoder:( NSCoder * )coder
{
	[ super init ];
	[ self setPlayerName:[ coder decodeObjectForKey:@"playerName" ] ];
	[ self setPlayerClass:[ coder decodeObjectForKey:@"playerClass" ] ];
	[ self setPlayerRace:[ coder decodeObjectForKey:@"playerRace" ] ];
	[ self setPlayerRole:[ coder decodeObjectForKey:@"playerRole" ] ];
	[ self setPlayerAlign:[ coder decodeObjectForKey:@"playerAlign" ] ];
	[ self setPlayerGender:[ coder decodeObjectForKey:@"playerGender" ] ];
	return self;
}

- (void)encodeWithCoder:( NSCoder * )coder
{
	[ coder encodeObject:playerName forKey:@"playerName" ];
	[ coder encodeObject:playerClass forKey:@"playerClass" ];
	[ coder encodeObject:playerRace forKey:@"playerRace" ];
	[ coder encodeObject:playerRole forKey:@"playerRole" ];
	[ coder encodeObject:playerAlign forKey:@"playerAlign" ];
	[ coder encodeObject:playerGender forKey:@"playerGender" ];
}
*/

- (void)awakeFromNib {
	[ self prepareAttributes ];
	[ self setPlayerArmour:0 ];
	[ self setPlayerCloak:0 ];
	[ self setPlayerHelmet:0 ];
	[ self setPlayerShield:0 ];
	[ self setPlayerGloves:0 ];
	[ self setPlayerShoes:0 ];
	[ self setPlayerRingL:0 ];
	[ self setPlayerRingR:0 ];
	[ self setPlayerWeapon:0 ];
	[ self setPlayerSubWeapon:0 ];
	[ self setPlayerAmulet:0 ];
	[ self setPlayerBlindFold:0 ];
	
}


/*
- (void)controlTextDidChange:( NSNotification * )notification
{	
	if ( [ [ inputName stringValue ] isEqual:@"" ] || [ [ inputName stringValue ] cStringLength ] >= PL_NSIZ-11 ) {
		[ self setPlayerName:[ NSString stringWithFormat:@"%@%d%@",@"input 1to",PL_NSIZ-12,@"Chars." ] ];
		[ self setDone_name:NO ];
	}
	else {
		[ self setPlayerName:[ inputName stringValue ] ];
		[ self setDone_name:YES ];
	}
}
*/
//
//

- (NSAttributedString *)playerName
{
	int fSize;
	switch ( playerName.length ) {
		case 15:
		case 16:
			fSize = 16;
			break;
		case 17:
		case 18:
			fSize = 14;
			break;
		case 19:
		case 20:
			fSize = 12;
			break;
		default:
			fSize = 17;
	}
	
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT
														 size:fSize];
	return [[NSAttributedString alloc] initWithString:playerName
										   attributes:strAttributes];
}

- (NSString*)playerRole 
{
	return playerRole;
}

- (NSString*)playerRace 
{
	return playerRace;
}

- (NSString*)playerAlign 
{
	return playerAlign;
}

- (NSString*)playerGender 
{
	return playerGender;
}

- (NSAttributedString *)playerClass
{
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT
														 size: 13];
	return [[NSAttributedString alloc] initWithString:playerClass
										   attributes:strAttributes];
}

- (NSString*)playerStatusLine
{
	return playerStatusLine;
}

- (float)playerWaningHp 
{
	return playerWaningHp;
}

- (float)playerCriticalHp 
{
	return playerCriticalHp;
}

- (float)playerWaningPow
{
	return playerWaningPow;
}

- (float)playerCriticalPow 
{
	return playerCriticalPow;
}

- (NSImage*)playerArmour
{
	return playerArmour;
}

- (void)setPlayerArmour:(int)glyph
{
	if ( !glyph ) {
		playerArmour = nil;
	} else {
		playerArmour = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerCloak
{
	return playerCloak;
}

- (void)setPlayerCloak:(int)glyph
{
	if ( !glyph ) {
		playerCloak = nil;
	} else {
		playerCloak = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerHelmet
{
	return playerHelmet;
}



- (void)setPlayerHelmet:(int)glyph
{
	if ( !glyph ) {
		playerHelmet = nil;
	} else {
		playerHelmet = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerShield
{
	return playerShield;
}

- (void)setPlayerShield:(int)glyph
{
	if ( !glyph ) {
		playerShield = nil;
	} else {
		playerShield = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerGloves
{
	return playerGloves;
}

- (void)setPlayerGloves:(int)glyph
{
	if ( !glyph ) {
		playerGloves = nil;
	} else {
		playerGloves = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerShoes
{
	return playerShoes;
}

- (void)setPlayerShoes:(int)glyph
{
	if ( !glyph ) {
		playerShoes = nil;
	} else {
		playerShoes = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerRingL
{
	return playerRingL;
}

- (void)setPlayerRingL:(int)glyph
{
	if ( !glyph ) {
		playerRingL = nil;
	} else {
		playerRingL = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerRingR
{
	return playerRingR;
}
 
- (void)setPlayerRingR:(int)glyph
{
	if ( !glyph ) {
		playerRingR = nil;		
	} else {
		playerRingR = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerWeapon
{
	return playerWeapon ;
}

- (void)setPlayerWeapon:(int)glyph
{
	if ( !glyph ) {
		playerWeapon = nil;
	} else {		
		playerWeapon = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerSubWeapon
{
	return playerSubWeapon;
}

- (void)setPlayerSubWeapon:(int)glyph
{
	if ( !glyph ) {
		playerSubWeapon = nil;
	} else {
		playerSubWeapon = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerAmulet
{
	return playerAmulet;
}

- (void)setPlayerAmulet:(int)glyph
{
	if ( !glyph ) {
		playerAmulet = nil;
	} else {
		playerAmulet = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- (NSImage*)playerBlindFold
{
	return playerBlindFold;
}

- (void)setPlayerBlindFold:(int)glyph
{
	if ( !glyph ) {
		playerBlindFold = nil;
	} else {
		playerBlindFold = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}


- (void)updatePlayerInventory
{
	if ( uarm ) { 
		[ self setPlayerArmour:obj_to_glyph( uarm ) ];
	} else {
		[ self setPlayerArmour:0 ];
	}
#ifdef TOURIST
	if ( uarmu && !uarm ) {
	[ self setPlayerArmour:obj_to_glyph( uarmu ) ];
	} else if ( !uarm ) {
		[ self setPlayerArmour:0 ];
	}
#endif
	
	if ( uarmc ) {
		[ self setPlayerCloak:obj_to_glyph( uarmc ) ];
	} else {
		[ self setPlayerCloak:0 ];
	}
	
	if ( uarmh ) {
		[ self setPlayerHelmet:obj_to_glyph( uarmh ) ];
	} else {
		[ self setPlayerHelmet:0 ];
	}
		
	if ( uarmg ) {
		[ self setPlayerGloves:obj_to_glyph( uarmg ) ];
	} else {
		[ self setPlayerGloves:0 ];
	}
	
	if ( uarmf ) {
		[ self setPlayerShoes:obj_to_glyph( uarmf ) ];
	} else {
		[ self setPlayerShoes:0 ];
	}
	
	if ( uleft ) {
		[ self setPlayerRingL:obj_to_glyph( uleft ) ];
	} else {
		[ self setPlayerRingL:0 ];
	}
	
	if ( uright ) {
		[ self setPlayerRingR:obj_to_glyph( uright ) ];
	} else {
		[ self setPlayerRingR:0 ];
	}
	
	if ( uwep ) {
		[ self setPlayerWeapon:obj_to_glyph( uwep ) ];
	} else {
		[ self setPlayerWeapon:0 ];
	}
	
	if ( uswapwep && !u.twoweap ) {
		[ self setPlayerSubWeapon:obj_to_glyph( uswapwep ) ];
	} else {
		[ self setPlayerSubWeapon:0 ];
	}
	
	if ( uarms && !u.twoweap ) {
		[ self setPlayerShield:obj_to_glyph( uarms ) ];
	} else if ( u.twoweap ) {
		[ self setPlayerShield:obj_to_glyph( uswapwep ) ];
	} else {
		[ self setPlayerShield:0 ];
	}
	
	if ( uamul ) {
		[ self setPlayerAmulet:obj_to_glyph( uamul ) ];
	} else {
		[ self setPlayerAmulet:0 ];
	}
	
	if ( ublindf ) {
		[ self setPlayerBlindFold:obj_to_glyph( ublindf ) ];
	} else {
		[ self setPlayerBlindFold:0 ];
	}

}
//
//
//

- (NSString*)playerStr {
	NSString* strStr = nil; 
	
	if ( playerStr > 118 ) {
		strStr = [ NSString stringWithFormat:@"%d",playerStr-100 ];
	} else if ( playerStr == 118 ) {
		strStr = @"18/**";
	} else if ( playerStr > 18 ) {
		strStr = [ NSString stringWithFormat:@"18/%02d",playerStr-18 ];
	} else {
		strStr = [ NSString stringWithFormat:@"%d",playerStr ];
	}
	return strStr;
}

- (NSImage *)strUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"STR", (int)strUpdate]];
}
- (NSImage *)dexUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"DEX", (int)dexUpdate]];
}
- (NSImage *)conUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"CON", (int)conUpdate]];
}
- (NSImage *)intUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"INT", (int)intUpdate]];
}
- (NSImage *)wisUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"WIS", (int)wisUpdate]];
}
- (NSImage *)chaUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"CHA", (int)chaUpdate]];
}
- (NSImage *)hpUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"HP", (int)hpUpdate]];
}
- (NSImage *)powUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Pow", (int)powUpdate]];
}
- (NSImage *)acUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Ac", (int)acUpdate]];
}
- (NSImage *)lvUpdate
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Lv", (int)lvUpdate]];
}


- (NSImage *)lowfulIcon
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Lowful", (int)lowfulIcon]];
}
- (NSImage *)newtralIcon
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Newtral", (int)newtralIcon]];
}
- (NSImage *)chaosIcon
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Chaos", (int)chaosIcon]];
}

- (NSImage *)stHunger
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Hunger", (int)stHunger]];
}
- (NSImage *)stConfuse
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Confuse", (int)stConfuse]];
}
- (NSImage *)stSick
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Sick", (int)stSick]];
}
- (NSImage *)stIll
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Ill", (int)stIll]];
}
- (NSImage *)stBlind
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Blind", (int)stBlind]];
}
- (NSImage *)stStun
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Stun", (int)stStun]];
}
- (NSImage *)stHallu
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Hallu", (int)stHallu]];
}

//
//
//

- (void)setPlayerName:(NSString *)aString {
	if ( ![ playerName isEqualToString: aString ] && aString.length <= PL_NSIZ-11 ) {
		playerName = aString;
		//strcpy( plname,[ playerName cStringUsingEncoding:NH3DTEXTENCODING ] );
	}
}

- (void)setPlayerClass:(NSString *)aString {
	if (![playerClass isEqualToString: aString]) {
		playerClass = [aString copy];
	}
}

- (void)setPlayerRace:(NSString *)aString {
	if (![playerRace isEqualToString: NSLocalizedString(aString,@"") ] ) {
		playerRace = NSLocalizedString(aString,@"");
	}
}


- (void)setPlayerRole:(NSString *)aString {
	if ( playerRole != NSLocalizedString(aString,@"") ) {
		playerRole = NSLocalizedString(aString,@"");
	}
}


- (void)setPlayerAlign:(NSString *)aString {
	if (![playerAlign isEqualToString: NSLocalizedString(aString,@"")]) {
		playerAlign = NSLocalizedString(aString,@"");
	}
}

- (void)setPlayerGender:(NSString *)aString {
	if (![playerGender isEqualToString: NSLocalizedString(aString,@"")]) {
		playerGender = NSLocalizedString(aString,@"");
	}
}


- (void)setPlayerStatusLine:(NSString *)aString
{
	if ( ![ playerStatusLine isEqualToString:aString ] ) {
		playerStatusLine = [aString copy];
	}
}


- (void)setPlayerStr:(int)aValue {
	static unsigned strcount;
	
	if ( playerStr != aValue && playerStr < aValue ) {
		playerStr = aValue;
		[ self setStrUpdate:YES ];
		strcount = playerTime;
	} else {
		playerStr = aValue;
		if ( strcount < playerTime-15 ) [ self setStrUpdate:NO ];
	}
}

- (void)setPlayerDex:(int)aValue {
	static unsigned dexcount;
	
	if ( playerDex != aValue && playerDex < aValue ) {
		playerDex = aValue;
		[ self setDexUpdate:YES ];
		dexcount = playerTime;
	} else {
		playerDex = aValue;
		if ( dexcount < playerTime-15 ) [ self setDexUpdate:NO ];
	}
}

- (void)setPlayerCon:(int)aValue {
	static unsigned concount;
	
	if ( playerCon != aValue && playerCon < aValue ) {
		playerCon = aValue;
		[ self setConUpdate:YES ];
		concount = playerTime;
	} else {
		playerCon = aValue;
		if ( concount < playerTime-15 ) [ self setConUpdate:NO ];
	}
}

- (void)setPlayerInt:(int)aValue {
	static unsigned intcount;
	
	if ( playerInt != aValue && playerInt < aValue ) {
		playerInt = aValue;
		[ self setIntUpdate:YES ];
		intcount = playerTime;
	} else {
		playerInt = aValue;
		if ( intcount < playerTime-15 ) [ self setIntUpdate:NO ];
	}
}

- (void)setPlayerWis:(int)aValue {
	static unsigned wiscount;
	
	if ( playerWis != aValue && playerWis < aValue ) {
		playerWis = aValue;
		[ self setWisUpdate:YES ];
		wiscount = playerTime;
	} else {
		playerWis = aValue;
		if ( wiscount < playerTime-15 ) [ self setWisUpdate:NO ];
	}
}

- (void)setPlayerCha:(int)aValue {
	static unsigned chacount;
	
	if ( playerCha != aValue && playerCha < aValue ) {
		playerCha = aValue;
		[ self setChaUpdate:YES ];
		chacount = playerTime;
	} else {
		playerCha = aValue;
		if ( chacount < playerTime-15 )
			[ self setChaUpdate:NO ];
	}
}


//
//
//


- (void)setPlayerMaxhp:(int)aValue {
	static unsigned hpcount;
	
	if ( playerMaxhp != aValue && playerMaxhp < aValue ) {
		playerMaxhp = aValue;
		[ self setPlayerWaningHp:aValue ];
		[ self setPlayerCriticalHp:aValue ];
		if ( !firstTime ) [ self setHpUpdate:YES ];
		hpcount = playerTime;
	} else if ( playerMaxhp != aValue ) {
		playerMaxhp = aValue;
		[ self setPlayerWaningHp:aValue ];
		[ self setPlayerCriticalHp:aValue ];
	}
	if ( hpcount < playerTime-15 )
		[ self setHpUpdate:NO ];
}

- (void)setPlayerMaxpow:(int)aValue {
	static unsigned powcount;
	
	if ( playerMaxpow != aValue && playerMaxpow < aValue ) {
		playerMaxpow = aValue;
		[ self setPlayerWaningPow:aValue ];
		[ self setPlayerCriticalPow:aValue ];
		if (!firstTime)
			[self setPowUpdate:YES];
		powcount = playerTime;
		
	} else if ( playerMaxpow != aValue ) {
		playerMaxpow = aValue;
		[ self setPlayerWaningPow:aValue ];
		[ self setPlayerCriticalPow:aValue ];
	}
	if ( powcount < playerTime-15 )
		[ self setPowUpdate:NO ];
}

- (void)setPlayerAc:(int)aValue {
	static unsigned account;
	
	if ( playerAc != aValue && playerAc > aValue ) {
		playerAc = aValue;
		[ self setAcUpdate:YES ];
		account = playerTime;
	} else {
		playerAc = aValue;
		if (account < playerTime-15)
			[ self setAcUpdate:NO];
	}
}

- (void)setPlayerLv:(int)aValue {
	static unsigned lvcount;
	
	if ( playerLv != aValue && playerLv < aValue ) {
		playerLv = aValue;
		[ self setLvUpdate:YES ];
		lvcount = playerTime;
	} else {
		playerLv = aValue;
		if ( lvcount < playerTime-15 )
			[ self setLvUpdate:NO ];
	}
}

- (void)setPlayerWaningHp:(int)maxHp
{
	playerWaningHp = maxHp/10*5;
}


- (void)setPlayerCriticalHp:(int)maxHp
{
	playerCriticalHp = maxHp/10*3;
}


- (void)setPlayerWaningPow:(int)maxPow
{
	playerWaningPow = maxPow/10*5;
}


- (void)setPlayerCriticalPow:(int)maxPow
{
	playerCriticalPow = maxPow/10*3;
}

//
//
//

- (void)setStrUpdate:( BOOL )update {
	strUpdate = update;
}
- (void)setDexUpdate:( BOOL )update {
	dexUpdate = update;
}
- (void)setConUpdate:( BOOL )update {
	conUpdate = update;
}
- (void)setIntUpdate:( BOOL )update {
	intUpdate = update;
}
- (void)setWisUpdate:( BOOL )update {
	wisUpdate = update;
}
- (void)setChaUpdate:( BOOL )update {
	chaUpdate = update;
}
- (void)setHpUpdate:( BOOL )update {
	hpUpdate = update;
}
- (void)setPowUpdate:( BOOL )update {
	powUpdate = update;
}
- (void)setAcUpdate:( BOOL )update {
	acUpdate = update;
}
- (void)setLvUpdate:(BOOL)update {
	lvUpdate = update;
}

- (void)setLowfulIcon:(BOOL)enable {
	lowfulIcon = enable;
}

- (void)setNewtralIcon:(BOOL)enable {
	newtralIcon = enable;
}

- (void)setChaosIcon:(BOOL)enable {
	chaosIcon = enable;
}

- (void)setStHunger:(BOOL)aBool
{
	stHunger = aBool;
	[self checkStDrawer];
}

- (void)setStConfuse:( BOOL )aBool
{
	stConfuse = aBool;
	[self checkStDrawer];
}

- (void)setStSick:( BOOL )aBool
{
	stSick = aBool;
	[self checkStDrawer];
}

- (void)setStIll:( BOOL )aBool
{
	stIll = aBool;
	[self checkStDrawer];
}

- (void)setStBlind:( BOOL )aBool
{
	stBlind = aBool;
	[self checkStDrawer];
}

- (void)setStStun:( BOOL )aBool
{
	stStun = aBool;
	[self checkStDrawer];
}

- (void)setStHallu:( BOOL )aBool
{
	stHallu = aBool;
	[self checkStDrawer];
}

- (void)checkStDrawer
{
	if ( stHunger || stConfuse || stSick || stIll || stBlind || stStun || stHallu ) {
		if (stDrawer.state == NSDrawerClosedState) {
			[stDrawer open];
			[[NSSound soundNamed:@"Purr"] play];
		}
	} else if (stDrawer.state != NSDrawerClosedState) {
		[stDrawer close];
	}
}

//
//
//

- (void)updatePlayer
{
	const char* hung = hu_stat[ u.uhs ];
	
	[ self setPlayerClass:[ NSString stringWithFormat:NSLocalizedString( @"the %@",@"" ),
							[ NSString stringWithCString:rank_of( u.ulevel, pl_character[ 0 ], flags.female ) 
											   encoding:NH3DTEXTENCODING ] ] ];
	
	[ self setPlayerTime:moves ];
	
	if ( u.mtimedone ) {
	// You're a monster.
		[ self setPlayerMaxhp:u.mhmax ];
		[ self setPlayerHp:u.mh ];
		[ self setPlayerLv:mons[ u.umonnum ].mlevel ];
	} else {
	// You're normal.
		[ self setPlayerMaxhp:u.uhpmax ];
		[ self setPlayerHp:u.uhp ];
		[ self setPlayerLv:u.ulevel ];
	}
	[ self setPlayerMaxpow:u.uenmax ];
	[ self setPlayerPow:u.uen ];
	
	[ self setPlayerStr:ACURR( A_STR ) ];
	[ self setPlayerDex:ACURR( A_DEX ) ];
	[ self setPlayerCon:ACURR( A_CON ) ];
	[ self setPlayerInt:ACURR( A_INT ) ];
	[ self setPlayerWis:ACURR( A_WIS ) ];
	[ self setPlayerCha:ACURR( A_CHA ) ];
#ifndef GOLDOBJ
	[ self setPlayerGold:u.ugold ];
#else
	[ self setPlayerGold:u.umoney0 ];
#endif
#ifdef SCORE_ON_BOTL
	[ self setPlayerScore:botl_score( ) ];
#endif
	[ self setPlayerExp:u.uexp ];
	[ self setPlayerAc:u.uac ];
	
	if ( Hallucination ) [ self setStHallu:YES ]; else [ self setStHallu:NO ];
	
	if ( Confusion ) [ self setStConfuse:YES ]; else [ self setStConfuse:NO ];
	
	if ( Stunned ) [ self setStStun:YES ]; else [ self setStStun:NO ];
	
	if ( Blind ) [ self setStBlind:YES ]; else [ self setStBlind:NO ];
	
	if ( Sick ) [ self setStSick:YES ]; else [ self setStSick:NO ]; 
	
	if ( Vomiting ) [ self setStIll:YES ]; else [ self setStIll:NO ];
	
	if ( hung[ 0 ]!=' ' ) [ self setStHunger:YES ]; else [ self setStHunger:NO ];
	
	switch ( u.ualign.type ) {
		case 1 : 
			[ self setPlayerAlign:@"Lowful" ];
			[ self setLowfulIcon:YES ];
			[ self setNewtralIcon:NO ];
			[ self setChaosIcon:NO ];
			break;
		case 0 :
			[ self setPlayerAlign:@"Newtral" ];
			[ self setLowfulIcon:NO ];
			[ self setNewtralIcon:YES ];
			[ self setChaosIcon:NO ];
			break;
		case -1 :
			[ self setPlayerAlign:@"Chaotic" ];
			[ self setLowfulIcon:NO ];
			[ self setNewtralIcon:NO ];
			[ self setChaosIcon:YES ];
			break;
		case -128 :
			[ self setPlayerAlign:@"Evil" ];
			[ self setLowfulIcon:YES ];
			[ self setNewtralIcon:YES ];
			[ self setChaosIcon:YES ];
			break;
	}
	
	
	firstTime = NO;

	[window displayIfNeeded];
}

@end
