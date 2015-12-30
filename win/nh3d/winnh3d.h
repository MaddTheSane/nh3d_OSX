//
//  winnh3d.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

/*	SCCS Id: @(#)winnh3d.h	3.4.	2005/09/07	*/
/* Copyright (C) 1998 by Erik Andersen <andersee@debian.org> */
/* Copyright (C) 1998 by Anthony Taylor <tonyt@ptialaska.net> */
/* NetHack may be freely redistributed.  See license for details. */

#ifndef WINNH3D_H
#define WINNH3D_H

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"

@class MapModel;
@class NH3DMapView;

#import "NH3DUserDefaultsExtern.h"

#import "func_tab.h"
#import "dlb.h"
#import "extern.h"
#import "patchlevel.h"


#import "NH3DUserStatusModel.h"
#import "NH3DMessenger.h"
#import "NH3DMenuWindow.h"
#import "NH3DTileCache.h"
#import "NH3DUserMakeSheetController.h"
#import "NH3DPreferenceController.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct nh3d_nhwindow_data {
	__unsafe_unretained id			win;
	int         type;
} NH3DWinData;

extern struct window_procs nh3d_procs;

// binding NetHack C codes to NH3DObjects.
void nh3d_init_nhwindows(int*__null_unspecified argc, char*__null_unspecified*__null_unspecified argv);
void nh3d_player_selection();
void nh3d_askname();
void nh3d_get_nh_event();
void nh3d_exit_nhwindows(const char *__null_unspecified str);
void nh3d_suspend_nhwindows(const char *__null_unspecified str);
void nh3d_resume_nhwindows();
winid nh3d_create_nhwindow(int type);
void nh3d_clear_nhwindow(winid wid);
void nh3d_display_nhwindow(winid wid, BOOLEAN_P block);
void nh3d_destroy_nhwindow(winid wid);
void nh3d_curs(winid wid, int x, int y);
void nh3d_putstr(winid wid, int attr, const char *__null_unspecified text);
void nh3d_display_file(const char *__null_unspecified filename, BOOLEAN_P must_exist);
void nh3d_start_menu(winid wid);
void nh3d_add_menu(winid wid, int glyph, const ANY_P *__null_unspecified identifier,
		CHAR_P accelerator, CHAR_P group_accel, int attr, 
		const char *__null_unspecified str, BOOLEAN_P presel);
void nh3d_end_menu(winid wid, const char *prompt);
int nh3d_select_menu(winid wid, int how, menu_item *__null_unspecified*__null_unspecified menu_list);
void nh3d_update_inventory();
void nh3d_mark_synch();
void nh3d_wait_synch();
void nh3d_cliparound(int x, int y);
void nh3d_cliparound_window(winid wid, int x, int y);
void nh3d_print_glyph(winid wid,XCHAR_P x,XCHAR_P y,int glyph, int under);
void nh3d_raw_print(const char *str);
void nh3d_raw_print_bold(const char *str);
int nh3d_nhgetch();
int nh3d_nh_poskey(int *__null_unspecified x, int *__null_unspecified y, int *mod);
void nh3d_nhbell();
int nh3d_doprev_message();
char nh3d_yn_function(const char *__null_unspecified question, const char *__null_unspecified choices, CHAR_P def);
void nh3d_getlin(const char *prompt, char *__null_unspecified line);
int nh3d_get_ext_cmd();
void nh3d_number_pad(int num);
void nh3d_delay_output();
void nh3d_start_screen();
void nh3d_end_screen();
void nh3d_outrip(winid wid, int how, time_t when);
//int nh3d_kbhit();


void nh3d_create_nhwindow_by_id( int type, winid i);
void nethack3d_exit(int status);
#ifndef GNUSTEP
void nh3d_set_savefile_name();
#endif
@interface NH3DBindController : NSObject <NSApplicationDelegate> {

	IBOutlet NSWindow *_window;
	IBOutlet NSMenu  *_mainMenu;
	IBOutlet NH3DUserStatusModel *_userStatus;
	IBOutlet NH3DMessenger *_messenger;
	IBOutlet MapModel *_mapModel;
	IBOutlet NH3DOpenGLView *_glMapView;
	IBOutlet NH3DMapView *_asciiMapView;
	IBOutlet NH3DMenuWindow *_menuWindow;
	IBOutlet NSDrawer *_stDrawer;
	
	NH3DPreferenceController *_prefPanel;
	NH3DTileCache			*_tileCache;
}

// App delegates
//
- (BOOL)windowShouldClose:(null_unspecified id)sender;
//- (void)windowWillBeginSheet:(NSNotification *)notification;

- (void)setTile;

//- (void)showSheet:(id)aSheet modalWindow:(id)aWindow;
- (void)showUserMakeSheet;
- (void)showMainWindow;
@property (readonly, strong) NSWindow *mainWindow;

- (void)didPresentError:(NSError *)error;

- (void)printGlyph:(winid)wid xPos:(XCHAR_P)x yPos:(XCHAR_P)y glyph:(int)glyph bkglyph:(int)bkglyph;
- (int)nhPosKeyAtX:(int *)x atY:(int *)y keyMod:(int *)mod;
- (int)nhGetKey;
- (void)updateAll;

// Actions
- (IBAction)startNetHack3D:(null_unspecified id)sender;
- (IBAction)showPreferencePanel:(null_unspecified id)sender;
- (void)endPreferencePanel;

@end

NS_ASSUME_NONNULL_END

#endif /* WINNH3D_H */
