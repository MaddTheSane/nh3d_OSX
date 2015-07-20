/* NH3DUserStatusModel */
//
//  NH3DUserStatusModel.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

//#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

#import "NH3DTileCache.h"

@interface NH3DUserStatusModel : NSObject {

//	IBOutlet NSTextField *inputName;
	IBOutlet NSDrawer *stDrawer;
	IBOutlet NSWindow *window;
	
	NSMutableDictionary *strAttributes;
	NSShadow *shadow;
	NSMutableParagraphStyle  *style;
	
	NSMutableDictionary *playerParams;

	
	NSString *playerName;
	NSString *playerClass;
	NSString *playerRace;
	NSString *playerRole;
	NSString *playerAlign;
	NSString *playerGender;
	NSString *playerStatusLine;
	int playerStr;
	int playerDex;
	int playerCon;
	int playerInt;
	int playerWis;
	int playerCha;
	int playerGold;
	unsigned playerScore;
	unsigned playerTime;
	int playerExp;
	int playerMaxhp;
	int playerMaxpow;
	int	playerHp;
	float playerWaningHp;
	float playerCriticalHp;
	float playerWaningPow;
	float playerCriticalPow;
	int playerPow;
	int playerAc;
	int playerLv;


	NSImage *playerArmour;
	NSImage *playerCloak;
	NSImage *playerHelmet;
	NSImage *playerShield;
	NSImage *playerGloves;
	NSImage *playerShoes;
	NSImage *playerRingL;
	NSImage *playerRingR;
	NSImage *playerWeapon;
	NSImage *playerSubWeapon;
	NSImage *playerAmulet;
	NSImage *playerBlindFold;
	
	
	BOOL stHunger;
	BOOL stConfuse;
	BOOL stSick;
	BOOL stIll;
	BOOL stBlind;
	BOOL stStun;
	BOOL stHallu;
	
	BOOL strUpdate;
	BOOL dexUpdate;
	BOOL conUpdate;
	BOOL intUpdate;
	BOOL wisUpdate;
	BOOL chaUpdate;
	BOOL hpUpdate;
	BOOL powUpdate;
	BOOL acUpdate;
	BOOL lvUpdate;
	
	BOOL lowfulIcon;
	BOOL newtralIcon;
	BOOL chaosIcon;
	
	BOOL firstTime;
		
//	NSLock *lock;
}

- (void)prepareAttributes;

/*
// Textfield Delegate
- (void)controlTextDidChange:(NSNotification *)notification;
*/
//for cocoa binding

- (NSAttributedString *)playerName;
- (NSAttributedString *)playerClass;
- (NSString *)playerRace;
- (NSString *)playerRole;
- (NSString *)playerAlign;
- (NSString *)playerGender;

- (NSString *)playerStatusLine;


- (NSString *)playerStr;
- (int)playerDex;
- (int)playerCon;
- (int)playerInt;
- (int)playerWis;
- (int)playerCha;
- (int)playerGold;
- (unsigned)playerScore;
- (unsigned)playerTime;
- (int)playerExp;

- (int)playerHp;
- (int)playerMaxhp;
- (float)playerWaningHp;
- (float)playerCriticalHp;
- (int)playerPow;
- (int)playerMaxpow;
- (float)playerWaningPow;
- (float)playerCriticalPow;
- (int)playerAc;
- (int)playerLv;

- (NSImage *)playerArmour;
- (void)setPlayerArmour:(int)glyph;
- (NSImage *)playerCloak;
- (void)setPlayerCloak:(int)glyph;
- (NSImage *)playerHelmet;
- (void)setPlayerHelmet:(int)glyph;
- (NSImage *)playerShield;
- (void)setPlayerShield:(int)glyph;
- (NSImage *)playerGloves;
- (void)setPlayerGloves:(int)glyph;
- (NSImage *)playerShoes;
- (void)setPlayerShoes:(int)glyph;
- (NSImage *)playerRingL;
- (void)setPlayerRingL:(int)glyph;
- (NSImage *)playerRingR;
- (void)setPlayerRingR:(int)glyph;
- (NSImage *)playerWeapon;
- (void)setPlayerWeapon:(int)glyph;
- (NSImage *)playerSubWeapon;
- (void)setPlayerSubWeapon:(int)glyph;
- (NSImage *)playerAmulet;
- (void)setPlayerAmulet:(int)glyph;
- (NSImage *)playerBlindFold;
- (void)setPlayerBlindFold:(int)glyph;

- (void)updatePlayerInventory;


- (NSString *)strUpdate;
- (NSString *)dexUpdate;
- (NSString *)conUpdate;
- (NSString *)intUpdate;
- (NSString *)wisUpdate;
- (NSString *)chaUpdate;
- (NSString *)hpUpdate;
- (NSString *)powUpdate;
- (NSString *)acUpdate;
- (NSString *)lvUpdate;

- (NSString *)lowfulIcon;
- (NSString *)newtralIcon;
- (NSString *)chaosIcon;

- (NSString *)stHunger;
- (NSString *)stConfuse;
- (NSString *)stSick;
- (NSString *)stIll;
- (NSString *)stBlind;
- (NSString *)stStun;
- (NSString *)stHallu;

- (void)setPlayerName:(NSString *)aString;
- (void)setPlayerClass:(NSString *)aString;
- (void)setPlayerRace:(NSString *)aString;
- (void)setPlayerRole:(NSString *)aString;
- (void)setPlayerAlign:(NSString *)aString;
- (void)setPlayerGender:(NSString *)aString;

- (void)setPlayerStatusLine:(NSString *)aString;

- (void)setPlayerStr:(int)aValue;
- (void)setPlayerDex:(int)aValue;
- (void)setPlayerCon:(int)aValue;
- (void)setPlayerInt:(int)aValue;
- (void)setPlayerWis:(int)aValue;
- (void)setPlayerCha:(int)aValue;
- (void)setPlayerGold:(int)aValue;
- (void)setPlayerScore:(unsigned)aValue;
- (void)setPlayerTime:(unsigned)aValue;
- (void)setPlayerExp:(int)aValue;

- (void)setPlayerMaxhp:(int)aValue;
- (void)setPlayerMaxpow:(int)aValue;
- (void)setPlayerHp:(int)aValue;
- (void)setPlayerPow:(int)aValue;
- (void)setPlayerAc:(int)aValue;
- (void)setPlayerLv:(int)aValue;
- (void)setPlayerWaningHp:(int)maxHp;
- (void)setPlayerCriticalHp:(int)maxHp;
- (void)setPlayerWaningPow:(int)maxPow;
- (void)setPlayerCriticalPow:(int)maxPow;

- (void)setStrUpdate:(BOOL)update;
- (void)setDexUpdate:(BOOL)update;
- (void)setConUpdate:(BOOL)update;
- (void)setIntUpdate:(BOOL)update;
- (void)setWisUpdate:(BOOL)update;
- (void)setChaUpdate:(BOOL)update;
- (void)setHpUpdate:(BOOL)update;
- (void)setPowUpdate:(BOOL)update;
- (void)setAcUpdate:(BOOL)update;
- (void)setLvUpdate:(BOOL)update;

- (void)setLowfulIcon:(BOOL)enable;
- (void)setNewtralIcon:(BOOL)enable;
- (void)setChaosIcon:(BOOL)enable;

- (void)setStHunger:(BOOL)aBool;
- (void)setStConfuse:(BOOL)aBool;
- (void)setStSick:(BOOL)aBool;
- (void)setStIll:(BOOL)aBool;
- (void)setStBlind:(BOOL)aBool;
- (void)setStStun:(BOOL)aBool;
- (void)setStHallu:(BOOL)aBool;
- (void)checkStDrawer;

//- (void)createPlayer;
- (void)updatePlayer;

//- (IBAction)checkRace:(id)sender;
//- (IBAction)checkRole:(id)sender;
//- (IBAction)checkGender:(id)sender;





@end
