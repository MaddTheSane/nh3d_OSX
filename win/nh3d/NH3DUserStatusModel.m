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

static const int DIALOG_OK		= 128;
static const int DIALOG_CANCEL	= 129;


//from nh3d_win.m
extern id _NH3DTileCache;


@implementation NH3DUserStatusModel

- ( id )init
{
	self = [ super init ];
    if ( self != nil ) {
					
		shadow = [ [ NSShadow alloc ] init ];
		style = [ [ NSMutableParagraphStyle alloc ] init ];
		strAttributes = [ [ NSMutableDictionary alloc ] init ];
		
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

- ( void )prepareAttributes
{

	[ shadow setShadowColor:[ NSColor colorWithCalibratedWhite:0.1 alpha:0.8 ] ];
	[ shadow setShadowOffset:NSMakeSize( 2, -2 ) ];
	[ shadow setShadowBlurRadius:0.5 ];
			
	[ style setAlignment:NSCenterTextAlignment ];
			
	
	[ strAttributes setObject:[ NSFont fontWithName:NH3DWINDOWFONT size: 14 ]
					   forKey:NSFontAttributeName ];
	[ strAttributes setObject:shadow
					   forKey:NSShadowAttributeName ];
	[ strAttributes setObject:style
					   forKey:NSParagraphStyleAttributeName ];
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

- ( void )encodeWithCoder:( NSCoder * )coder
{
	[ coder encodeObject:playerName forKey:@"playerName" ];
	[ coder encodeObject:playerClass forKey:@"playerClass" ];
	[ coder encodeObject:playerRace forKey:@"playerRace" ];
	[ coder encodeObject:playerRole forKey:@"playerRole" ];
	[ coder encodeObject:playerAlign forKey:@"playerAlign" ];
	[ coder encodeObject:playerGender forKey:@"playerGender" ];
}
*/

- ( void )dealloc
{
	[ strAttributes release ];
	[ shadow release ];
	[ style release ];
	
	[ playerName release ];
	[ playerClass release ];
	[ playerRace release ];
	[ playerRole release ];
	[ playerAlign release ];
	[ playerGender release ];
	[ playerStatusLine release ];
		
	[ playerArmour release ];
	[ playerCloak release ];
	[ playerHelmet release ];
	[ playerShield release ];
	[ playerGloves release ];
	[ playerShoes release ];
	[ playerRingL release ];
	[ playerRingR release ];
	[ playerWeapon release ];
	[ playerSubWeapon release ];
	[ playerAmulet release ];
	[ playerBlindFold release ];

	[ super dealloc ];
}

- ( void )awakeFromNib {
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
- ( void )controlTextDidChange:( NSNotification * )notification
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

- ( NSAttributedString * )playerName
{
	int fSize;
	switch ( [ playerName cStringLength ] ) 
	{
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
	
	[ strAttributes setObject:
						[ NSFont fontWithName:NH3DWINDOWFONT
								size:fSize ]
								forKey:NSFontAttributeName ];
	return [ [ [ NSAttributedString alloc ] 
								initWithString:playerName 
								attributes:strAttributes ] autorelease ];
}

- ( NSString * )playerRole 
{
	return playerRole;
}

- ( NSString * )playerRace 
{
	return playerRace;
}

- ( NSString * )playerAlign 
{
	return playerAlign;
}

- ( NSString * )playerGender 
{
	return playerGender;
}

- ( NSAttributedString * )playerClass 
{
	[ strAttributes setObject:
						[ NSFont fontWithName:NH3DWINDOWFONT
								size: 13 ]
								forKey:NSFontAttributeName ];
	return [ [ [ NSAttributedString alloc ] 
								initWithString:playerClass 
								attributes:strAttributes ] autorelease ];
}


- ( NSString * )playerStatusLine
{
	return playerStatusLine;
}




- ( int )playerHp 
{
	return playerHp;
}

- ( int )playerMaxhp 
{
	return playerMaxhp;
}

- ( int )playerPow 
{
	return playerPow;
}

- ( int )playerMaxpow 
{
	return playerMaxpow;
}

- ( float )playerWaningHp 
{
	return playerWaningHp;
}

- ( float )playerCriticalHp 
{
	return playerCriticalHp;
}

- ( float )playerWaningPow
{
	return playerWaningPow;
}

- ( float )playerCriticalPow 
{
	return playerCriticalPow;
}

- ( int )playerAc 
{
	return playerAc;
}

- ( int )playerLv 
{
	return playerLv;
}


- ( NSImage * )playerArmour
{
	return playerArmour;
}

- ( void )setPlayerArmour:( int )glyph
{
	if ( !glyph ) {
		[ playerArmour release ];
		playerArmour = nil;
	} else {
		[ playerArmour release ];
		playerArmour = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerCloak
{
	return playerCloak;
}

- ( void )setPlayerCloak:( int )glyph
{
	if ( !glyph ) {
		[ playerCloak release ];
		playerCloak = nil;
	} else {
		[ playerCloak release ];
		playerCloak = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerHelmet
{
	return playerHelmet;
}



- ( void )setPlayerHelmet:( int )glyph
{
	if ( !glyph ) {
		[ playerHelmet release ];
		playerHelmet = nil;
	} else {
		[ playerHelmet release ];
		playerHelmet = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerShield
{
	return playerShield;
}

- ( void )setPlayerShield:( int )glyph
{
	if ( !glyph ) {
		[ playerShield release ];
		playerShield = nil;
	} else {
		[ playerShield release ];
		playerShield = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerGloves
{
	return playerGloves;
}

- ( void )setPlayerGloves:( int )glyph
{
	if ( !glyph ) {
		[ playerGloves release ];
		playerGloves = nil;
	} else {
		[ playerGloves release ];
		playerGloves = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerShoes
{
	return playerShoes;
}

- ( void )setPlayerShoes:( int )glyph
{
	if ( !glyph ) {
		[ playerShoes release ];
		playerShoes = nil;
	} else {
		[ playerShoes release ];
		playerShoes = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerRingL
{
	return playerRingL;
}

- ( void )setPlayerRingL:( int )glyph
{
	if ( !glyph ) {
		[ playerRingL release ]; 
		playerRingL = nil;
	} else {
		[ playerRingL release ]; 
		playerRingL = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerRingR
{
	return playerRingR;
}
 
- ( void )setPlayerRingR:( int )glyph
{
	if ( !glyph ) {
		[ playerRingR release ];
		playerRingR = nil;		
	} else {
		[ playerRingR release ];
		playerRingR = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerWeapon
{
	return playerWeapon ;
}

- ( void )setPlayerWeapon:( int )glyph
{
	if ( !glyph ) {
		[ playerWeapon release ];
		playerWeapon = nil;
	} else {		
		[ playerWeapon release ];
		playerWeapon = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerSubWeapon
{
	return playerSubWeapon;
}

- ( void )setPlayerSubWeapon:( int )glyph
{
	if ( !glyph ) {
		[ playerSubWeapon release ];
		playerSubWeapon = nil;
	} else {
		[ playerSubWeapon release ];
		playerSubWeapon = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerAmulet
{
	return playerAmulet;
}

- ( void )setPlayerAmulet:( int )glyph
{
	if ( !glyph ) {
		[ playerAmulet release ];
		playerAmulet = nil;
	} else {
		[ playerAmulet release ];
		playerAmulet = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}

- ( NSImage * )playerBlindFold
{
	return playerBlindFold;
}

- ( void )setPlayerBlindFold:( int )glyph
{
	if ( !glyph ) {
		[ playerBlindFold release ];
		playerBlindFold = nil;
	} else {
		[ playerBlindFold release ];
		playerBlindFold = [ [ _NH3DTileCache tileImageFromGlyph:glyph ] copy ];
	}
}


- ( void )updatePlayerInventory
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

- ( NSString * )playerStr {
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

- ( int )playerDex {
	return playerDex;
}

- ( int )playerCon {
	return playerCon;
}

- ( int )playerInt {
	return playerInt;
}

- ( int )playerWis {
	return playerWis;
}

- ( int )playerCha {
	return playerCha;
}

- ( int )playerGold {
	return playerGold;
}

- ( unsigned )playerScore {
	return playerScore;
}

- ( unsigned )playerTime {
	return playerTime;
}

- ( int )playerExp {
	return playerExp;
}

- ( NSString * )strUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"STR",strUpdate ] ];
}
- ( NSString * )dexUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"DEX",dexUpdate ] ];
}
- ( NSString * )conUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"CON",conUpdate ] ];
}
- ( NSString * )intUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"INT",intUpdate ] ];
}
- ( NSString * )wisUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"WIS",wisUpdate ] ];
}
- ( NSString * )chaUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"CHA",chaUpdate ] ];
}
- ( NSString * )hpUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"HP",hpUpdate ] ];
}
- ( NSString * )powUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Pow",powUpdate ] ];
}
- ( NSString * )acUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Ac",acUpdate ] ];
}
- ( NSString * )lvUpdate
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Lv",lvUpdate ] ];
}


- ( NSString * )lowfulIcon 
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Lowful",lowfulIcon ] ];
}
- ( NSString * )newtralIcon
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Newtral",newtralIcon ] ];
}
- ( NSString * )chaosIcon
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Chaos",chaosIcon ] ];
}

- ( NSString * )stHunger
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Hunger",stHunger ] ];
}
- ( NSString * )stConfuse
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Confuse",stConfuse ] ];
}
- ( NSString * )stSick
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Sick",stSick ] ];
}
- ( NSString * )stIll
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Ill",stIll ] ];
}
- ( NSString * )stBlind
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Blind",stBlind ] ];
}
- ( NSString * )stStun
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Stun",stStun ] ];
}
- ( NSString * )stHallu
{
	return [ [ NSBundle mainBundle ] pathForImageResource:
										[ NSString stringWithFormat:@"%@%d",@"Hallu",stHallu ] ];
}

//
//
//

- ( void )setPlayerName:( NSString * )aString {
	if ( ![ playerName isEqualToString: aString ] && [ aString cStringLength ] <= PL_NSIZ-11 ) {
		[ playerName release ];
		playerName = [ aString retain ];
		//strcpy( plname,[ playerName cStringUsingEncoding:NH3DTEXTENCODING ] );
	}
}

- ( void )setPlayerClass:( NSString * )aString {
		if ( ![ playerClass isEqualToString: aString ] ) {
		[ playerClass release ];
		playerClass = [ aString retain ];
		}
}

- ( void )setPlayerRace:( NSString * )aString {
		if ( ![ playerRace isEqualToString: NSLocalizedString(aString,@"") ] ) {
		[ playerRace release ];
		playerRace = [ NSLocalizedString(aString,@"") retain ];
	}
	
}


- ( void )setPlayerRole:( NSString * )aString {
	if ( playerRole != NSLocalizedString(aString,@"") ) {
		[ playerRole release ];
		playerRole = [ NSLocalizedString(aString,@"") retain ];
	}

}


- ( void )setPlayerAlign:( NSString * )aString {
	if ( playerAlign != NSLocalizedString(aString,@"") ) {
		[ playerAlign release ];
		playerAlign = [ NSLocalizedString(aString,@"") retain ];
	}
}

- ( void )setPlayerGender:( NSString * )aString {
	if ( playerGender != NSLocalizedString(aString,@"") ) {
		[ playerGender release ];
		playerGender = [ NSLocalizedString(aString,@"") retain ];
	}
}


- ( void )setPlayerStatusLine:( NSString * )aString
{
	if ( ![ playerStatusLine isEqualToString:aString ] ) {
		[ playerStatusLine release ];
		playerStatusLine = [ aString retain ];
	}
}


- ( void )setPlayerStr:( int )aValue {
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

- ( void )setPlayerDex:( int )aValue {
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

- ( void )setPlayerCon:( int )aValue {
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

- ( void )setPlayerInt:( int )aValue {
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

- ( void )setPlayerWis:( int )aValue {
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

- ( void )setPlayerCha:( int )aValue {
	static unsigned chacount;
	
	if ( playerCha != aValue && playerCha < aValue ) {
		playerCha = aValue;
		[ self setChaUpdate:YES ];
		chacount = playerTime;
	} else {
		playerCha = aValue;
		if ( chacount < playerTime-15 ) [ self setChaUpdate:NO ];
	}
}

- ( void )setPlayerGold:( int )aValue {
	playerGold = aValue;
}

- ( void )setPlayerScore:( unsigned )aValue {
	playerScore = aValue;
}

- ( void )setPlayerTime:( unsigned )aValue{
	playerTime = aValue;
}

- ( void )setPlayerExp:( int )aValue{
	playerExp = aValue;
}

//
//
//


- ( void )setPlayerMaxhp:( int )aValue {
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
	if ( hpcount < playerTime-15 ) [ self setHpUpdate:NO ];
}

- ( void )setPlayerMaxpow:( int )aValue {
	static unsigned powcount;
	
	if ( playerMaxpow != aValue && playerMaxpow < aValue ) {
			playerMaxpow = aValue;
		[ self setPlayerWaningPow:aValue ];
		[ self setPlayerCriticalPow:aValue ];
			if ( !firstTime )	[ self setPowUpdate:YES ];
			powcount = playerTime;
			
	}else if ( playerMaxpow != aValue ) {
		playerMaxpow = aValue;
		[ self setPlayerWaningPow:aValue ];
		[ self setPlayerCriticalPow:aValue ];
	}
	if ( powcount < playerTime-15 ) [ self setPowUpdate:NO ];
}

- ( void )setPlayerHp:( int )aValue {
	playerHp = aValue;
}

- ( void )setPlayerPow:( int )aValue {
	playerPow = aValue;
}

- ( void )setPlayerAc:( int )aValue {
	static unsigned account;
	
	if ( playerAc != aValue && playerAc > aValue ) {
		playerAc = aValue;
		[ self setAcUpdate:YES ];
		account = playerTime; 
	} else {
		playerAc = aValue;
		if ( account < playerTime-15 ) [ self setAcUpdate:NO ];
	}	
	
}

- ( void )setPlayerLv:( int )aValue {
	static unsigned lvcount;
	
	if ( playerLv != aValue && playerLv < aValue ) {
		playerLv = aValue;
		[ self setLvUpdate:YES ];
		lvcount = playerTime; 
	} else {
		playerLv = aValue;
		if ( lvcount < playerTime-15 ) [ self setLvUpdate:NO ];
	}	
}

- ( void )setPlayerWaningHp:( int )maxHp
{
	playerWaningHp = maxHp/10*5;
}


- ( void )setPlayerCriticalHp:( int )maxHp
{
	playerCriticalHp = maxHp/10*3;
}


- ( void )setPlayerWaningPow:( int )maxPow
{
	playerWaningPow = maxPow/10*5;
}


- ( void )setPlayerCriticalPow:( int )maxPow
{
	playerCriticalPow = maxPow/10*3;
}

//
//
//

- ( void )setStrUpdate:( BOOL )update {
	strUpdate = update;
}
- ( void )setDexUpdate:( BOOL )update {
	dexUpdate = update;
}
- ( void )setConUpdate:( BOOL )update {
	conUpdate = update;
}
- ( void )setIntUpdate:( BOOL )update {
	intUpdate = update;
}
- ( void )setWisUpdate:( BOOL )update {
	wisUpdate = update;
}
- ( void )setChaUpdate:( BOOL )update {
	chaUpdate = update;
}
- ( void )setHpUpdate:( BOOL )update {
	hpUpdate = update;
}
- ( void )setPowUpdate:( BOOL )update {
	powUpdate = update;
}
- ( void )setAcUpdate:( BOOL )update {
	acUpdate = update;
}
- ( void )setLvUpdate:( BOOL )update {
	lvUpdate = update;
}

- ( void )setLowfulIcon:( BOOL )enable {
	lowfulIcon = enable;
}
- ( void )setNewtralIcon:( BOOL )enable {
	newtralIcon = enable;
}
- ( void )setChaosIcon:( BOOL )enable {
	chaosIcon = enable;
}

- ( void )setStHunger:( BOOL )aBool 
{
	stHunger = aBool;
	[ self checkStDrawer ];
	
}

- ( void )setStConfuse:( BOOL )aBool
{
	stConfuse = aBool;
	[ self checkStDrawer ];	
}

- ( void )setStSick:( BOOL )aBool
{
	stSick = aBool;
	[ self checkStDrawer ];
}

- ( void )setStIll:( BOOL )aBool
{
	stIll = aBool;
	[ self checkStDrawer ];
}

- ( void )setStBlind:( BOOL )aBool
{
	stBlind = aBool;
	[ self checkStDrawer ];
}

- ( void )setStStun:( BOOL )aBool
{
	stStun = aBool;
	[ self checkStDrawer ];	
}

- ( void )setStHallu:( BOOL )aBool
{
	stHallu = aBool;
	[ self checkStDrawer ];
	
}

- ( void )checkStDrawer
{
	if ( stHunger || stConfuse || stSick || stIll || stBlind || stStun || stHallu )
		{	
		if ( [ stDrawer state ] == NSDrawerClosedState ) {
			[ stDrawer open ];
			[ [ NSSound soundNamed:@"Purr" ] play ];
		}
	} else if ( [ stDrawer state ] != NSDrawerClosedState ) [ stDrawer close ];
		
}

//
//
//

- ( void )updatePlayer
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

	[ window displayIfNeeded ];
}

@end
