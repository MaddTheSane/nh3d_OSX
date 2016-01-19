/* NH3DUserStatusModel */
//
//  NH3DUserStatusModel.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

#import "NH3DTileCache.h"

@interface NH3DUserStatusModel : NSObject {
//	IBOutlet NSTextField *inputName;
	IBOutlet NSDrawer *stDrawer;
	IBOutlet NSWindow *window;
	
@private
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
	unsigned playerScore;
	unsigned playerTime;
	int playerExp;
	int playerMaxhp;
	int playerMaxpow;
	int	playerHp;
	CGFloat playerWaningHp;
	CGFloat playerCriticalHp;
	CGFloat playerWaningPow;
	CGFloat playerCriticalPow;
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
- (void)setPlayerName:(NSString *)aString;
- (NSAttributedString *)playerClass;
- (void)setPlayerClass:(NSString *)aString;
@property (copy) NSString *playerRace;
@property (copy) NSString *playerRole;
@property (copy) NSString *playerAlign;
@property (copy) NSString *playerGender;

@property (copy) NSString *playerStatusLine;


- (NSString *)playerStr;
@property (nonatomic) int playerDex;
@property (nonatomic) int playerCon;
@property (nonatomic) int playerInt;
@property (nonatomic) int playerWis;
@property (nonatomic) int playerCha;
@property long playerGold;
@property unsigned int playerScore;
@property unsigned int playerTime;
@property int playerExp;

@property int playerHp;
@property (nonatomic) int playerMaxhp;
- (CGFloat)playerWaningHp;
- (CGFloat)playerCriticalHp;
@property int playerPow;
@property (nonatomic) int playerMaxpow;
- (CGFloat)playerWaningPow;
- (CGFloat)playerCriticalPow;
@property (nonatomic) int playerAc;
@property (nonatomic) int playerLv;

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


- (NSImage *)strUpdate;
- (NSImage *)dexUpdate;
- (NSImage *)conUpdate;
- (NSImage *)intUpdate;
- (NSImage *)wisUpdate;
- (NSImage *)chaUpdate;
- (NSImage *)hpUpdate;
- (NSImage *)powUpdate;
- (NSImage *)acUpdate;
- (NSImage *)lvUpdate;

- (NSImage *)lowfulIcon;
- (NSImage *)newtralIcon;
- (NSImage *)chaosIcon;

- (NSImage *)stHunger;
- (NSImage *)stConfuse;
- (NSImage *)stSick;
- (NSImage *)stIll;
- (NSImage *)stBlind;
- (NSImage *)stStun;
- (NSImage *)stHallu;


- (void)setPlayerStr:(int)aValue;

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
