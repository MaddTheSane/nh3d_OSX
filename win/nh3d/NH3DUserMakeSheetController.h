//
//  NH3DUserMakeSheetController.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/12/24.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

@class NH3DUserStatusModel;


@interface NH3DUserMakeSheetController : NSWindowController {

	NH3DUserStatusModel *_userStatus;
	
	IBOutlet NSMatrix *chooseRace;
	IBOutlet NSMatrix *chooseRole;
	IBOutlet NSMatrix *chooseAlign;
	IBOutlet NSMatrix *chooseGender;
	
@private
	// for UserMakeSeet
	BOOL done_race;
	BOOL done_role;
	BOOL done_name;
	
	BOOL en_archeologist;
	BOOL en_barbarian;
	BOOL en_caveman;
	BOOL en_healer;
	BOOL en_knight;
	BOOL en_monk;
	BOOL en_priest;
	BOOL en_rouge;
	BOOL en_ranger;
	BOOL en_samurai;
	BOOL en_tourist;
	BOOL en_valkyrie;
	BOOL en_wizard;
	
	BOOL en_lowful;
	BOOL en_newtral;
	BOOL en_chaotic;
	
	BOOL en_male;
	BOOL en_female;
	
	NSString *priestName;
	NSString *cavemanName;
	
	NSAttributedString *playerName;
	
}

- (void)setDone_race:(BOOL)enable;
- (void)setDone_role:(BOOL)enable;
- (void)setDone_name:(BOOL)enable;

- (void)setEn_archeologist:(BOOL)enable;
- (void)setEn_barbarian:(BOOL)enable;
- (void)setEn_caveman:(BOOL)enable;
- (void)setEn_healer:(BOOL)enable;
- (void)setEn_knight:(BOOL)enable;
- (void)setEn_monk:(BOOL)enable;
- (void)setEn_priest:(BOOL)enable;
- (void)setEn_rouge:(BOOL)enable;
- (void)setEn_ranger:(BOOL)enable;
- (void)setEn_samurai:(BOOL)enable;
- (void)setEn_tourist:(BOOL)enable;
- (void)setEn_valkyrie:(BOOL)enable;
- (void)setEn_wizard:(BOOL)enable;
- (void)setEn_lowful:(BOOL)enable;
- (void)setEn_newtral:(BOOL)enable;
- (void)setEn_chaotic:(BOOL)enable;

- (void)setEn_male:(BOOL)enable;
- (void)setEn_female:(BOOL)enable;

- (void)setPriestName:(NSString *)aString;
- (void)setCavemanName:(NSString *)aString;

@property (copy) NSAttributedString *playerName;

- (void)startSheet:(NH3DUserStatusModel *)userStatusModel;

- (IBAction)makePlayer:(id)sender;
- (IBAction)quitGame:(id)sender;

- (IBAction)checkRace:(id)sender;
- (IBAction)checkRole:(id)sender;
- (IBAction)checkGender:(id)sender;


@end
