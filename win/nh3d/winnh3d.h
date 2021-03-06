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
@class NH3DPreferenceController;

#import "NH3DUserDefaultsExtern.h"

#import "func_tab.h"
#import "dlb.h"
#import "extern.h"
#import "patchlevel.h"


#import "NH3DUserStatusModel.h"
#import "NH3DMenuWindow.h"
#import "NH3DUserMakeSheetController.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct nh3d_nhwindow_data {
	__unsafe_unretained id	__nullable	win;
	int									type;
} NH3DWinData;

extern struct window_procs nh3d_procs;
extern BOOL CocoaPortIsReady;

// binding NetHack C codes to NH3DObjects.
void nh3d_init_nhwindows(int*__null_unspecified argc, char*__null_unspecified*__null_unspecified argv);
void nh3d_player_selection(void);
void nh3d_askname(void);
void nh3d_get_nh_event(void);
void nh3d_exit_nhwindows(const char *__null_unspecified str);
void nh3d_suspend_nhwindows(const char *__null_unspecified str);
void nh3d_resume_nhwindows(void);
winid nh3d_create_nhwindow(int type);
void nh3d_clear_nhwindow(winid wid);
void nh3d_display_nhwindow(winid wid, boolean block);
void nh3d_destroy_nhwindow(winid wid);
void nh3d_curs(winid wid, int x, int y);
void nh3d_putstr(winid wid, int attr, const char *__null_unspecified text);
void nh3d_display_file(const char *__null_unspecified filename, boolean must_exist);
void nh3d_start_menu(winid wid);
void nh3d_add_menu(winid wid, int glyph, const ANY_P *__null_unspecified identifier,
		char accelerator, char group_accel, int attr,
		const char *__null_unspecified str, boolean presel);
void nh3d_end_menu(winid wid, const char *prompt);
int nh3d_select_menu(winid wid, int how, menu_item *__null_unspecified*__null_unspecified menu_list);
void nh3d_update_inventory(void);
void nh3d_mark_synch(void);
void nh3d_wait_synch(void);
void nh3d_cliparound(int x, int y);
void nh3d_cliparound_window(winid wid, int x, int y);
void nh3d_print_glyph(winid wid, xchar x, xchar y, int glyph, int under);
void nh3d_raw_print(const char *__null_unspecified str);
void nh3d_raw_print_bold(const char *__null_unspecified str);
int nh3d_nhgetch(void);
int nh3d_nh_poskey(int *__null_unspecified x, int *__null_unspecified y, int *__null_unspecified mod);
void nh3d_nhbell(void);
int nh3d_doprev_message(void);
char nh3d_yn_function(const char *__null_unspecified question, const char *__null_unspecified choices, char def);
void nh3d_getlin(const char *__null_unspecified prompt, char *__null_unspecified line);
int nh3d_get_ext_cmd(void);
void nh3d_number_pad(int num);
void nh3d_delay_output(void);
void nh3d_start_screen(void);
void nh3d_end_screen(void);
void nh3d_outrip(winid wid, int how, time_t when);
void nh3d_status_init(void);
void nh3d_status_finish(void);
void nh3d_status_enablefield(int, const char *__null_unspecified, const char *__null_unspecified, boolean);
void nh3d_status_update(int, genericptr_t __null_unspecified, int, int, int, unsigned long *__null_unspecified);
//int nh3d_kbhit();

extern void app_recover(const char* path);

@class NH3DMessaging;
@class NH3DOpenGLView;

void nh3d_create_nhwindow_by_id(int type, winid i);
void nethack3d_exit(int status);
#ifndef GNUSTEP
void nh3d_set_savefile_name(void);
#endif
@interface NH3DBindController : NSObject <NSApplicationDelegate, NSWindowDelegate>

- (void)setTile;

//- (void)showSheet:(id)aSheet modalWindow:(id)aWindow;
- (void)showUserMakeSheet;
@property (weak) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSWindow *launchWindow;

@property (weak) IBOutlet NSView *majorMapView;
@property (weak) IBOutlet NSView *minorMapView;

@property (weak) IBOutlet NSMenu *mainMenu;
@property (weak) IBOutlet NH3DUserStatusModel *userStatus;
@property (weak) IBOutlet NH3DMessaging *messenger;
@property (weak) IBOutlet MapModel *mapModel;
@property (weak) IBOutlet NH3DOpenGLView *glMapView;
@property (weak) IBOutlet NH3DMapView *asciiMapView;
@property (weak) IBOutlet NH3DMenuWindow *menuWindow;
- (void)didPresentError:(NSError *)error;

- (void)printGlyph:(winid)wid xPos:(xchar)x yPos:(xchar)y glyph:(int)glyph bkglyph:(int)bkglyph;
- (int)nhPosKeyAtX:(int *)x atY:(int *)y keyMod:(int *)mod;
- (int)nhGetKey;
- (void)updateAll;

// Actions
- (IBAction)startNetHack3D:(null_unspecified id)sender;
- (IBAction)showPreferencePanel:(null_unspecified id)sender;
- (void)endPreferencePanel;

- (IBAction)openNethackrc:(nullable id)sender;

@end


/// Something really bad happened!
__dead2 NS_SWIFT_NAME(panic(_:))
extern void Swift_NSPanic(NSString *__nonnull panicText);

NS_ASSUME_NONNULL_END

#endif /* WINNH3D_H */
