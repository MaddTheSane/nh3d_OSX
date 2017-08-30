/* NH3DUserStatusModel */
//
//  NH3DUserStatusModel.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

#include "C99Bool.h"
#import "NH3DUserStatusModel.h"
#import "NetHack3D-Swift.h"

extern const char *enc_stat[]; /* from botl.c */
extern const char *hu_stat[]; /* from eat.c */

#define DIALOG_OK		 128
#define DIALOG_CANCEL	 129


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


@synthesize playerRole;
@synthesize playerRace;
@synthesize playerAlign;
@synthesize playerGender;

@synthesize playerStatusLine;

- (instancetype)init
{
    if (self = [super init]) {
		shadow = [[NSShadow alloc] init];
		style = [[NSMutableParagraphStyle alloc] init];
		strAttributes = [[NSMutableDictionary alloc] init];
		
		[self setPlayerCriticalHp:0];
		[self setPlayerCriticalPow:0];
		[self setPlayerWaningHp:0];
		[self setPlayerWaningPow:0];
		
		[self setPlayerName:@""];
		[self setPlayerClass:@""];
		self.playerMaxhp = 9999;
		self.playerMaxpow = 9999;
		self.playerHp = 9999;
		self.playerPow = 9999;
		[self setPlayerStr:9999];
		self.playerDex = 9999;
		self.playerCon = 9999;
		self.playerInt = 9999;
		self.playerWis = 9999;
		self.playerCha = 9999;
		self.playerGold = 9999;
		self.playerScore = 9999;
		self.playerTime = 9999;
		self.playerExp = 9999;
		self.playerAc = -9999;
		self.playerLv = 9999;

		[self setStrUpdate:NO];
		[self setHpUpdate:NO];
		[self setDexUpdate:NO];
		[self setConUpdate:NO];
		[self setIntUpdate:NO];
		[self setWisUpdate:NO];
		[self setChaUpdate:NO];
		[self setLvUpdate:NO];
		[self setPowUpdate:NO];
		[self setAcUpdate:NO];
				
		firstTime = YES;
    }
    return self;
}

- (void)prepareAttributes
{
	shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.1 alpha:0.8];
	shadow.shadowOffset = NSMakeSize(2, -2);
	shadow.shadowBlurRadius = 0.5;
			
	style.alignment = NSTextAlignmentCenter;
	
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT size: 14];
	strAttributes[NSShadowAttributeName] = [shadow copy];
	strAttributes[NSParagraphStyleAttributeName] = [style copy];
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
	[self prepareAttributes];
	[self setPlayerArmour:0];
	[self setPlayerCloak:0];
	[self setPlayerHelmet:0];
	[self setPlayerShield:0];
	[self setPlayerGloves:0];
	[self setPlayerShoes:0];
	[self setPlayerRingL:0];
	[self setPlayerRingR:0];
	[self setPlayerWeapon:0];
	[self setPlayerSubWeapon:0];
	[self setPlayerAmulet:0];
	[self setPlayerBlindFold:0];
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
	switch (playerName.length) {
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
			break;
	}
	
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT
														 size:fSize];
	return [[NSAttributedString alloc] initWithString:playerName
										   attributes:strAttributes];
}

- (NSAttributedString *)playerClass
{
	strAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT
														 size: 13];
	return [[NSAttributedString alloc] initWithString:playerClass
										   attributes:strAttributes];
}

- (CGFloat)playerWaningHp
{
	return playerWaningHp;
}

- (CGFloat)playerCriticalHp
{
	return playerCriticalHp;
}

- (CGFloat)playerWaningPow
{
	return playerWaningPow;
}

- (CGFloat)playerCriticalPow
{
	return playerCriticalPow;
}

- (NSImage*)playerArmour
{
	return playerArmour;
}

- (void)setPlayerArmour:(int)glyph
{
	if (!glyph) {
		playerArmour = nil;
	} else {
		playerArmour = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerCloak
{
	return playerCloak;
}

- (void)setPlayerCloak:(int)glyph
{
	if (!glyph) {
		playerCloak = nil;
	} else {
		playerCloak = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerHelmet
{
	return playerHelmet;
}

- (void)setPlayerHelmet:(int)glyph
{
	if (!glyph) {
		playerHelmet = nil;
	} else {
		playerHelmet = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerShield
{
	return playerShield;
}

- (void)setPlayerShield:(int)glyph
{
	if (!glyph) {
		playerShield = nil;
	} else {
		playerShield = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerGloves
{
	return playerGloves;
}

- (void)setPlayerGloves:(int)glyph
{
	if (!glyph) {
		playerGloves = nil;
	} else {
		playerGloves = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerShoes
{
	return playerShoes;
}

- (void)setPlayerShoes:(int)glyph
{
	if (!glyph) {
		playerShoes = nil;
	} else {
		playerShoes = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerRingL
{
	return playerRingL;
}

- (void)setPlayerRingL:(int)glyph
{
	if (!glyph) {
		playerRingL = nil;
	} else {
		playerRingL = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerRingR
{
	return playerRingR;
}
 
- (void)setPlayerRingR:(int)glyph
{
	if (!glyph) {
		playerRingR = nil;		
	} else {
		playerRingR = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerWeapon
{
	return playerWeapon;
}

- (void)setPlayerWeapon:(int)glyph
{
	if (!glyph) {
		playerWeapon = nil;
	} else {		
		playerWeapon = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerSubWeapon
{
	return playerSubWeapon;
}

- (void)setPlayerSubWeapon:(int)glyph
{
	if (!glyph) {
		playerSubWeapon = nil;
	} else {
		playerSubWeapon = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerAmulet
{
	return playerAmulet;
}

- (void)setPlayerAmulet:(int)glyph
{
	if (!glyph) {
		playerAmulet = nil;
	} else {
		playerAmulet = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

- (NSImage*)playerBlindFold
{
	return playerBlindFold;
}

- (void)setPlayerBlindFold:(int)glyph
{
	if (!glyph) {
		playerBlindFold = nil;
	} else {
		playerBlindFold = [[[TileSet instance] imageForGlyph:glyph] copy];
	}
}

static NSString *stripParentheses(NSString *text)
{
	// Cache these strings so they aren't auto-generated each time
	static NSString *leftHandStr;
	static NSString *rightHandStr;
	static NSString *weapInHand;
	static NSString *weapInHands;
	static NSString *otherHand;
	static const char *hand = NULL;
	// ...but regenerate them when our hands change
	if (hand != body_part(HAND)) {
		hand = body_part(HAND);
		NSString *handPart = [NSString stringWithCString:hand encoding:NH3DTEXTENCODING];
		const char* hand_s = makeplural(hand);
		NSString *handsPart = [NSString stringWithCString:hand_s encoding:NH3DTEXTENCODING];
		leftHandStr = [[NSString alloc] initWithFormat:@" (on left %@)", handPart];
		rightHandStr = [[NSString alloc] initWithFormat:@" (on right %@)", handPart];
		weapInHand = [[NSString alloc] initWithFormat:@" (weapon in %@)", handPart];
		weapInHands = [[NSString alloc] initWithFormat:@" (weapon in %@)", handsPart];
		otherHand = [[NSString alloc] initWithFormat:@" (wielded in other %@)", handPart];
	}

	if ([text hasSuffix:@" (being worn)"]) {
		text = [text substringToIndex:text.length - @" (being worn)".length];
	} else if ([text hasSuffix:weapInHands]) {
		text = [text substringToIndex:text.length - weapInHands.length];
	} else if ([text hasSuffix:weapInHand]) {
		text = [text substringToIndex:text.length - weapInHand.length];
	} else if ([text hasSuffix:leftHandStr])  {
		text = [text substringToIndex:text.length - leftHandStr.length];
	} else if ([text hasSuffix:rightHandStr])  {
		text = [text substringToIndex:text.length - rightHandStr.length];
	} else if ([text hasSuffix:@" (alternate weapon; not wielded)"]) {
		text = [text substringToIndex:text.length - @" (alternate weapon; not wielded)".length];
	} else if ([text hasSuffix:otherHand]) {
		text = [text substringToIndex:text.length - otherHand.length];
	} else if ([text hasSuffix:@" (in quiver)"]) {
		text = [text substringToIndex:text.length - @" (in quiver)".length];
	} else if ([text hasSuffix:@" (in quiver pouch)"]) {
		text = [text substringToIndex:text.length - @" (in quiver pouch)".length];
	} else if ([text hasSuffix:@" (at the ready)"]) {
		text = [text substringToIndex:text.length - @" (at the ready)".length];
	}

	return text;
}

- (void)updatePlayerInventory
{
	if (uarm) {
		[self setPlayerArmour:obj_to_glyph(uarm)];
		self.playerArmorString = stripParentheses([NSString stringWithCString:Doname2(uarm) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerArmour:0];
		self.playerArmorString = nil;
	}

	if (uarmu && !uarm) {
		[self setPlayerArmour:obj_to_glyph(uarmu)];
		self.playerArmorString = stripParentheses([NSString stringWithCString:Doname2(uarmu) encoding:NH3DTEXTENCODING]);
	} else if (!uarm) {
		[self setPlayerArmour:0];
		self.playerArmorString = nil;
	}
	
	if (uarmc) {
		[self setPlayerCloak:obj_to_glyph(uarmc)];
		self.playerCloakString = stripParentheses([NSString stringWithCString:Doname2(uarmc) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerCloak:0];
		self.playerCloakString = nil;
	}
	
	if (uarmh) {
		[self setPlayerHelmet:obj_to_glyph(uarmh)];
		self.playerHelmetString = stripParentheses([NSString stringWithCString:Doname2(uarmh) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerHelmet:0];
		self.playerHelmetString = nil;
	}
		
	if (uarmg) {
		[self setPlayerGloves:obj_to_glyph(uarmg)];
		self.playerGlovesString = stripParentheses([NSString stringWithCString:Doname2(uarmg) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerGloves:0];
		self.playerGlovesString = nil;
	}
	
	if (uarmf) {
		[self setPlayerShoes:obj_to_glyph(uarmf)];
		self.playerShoesString = stripParentheses([NSString stringWithCString:Doname2(uarmf) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerShoes:0];
		self.playerShoesString = nil;
	}
	
	if (uleft) {
		[self setPlayerRingL:obj_to_glyph(uleft)];
		self.playerRingLString = stripParentheses([NSString stringWithCString:Doname2(uleft) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerRingL:0];
		self.playerRingLString = nil;
	}
	
	if (uright) {
		[self setPlayerRingR:obj_to_glyph(uright)];
		self.playerRingRString = stripParentheses([NSString stringWithCString:Doname2(uright) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerRingR:0];
		self.playerRingRString = nil;
	}
	
	if (uwep) {
		[self setPlayerWeapon:obj_to_glyph(uwep)];
		self.playerWeaponString = stripParentheses([NSString stringWithCString:Doname2(uwep) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerWeapon:0];
		self.playerWeaponString = nil;
	}
	
	if (uswapwep && !u.twoweap) {
		[self setPlayerSubWeapon:obj_to_glyph(uswapwep)];
		self.playerSubWeaponString = stripParentheses([NSString stringWithCString:Doname2(uswapwep) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerSubWeapon:0];
		self.playerSubWeaponString = nil;
	}
	
	if (uarms && !u.twoweap) {
		[self setPlayerShield:obj_to_glyph(uarms)];
		self.playerShieldString = stripParentheses(@(Doname2(uarms)));
	} else if (u.twoweap) {
		[self setPlayerShield:obj_to_glyph(uswapwep)];
		self.playerShieldString = stripParentheses(@(Doname2(uswapwep)));
	} else {
		[self setPlayerShield:0];
		self.playerShieldString = nil;
	}
	
	if (uamul) {
		[self setPlayerAmulet:obj_to_glyph(uamul)];
		self.playerAmuletString = stripParentheses([NSString stringWithCString:Doname2(uamul) encoding:NH3DTEXTENCODING]);
	} else {
		[self setPlayerAmulet:0];
		self.playerAmuletString = nil;
	}
	
	if (ublindf) {
		[self setPlayerBlindFold:obj_to_glyph(ublindf)];
		self.playerBlindFoldString = stripParentheses([NSString stringWithCString:Doname2(ublindf) encoding:NH3DTEXTENCODING]);
	} else if (uarmh) {
		[self setPlayerBlindFold:0];
		//Needed, otherwise the blindfold overlaps the helmet, and it doesn't show up.
		self.playerBlindFoldString = _playerHelmetString;
	} else {
		[self setPlayerBlindFold:0];
		self.playerBlindFoldString = nil;
	}
}
//
//
//

- (NSString*)playerStr {
	NSString* strStr;
	
	if (playerStr > 118) {
		strStr = [NSString stringWithFormat:@"%d", playerStr - 100];
	} else if (playerStr == 118) {
		strStr = @"18/**";
	} else if (playerStr > 18) {
		strStr = [NSString stringWithFormat:@"18/%02d", playerStr - 18];
	} else {
		strStr = [NSString stringWithFormat:@"%d", playerStr];
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

#pragma mark -

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

#pragma mark -

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
- (NSImage *)stLoad
{
	return [NSImage imageNamed:[NSString stringWithFormat:@"%@%d", @"Load", (int)stLoad]];
}

#pragma mark -

- (NSString*)stHungerTip
{
	NSString *toAdd = @"Full";
	if (hu_stat[stHunger][0] != ' ') {
		toAdd = [@(hu_stat[stHunger]) stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	}
	return [@"Hunger: " stringByAppendingString:toAdd];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingStHungerTip
{
	return [NSSet setWithObject:@"stHunger"];
}

- (NSString*)stLoadTip
{
	NSString *toAdd = @"Unencumbered";
	if (enc_stat[stLoad][0] != '\0') {
		toAdd = @(enc_stat[stLoad]);
	}
	return [@"Load: " stringByAppendingString:toAdd];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingStLoadTip
{
	return [NSSet setWithObject:@"stLoad"];
}

#pragma mark -

- (void)setPlayerName:(NSString *)aString {
	if (![playerName isEqualToString:aString] && aString.length <= PL_NSIZ-11) {
		playerName = [aString copy];
		//strcpy( plname,[ playerName cStringUsingEncoding:NH3DTEXTENCODING ] );
	}
}

- (void)setPlayerClass:(NSString *)aString {
	if (![playerClass isEqualToString: aString]) {
		playerClass = [aString copy];
	}
}

- (void)setPlayerRace:(NSString *)aString {
	if (![playerRace isEqualToString: NSLocalizedString(aString, @"")]) {
		playerRace = NSLocalizedString(aString, @"");
	}
}

- (void)setPlayerRole:(NSString *)aString {
	if (![playerRole isEqualToString: NSLocalizedString(aString, @"")]) {
		playerRole = NSLocalizedString(aString, @"");
	}
}

- (void)setPlayerAlign:(NSString *)aString {
	if (![playerAlign isEqualToString: NSLocalizedString(aString, @"")]) {
		playerAlign = NSLocalizedString(aString, @"");
	}
}

- (void)setPlayerGender:(NSString *)aString {
	if (![playerGender isEqualToString: NSLocalizedString(aString, @"")]) {
		playerGender = NSLocalizedString(aString, @"");
	}
}

#pragma mark -

- (void)setPlayerStr:(int)aValue {
	static unsigned strcount;
	
	if (playerStr != aValue && playerStr < aValue) {
		playerStr = aValue;
		[self setStrUpdate:YES];
		strcount = playerTime;
	} else {
		playerStr = aValue;
		if (strcount < playerTime - 15)
			[self setStrUpdate:NO];
	}
}

- (void)setPlayerDex:(int)aValue {
	static unsigned dexcount;
	
	if (playerDex != aValue && playerDex < aValue) {
		playerDex = aValue;
		[self setDexUpdate:YES];
		dexcount = playerTime;
	} else {
		playerDex = aValue;
		if (dexcount < playerTime - 15)
			[self setDexUpdate:NO];
	}
}

- (void)setPlayerCon:(int)aValue {
	static unsigned concount;
	
	if (playerCon != aValue && playerCon < aValue) {
		playerCon = aValue;
		[self setConUpdate:YES];
		concount = playerTime;
	} else {
		playerCon = aValue;
		if (concount < playerTime - 15)
			[self setConUpdate:NO];
	}
}

- (void)setPlayerInt:(int)aValue {
	static unsigned intcount;
	
	if (playerInt != aValue && playerInt < aValue) {
		playerInt = aValue;
		[self setIntUpdate:YES];
		intcount = playerTime;
	} else {
		playerInt = aValue;
		if (intcount < playerTime - 15)
			[self setIntUpdate:NO];
	}
}

- (void)setPlayerWis:(int)aValue {
	static unsigned wiscount;
	
	if (playerWis != aValue && playerWis < aValue) {
		playerWis = aValue;
		[self setWisUpdate:YES];
		wiscount = playerTime;
	} else {
		playerWis = aValue;
		if (wiscount < playerTime - 15)
			[self setWisUpdate:NO];
	}
}

- (void)setPlayerCha:(int)aValue {
	static unsigned chacount;
	
	if (playerCha != aValue && playerCha < aValue) {
		playerCha = aValue;
		[self setChaUpdate:YES];
		chacount = playerTime;
	} else {
		playerCha = aValue;
		if (chacount < playerTime - 15)
			[self setChaUpdate:NO];
	}
}

#pragma mark -

- (void)setPlayerMaxhp:(int)aValue {
	static unsigned hpcount;
	
	if (playerMaxhp != aValue && playerMaxhp < aValue) {
		playerMaxhp = aValue;
		[self setPlayerWaningHp:aValue];
		[self setPlayerCriticalHp:aValue];
		if (!firstTime)
			[self setHpUpdate:YES];
		hpcount = playerTime;
	} else if (playerMaxhp != aValue) {
		playerMaxhp = aValue;
		[self setPlayerWaningHp:aValue];
		[self setPlayerCriticalHp:aValue];
	}
	if (hpcount < playerTime - 15)
		[self setHpUpdate:NO];
}

- (void)setPlayerMaxpow:(int)aValue {
	static unsigned powcount;
	
	if (playerMaxpow != aValue && playerMaxpow < aValue) {
		playerMaxpow = aValue;
		[self setPlayerWaningPow:aValue];
		[self setPlayerCriticalPow:aValue];
		if (!firstTime)
			[self setPowUpdate:YES];
		powcount = playerTime;
		
	} else if (playerMaxpow != aValue) {
		playerMaxpow = aValue;
		[self setPlayerWaningPow:aValue];
		[self setPlayerCriticalPow:aValue];
	}
	if (powcount < playerTime - 15)
		[self setPowUpdate:NO];
}

- (void)setPlayerAc:(int)aValue {
	static unsigned account;
	
	if (playerAc != aValue && playerAc > aValue) {
		playerAc = aValue;
		[self setAcUpdate:YES];
		account = playerTime;
	} else {
		playerAc = aValue;
		if (account < playerTime - 15)
			[self setAcUpdate:NO];
	}
}

- (void)setPlayerLv:(int)aValue {
	static unsigned lvcount;
	
	if (playerLv != aValue && playerLv < aValue) {
		playerLv = aValue;
		[self setLvUpdate:YES];
		lvcount = playerTime;
	} else {
		playerLv = aValue;
		if (lvcount < playerTime - 15)
			[self setLvUpdate:NO];
	}
}

- (void)setPlayerWaningHp:(int)maxHp
{
	playerWaningHp = (CGFloat)maxHp / 10 * 5;
}

- (void)setPlayerCriticalHp:(int)maxHp
{
	playerCriticalHp = (CGFloat)maxHp / 10 * 3;
}

- (void)setPlayerWaningPow:(int)maxPow
{
	playerWaningPow = (CGFloat)maxPow / 10 * 5;
}

- (void)setPlayerCriticalPow:(int)maxPow
{
	playerCriticalPow = (CGFloat)maxPow / 10 * 3;
}

#pragma mark -

- (void)setStrUpdate:(BOOL)update {
	strUpdate = update;
}
- (void)setDexUpdate:(BOOL)update {
	dexUpdate = update;
}
- (void)setConUpdate:(BOOL)update {
	conUpdate = update;
}
- (void)setIntUpdate:(BOOL)update {
	intUpdate = update;
}
- (void)setWisUpdate:(BOOL)update {
	wisUpdate = update;
}
- (void)setChaUpdate:(BOOL)update {
	chaUpdate = update;
}
- (void)setHpUpdate:(BOOL)update {
	hpUpdate = update;
}
- (void)setPowUpdate:(BOOL)update {
	powUpdate = update;
}
- (void)setAcUpdate:(BOOL)update {
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

- (void)setStHunger:(unsigned)aBool
{
	stHunger = aBool;
}

- (void)setStConfuse:(BOOL)aBool
{
	stConfuse = aBool;
}

- (void)setStSick:(BOOL)aBool
{
	stSick = aBool;
}

- (void)setStIll:(BOOL)aBool
{
	stIll = aBool;
}

- (void)setStBlind:(BOOL)aBool
{
	stBlind = aBool;
}

- (void)setStStun:(BOOL)aBool
{
	stStun = aBool;
}

- (void)setStHallu:(BOOL)aBool
{
	stHallu = aBool;
}

- (void)setStLoad:(int)curVal
{
	stLoad = curVal;
}

- (void)checkStDrawer
{
	if (stHunger > NOT_HUNGRY || stConfuse || stSick || stIll || stBlind || stStun || stHallu || stLoad > UNENCUMBERED) {
		if (stDrawer.state == NSDrawerClosedState || stDrawer.state == NSDrawerClosingState) {
			if (!SOUND_MUTE) {
				[[NSSound soundNamed:@"Purr"] play];
			}
			[stDrawer open];
		}
	} else if (stDrawer.state == NSDrawerOpenState || stDrawer.state == NSDrawerOpeningState) {
		[stDrawer close];
	}
}

#pragma mark -

- (void)pokeDrawer
{
	[window displayIfNeeded];
	[stDrawer.contentView display];
}

- (void)updatePlayer
{
	[self setPlayerClass:[NSString stringWithFormat:NSLocalizedString(@"the %@", @""),
						  [NSString stringWithCString:rank_of(u.ulevel, pl_character[0], flags.female)
											 encoding:NH3DTEXTENCODING]]];
	
	self.playerTime = moves;
	
	if (u.mtimedone) {
		// You're a monster.
		self.playerMaxhp = u.mhmax;
		self.playerHp = u.mh;
		self.playerLv = mons[u.umonnum].mlevel;
	} else {
		// You're normal.
		self.playerMaxhp = u.uhpmax;
		self.playerHp = u.uhp;
		self.playerLv = u.ulevel;
	}
	self.playerMaxpow = u.uenmax;
	self.playerPow = u.uen;
	
	[self setPlayerStr:ACURR(A_STR)];
	[self setPlayerDex:ACURR(A_DEX)];
	[self setPlayerCon:ACURR(A_CON)];
	[self setPlayerInt:ACURR(A_INT)];
	[self setPlayerWis:ACURR(A_WIS)];
	[self setPlayerCha:ACURR(A_CHA)];
	self.playerGold = money_cnt(invent);
#ifdef SCORE_ON_BOTL
	self.playerScore = botl_score();
#else
	[self setPlayerScore:0];
#endif
	self.playerExp = u.uexp;
	self.playerAc = u.uac;
	
	if (Hallucination)
		[self setStHallu:YES];
	else
		[self setStHallu:NO];
	
	if (Confusion)
		[self setStConfuse:YES];
	else
		[self setStConfuse:NO];
	
	if (Stunned)
		[self setStStun:YES];
	else
		[self setStStun:NO];
	
	if (Blind)
		[self setStBlind:YES];
	else
		[self setStBlind:NO];
	
	if (Sick)
		[self setStSick:YES];
	else
		[self setStSick:NO];
	
	if (Vomiting)
		[self setStIll:YES];
	else
		[self setStIll:NO];
	
	[self setStHunger:u.uhs];
	[self setStLoad:near_capacity()];
	
	switch (u.ualign.type) {
		case A_LAWFUL:
			self.playerAlign = @"Lowful";
			[self setLowfulIcon:YES];
			[self setNewtralIcon:NO];
			[self setChaosIcon:NO];
			break;
			
		case A_NEUTRAL:
			self.playerAlign = @"Newtral";
			[self setLowfulIcon:NO];
			[self setNewtralIcon:YES];
			[self setChaosIcon:NO];
			break;
			
		case A_CHAOTIC:
			self.playerAlign = @"Chaotic";
			[self setLowfulIcon:NO];
			[self setNewtralIcon:NO];
			[self setChaosIcon:YES];
			break;
			
		case A_NONE:
			self.playerAlign = @"Evil";
			[self setLowfulIcon:YES];
			[self setNewtralIcon:YES];
			[self setChaosIcon:YES];
			break;
	}
	
	firstTime = NO;

	[self checkStDrawer];
	if (stDrawer.state != NSDrawerClosedState) {
		[stDrawer.contentView setNeedsDisplay:YES];
		[self performSelector:@selector(pokeDrawer) withObject:nil afterDelay:0.5];
	}
}

@end
