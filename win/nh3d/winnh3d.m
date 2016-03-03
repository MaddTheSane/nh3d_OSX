//
//  winnh3d.m
//  NetHack3D Application Controller
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

#include "C99Bool.h"
#import "winnh3d.h"
#import "NetHack3D-Swift.h"
#import "NH3DMapView.h"
#import "NetHack3D-Swift.h"
#import "NetHack3D-Bridging-Header.h"

#include <sys/stat.h>
#include <signal.h>
#include <pwd.h>
#ifndef O_RDONLY
#include <sys/fcntl.h>
#endif
#ifdef XI18N
#include <X11/Xlocale.h>
#endif

#if !defined(_BULL_SOURCE) && !defined(__sgi) && !defined(_M_UNIX)
# if !defined(SUNOS4) && !(defined(ULTRIX) && defined(__GNUC__))
#  if defined(POSIX_TYPES) || defined(SVR4) || defined(HPUX)
extern struct passwd *FDECL(getpwuid, (uid_t));
#  else
extern struct passwd *FDECL(getpwuid, (int));
#  endif
# endif
#endif
extern struct passwd *FDECL(getpwnam, (const char *));
#ifdef CHDIR
static void FDECL(chdirx, (const char *,boolean));
#endif /* CHDIR */
static boolean NDECL(whoami);
static void FDECL(process_options, (int, char **));


#ifdef WIZARD
static boolean wiz_error_flag = FALSE;
#endif


NH3DWinData nh3d_windowlist[10];

extern int NXArgc;
extern char **NXArgv;
extern char *sounddir;

//bind NetHack C routines to NH3DObjects.
//set object's instance pointer to work.
static __strong NH3DBindController *_NH3DBindController;
static __strong NH3DUserStatusModel *_NH3DUserStatusModel;
static __strong MapModel *_NH3DMapModel;
static __strong NH3DMessaging *_NH3DMessenger;
static __strong NH3DMenuWindow *_NH3DMenuWindow;
static __strong NH3DMapView *_NH3DKeyBuffer;
static __strong NH3DOpenGLView *_NH3DOpenGLView;

__strong NH3DTileCache *_NH3DTileCache;

static void NDECL(wd_message);

// set Localized String's Text encoding(used only for hard corded strings in 'C' source files)
// localized 'Cocoa' Strings use '<your locale>.iproj/Localizable.strings'file. that format is "baseStr"="LocalStr";.  
//const NSStringEncoding NH3DTEXTENCODING = NSJapaneseEUCStringEncoding;
//const NSStringEncoding NH3DTEXTENCODING = NSASCIIStringEncoding;
const NSStringEncoding NH3DTEXTENCODING = NSUTF8StringEncoding;

extern BOOL CocoaPortIsReady;
BOOL CocoaPortIsReady = NO;

// UserDefaultKeys
NSString *NH3DMsgFontKey = @"MainFontName";
NSString *NH3DMapFontKey = @"FixedWidthFontName";
NSString *NH3DBoldFontKey = @"BoldFontName" ;
NSString *NH3DInventryFontKey = @"MenuItemFontName";
NSString *NH3DWindowFontKey = @"WindowFontName";

NSString *NH3DMsgFontSizeKey = @"MainFontSize";
NSString *NH3DMapFontSizeKey = @"FixedWidthFontSize";
NSString *NH3DBoldFontSizeKey = @"BoldFontSize";
NSString *NH3DInventryFontSizeKey = @"MenuItemFontSize";
NSString *NH3DWindowFontSizeKey = @"WindowFontSize";

NSString *NH3DOpenGLWaitRateKey = @"OpenGLViewFrameRateValue";
NSString *NH3DOpenGLWaitSyncKey = @"OpenGLViewisWaitSync";
NSString *NH3DOpenGLUseWaitRateKey = @"OpenGLViewHasWaitRate";
NSString *NH3DOpenGLNumberOfThreadsKey = @"OpenGLViewNumberOfThreads";
NSString *NH3DGLTileKey = @"OpenGLViewUseTile";

NSString *NH3DUseTileInLevelMapKey = @"LevelMapisUseTile";
NSString *NH3DUseSightRestrictionKey = @"ASCIIMapisRestricted";

NSString *NH3DUseTraditionalMapKey = @"UseTraditionalMap";
NSString *NH3DTraditionalMapModeKey = @"TraditionalMapMode";

NSString *const NH3DTileNameKey = @"TileName";
NSString *const NH3DTileSizeWidthKey = @"TileSizeWidth";
NSString *const NH3DTileSizeHeightKey = @"TileSizeHeight";
NSString *const NH3DTilesPerLineKey = @"TilesPerLine";
NSString *const NH3DNumberOfTilesRowKey = @"NumberOfTilesRow";

NSString *const NH3DUseRetinaOpenGL = @"Use Retina";

NSString *const NH3DSoundMuteKey = @"SoundMute";

NSString *const NHUseNumPad = @"Use Num Pad";
NSString *const NHMaxMessages = @"Max messages";

static void
process_options(int argc, char *argv[])
{
	int i;
	int l;
	/*
	 * Process options.
	 */
	while(argc > 1 && argv[ 1 ][ 0 ] == '-'){
		argv++;
		argc--;
		l = (int) strlen(*argv);
		/* must supply at least 4 chars to match "-XXXgraphics" */
		if (l < 4)
			l = 4;
		switch(argv[ 0 ][ 1 ]){
			case 'D':
			case 'd':
				if ((argv[0][1] == 'D' && !argv[0][2])
					|| !strcmpi(*argv, "-debug")) {
					wizard = TRUE, discover = FALSE;
				} else if (!strncmpi(*argv, "-DECgraphics", l)) {
					load_symset("DECGraphics", PRIMARY);
					switch_symbols(TRUE);
				} else {
					//raw_printf("Unknown option: %s", *argv);
				}
				break;

			case 'X':
				wizard = TRUE, discover = TRUE;
				break;
#ifdef NEWS
			case 'n':
				iflags.news = FALSE;
				break;
#endif
			case 'u':
				if(argv[ 0 ][ 2 ])
					(void) strncpy(plname, argv[ 0 ]+2, sizeof(plname)-1);
				else if(argc > 1) {
					argc--;
					argv++;
					(void) strncpy(plname, argv[ 0 ], sizeof(plname)-1);
				} else
					raw_print("Player name expected after -u");
				break;
			case 'I':
			case 'i':
				if (!strncmpi(argv[ 0 ]+1, "IBM", 3)) {
					load_symset("IBMGraphics", PRIMARY);
					load_symset("RogueIBM", ROGUESET);
					switch_symbols(TRUE);
				}
				break;
			case 'p': /* profession (role) */
				if (argv[ 0 ][ 2 ]) {
					if ((i = str2role(&argv[ 0 ][ 2 ])) >= 0)
						flags.initrole = i;
				} else if (argc > 1) {
					argc--;
					argv++;
					if ((i = str2role(argv[ 0 ])) >= 0)
						flags.initrole = i;
				}
				break;
			case 'r': /* race */
				if (argv[ 0 ][ 2 ]) {
					if ((i = str2race(&argv[ 0 ][ 2 ])) >= 0)
						flags.initrace = i;
				} else if (argc > 1) {
					argc--;
					argv++;
					if ((i = str2race(argv[ 0 ])) >= 0)
						flags.initrace = i;
				}
				break;
			case '@':
				flags.randomall = 1;
				break;
			default:
				if ((i = str2role(&argv[ 0 ][ 1 ])) >= 0) {
					flags.initrole = i;
					break;
				}
				/* else raw_printf("Unknown option: %s", *argv); */
		}
	}
	
	if(argc > 1)
		locknum = atoi(argv[ 1 ]);
#ifdef MAX_NR_OF_PLAYERS
	if(!locknum || locknum > MAX_NR_OF_PLAYERS)
		locknum = MAX_NR_OF_PLAYERS;
#endif
}

#ifdef CHDIR
static void
chdirx(const char *dir, boolean wr)
{
	if (dir					/* User specified directory? */
# ifdef HACKDIR
		&& strcmp(dir, HACKDIR)		/* and not the default? */
# endif
		) {
# ifdef SECURE
		(void) setgid(getgid());
		(void) setuid(getuid());		/* Ron Wessels */
# endif
	} else {
		/* non-default data files is a sign that scores may not be
		 * compatible, or perhaps that a binary not fitting this
		 * system's layout is being used.
		 */
# ifdef VAR_PLAYGROUND
		int len = strlen(VAR_PLAYGROUND);
		
		fqn_prefix[SCOREPREFIX] = (char *)alloc(len+2);
		Strcpy(fqn_prefix[SCOREPREFIX], VAR_PLAYGROUND);
		if (fqn_prefix[SCOREPREFIX][len-1] != '/') {
			fqn_prefix[SCOREPREFIX][len] = '/';
			fqn_prefix[SCOREPREFIX][len+1] = '\0';
		}
# endif
	}
	
# ifdef HACKDIR
	if (dir == (const char *)0)
		dir = HACKDIR;
# endif
		
		if (dir && chdir(dir) < 0) {
			perror(dir);
			error("Cannot chdir to %s.", dir);
		}
	
	/* warn the player if we can't write the record file */
	/* perhaps we should also test whether . is writable */
	/* unfortunately the access system-call is worthless */
	if (wr) {
# ifdef VAR_PLAYGROUND
		fqn_prefix[LEVELPREFIX] = fqn_prefix[SCOREPREFIX];
		fqn_prefix[SAVEPREFIX] = fqn_prefix[SCOREPREFIX];
		fqn_prefix[BONESPREFIX] = fqn_prefix[SCOREPREFIX];
		fqn_prefix[LOCKPREFIX] = fqn_prefix[SCOREPREFIX];
		fqn_prefix[TROUBLEPREFIX] = fqn_prefix[SCOREPREFIX];
# endif
		check_recordfile(dir);
	}
}
#endif /* CHDIR */

#ifdef PORT_HELP
void
port_help()
{
	display_file(PORT_HELP, TRUE);
}
#endif

//--------------------------------------------------------------//
#pragma mark -- bind to NH3D Objects --
//--------------------------------------------------------------//

void nh3d_init_nhwindows(int* argc, char** argv)
{
	/*All window incetance are already completion when loaded .nib file*/
	iflags.window_inited = TRUE;

#ifdef GNUSTEP
	NXArgc = *argc;
	NXArgv = argv;

	NSApplicationMain(*argc,  argv);
	exit(EXIT_SUCCESS);
#endif
}

void nh3d_player_selection()
{			
	@autoreleasepool {
		[_NH3DBindController showUserMakeSheet];
	}
}

void nh3d_askname()
{
	@autoreleasepool {
		nh3d_getlin([NSLocalizedString(@"Who are you?", @"") cStringUsingEncoding:NH3DTEXTENCODING], plname);
		
		if ([NSString stringWithCString:plname encoding:NH3DTEXTENCODING].length >= PL_NSIZ-11) {
			plname[0] = 0;
			
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = NSLocalizedString(@"A name is too long, and it is difficult to learn.", @"");
			alert.informativeText = NSLocalizedString(@"Please input it within 1 to 20 characters.", @"");
			[alert runModal];
		} else {
			NSString *pcName = [[NSString alloc] initWithCString:plname encoding:NH3DTEXTENCODING];
			[_NH3DUserStatusModel setPlayerName:pcName];
		}
	}
}

static NSMutableDictionary<NSString*, NSSound*> *soundDict = nil;

void nh3d_get_nh_event()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		soundDict = [[NSMutableDictionary alloc] initWithCapacity:9];
	});
	NSSound *soundEffect = nil;
	
	@autoreleasepool {
		if (SOUND_MUTE)
			return;
		
		int se = random() % 150;
		
		switch (se) {
#define PlaySoundName(aName) \
soundEffect = soundDict[aName]; \
if (!soundEffect) { \
soundEffect = [NSSound soundNamed:aName]; \
soundDict[aName] = soundEffect; \
} \
[soundEffect play]

			case 1:
				PlaySoundName(@"waterDrop");
				break;
				
			case 8:
			case 48:
			case 18:
				PlaySoundName(@"hearnoise");
				break;
				
			case 13:
				PlaySoundName(@"waterDrop5");
				break;
				
			//case 18:
			//	soundEffect = [NSSound soundNamed:@"hearnoise"];
			//	[soundEffect play];
			//	break;
				
			case 25:
				PlaySoundName(@"waterDrop2");
				break;
				
			case 32:
			case 57:
				PlaySoundName(@"waterDrop4");
				break;
				
			//case 48:
			//	soundEffect = [NSSound soundNamed:@"hearnoise"];
			//	[soundEffect play];
			//	break;
				
			//case 57:
			//	soundEffect = [NSSound soundNamed:@"waterDrop4"];
			//	[soundEffect play];
			//	break;
				
			case 80:
				PlaySoundName(@"waterDrop3");
				break;
				
			default:
				soundEffect = nil;
				break;
		}
#undef PlaySoundName
	}
	// Make sure we're playing the sound
	if (soundEffect != nil && !soundEffect.isPlaying) {
		[soundEffect play];
	}
}

void nh3d_exit_nhwindows(const char *str)
{
	[_NH3DOpenGLView setRunning:NO];
}

void nh3d_suspend_nhwindows(const char *str)
{
	/*Do Nothing.*/
	return;
}

void nh3d_resume_nhwindows()
{
	/*Do Nothing.*/
	return;
}

/*
NHW_MESSAGE 1
NHW_STATUS  2
NHW_MAP     3
NHW_MENU    4
NHW_TEXT    5
*/ 

winid nh3d_create_nhwindow(int type)
{
	@autoreleasepool {
		int i;

		for (i = 1; i < 10; i++) {
			if (nh3d_windowlist[i].win == nil) {
				break;
			}
		}
		if (i > 10) {
			NSLog(@"ERROR:  No windows available...\n");
		}
		nh3d_create_nhwindow_by_id(type, i);
		
		return i;
	}
}

void nh3d_create_nhwindow_by_id(int type, winid i)
{
	@autoreleasepool {
		switch (type) {
			case NHW_MAP:
				nh3d_windowlist[i].win = _NH3DMapModel;
				nh3d_windowlist[i].type = NHW_MAP;
				break;

			case NHW_MESSAGE:
				nh3d_windowlist[i].win = _NH3DMessenger;
				nh3d_windowlist[i].type = NHW_MESSAGE;
				break; 

			case NHW_STATUS:
				nh3d_windowlist[i].win = _NH3DUserStatusModel;
				nh3d_windowlist[i].type = NHW_STATUS;
				break;

			case NHW_MENU:
				nh3d_windowlist[i].win = _NH3DMenuWindow;
				nh3d_windowlist[i].type = NHW_MENU;
				break;

			case NHW_TEXT:
				nh3d_windowlist[i].win = _NH3DMenuWindow;
				nh3d_windowlist[i].type = NHW_TEXT;
				break;
		}
	}
}

void nh3d_clear_nhwindow(winid wid)
{
	@autoreleasepool {
		switch (nh3d_windowlist[wid].type) {
			case NHW_MAP:
				[_NH3DMapModel clearMapModel];
				break;
				
			case NHW_MESSAGE:
				//[_NH3DMessenger clearMainMessage];
				break;
				
			case NHW_STATUS:
				break;
				
			case NHW_MENU:
				if (_NH3DMenuWindow.isMenu) {
					[_NH3DMenuWindow clearMenuWindow];
				} else {
					[_NH3DMenuWindow clearTextMessage];
				}
				break;
				
			case NHW_TEXT:
				[_NH3DMenuWindow clearTextMessage];
				break;
		}
	}
}

void nh3d_display_nhwindow(winid wid, boolean block)
{
	@autoreleasepool {
		switch (nh3d_windowlist[wid].type) {
			case NHW_MENU:
				if (_NH3DMenuWindow.isMenu) {
					[_NH3DMenuWindow showMenuPanel:""];
				} else {
					[_NH3DMenuWindow showTextPanel];
				}
				break;
				
			case NHW_TEXT:
				[_NH3DMenuWindow showTextPanel];
				break;
		}
	}
}

void nh3d_destroy_nhwindow(winid wid)
{
	@autoreleasepool {
		switch (nh3d_windowlist[wid].type) {
			case NHW_MAP:
			case NHW_MESSAGE:
			case NHW_STATUS:
				/* No thanks */
				return;
				break;
				
			case NHW_MENU:
				[_NH3DMenuWindow clearMenuWindow];
				[_NH3DMenuWindow setIsMenu:NO];
				[_NH3DMenuWindow clearTextMessage];
		
				nh3d_windowlist[wid].win = nil;
				nh3d_windowlist[wid].type = 0;
				break;

			case NHW_TEXT:
				[_NH3DMenuWindow clearTextMessage];
				nh3d_windowlist[wid].win = nil;
				nh3d_windowlist[wid].type = 0;
				break;
		}
	}
}

void nh3d_curs(winid wid, int x, int y)
{
	if (wid != -1 && nh3d_windowlist[wid].type == NHW_MAP && nh3d_windowlist[wid].win != nil) {
		@autoreleasepool {
			/* this function Implementation being completed only to type NHW_MAP   */
			[_NH3DMapModel setPosCursorAtX:x atY:y];
			[_NH3DBindController updateAll];
		}
    }
}

void nh3d_putstr(winid wid, int attr, const char *text)
{
	@autoreleasepool {
		switch (nh3d_windowlist[wid].type) {
			case NHW_MESSAGE:
				play_sound_for_message(text);
				[_NH3DMessenger putMainMessage:attr text:text];
				break;
				
			case NHW_TEXT:
				[_NH3DMenuWindow putTextMessage:
						[NSString stringWithCString:text
											encoding:NH3DTEXTENCODING]];
				break;
				
			case NHW_MENU:
				if (!_NH3DMenuWindow.isMenu) {
					[_NH3DMenuWindow putTextMessage:
					 [NSString stringWithCString:text
										encoding:NH3DTEXTENCODING]];
				}
				break;
				
			case NHW_MAP:
				/* NO PUT MESSAGE FOR MAP */
				break;
				
			case NHW_STATUS:
				[_NH3DUserStatusModel setPlayerStatusLine:
				 [NSString stringWithCString:text encoding:NH3DTEXTENCODING]];
				break;
				
			default:
				NSLog(@"ERROR Window type does not exist. win id is %d, type is %d, message: %@",
					  wid, nh3d_windowlist[wid].type, [NSString stringWithCString:text encoding:
													   NH3DTEXTENCODING]);
				break;
		}
	}
}

void nh3d_display_file(const char *filename, boolean must_exist)
{
	@autoreleasepool {
		NSString *loc = [[NSBundle mainBundle] pathForResource:[NSString stringWithCString:filename encoding:NH3DTEXTENCODING] ofType:nil];
		NSString *contentsOfFile = nil;
		NSError *lerror = nil;
		// try same Japanese encodeing. see 'NSString.h' for more infomation. nethack3d default encoding is '3'(EUC-JP)
		NSStringEncoding fileEncoding[6] = {NSUTF8StringEncoding, NSJapaneseEUCStringEncoding, NSShiftJISStringEncoding, NSUnicodeStringEncoding, NSISO2022JPStringEncoding, NSMacOSRomanStringEncoding};
		int i = 0;
		
		while (contentsOfFile == nil) {
			contentsOfFile = [[NSString alloc] initWithContentsOfFile:loc
															 encoding:fileEncoding[i]
																error:&lerror];
			
			if (contentsOfFile != nil || i == 6) {
				break;
			} else {
				i++ ;
			}
		}
		
		if (contentsOfFile != nil) {
			[_NH3DMenuWindow putTextMessage:contentsOfFile];
			[_NH3DMenuWindow showTextPanel];
		} else {
			if (must_exist) {
				NSLog(@"Failed to Load %s", filename);
				[_NH3DBindController didPresentError:lerror];
			}
		}
	}
}

void nh3d_start_menu(winid wid)
{
	@autoreleasepool {
		if (nh3d_windowlist[wid].win != nil && nh3d_windowlist[wid].type == NHW_MENU) {
			[nh3d_windowlist[wid].win createMenuWindow:wid];
			[nh3d_windowlist[wid].win setIsMenu:YES];
		}
	}
}


void nh3d_add_menu(winid wid, int glyph, const ANY_P *identifier,
		char accelerator, char group_accel, int attr,
		const char *str, boolean presel)
{
	@autoreleasepool {
		if (nh3d_windowlist[wid].win != nil && nh3d_windowlist[wid].type == NHW_MENU) {
			[nh3d_windowlist[wid].win addMenuItem:wid glyph:glyph identifier:identifier accelerator:accelerator groupAccel:group_accel attr:attr str:str presel:presel];
		}
	}
}

void nh3d_end_menu(winid wid, const char *prompt)
{
	@autoreleasepool {
		if (nh3d_windowlist[wid].win != nil && nh3d_windowlist[wid].type == NHW_MENU) {
			[nh3d_windowlist[wid].win updateMenuWindow];
			[nh3d_windowlist[wid].win showMenuPanel:prompt];
		}
	}
}

int nh3d_select_menu(winid wid, int how, menu_item **selected)
{
	int ret = -1;
	@autoreleasepool {
		if (nh3d_windowlist[wid].win != nil && nh3d_windowlist[wid].type == NHW_MENU) {
			if (_NH3DMenuWindow.isMenu) {
				ret = [nh3d_windowlist[wid].win selectMenu:wid how:how selected:selected];
				[nh3d_windowlist[wid].win setIsMenu:NO];
				
			}
		}
	}
	return ret;
}

void nh3d_update_inventory()
{
	/* Do nothing */
}

void nh3d_mark_synch()
{
	/* Do nothing */
}

void nh3d_wait_synch()
{
	/* Do nothing */
}

void nh3d_cliparound(int x, int y)
{
	/* view objects,texts clipping do self.*/
}

void nh3d_cliparound_window(winid wid, int x, int y)
{
	/* view objects,texts clipping do self.*/
}

void nh3d_print_glyph(winid wid, xchar x, xchar y, int glyph, int under)
{
	@autoreleasepool {
		[_NH3DBindController printGlyph:wid xPos:x yPos:y glyph:glyph bkglyph:under];
	}
}

void nh3d_raw_print(const char *str)
{
	@autoreleasepool {
		NSString *aStr = [[NSString alloc] initWithCString:str encoding:NH3DTEXTENCODING];
//#if DEBUG
#if 1
		NSLog(@"%@", aStr);
#endif
		[_NH3DMessenger putLogMessage:aStr bold:NO];
	}
}

void nh3d_raw_print_bold(const char *str)
{
	@autoreleasepool {
		NSString *aStr = [[NSString alloc] initWithCString:str encoding:NH3DTEXTENCODING];
//#if DEBUG
#if 1
		NSLog(@"%@", aStr);
#endif
		[_NH3DMessenger putLogMessage:aStr bold:YES];
	}
}

int nh3d_nhgetch()
{
	return [_NH3DBindController nhGetKey];
}

int nh3d_nh_poskey(int *x, int *y, int *mod)
{
	return [_NH3DBindController nhPosKeyAtX:x atY:y keyMod:mod];
}

void nh3d_nhbell()
{
	@autoreleasepool {
		NSSound *bell = [NSSound soundNamed:@"Sosumi"];
		[bell play];
	}
}

int nh3d_doprev_message()
{
	/*Do Nothing... They can read old messages using the scrollbar. */
	return 0;
}

char nh3d_yn_function(const char *question, const char *choices, char def)
{
	@autoreleasepool {
		char yn;
		char buf[BUFSZ];
		int result;
		BOOL ynfunc;
		
		if (question != nil)
			Strcpy(buf,question);
		if (choices != nil)
			Strcat(buf,choices);
		//Just in case the message window isn't up yet.
		if (WIN_MESSAGE == WIN_ERR) {
			return 'y';
		}
		putstr(WIN_MESSAGE, ATR_BOLD, buf);
		
		if (choices && strcmp(choices, ynchars) == 0) {
			ynfunc = YES;
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = [NSString stringWithCString:question encoding:NH3DTEXTENCODING];
			alert.informativeText = @" ";
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			
			result = [alert runModal];
		} else if (choices && strcmp(choices, ynqchars) == 0) {
			ynfunc = YES;
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = [NSString stringWithCString:question encoding:NH3DTEXTENCODING];
			alert.informativeText = @" ";
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			[alert addButtonWithTitle:@"Quit"];
			
			result = [alert runModal];
		} else if (choices && strcmp(choices, ynaqchars) == 0) {
			ynfunc = YES;
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = [NSString stringWithCString:question encoding:NH3DTEXTENCODING];
			alert.informativeText = @" ";
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			
			{
				NSButton *abutt = [alert addButtonWithTitle:@"Auto"];
				abutt.tag = NSAlertThirdButtonReturn + 1;
				
				abutt = [alert addButtonWithTitle:@"Quit"];
				abutt.tag = NSAlertThirdButtonReturn;
			}
			result = [alert runModal];
		} else if ([[NSString stringWithCString:question encoding:NH3DTEXTENCODING] isLike:
					NSLocalizedString(@"*what direction*", @"")]) {
			// hmm... These letters from cmd.c will not there be a good method?
			int x = u.ux; int y = u.uy; int mod = 0;
			ynfunc = NO;
			result = nh_poskey(&x, &y, &mod);
			
			if (!result) {
				int hdirect,vdirect;
				hdirect = (x > u.ux) ? 1 : 2;
				vdirect = (y < u.uy) ? 3 : 6;
				hdirect = (x == u.ux) ? 0 : hdirect;
				vdirect = (y == u.uy) ? 0 : vdirect;
				
				switch ( hdirect + vdirect ) {
					case 1 : // choice right
						result = (iflags.num_pad) ? '6' : 'l';
						[_NH3DMessenger setLastAttackDirection:0];
						break;
					case 2 : // choice left
						result = (iflags.num_pad) ? '4' : 'h';
						[_NH3DMessenger setLastAttackDirection:0];
						break;
					case 3 : // choice front
						result = (iflags.num_pad) ? '8' : 'k';
						[_NH3DMessenger setLastAttackDirection:2];
						break;
					case 4 : // choice front right
						result = (iflags.num_pad) ? '9' : 'u';
						[_NH3DMessenger setLastAttackDirection:3];
						break;
					case 5 : // choice front left
						result = (iflags.num_pad) ? '7' : 'y';
						[_NH3DMessenger setLastAttackDirection:1];
						break;
					case 6 : // choice back
						result = (iflags.num_pad) ? '2' : 'j';
						[_NH3DMessenger setLastAttackDirection:0];
						break;
					case 7 : // choice back right
						result = (iflags.num_pad) ? '3' : 'n';
						[_NH3DMessenger setLastAttackDirection:0];
						break;
					case 8 : // choice back left
						result = (iflags.num_pad) ? '1' : 'b';
						[_NH3DMessenger setLastAttackDirection:0];
						break;
				}
			}
		} else {
			char *p;
			ynfunc = NO;
			result = nhgetch();
			
			if (choices != nil) {
				buf[0] = result;
				buf[1] = '\0';
				p = strstr(choices, buf);
				if (p == NULL)
					result = 'n';
				
				sprintf(buf, "> [ %c ]", result);
				putstr(WIN_MESSAGE, ATR_ULINE, buf);
			}
		}
		
		if(result == NSAlertFirstButtonReturn && ynfunc) {
			yn = 'y';
		} else if(result == NSAlertSecondButtonReturn && ynfunc) {
			yn = 'n';
		} else if(result == NSAlertThirdButtonReturn && (strcmp(choices, ynqchars) == 0 || strcmp(choices, ynaqchars) == 0)  && ynfunc) {
			yn = 'q';
		} else if (result == NSAlertThirdButtonReturn + 1 && strcmp(choices, ynaqchars) == 0 && ynfunc) {
			yn = 'a';
		} else if (result == NSAlertThirdButtonReturn && ynfunc) {
			yn = 'n';
		} else {
			yn = result;
		}
		
		if (ynfunc) {
			sprintf(buf, "> [ %c ]", yn);
			putstr(WIN_MESSAGE, ATR_ULINE, buf);
		}
		
		return yn;
	}
}

void nh3d_getlin(const char *prompt, char *line)
{
	int ret = 0;
	
	@autoreleasepool {
		ret = [_NH3DMessenger showInputPanel:prompt line:line];
	}
	if (ret == -1)
		line[0] = (char)0;
}

int nh3d_get_ext_cmd()
{
	@autoreleasepool {
		int ret = _NH3DKeyBuffer.extendKey;
		if (ret != -1 ) {
			_NH3DKeyBuffer.extendKey = -1;
			return ret;
		} else {
			menu_item *mi;
			anything ident;
			char buf[100];
			int win = create_nhwindow(NHW_MENU);
			start_menu(win);
			[_NH3DMenuWindow setIsExtendMenu:YES];
			for (ret = 0; extcmdlist[ret].ef_txt != NULL; ++ret) {
				ident.a_char = extcmdlist[ret].ef_txt[0];
				sprintf(buf, "%-10s - %s ",
						extcmdlist[ret].ef_txt,
						extcmdlist[ret].ef_desc);
				add_menu(win, NO_GLYPH, &ident, 0, 0, 0, buf, MENU_UNSELECTED);
			}
			
			end_menu(win, (char*)0);
			ret = select_menu(win, PICK_ONE, &mi);
			destroy_nhwindow(win);
			
			if (ret >= 1) {
				ret = _NH3DMenuWindow.selectedRow;
			} else {
				ret = -1;
			}
			
			_NH3DKeyBuffer.extendKey = -1;
			free(mi);
			return ret;
		}
	}
}

void nh3d_number_pad(int num)
{
	/* Do Nothing */
}

void nh3d_delay_output()
{
	@autoreleasepool {
		[_NH3DMapModel updateAllMaps];
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	}
}

void nh3d_start_screen()
{
	NSLog(@"StartScreen");
	/* Do Nothing */
	return;
}

void nh3d_end_screen()
{
	NSLog(@"EndScreen");
	/* Do Nothing */
	return;
}

void nh3d_outrip(winid wid, int how, time_t when)
{
	@autoreleasepool {
		char buf[BUFSZ];
		NSMutableString *ripString = [[NSMutableString alloc] initWithCapacity:100];
		
		_NH3DMenuWindow.doneRip = YES;
		
		Sprintf(buf, "%s\n", plname);
		[ripString appendString:[NSString stringWithCString:buf encoding:NH3DTEXTENCODING]];
		//Strcat(ripString, buf);
		
		/* Put $ on stone */
		Sprintf(buf, "%ld Gold\n", done_money);
		[ripString appendString:[NSString stringWithCString:buf encoding:NH3DTEXTENCODING]];
		
		/* Put together death description */
		formatkiller(buf, BUFSZ, how);
		
		/* Put death type on stone */
		[ripString appendString:[NSString stringWithCString:buf encoding:NH3DTEXTENCODING]];
		[ripString appendString:@"\n"];
		
		/* Put year on stone */
		long year = yyyymmdd(when) / 10000L;
		Sprintf(buf, "%4ld\n", year);
		[ripString appendString:[NSString stringWithCString:buf encoding:NH3DTEXTENCODING]];
		
		[_NH3DMapModel stopIndicator];
		[_NH3DMessenger showOutRipString:[ripString copy]];
	}
}

/*
int nh3d_kbhit()
{
	NSLog(@"kbhit");
	return 0;
}
*/

void nethack3d_exit(int status)
{
	[NSApp terminate:nil];
}

#ifndef GNUSTEP
//  UTF8 file Handring
void nh3d_set_savefile_name()
{
	@autoreleasepool {
		NSString *saveString;
		saveString = [NSString stringWithFormat:@"%d%@", (int)getuid(), [NSString stringWithCString:plname encoding:NH3DTEXTENCODING]];
		Strcpy(SAVEF, saveString.fileSystemRepresentation);
	}
}
#endif

static char * nh3d_getmsghistory(boolean init);
static void nh3d_putmsghistory(const char*msg, boolean is_restoring);
static void nh3d_preference_update(const char *pref);

struct window_procs nh3d_procs = {
    "nh3d",
	WC_COLOR|
	WC_HILITE_PET|
	WC_INVERSE|
	WC_ASCII_MAP|
	WC_POPUP_DIALOG|
	WC_MOUSE_SUPPORT|
	WC_PLAYER_SELECTION|
	WC_FONT_TEXT|
	WC_TILED_MAP,
    0L,
	nh3d_init_nhwindows,
	nh3d_player_selection,
	nh3d_askname,
	nh3d_get_nh_event,
	nh3d_exit_nhwindows,
	nh3d_suspend_nhwindows,
	nh3d_resume_nhwindows,
	nh3d_create_nhwindow,
	nh3d_clear_nhwindow,
	nh3d_display_nhwindow,
	nh3d_destroy_nhwindow,
	nh3d_curs,
	nh3d_putstr,
	genl_putmixed,
	nh3d_display_file,
	nh3d_start_menu,
	nh3d_add_menu,
	nh3d_end_menu,
	nh3d_select_menu,
    genl_message_menu,      /* no need for X-specific handling */
	nh3d_update_inventory,
	nh3d_mark_synch,
	nh3d_wait_synch,
#ifdef CLIPPING
	nh3d_cliparound,
#endif
#ifdef POSITIONBAR
    donull,
#endif
	nh3d_print_glyph,
    // nh3d_print_glyph_compose,
	nh3d_raw_print,
	nh3d_raw_print_bold,
	nh3d_nhgetch,
	nh3d_nh_poskey,
	nh3d_nhbell,
	nh3d_doprev_message,
	nh3d_yn_function,
	nh3d_getlin,
	nh3d_get_ext_cmd,
	nh3d_number_pad,
	nh3d_delay_output,
#ifdef CHANGE_COLOR     /* only a Mac option currently */
    donull,
    donull,
#endif
    /* other defs that really should go away (they're tty specific) */
	nh3d_start_screen,
	nh3d_end_screen,
#ifdef GRAPHIC_TOMBSTONE
	nh3d_outrip,
#else
    genl_outrip,
#endif
    nh3d_preference_update,
	genl_getmsghistory,
	genl_putmsghistory,
#ifdef STATUS_VIA_WINDOWPORT
	hup_void_ndecl,                                   /* status_init */
	hup_void_ndecl,                                   /* status_finish */
	genl_status_enablefield, hup_status_update,
#ifdef STATUS_HILITES
	genl_status_threshold,
#endif
#endif /* STATUS_VIA_WINDOWPORT */
	genl_can_suspend_no,
};

char * nh3d_getmsghistory(boolean init)
{
	return genl_getmsghistory(init);
}

void nh3d_putmsghistory(const char*msg, boolean is_restoring)
{
	genl_putmsghistory(msg, is_restoring);
}

void nh3d_preference_update(const char *pref)
{
	genl_preference_update(pref);
}

static void
wd_message()
{
#ifdef WIZARD
	if (wiz_error_flag) {
		
		pline("Only user \"%s\" may access debug (wizard) mode.",
			  /*
			   pline("「%s」のみがデバッグ(wizard)モードを使用できる．",
			   */
# ifndef KR1ED
			  WIZARD);
# else
		WIZARD_NAME);
# endif
		
		pline("Entering discovery mode instead.");
		/*
		 pline("かわりに発見モードへ移行する．");
		 */
	} else
#endif
		if (discover)
			
			You("are in non-scoring discovery mode.");
	/*
	 You("スコアの載らない発見モードで起動した．");
	 */
}

//--------------------------------------------------------------//
#pragma mark -- NH3D Window port --
//--------------------------------------------------------------//

@implementation NH3DBindController {
	NH3DPreferenceController *_prefPanel;
	NH3DTileCache			*_tileCache;
}

// for UserDefaults
// set user defaults
+ (void) initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSDictionary *defaultValues;
		
		defaultValues = @{
						  NH3DUseTraditionalMapKey: @NO,
						  NH3DTraditionalMapModeKey: @NO,
						  
						  NH3DTileNameKey: @"nhtiles",
						  NH3DTileSizeWidthKey: @16,
						  NH3DTileSizeHeightKey: @16,
						  NH3DTilesPerLineKey: @40,
						  NH3DNumberOfTilesRowKey: @37,
						  
						  NH3DUseTileInLevelMapKey: @YES,
						  NH3DUseSightRestrictionKey: @YES,
						  
						  NH3DOpenGLWaitSyncKey: @YES,
						  NH3DOpenGLUseWaitRateKey: @YES,
						  NH3DOpenGLNumberOfThreadsKey: @1,
						  
						  NH3DOpenGLWaitRateKey: @(WAIT_NORMAL),
						  
						  NH3DMsgFontKey: @"Hiragino Maru Gothic Pro",
						  NH3DMapFontKey: @"Courier New",
						  NH3DBoldFontKey: @"Lucida Grande Bold",
						  NH3DInventryFontKey: @"Menlo",
						  NH3DWindowFontKey: @"Optima",
						  
						  NH3DGLTileKey: @NO,
						  
						  NH3DMsgFontSizeKey: @13.0f,
						  NH3DMapFontSizeKey: @13.0f,
						  NH3DBoldFontSizeKey: @13.0f,
						  NH3DInventryFontSizeKey: @13.0f,
						  NH3DWindowFontSizeKey: @13.0f,
						  
						  NH3DSoundMuteKey: @NO,
						  
						  NHUseNumPad: @NO,
						  NHMaxMessages: @30,
						  NH3DUseRetinaOpenGL: @YES,
						  };
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
		
		[NSUserDefaultsController sharedUserDefaultsController].initialValues = defaultValues;
	});
}

- (instancetype)init
{
	if (self = [super init]) {
		_prefPanel = nil;
	}
	return self;
}

- (void)awakeFromNib
{		
	_window.alphaValue = 0;
	[_window setMovableByWindowBackground:NO];
}

//-------------------------------------------------------------
// App delgates
//-------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	@autoreleasepool {
		_tileCache = [[NH3DTileCache alloc] initWithNamed:TILE_FILE_NAME];
		
		_NH3DBindController = self;
		_NH3DUserStatusModel = _userStatus;
		_NH3DMapModel = _mapModel;
		_NH3DMessenger = _messenger;
		_NH3DMenuWindow = _menuWindow;
		_NH3DKeyBuffer = _asciiMapView;
		_NH3DOpenGLView = _glMapView;
		_NH3DTileCache = _tileCache;
	}
}

- (BOOL)windowShouldClose:(id)sender
{
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = NSLocalizedString(@"Quit NetHack3D",@"");
	alert.informativeText = NSLocalizedString(@"Do you really want to Force Quit?", @"");
	[alert addButtonWithTitle:@"Cancel"];
	[alert addButtonWithTitle:@"Quit"];
	NSInteger choise = [alert runModal];
	if (choise == NSAlertSecondButtonReturn) {
		[NSApp terminate:self];
		return YES;
	} else {
		return NO;
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	NSApplicationTerminateReply ret;
	
	if (!iflags.window_inited)
		return NSTerminateNow;
	
	if (_stDrawer.state != NSDrawerClosedState) {
		[_stDrawer close:self];
	} 
	
	raw_print([NSLocalizedString(@"NetHack3D say,'See you again.'", @"") cStringUsingEncoding:NH3DTEXTENCODING]);
	ret = [_messenger showLogPanel];
	
	if (ret == NSTerminateNow) {
		clearlocks();
	}
	
	if (ret != NSTerminateCancel) {
		[_glMapView setRunning:NO];
	}
	
	return ret;
}

//-------------------------------------------------------------
//  over App delgates. 
//-------------------------------------------------------------

- (void)setTile
{
	_tileCache = [[NH3DTileCache alloc] initWithNamed:TILE_FILE_NAME];
	_NH3DTileCache = _tileCache;
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:NH3DTraditionalMapModeKey];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DTraditionalMapModeKey];
}

// show user make panel.
- (void)showUserMakeSheet
{
	NH3DUserMakeSheetController *userMakeSheet = nil;
	
	if ([[_userStatus playerName].string isEqualToString:@""]) {
	
		//NSString *pName = [ [ NSString alloc ] initWithCString:plname encoding:NH3DTEXTENCODING ];
		[_userStatus setPlayerName:[NSString stringWithCString:plname encoding:NH3DTEXTENCODING]];
	}
	
	// Display sheet dialog
	
	if (!userMakeSheet) {
		userMakeSheet = [[NH3DUserMakeSheetController alloc] init];
	}
		
	[userMakeSheet startSheet:_userStatus];
}

- (void)showMainWindow
{
	// window fade in
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
		context.duration = 1.0;
		_window.animator.alphaValue = 1;
	} completionHandler:^{
		
	}];
}

- (NSWindow*)mainWindow
{
	return _window;
}

- (void)didPresentError:(NSError *)error
{
	//NSInteger result;
	NSAlert *alert = [NSAlert alertWithError:error];
	NSLog(@"%@", error);
	/*result = */[alert runModal];
}

- (void)printGlyph:(winid)wid xPos:(xchar)x yPos:(xchar)y glyph:(int)glyph bkglyph:(int)bkglyph
{
	switch (nh3d_windowlist[wid].type) {
	case NHW_MAP:
		[_mapModel setMapModelGlyph:glyph xPos:x yPos:y bgGlyph:bkglyph];
		break;
	default:
		break;
	}
}	

- (int)nhPosKeyAtX:(int *)x atY:(int *)y keyMod:(int *)mod
{
	int ret = 0;
	NSUInteger mask = (NSAnyEventMask);

	//Wait next Event
	[_asciiMapView nh3dEventHandlerLoopWithMask:mask];
	
	ret = _asciiMapView.keyBuffer;

	if (ret == 0) {
		*x = _mapModel.cursX;
		*y = _mapModel.cursY;
		*mod = _asciiMapView.clickType;
	}
	[_asciiMapView setKeyUpdated:NO];

	return ret;
}

- (int)nhGetKey
{
	int ret;
	NSEventMask mask = (NSLeftMouseDownMask	|
						NSKeyDownMask		|
						NSApplicationDefinedMask);
	
	[_asciiMapView setGetCharMode:YES];
	//Wait next Event
	[_asciiMapView nh3dEventHandlerLoopWithMask:mask];

	ret = _asciiMapView.keyBuffer;
	[_asciiMapView setKeyUpdated:NO];
	[_asciiMapView setGetCharMode:NO];
	return ret;
}

- (void)updateAll
{
	char buf[BUFSZ] = " ";
	_asciiMapView.needClear = YES;
	[_asciiMapView updateMap];
	[_glMapView updateMap];
	[_userStatus updatePlayerInventory];
	[_userStatus updatePlayer];
	
	Sprintf(buf, "%s, level %d", dungeons[u.uz.dnum].dname, depth(&u.uz));
	/*
	 Sprintf(buf, "%s  地下%d階", jtrns_obj('d',dungeons[ u.uz.dnum ].dname), depth(&u.uz));
	 */
	[_mapModel setDungeonName:[NSString stringWithCString:buf encoding:NH3DTEXTENCODING]];
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (_prefPanel == nil)
		_prefPanel = [[NH3DPreferenceController alloc] init];
	
	[_prefPanel showPreferencePanel:self];
}

- (void)endPreferencePanel
{
	_prefPanel = nil;
}

/// Loads Nethack-specific preferences
- (void)loadNethackOptions
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	iflags.num_pad = [defaults boolForKey:NHUseNumPad];
	if (iflags.num_pad) {
		iflags.num_pad_mode = 1;
		reset_commands(FALSE);
	}
	iflags.msg_history = [defaults integerForKey:NHMaxMessages];
}

// ---------------------------------------------------------------------------- //
// START NETHACK 3D
// ---------------------------------------------------------------------------- //

static char ynPreReady(const char *str)
{
	NSAlert *eraseSaveAlert = [[NSAlert alloc] init];
	eraseSaveAlert.messageText = NSLocalizedString(@"Old Save File", @"");
	eraseSaveAlert.informativeText = NSLocalizedString(@(str), @"");
	
	[eraseSaveAlert addButtonWithTitle:@"No"];
	[eraseSaveAlert addButtonWithTitle:@"Yes"];
	
	NSInteger result = [eraseSaveAlert runModal];
	
	if (result == NSAlertSecondButtonReturn) {
		return 'y';
	}
	
	return 'n';
}

- (IBAction)startNetHack3D:(id)sender
{
	bool isResuming = true;
	int fd;
	int argc = NXArgc;
	char **argv = NXArgv;
	char buf[ BUFSZ ];
#ifndef GNUSTEP
#ifdef CHDIR
	const char *dir;
#endif
#endif
	[[sender window] close];
	[_window makeKeyAndOrderFront:self];
	
#ifndef GNUSTEP
	
#ifdef XI18N
	setlocale(LC_ALL, "");
#endif
	
	hname = argv[ 0 ];
	hackpid = getpid();
	(void) umask(0777 & ~FCMASK);
	
	choose_windows(DEFAULT_WINDOW_SYS);
	
#ifdef CHDIR
	/* get resourcePath */
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *aURL = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL];
	aURL = [aURL URLByAppendingPathComponent:@"NetHack3D" isDirectory:YES];
	if (![aURL checkResourceIsReachableAndReturnError:NULL]) {
		[fm createDirectoryAtURL:aURL withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions:@(S_IRWXU)} error:NULL];
	}
	@autoreleasepool {
		//Make sure the rest of the directory structure is okay
		NSURL *permURL = [aURL URLByAppendingPathComponent:@"perm"];
		NSURL *logURL = [aURL URLByAppendingPathComponent:@"logfile"];
		NSURL *xlogURL = [aURL URLByAppendingPathComponent:@"xlogfile"];
		NSData *blankData = [[NSData alloc] init];
		if (![permURL checkResourceIsReachableAndReturnError:NULL]) {
			//touch perm
			[blankData writeToURL:permURL atomically:NO];
		}
		if (![logURL checkResourceIsReachableAndReturnError:NULL]) {
			//touch logfile
			[blankData writeToURL:logURL atomically:NO];
		}
		if (![xlogURL checkResourceIsReachableAndReturnError:NULL]) {
			//touch xlogfile
			[blankData writeToURL:xlogURL atomically:NO];
		}
		
		NSString *syscf = @(SYSCF_FILE);
		NSURL *localSyscf = [aURL URLByAppendingPathComponent:syscf isDirectory:NO];
		if (![localSyscf checkResourceIsReachableAndReturnError:NULL]) {
			[fm copyItemAtURL:[[NSBundle mainBundle] URLForResource:syscf withExtension:nil] toURL:localSyscf error:NULL];
		}
	}
	dir = aURL.fileSystemRepresentation;
#endif
	
	if(argc > 1) {
#ifdef CHDIR
		if (!strncmp(argv[ 1 ], "-d", 2) && argv[ 1 ][ 2 ] != 'e') {
			/* avoid matching "-dec" for DECgraphics; since the man page
			 * says -d directory, hope nobody's using -desomething_else
			 */
			argc--;
			argv++;
			dir = argv[ 0 ]+2;
			if(*dir == '=' || *dir == ':') dir++;
			if(!*dir && argc > 1) {
				argc--;
				argv++;
				dir = argv[ 0 ];
			}
			if(!*dir)
				error("Flag -d must be followed by a directory name.");
		}
		if (argc > 1)
#endif /* CHDIR */
			
		/*
		 * Now we know the directory containing 'record' and
		 * may do a prscore().  Exclude `-style' - it's a Qt option.
		 */
			if (!strncmp(argv[1], "-s", 2) && strncmp(argv[1], "-style", 6)) {
#ifdef CHDIR
				chdirx(dir,0);
#endif
				/*
				 setkcode('I');
				 initoptions();
				 init_jtrns();
				 prscore(argc, argv);
				 jputchar('\0');*/ /* reset */
				
				prscore(argc, argv);
				
				exit(EXIT_SUCCESS);
			}
	}
	
	
	/*
	 * Change directories before we initialize the window system so
	 * we can find the tile file.
	 */
#ifdef CHDIR
	chdirx(dir,1);
#endif
	
	
	/* Line like "OPTIONS=name:foo-@" may exist in config file.
	 * In this case, need to select random class,
	 * so must call setrandom() before initoptions().
	 */
	//	setrandom();
	
	iflags.hilite_pile = true;
	initoptions();
	init_nhwindows(&argc,argv);
	[_NH3DBindController loadNethackOptions];
	
#endif // GNUSTEP
	/*
	 * It seems you really want to play.
	 */
	u.uhp = 1;	/* prevent RIP on early quits */
	(void) signal(SIGHUP, (SIG_RET_TYPE) hangup);
#ifdef SIGXCPU
	(void) signal(SIGXCPU, (SIG_RET_TYPE) hangup);
#endif
	
	process_options(argc, argv);
	
	// Always get the background glyph
	iflags.use_background_glyph = TRUE;
	
	[self showMainWindow];
	
#ifdef WIZARD
	if (wizard)
		Strcpy(plname, "wizard");
	else
#endif
		
		if(!*plname || !strncmp(plname, "player", 4)
		   || !strncmp(plname, "games", 4)) {
			askname();
		}
	
	plnamesuffix();		/* strip suffix from name; calls askname() */
	/* again if suffix was whole name */
	/* accepts any suffix */
	/*
	 * check for multiple games under the same name
	 * (if !locknum) or check max nr of players (otherwise)
	 */
	(void) signal(SIGQUIT,SIG_IGN);
	(void) signal(SIGINT,SIG_IGN);
	if(!locknum) {
#ifndef GNUSTEP
		//for OSX (UTF8) File System
		NSString *lockString;
		lockString = [NSString stringWithFormat:@"%d%@",(int)getuid(), [NSString stringWithCString:plname encoding:NH3DTEXTENCODING]];
		Strcpy(lock, lockString.fileSystemRepresentation);
#else
		Sprintf(lock, "%d%s", (int)getuid(), plname);
#endif
	}
	getlock();
	
	dlb_init();	/* must be before newgame() */
	
	/*
	 * Initialization of the boundaries of the mazes
	 * Both boundaries have to be even.
	 */
	x_maze_max = COLNO-1;
	if (x_maze_max % 2)
		x_maze_max--;
	y_maze_max = ROWNO-1;
	if (y_maze_max % 2)
		y_maze_max--;
	
	/*
	 *  Initialize the vision system.  This must be before mklev() on a
	 *  new game or before a level restore on a saved game.
	 */
	vision_init();
	
	//switch_graphics(ASCII_GRAPHICS);
	display_gamewindows();
	
	
#ifdef TEXTCOLOR
	iflags.use_color = TRUE;
#endif
	
	if ((fd = restore_saved_game()) >= 0) {
		isResuming = false;
		const char *fq_save = fqname(SAVEF, SAVEPREFIX, 1);
		
		(void) chmod(fq_save,0);	/* disallow parallel restores */
		(void) signal(SIGINT, (SIG_RET_TYPE) done1);
		
#ifdef NEWS
		if(iflags.news) {
			display_file(NEWS, FALSE);
			iflags.news = FALSE; /* in case dorecover() fails */
		}
#endif
		
		pline("Restoring save file...");
		
		/*
		 pline("セーブファイルを復元中．．．");
		 */
		mark_synch();	/* flush output */
		if(!dorecover(fd))
			goto not_recovered;
		
		check_special_room(FALSE);
		wd_message();
		
		if (discover || wizard) {
			if(ynPreReady("Do you want to keep the save file?") == 'n')
				(void) delete_savefile();
			else {
				(void) chmod(fq_save, FCMASK); /* back to readable */
				//compress(fq_save);
			}
		}
		//flags.move = 0;
		[_userStatus setPlayerName:[NSString stringWithCString:plname encoding:NH3DTEXTENCODING]];
	} else {
	not_recovered:
		
		player_selection();
		
		newgame();
		wd_message();
		//flags.move = 0;
		set_wear(NULL);
		(void) pickup(1);
	}
	
	[_userStatus updatePlayer];
	
	Sprintf(buf, "%s, level %d", dungeons[u.uz.dnum].dname, depth(&u.uz));
	/*
	 Sprintf(buf, "%s  地下%d階", jtrns_obj('d',dungeons[ u.uz.dnum ].dname), depth(&u.uz));
	 */
	
	[_mapModel setDungeonName:[NSString stringWithCString:buf encoding:NH3DTEXTENCODING]];
	[_mapModel updateAllMaps];
	CocoaPortIsReady = YES;
	
	moveloop(isResuming);
}

@end

FILE *cocoa_dlb_fopen(const char *filename, const char *mode)
{
	FILE *file = NULL;
	static NSURL *resDir;
	@autoreleasepool {
		if (!resDir) {
			resDir = [[NSBundle mainBundle] resourceURL];
		}
		NSString *aFile = @(filename);
		NSURL *toRet = [resDir URLByAppendingPathComponent:aFile];
		file = fopen(toRet.fileSystemRepresentation, mode);
	}
	return file;
}


#ifdef USER_SOUNDS

void
play_usersound(const char *filename, int volume)
{
	NSURL *url = [NSURL fileURLWithFileSystemRepresentation:filename isDirectory:NO relativeToURL:nil];
	
	[_NH3DMessenger playSoundAtURL:url volume:volume];
}

#endif

boolean add_effect_mapping(const char *mesgTxt)
{
	char text[256];
	int type;
	
	if (sscanf(mesgTxt, "MESG \"%255[^\"]\" %d", text,
			    &type) == 2) {
		
		return [_NH3DMessenger addEffectMessage:@(text) effectType:type];
	} else {
		return false;
	}
}
