//
//  NH3DUserMakeSheetController.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/12/24.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

#import "NH3DUserMakeSheetController.h"
#import "NH3DUserStatusModel.h"


static const int DIALOG_OK		= 128;
static const int DIALOG_CANCEL	= 129;



@implementation NH3DUserMakeSheetController
@synthesize playerName;

- (instancetype) init {
	self = [ super initWithWindowNibName:@"Usermakesheet" ];
	if (self != nil) {
		
		[ self setPriestName:@"Priest" ];
		[ self setCavemanName:@"Caveman" ];
		playerName = nil;

	}
	return self;
}


- (void)awakeFromNib {
	[super awakeFromNib];
	[self.window setStyleMask:NSBorderlessWindowMask];
	self.window.backgroundColor = [NSColor clearColor];
	self.window.opaque = NO;
}
	

- ( void )setPriestName:( NSString * )aString {
	priestName = NSLocalizedString(aString,@"");
}


- ( void )setCavemanName:( NSString * )aString {
	cavemanName = NSLocalizedString(aString, @"");
}

- (IBAction)checkRace:(id)sender
{
	int tag ;
	tag = [ chooseRace selectedTag ];
	[ _userStatus setPlayerRole:nil ];
	[ self setDone_role:NO ];
	[ self setEn_male:NO ];
	[ self setEn_female:NO ];
	[ self setEn_lowful:NO ];
	[ self setEn_newtral:NO ];
	[ self setEn_chaotic:NO ];
	[ chooseRole deselectSelectedCell ];

	switch ( tag ) {
		
		case 0:
			[ _userStatus setPlayerRace:@"Human" ];
			[ self setDone_race:YES ];
			[ self setEn_archeologist:YES ];
			[ self setEn_barbarian:YES ];
			[ self setEn_caveman:YES ];
			[ self setEn_healer:YES ];
			[ self setEn_knight:YES ];
			[ self setEn_monk:YES ];
			[ self setEn_priest:YES ];
			[ self setEn_rouge:YES ];
			[ self setEn_ranger:YES ];
			[ self setEn_samurai:YES ];
			[ self setEn_tourist:YES ];
			[ self setEn_valkyrie:YES ];
			[ self setEn_wizard:YES ];
			break;
			
		case 1:
			[ _userStatus setPlayerRace:@"Elf" ];
			[ self setDone_race:YES ];
			[ self setEn_archeologist:NO ];
			[ self setEn_barbarian:NO ];
			[ self setEn_caveman:NO ];
			[ self setEn_healer:NO ];
			[ self setEn_knight:NO ];
			[ self setEn_monk:NO ];
			[ self setEn_priest:YES ];
			[ self setEn_rouge:NO ];
			[ self setEn_ranger:YES ];
			[ self setEn_samurai:NO ];
			[ self setEn_tourist:NO ];
			[ self setEn_valkyrie:NO ];
			[ self setEn_wizard:YES ];
			break;
			
		case 2:
			[ _userStatus setPlayerRace:@"Dwarf" ];
			[ self setDone_race:YES ];
			[ self setEn_archeologist:YES ];
			[ self setEn_barbarian:NO ];
			[ self setEn_caveman:YES ];
			[ self setEn_healer:NO ];
			[ self setEn_knight:NO ];
			[ self setEn_monk:NO ];
			[ self setEn_priest:NO ];
			[ self setEn_rouge:NO ];
			[ self setEn_ranger:NO ];
			[ self setEn_samurai:NO ];
			[ self setEn_tourist:NO ];
			[ self setEn_valkyrie:YES ];
			[ self setEn_wizard:NO ];
			break;
			
		case 3:
			[ _userStatus setPlayerRace:@"Gnome" ];
			[ self setDone_race:YES ];
			[ self setEn_archeologist:YES ];
			[ self setEn_barbarian:NO ];
			[ self setEn_caveman:YES ];
			[ self setEn_healer:YES ];
			[ self setEn_knight:NO ];
			[ self setEn_monk:NO ];
			[ self setEn_priest:NO ];
			[ self setEn_rouge:NO ];
			[ self setEn_ranger:YES ];
			[ self setEn_samurai:NO ];
			[ self setEn_tourist:NO ];
			[ self setEn_valkyrie:NO ];
			[ self setEn_wizard:YES ];
			break;
			
		case 4:
			[ _userStatus setPlayerRace:@"Orc" ];
			[ self setDone_race:YES ];
			[ self setEn_archeologist:NO ];
			[ self setEn_barbarian:YES ];
			[ self setEn_caveman:NO ];
			[ self setEn_healer:NO ];
			[ self setEn_knight:NO ];
			[ self setEn_monk:NO ];
			[ self setEn_priest:NO ];
			[ self setEn_rouge:YES ];
			[ self setEn_ranger:YES ];
			[ self setEn_samurai:NO ];
			[ self setEn_tourist:NO ];
			[ self setEn_valkyrie:NO ];
			[ self setEn_wizard:YES ];
			break;
			
		default:
			[ _userStatus setPlayerRace:nil ];
			[ self setDone_race:NO ];
			[ self setEn_archeologist:NO ];
			[ self setEn_barbarian:NO ];
			[ self setEn_caveman:NO ];
			[ self setEn_healer:NO ];
			[ self setEn_knight:NO ];
			[ self setEn_monk:NO ];
			[ self setEn_priest:NO ];
			[ self setEn_rouge:NO ];
			[ self setEn_ranger:NO ];
			[ self setEn_samurai:NO ];
			[ self setEn_tourist:NO ];
			
			[ self setEn_valkyrie:NO ];
			[ self setEn_wizard:NO ];
	}
}

- ( IBAction )checkRole:( id )sender 
{
	int tag ;
	int race;
	tag = [ chooseRole selectedTag ];
	race = [ chooseRace selectedTag ];

	/*
	if ( [ [ inputName stringValue ] isEqual:@"" ] || [ [ inputName stringValue ] cStringLength ] >= PL_NSIZ-11 ) {
		[ self setPlayerName:[ NSString stringWithFormat:@"%@%d%@",@"input 1to",PL_NSIZ-12,@"Chars." ] ];
		[ self setDone_name:NO ];
	}
	else {
		[ self setPlayerName:[ inputName stringValue ] ];
		[ self setDone_name:YES ];
	}
	*/
	
	switch ( tag ) {
		case 0 :
			[ _userStatus setPlayerRole:@"Archeologist" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 1 :
			[ _userStatus setPlayerRole:@"Barbarian" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 2 :
			[ _userStatus setPlayerRole:cavemanName ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 3 :
			[ _userStatus setPlayerRole:@"Healer" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 4 :
			[ _userStatus setPlayerRole:@"Knight" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 5 :
			[ _userStatus setPlayerRole:@"Monk" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 6 :
			[ _userStatus setPlayerRole:priestName ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 7 :
			[ _userStatus setPlayerRole:@"Rogue" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 8 :
			[ _userStatus setPlayerRole:@"Ranger" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 9 :
			[ _userStatus setPlayerRole:@"Samurai" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 10 :
			[ _userStatus setPlayerRole:@"Tourist" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		case 11 :
			[ _userStatus setPlayerRole:@"Valkyrie" ];
			[ chooseGender selectCellWithTag:1 ];
			[ self setPriestName:@"Priestess" ];
			[ self setCavemanName:@"Cavewoman" ];
			[ _userStatus setPlayerGender:@"Female" ];
			[ self setDone_role:YES ];
			[ self setEn_male:NO ];
			[ self setEn_female:YES ];
			break;
		case 12 :
			[ _userStatus setPlayerRole:@"Wizard" ];
			[ self setDone_role:YES ];
			[ self setEn_male:YES ];
			[ self setEn_female:YES ];
			break;
		default:
			[ _userStatus setPlayerRole:nil ];
			[ self setDone_role:NO ];
			[ self setEn_male:NO ];
			[ self setEn_female:NO ];
			[ self setEn_lowful:NO ];
			[ self setEn_newtral:NO ];
			[ self setEn_chaotic:NO ];
			
	}
	
	switch ( race ) {
		case 0 :
			switch ( tag ) {
				case 0 :
				case 2 :
				case 11 :
					if ( [ chooseAlign selectedTag ] == 2 ) {
						[ chooseAlign selectCellWithTag:1 ];
					}
					[ self setEn_lowful:YES ];
					[ self setEn_newtral:YES ];
					[ self setEn_chaotic:NO ];
					break;
				case 1 :
				case 8 :
				case 12 :
					if ( [ chooseAlign selectedTag ] == 0 ) {
						[ chooseAlign selectCellWithTag:1 ];
					}
					[ self setEn_lowful:NO ];
					[ self setEn_newtral:YES ];
					[ self setEn_chaotic:YES ];
					break;
				case 3 :
				case 10 :
					[ chooseAlign selectCellWithTag:1 ];
					[ self setEn_lowful:NO ];
					[ self setEn_newtral:YES ];
					[ self setEn_chaotic:NO ];
					break;
				case 4 :
				case 9 :
					[ chooseAlign selectCellWithTag:0 ];
					[ self setEn_lowful:YES ];
					[ self setEn_newtral:NO ];
					[ self setEn_chaotic:NO ];
					break;
				case 5 :
				case 6 :
					[ self setEn_lowful:YES ];
					[ self setEn_newtral:YES ];
					[ self setEn_chaotic:YES ];
					break;
				case 7 :
					[ chooseAlign selectCellWithTag:2 ];
					[ self setEn_lowful:NO ];
					[ self setEn_newtral:NO ];
					[ self setEn_chaotic:YES ];
					break;
			}
			
			break;
		case 1 :
			[ chooseAlign selectCellWithTag:2 ];
			[ self setEn_lowful:NO ];
			[ self setEn_newtral:NO ];
			[ self setEn_chaotic:YES ];
			break;
		case 2 :
			[ chooseAlign selectCellWithTag:0 ];
			[ self setEn_lowful:YES ];
			[ self setEn_newtral:NO ];
			[ self setEn_chaotic:NO ];
			break;
		case 3 :
			[ chooseAlign selectCellWithTag:1 ];
			[ self setEn_lowful:NO ];
			[ self setEn_newtral:YES ];
			[ self setEn_chaotic:NO ];
			break;
		case 4 :
			[ chooseAlign selectCellWithTag:2 ];
			[ self setEn_lowful:NO ];
			[ self setEn_newtral:NO ];
			[ self setEn_chaotic:YES ];
			break;
	}
	
}

- ( IBAction )checkGender:( id )sender
{
	int tag,role;
	tag = [ chooseGender selectedTag ];
	role = [ chooseRole selectedTag ];
	
	/*
	if ( [ [ inputName stringValue ] isEqual:@"" ] || [ [ inputName stringValue ] cStringLength ] >= PL_NSIZ-11 ) {
		[ self setPlayerName:[ NSString stringWithFormat:@"%@%d%@",@"input 1to",PL_NSIZ-12,@"Chars." ] ];
		[ self setDone_name:NO ];
	}
	else {
		[ self setPlayerName:[ inputName stringValue ] ];
		[ self setDone_name:YES ];
	}
	 */
	
	if ( !tag ) {
		[ self setPriestName:@"Priest" ];
		[ self setCavemanName:@"Caveman" ];
		[ _userStatus setPlayerGender:@"Male" ];
	}
	else {
		[ self setPriestName:@"Priestess" ];
		[ self setCavemanName:@"Cavewoman" ];
		[ _userStatus setPlayerGender:@"Female" ];
	}
	
	if ( role == 2 || role == 6 ) {
		[ self checkRole:self ];
	}			
}

//
// Matrix tags enabled/disabled use CocoaBinding
//
- ( void )setDone_race:( BOOL )enable {
	done_race = enable;
}	
- ( void )setDone_role:( BOOL )enable {
	done_role = enable;
}
- ( void )setDone_name:( BOOL )enable {
	done_name = enable;
}

- ( void )setEn_archeologist:( BOOL )enable {
	en_archeologist = enable;
}
- ( void )setEn_barbarian:( BOOL )enable {
	en_barbarian = enable;
}
- ( void )setEn_caveman:( BOOL )enable {
	en_caveman = enable;
}
- ( void )setEn_healer:( BOOL )enable {
	en_healer = enable;
}
- ( void )setEn_knight:( BOOL )enable {
	en_knight = enable;
}
- ( void )setEn_monk:( BOOL )enable {
	en_monk = enable;
}
- ( void )setEn_priest:( BOOL )enable {
	en_priest = enable;
}
- ( void )setEn_rouge:( BOOL )enable {
	en_rouge = enable;
}
- ( void )setEn_ranger:( BOOL )enable {
	en_ranger = enable;
}
- ( void )setEn_samurai:( BOOL )enable {
	en_samurai = enable;
}
- ( void )setEn_tourist:( BOOL )enable {
	en_tourist = enable;
}
- ( void )setEn_valkyrie:( BOOL )enable {
	en_valkyrie = enable;
}
- ( void )setEn_wizard:( BOOL )enable {
	en_wizard = enable;
}


- ( void )setEn_lowful:( BOOL )enable {
	en_lowful = enable;
}
- ( void )setEn_newtral:( BOOL )enable {
	en_newtral = enable;
}
- ( void )setEn_chaotic:( BOOL )enable {
	en_chaotic = enable;
}

- ( void )setEn_male:( BOOL )enable {
	en_male = enable;
}
- ( void )setEn_female:( BOOL )enable {
	en_female = enable;
}



- ( void )createPlayer
{	
	int race,role,align,gender;
	align = [ chooseAlign selectedTag ];
	role = [ chooseRole selectedTag ];
	race = [ chooseRace selectedTag ];
	gender = [ chooseGender selectedTag ];
	
	switch ( align ) {
		case 0 : 
			[ _userStatus setPlayerAlign:@"Lowful" ];
			[ _userStatus setLowfulIcon:YES ];
			[ _userStatus setNewtralIcon:NO ];
			[ _userStatus setChaosIcon:NO ];
			break;
		case 1 :
			[ _userStatus setPlayerAlign:@"Newtral" ];
			[ _userStatus setLowfulIcon:NO ];
			[ _userStatus setNewtralIcon:YES ];
			[ _userStatus setChaosIcon:NO ];
			break;
		case 2 :
			[ _userStatus setPlayerAlign:@"Chaotic" ];
			[ _userStatus setLowfulIcon:NO ];
			[ _userStatus setNewtralIcon:NO ];
			[ _userStatus setChaosIcon:YES ];
			break;
	}
	
	flags.initrace = race;
	flags.initrole = role;
	flags.initgend = gender;
	flags.initalign = align;
	
}


- (void)startSheet:(NH3DUserStatusModel *)userStatusModel
{
	
	_userStatus = userStatusModel;
	
	self.playerName = [userStatusModel playerName];
	
	[NSApp.mainWindow beginSheet:self.window completionHandler:^(NSModalResponse returnCode) {
		[NSApp stopModal];
		[self.window orderOut:self];
		
		// Check return code
		if(returnCode == DIALOG_CANCEL) {
			// Quit button was pushed
			[ NSApp terminate:self ];
			return;
		} else if(returnCode == DIALOG_OK) {
			/* direct to makePlayer method */
		}
	}];
	
	[NSApp runModalForWindow:self.window];
}


- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [self.window orderOut:self];
	[NSApp stopModal];
	//[ [ self window ] release ];
    
    // Check return code
    if(returnCode == DIALOG_CANCEL) {
        // Quit button was pushed
		[NSApp terminate:self];
        return;
    }
    else if(returnCode == DIALOG_OK) {
		/* direct to makePlayer method */
    }
}



- (IBAction)makePlayer:(id)sender 
{
	
	[ self createPlayer ];
	[NSApp.mainWindow endSheet: self.window returnCode:DIALOG_OK];
	
}


- (IBAction)quitGame:(id)sender
{
    // Cancel button is pushed
    [NSApp.mainWindow endSheet: self.window returnCode:DIALOG_CANCEL];
}


@end
