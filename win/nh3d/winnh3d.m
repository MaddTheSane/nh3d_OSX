//
//  winnh3d.m
//  NetHack3D Application Controller
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//
#import "winnh3d.h"

#import <sys/stat.h>
#import <signal.h>
#import <pwd.h>
#ifndef O_RDONLY
#import <sys/fcntl.h>
#endif
#ifdef XI18N
#include <X11/Xlocale.h>
#endif

#if !defined(_BULL_SOURCE) && !defined(__sgi) && !defined(_M_UNIX)
# if !defined(SUNOS4) && !(defined(ULTRIX) && defined(__GNUC__))
#  if defined(POSIX_TYPES) || defined(SVR4) || defined(HPUX)
extern struct passwd *FDECL(getpwuid,(uid_t));
#  else
extern struct passwd *FDECL(getpwuid,(int));
#  endif
# endif
#endif
extern struct passwd *FDECL(getpwnam,(const char *));
#ifdef CHDIR
static void FDECL(chdirx, (const char *,BOOLEAN_P));
#endif /* CHDIR */
static boolean NDECL(whoami);
static void FDECL(process_options, (int, char **));


#ifdef WIZARD
 static boolean wiz_error_flag = FALSE;
#endif


NH3DWinData nh3d_windowlist[ 10 ];

extern int NXArgc;
extern char **NXArgv;

//bind NetHack C routines to NH3DObjects.
//set object's instance pointer to work.
static id _NH3DBindController;
static id _NH3DUserStatusModel;
static id _NH3DMapModel;
static id _NH3DMessenger;
static id _NH3DMenuWindow;
static id _NH3DKeyBuffer;
static id _NH3DOpenGLView;

id _NH3DTileCache;

static void NDECL(wd_message);

// set Localized String's Text encoding(used only for hard corded strings in 'C' source files)
// localized 'Cocoa' Strings use '<your locale>.iproj/Localizable.strings'file. that format is "baseStr"="LocalStr";.  
const int NH3DTEXTENCODING = NSJapaneseEUCStringEncoding; 


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

NSString *NH3DTileNameKey = @"TileName";
NSString *NH3DTileSizeWidthKey = @"TileSizeWidth";
NSString *NH3DTileSizeHeightKey = @"TileSizeHeight";
NSString *NH3DTilesPerLineKey = @"TilesPerLine";
NSString *NH3DNumberOfTilesRowKey = @"NumberOfTilesRow";

NSString *NH3DSoundMuteKey = @"SoundMute";

static void
process_options(argc, argv)
int argc;
char *argv[ ];
{
	int i;
	/*
	 * Process options.
	 */
	while(argc > 1 && argv[ 1 ][ 0 ] == '-'){
		argv++;
		argc--;
		switch(argv[ 0 ][ 1 ]){
			case 'D':
#ifdef WIZARD
			{
				char *user;
				int uid;
				struct passwd *pw = (struct passwd *)0;
				
				uid = getuid();
				user = getlogin();
				if (user) {
					pw = getpwnam(user);
					if (pw && (pw->pw_uid != uid)) pw = 0;
				}
				if (pw == 0) {
					user = nh_getenv("USER");
					if (user) {
						pw = getpwnam(user);
						if (pw && (pw->pw_uid != uid)) pw = 0;
					}
					if (pw == 0) {
						pw = getpwuid(uid);
					}
				}
				if (pw && !strcmp(pw->pw_name,WIZARD)) {
					wizard = TRUE;
					break;
				}
			}
				/* otherwise fall thru to discover */
				wiz_error_flag = TRUE;
#endif
			case 'X':
				discover = TRUE;
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
				if (!strncmpi(argv[ 0 ]+1, "IBM", 3))
					switch_graphics(IBM_GRAPHICS);
				break;
				/*  case 'D': */
			case 'd':
				if (!strncmpi(argv[ 0 ]+1, "DEC", 3))
					switch_graphics(DEC_GRAPHICS);
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
chdirx(dir, wr)
const char *dir;
boolean wr;
{
	if (dir) {
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
		
	    fqn_prefix[ SCOREPREFIX ] = (char *)alloc(len+2);
	    Strcpy(fqn_prefix[ SCOREPREFIX ], VAR_PLAYGROUND);
	    if (fqn_prefix[ SCOREPREFIX ][ len-1 ] != '/') {
			fqn_prefix[ SCOREPREFIX ][ len ] = '/';
			fqn_prefix[ SCOREPREFIX ][ len+1 ] = '\0';
	    }
# endif
	}
	
	if (dir && chdir(dir) < 0) {
		perror(dir);
		error("Cannot chdir to %s.", dir);
	}
	
	/* warn the player if we can't write the record file */
	/* perhaps we should also test whether . is writable */
	/* unfortunately the access system-call is worthless */
	if (wr) {
# ifdef VAR_PLAYGROUND
		fqn_prefix[ LEVELPREFIX ] = fqn_prefix[ SCOREPREFIX ];
		fqn_prefix[ SAVEPREFIX ] = fqn_prefix[ SCOREPREFIX ];
		fqn_prefix[ BONESPREFIX ] = fqn_prefix[ SCOREPREFIX ];
		fqn_prefix[ LOCKPREFIX ] = fqn_prefix[ SCOREPREFIX ];
		fqn_prefix[ TROUBLEPREFIX ] = fqn_prefix[ SCOREPREFIX ];
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
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	[ _NH3DBindController showUserMakeSheet ];
	[ pool release ];
}


void nh3d_askname()
{		
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	nh3d_getlin( [ NSLocalizedString(@"Who are you?",@"") cStringUsingEncoding:NH3DTEXTENCODING ],plname );
	
	if ( [ [ NSString stringWithCString:plname encoding:NH3DTEXTENCODING ] cStringLength ] >= PL_NSIZ-11 ) {
		plname[ 0 ] = 0;
		
		NSRunAlertPanel(NSLocalizedString(@"A name is too long, and it is difficult to learn.",@""),
						NSLocalizedString(@"Please input it within 1 to 20 characters.",@""),
						@"OK",nil,nil);
		
	} else {
		NSString *pcName = [ [ NSString alloc ] initWithCString:plname encoding:NH3DTEXTENCODING ];
		[ _NH3DUserStatusModel setPlayerName:pcName ];
		[ pcName release ];
	}
	
	[ pool release ];
}


void nh3d_get_nh_event()
{
	
	static NSAutoreleasePool* NH3DfirstPool;
	
	NSSound *soundEffect = nil;
	
	
	if ( NH3DfirstPool != nil ) {
		[ NH3DfirstPool release ];
		NH3DfirstPool = [ [ NSAutoreleasePool alloc ] init ];
	} else {
		NH3DfirstPool = [ [ NSAutoreleasePool alloc ] init ];
	}
	
	if ( SOUND_MUTE ) return;
	
		int se = random() %150;
	
		switch (se) {
			case 1:  soundEffect = [ NSSound soundNamed:@"waterDrop.wav" ];
					 [ soundEffect play ];
				break;
			case 8:  soundEffect = [ NSSound soundNamed:@"hearnoise.wav" ];
					 [ soundEffect play ];
				break;
			case 13: soundEffect = [ NSSound soundNamed:@"waterDrop5.wav" ];
					[ soundEffect play ];
				break;
			case 18:  soundEffect = [ NSSound soundNamed:@"hearnoise.wav" ];
					 [ soundEffect play ];
				break;
			case 25:  soundEffect = [ NSSound soundNamed:@"waterDrop2.wav" ];
					 [ soundEffect play ];
				break;
			case 32: soundEffect = [ NSSound soundNamed:@"waterDrop4.wav" ];
					[ soundEffect play ];
				break;
			case 48:  soundEffect = [ NSSound soundNamed:@"hearnoise.wav" ];
					 [ soundEffect play ];
				break;
			case 57:  soundEffect = [ NSSound soundNamed:@"waterDrop4.wav" ];
					 [ soundEffect play ];
				break;
			case 80: soundEffect = [ NSSound soundNamed:@"waterDrop3.wav" ];
					[ soundEffect play ];
				break;	
			default:
				soundEffect = nil;
			break;
		}
		
	
}


void nh3d_exit_nhwindows(const char *str)
{
	[ _NH3DOpenGLView setRunnning:NO ];
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
	int i;
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	for ( i=1 ; i<10 ; i++ )
		if ( nh3d_windowlist[ i ].win == nil )
			break;
	if ( i > 10 )
		NSLog(@"ERROR:  No windows available...\n");
	nh3d_create_nhwindow_by_id( type, i);
	
	[ pool release ];
	
	return i;
	
}

void nh3d_create_nhwindow_by_id( int type, winid i)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	switch ( type )
	{
		case NHW_MAP:
		{
			nh3d_windowlist[ i ].win = _NH3DMapModel;
			nh3d_windowlist[ i ].type = NHW_MAP;
			break;
		}
		case NHW_MESSAGE:
		{
			nh3d_windowlist[ i ].win = _NH3DMessenger;
			nh3d_windowlist[ i ].type = NHW_MESSAGE;
			break; 
		}
		case NHW_STATUS:
		{
			nh3d_windowlist[ i ].win = _NH3DUserStatusModel;
			nh3d_windowlist[ i ].type = NHW_STATUS;
			break;
		}    
		case NHW_MENU:
		{
			nh3d_windowlist[ i ].win = _NH3DMenuWindow;
			nh3d_windowlist[ i ].type = NHW_MENU;
			break;
		} 
		case NHW_TEXT:
		{
			nh3d_windowlist[ i ].win = _NH3DMenuWindow;
			nh3d_windowlist[ i ].type = NHW_TEXT;
			break;
		}
	}
	[ pool release ];
}


void nh3d_clear_nhwindow(winid wid)
{
	
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	switch ( nh3d_windowlist[ wid ].type ) {
      case NHW_MAP:
		[ _NH3DMapModel clearMapModel ];
		break;
      case NHW_MESSAGE:
	//	[ _NH3DMessenger clearMainMessarge ];
	  break; 
      case NHW_STATUS:
	  break;   
      case NHW_MENU:
		if ([ _NH3DMenuWindow isMenu ]) {
			[ _NH3DMenuWindow clearMenuWindow ];
		} else {
			[ _NH3DMenuWindow clearTextMessarge ];
		}
	  break;
      case NHW_TEXT:
		[ _NH3DMenuWindow clearTextMessarge ];
	  break;
      }
	
	[ pool release ];
}

void nh3d_display_nhwindow(winid wid, BOOLEAN_P block)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	switch ( nh3d_windowlist[ wid ].type )
	{
		case NHW_MENU:
		{
			if ( [ _NH3DMenuWindow isMenu ] ) {	
				[ _NH3DMenuWindow showMenuPanel:"" ];
			} else {
				[ _NH3DMenuWindow showTextPanel ];
			}
			break;
		} 
		case NHW_TEXT:
		{
			[ _NH3DMenuWindow showTextPanel ];
			break;
		}
	}
	
	[ pool release ];
}


void nh3d_destroy_nhwindow(winid wid)
{	
	
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	switch ( nh3d_windowlist[ wid ].type )
	{
		case NHW_MAP:
		case NHW_MESSAGE:
		case NHW_STATUS:
		{
			/* No thanks */
			return;
			break;
		}
		case NHW_MENU:
		{
			
			[ _NH3DMenuWindow clearMenuWindow ];
			[ _NH3DMenuWindow setIsMenu:NO ];
			[ _NH3DMenuWindow clearTextMessarge ];
	
			nh3d_windowlist[ wid ].win = nil;
			nh3d_windowlist[ wid ].type = 0;
			break;
		} 
		case NHW_TEXT:
		{
			[ _NH3DMenuWindow clearTextMessarge ];
			nh3d_windowlist[ wid ].win = nil;
			nh3d_windowlist[ wid ].type = 0;
			break;
		}
	}
	
	[ pool release ];
	
}

void nh3d_curs(winid wid, int x, int y)
{
	if ( wid != -1 && nh3d_windowlist[ wid ].type == NHW_MAP && nh3d_windowlist[ wid ].win != nil )
    {
		NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
		/* this function Implementation being completed only to type NHW_MAP   */
		[ _NH3DMapModel setPosCursorAtX:x atY:y ];
		[ _NH3DBindController updateAll ];
		[ pool release ];
    }
	
}

void nh3d_putstr(winid wid, int attr, const char *text)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	switch ( nh3d_windowlist[ wid ].type )
	{
		case NHW_MESSAGE:
			[ _NH3DMessenger putMainMessarge:attr:text ];
			break;
		case NHW_TEXT:
			[ _NH3DMenuWindow putTextMessarge:
					[ NSString stringWithCString:text
										encoding:NH3DTEXTENCODING ] ];
			break;
		case NHW_MENU:
			if ( ![ _NH3DMenuWindow isMenu ] ) {
				[ _NH3DMenuWindow putTextMessarge:
						[ NSString stringWithCString:text
											encoding:NH3DTEXTENCODING ] ];
			} 
			break;
		case NHW_MAP:
			/* NO PUT MESSARGE FOR MAP */
			break;
		case NHW_STATUS:
			[ _NH3DUserStatusModel setPlayerStatusLine:
				[ NSString stringWithCString:text encoding:NH3DTEXTENCODING ] ];
			break;
		default:
			NSLog (@"ERROR Window type does not exist. win id is %d :type is %d:messarge %@"
				   ,wid,nh3d_windowlist[ wid ].type,[ NSString stringWithCString:text encoding:NH3DTEXTENCODING ]);
			break;

	}
	
	[ pool release ];
}


void nh3d_display_file(const char *filename, BOOLEAN_P must_exist)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	NSString *contentsOfFile = nil;
	NSError *lerror = nil;
	// try same Japanese encodeing. see 'NSString.h' for more infomation. nethack3d default encoding is '3'(EUC-JP)
	unsigned int fileEncoding[ 6 ] = {3,4,8,10,21,30};
	int i = 0;
	
	while ( contentsOfFile == nil  ) {
		contentsOfFile = [ NSString stringWithContentsOfFile:
			[ NSString stringWithCString:filename encoding:NH3DTEXTENCODING ]
												   encoding:fileEncoding[ i ]
													  error:&lerror ];
		
		if (contentsOfFile != nil || i == 6) {
			break;
		} else {
			i++ ;
		}
	}
	
	if (contentsOfFile != nil) {
		[ _NH3DMenuWindow putTextMessarge:contentsOfFile ];
		[ _NH3DMenuWindow showTextPanel ];
	} else {
		if ( must_exist ) {
			NSLog(@"Failed to Load %s",filename);
			[ _NH3DBindController didPresentError:lerror ];
		}
	}
	
	[ pool release ];
}


void nh3d_start_menu(winid wid)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	if ( nh3d_windowlist[ wid ].win != nil && nh3d_windowlist[ wid ].type == NHW_MENU ) {		
		[ nh3d_windowlist[ wid ].win createMenuWindow:wid ];
		[ nh3d_windowlist[ wid ].win setIsMenu:YES ];
	}
	
	[ pool release ];
}


void nh3d_add_menu(winid wid, int glyph, const ANY_P *identifier,
		CHAR_P accelerator, CHAR_P group_accel, int attr, 
		const char *str, BOOLEAN_P presel)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	if ( nh3d_windowlist[ wid ].win != nil && nh3d_windowlist[ wid ].type == NHW_MENU ) {
		[ nh3d_windowlist[ wid ].win addMenuItem:wid:glyph:identifier:accelerator:group_accel:attr:str:presel ];
	}
	
	[ pool release ];
}


void nh3d_end_menu(winid wid, const char *prompt)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	if ( nh3d_windowlist[ wid ].win != nil && nh3d_windowlist[ wid ].type == NHW_MENU ) {
		[ nh3d_windowlist[ wid ].win updateMenuWindow ];
		[ nh3d_windowlist[ wid ].win showMenuPanel:prompt ];
	}
	
	[ pool release ];
}


int nh3d_select_menu(winid wid, int how, menu_item **selected)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	int ret = -1;
	
	if ( nh3d_windowlist[ wid ].win != nil && nh3d_windowlist[ wid ].type == NHW_MENU ) {
		if ( [ _NH3DMenuWindow isMenu ] ) {
			ret = [ nh3d_windowlist[ wid ].win selectMenu:wid :how :selected ];
			[ nh3d_windowlist[ wid ].win setIsMenu:NO ];
			
		}
	}
	
	[ pool release ];
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


void nh3d_print_glyph(winid wid,XCHAR_P x,XCHAR_P y,int glyph)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	[ _NH3DBindController printGlyph:wid xPos:x yPos:y glyph:glyph ];
	[ pool release ];
}


void nh3d_raw_print(const char *str)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	[ _NH3DMessenger putLogMessarge:[ NSString stringWithCString:str encoding:NH3DTEXTENCODING ] ];
	[ pool release ];
}


void nh3d_raw_print_bold(const char *str)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	[ _NH3DMessenger putLogMessarge:[ NSString stringWithCString:str encoding:NH3DTEXTENCODING ] ];
	[ pool release ];
}


int nh3d_nhgetch()
{
	return [ _NH3DBindController nhGetKey ];
}


int nh3d_nh_poskey(int *x, int *y, int *mod)
{
	return [ _NH3DBindController nhPosKeyAtX:x atY:y keyMod:mod ];
}


void nh3d_nhbell()
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	NSSound *bell = [ NSSound soundNamed:@"Sosumi" ];
	[ bell play ];
	[ pool release ];
}


int nh3d_doprev_message()
{
	/*Do Nothing... They can read old messages using the scrollbar. */
	return 0;
}


char nh3d_yn_function(const char *question, const char *choices, CHAR_P def)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	char yn;
	char buf[ BUFSZ ];
	int result;
	BOOL ynfunc;
	
	if ( question != nil ) Strcpy(buf,question);
	if ( choices != nil ) Strcat(buf,choices);
	putstr(WIN_MESSAGE, ATR_BOLD, buf);
	
	if ( choices == "yn" ) {
		ynfunc = YES;
		result = NSRunAlertPanel(
                [ NSString stringWithCString:question encoding:NH3DTEXTENCODING ], 
                @" ", 
                @"YES", 
                @"NO", 
                @"Cancel",nil);
	
	} else if ( choices == "ynq" ) {
		ynfunc = YES;
		result = NSRunAlertPanel(
				[ NSString stringWithCString:question encoding:NH3DTEXTENCODING ], 
				@" ", 
				@"YES", 
				@"NO", 
				@"Quit",nil);
	} else if ( [ [ NSString stringWithCString:question encoding:NH3DTEXTENCODING ] isLike:
											NSLocalizedString(@"*what direction*",@"") ] ) {
		// hmm... These letters from cmd.c will not there be a good method?
		int x = u.ux; int y = u.uy; int mod = 0;
		ynfunc = NO;
		result = nh_poskey(&x, &y, &mod);
		
		if ( !result ) {
			int hdirect,vdirect;
			hdirect = ( x > u.ux ) ? 1 : 2;
			vdirect = ( y < u.uy ) ? 3 : 6;
			hdirect = ( x == u.ux ) ? 0 : hdirect;
			vdirect = ( y == u.uy ) ? 0 : vdirect;
			
			switch ( hdirect + vdirect ) {
				case 1 : // choice right
					result = ( iflags.num_pad ) ? '6' : 'l' ;
					[ _NH3DMessenger setLastAttackDirection:0 ];
					break;
				case 2 : // choice left
					result = ( iflags.num_pad ) ? '4' : 'h' ;
					[ _NH3DMessenger setLastAttackDirection:0 ];
					break;
				case 3 : // choice front
					result = ( iflags.num_pad ) ? '8' : 'k' ;
					[ _NH3DMessenger setLastAttackDirection:2 ];
					break;
				case 4 : // choice front right
					result = ( iflags.num_pad ) ? '9' : 'u' ;
					[ _NH3DMessenger setLastAttackDirection:3 ];
					break;
				case 5 : // choice front left
					result = ( iflags.num_pad ) ? '7' : 'y' ;
					[ _NH3DMessenger setLastAttackDirection:1 ];
					break;
				case 6 : // choice back
					result = ( iflags.num_pad ) ? '2' : 'j' ;
					[ _NH3DMessenger setLastAttackDirection:0 ];
					break;
				case 7 : // choice back right
					result = ( iflags.num_pad ) ? '3' : 'n' ;
					[ _NH3DMessenger setLastAttackDirection:0 ];
					break;
				case 8 : // choice back left
					result = ( iflags.num_pad ) ? '1' : 'b' ;
					[ _NH3DMessenger setLastAttackDirection:0 ];
					break;
			}
		}

	} else {
		char *p;
		ynfunc = NO;
		result = nhgetch();
		
		if (choices != nil) {
			buf[ 0 ] = result;
			buf[ 1 ] = '\0';
			p = strstr(choices,buf);
			if (p == NULL) result = 'n';
			
			sprintf(buf,"> [ %c ]",result);
			putstr(WIN_MESSAGE, ATR_ULINE, buf);
		}
	}
	
	
	if(result == NSAlertDefaultReturn && ynfunc) {
		yn = 'y';
	}
	else if(result == NSAlertAlternateReturn && ynfunc) {
		yn = 'n';
	}
	else if(result == NSAlertOtherReturn && choices == "ynq" && ynfunc) {
		yn = 'q';
	} else if (result == NSAlertOtherReturn && ynfunc) {
		yn = 'n';
	} else {
		yn = result;
	}
	
	if (ynfunc) {
		sprintf(buf,"> [ %c ]",yn);		
		putstr(WIN_MESSAGE, ATR_ULINE, buf);
	}
	
	[ pool release ];
	
	return yn;

}


void nh3d_getlin(const char *prompt, char *line)
{
	int ret = 0;
	
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	ret = [ _NH3DMessenger showInputPanel:prompt:line ];
	[ pool release ];
	if (ret == -1) line[ 0 ] = (char)0;
	
}


int nh3d_get_ext_cmd()
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	int ret = [ _NH3DKeyBuffer extendKey ];
	if (ret != -1 ) {
		[ _NH3DKeyBuffer setExtendKey:-1 ];
		[ pool release ];
		return ret;
	} else {
		menu_item *mi;
		anything ident;
		char buf[ 100 ];
		int win = create_nhwindow( NHW_MENU );
		start_menu( win );
		[ _NH3DMenuWindow setIsExtendMenu:YES ];
		 for (ret = 0; extcmdlist[ ret ].ef_txt != NULL; ++ret) {
			 ident.a_char = extcmdlist[ ret ].ef_txt[ 0 ];
			 sprintf( buf, "%-10s - %s ",
					  extcmdlist[ ret ].ef_txt,
					  extcmdlist[ ret ].ef_desc );
			 add_menu( win, NO_GLYPH, &ident, 0, 0, 0, buf, MENU_UNSELECTED);
		 }
		 
		 end_menu(win,(char*)0);
		 ret = select_menu(win, PICK_ONE, &mi );
		 destroy_nhwindow(win);
		 
		 if( ret >= 1 )
		 {
			 ret = [ _NH3DMenuWindow selectedRow ];
		 } else {
			 ret = -1;
		 }
			 
		 [ _NH3DKeyBuffer setExtendKey:-1 ];
		 free(mi);
		 [ pool release ];
		 return ret;
	}
}


void nh3d_number_pad(int num)
{
	/* Do Nothing */
}


void nh3d_delay_output()
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	[ _NH3DMapModel updateAllMaps ];
	[ NSThread sleepUntilDate:[ NSDate dateWithTimeIntervalSinceNow:0.01 ] ];
	
	[ pool release ];
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


void nh3d_outrip(winid wid, int how)
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	char buf[ BUFSZ ];
    char ripString[ BUFSZ ]="\0";
    extern const char *killed_by_prefix[ ];
	
	[ _NH3DMenuWindow setDoneRip:YES ];
	
	Sprintf(buf, "%s\n", plname);
    Strcat(ripString, buf);
    
    /* Put $ on stone */
    Sprintf(buf, "%ld Au\n",
#ifndef GOLDOBJ
			u.ugold);
#else
	done_money);
#endif
Strcat(ripString, buf);

/* Put together death description */
/* English version */
switch (killer_format) {
	default: impossible("bad killer format?");
	case KILLED_BY_AN:
		Strcpy(buf, killed_by_prefix[how]);
		Strcat(buf, an(killer));
		break;
	case KILLED_BY:
		Strcpy(buf, killed_by_prefix[how]);
		Strcat(buf, killer);
		break;
	case NO_KILLER_PREFIX:
		Strcpy(buf, killer);
		break;		
}


/* Japanese version 
switch (killer_format) {
	default: impossible("bad killer format?");
	case KILLED_BY_AN:
		Strcpy(buf, killed_by_prefix[ how ]);
		Strcat(buf, an(killer));
		break;
	case KILLED_BY:
		Strcpy(buf, killed_by_prefix[ how ]);
		Strcat(buf, killer);
		break;
	case NO_KILLER_PREFIX:
		Strcpy(buf, killer);
		break;
	case KILLED_SUFFIX:
		Strcpy(buf, killer);
		Strcat(buf, "に殺された");
}
*/
/**/
/* Put death type on stone */
	Strcat(ripString, buf);
	Strcat(ripString, "\n");

/* Put year on stone */
	Sprintf(buf, "%4d\n", getyear());
	Strcat(ripString, buf);

	[ _NH3DMapModel stopIndicator ];
	[ _NH3DMessenger showOutRip:ripString ];

	[ pool release ];
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
	[ NSApp terminate:nil ];
}

#ifndef GNUSTEP
//  UTF8 file Handring
void nh3d_set_savefile_name()
{
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	NSString *saveString;
	saveString = [ NSString stringWithFormat:@"%d%@",(int)getuid(),[ NSString stringWithCString:plname encoding:NH3DTEXTENCODING ] ];
	Strcpy(SAVEF,[ saveString UTF8String ]);
	[ pool release ];
}
#endif

struct window_procs nh3d_procs = {
    "nh3d",
	WC_COLOR|
	WC_HILITE_PET|
	WC_INVERSE|
	WC_ASCII_MAP|
	WC_POPUP_DIALOG|
	WC_MOUSE_SUPPORT|
	WC_PLAYER_SELECTION,
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
    genl_preference_update,
};

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


@implementation NH3DBindController


// for UserDefaults

+ (void) initialize
{
	NSMutableDictionary *defaultValues = [ NSMutableDictionary dictionary ];
	
	[ defaultValues setObject:[ NSNumber numberWithBool:NO ] forKey:NH3DUseTraditionalMapKey ];
	[ defaultValues setObject:[ NSNumber numberWithBool:NO ] forKey:NH3DTraditionalMapModeKey ];

	
	[ defaultValues setObject:@"nhtiles.tiff" forKey:NH3DTileNameKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:16 ] forKey:NH3DTileSizeWidthKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:16 ] forKey:NH3DTileSizeHeightKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:40 ] forKey:NH3DTilesPerLineKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:30 ] forKey:NH3DNumberOfTilesRowKey ];
	
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey:NH3DUseTileInLevelMapKey ];
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey:NH3DUseSightRestrictionKey ];
	
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey:NH3DOpenGLWaitSyncKey ];
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey:NH3DOpenGLUseWaitRateKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:1 ] forKey:NH3DOpenGLNumberOfThreadsKey ];
	
	[ defaultValues setObject:[ NSNumber numberWithFloat:WAIT_NORMAL ] forKey:NH3DOpenGLWaitRateKey ];
	
	[ defaultValues setObject:@"Hiragino Maru Gothic Pro" forKey:NH3DMsgFontKey ];
	[ defaultValues setObject:@"Courier Bold" forKey:NH3DMapFontKey ];
	[ defaultValues setObject:@"Lucida Grande Bold" forKey:NH3DBoldFontKey ];
	[ defaultValues setObject:@"Courier New Bold" forKey:NH3DInventryFontKey ];
	[ defaultValues setObject:@"Optima Bold" forKey:NH3DWindowFontKey ];
	
	[ defaultValues setObject:[ NSNumber numberWithBool:NO ] forKey:NH3DGLTileKey ];
		
	[ defaultValues setObject:[ NSNumber numberWithFloat:13 ] forKey:NH3DMsgFontSizeKey ];
	[ defaultValues setObject:[ NSNumber numberWithFloat:13 ] forKey:NH3DMapFontSizeKey ];
	[ defaultValues setObject:[ NSNumber numberWithFloat:13 ] forKey:NH3DBoldFontSizeKey ];
	[ defaultValues setObject:[ NSNumber numberWithFloat:13 ] forKey:NH3DInventryFontSizeKey ];
	[ defaultValues setObject:[ NSNumber numberWithFloat:13 ] forKey:NH3DWindowFontSizeKey ];
	
	[ defaultValues setObject:[ NSNumber numberWithBool:NO ] forKey:NH3DSoundMuteKey ];
	
	[ [NSUserDefaults standardUserDefaults] registerDefaults:defaultValues ];
	
	[ [NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues ];

}


- (id)init
{
		self = [ super init ];
		_prefPanel = nil;
		return self;
}

- (void)dealloc
{
	[ _prefPanel release ];
	[ super dealloc ];
}


- (void)awakeFromNib
{		
	[ _window setAlphaValue:0 ];
	[ _window setMovableByWindowBackground:NO ];
	
}


//-------------------------------------------------------------
// App delgates
//-------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init ];
	
	_tileCache = [ [ NH3DTileCache alloc ] initWithNamed:TILE_FILE_NAME ];
	
	_NH3DBindController = self;
	_NH3DUserStatusModel = _userStatus;
	_NH3DMapModel = _mapModel;
	_NH3DMessenger = _messenger;
	_NH3DMenuWindow = _menuWindow;
	_NH3DKeyBuffer = _asciiMapView;
	_NH3DOpenGLView = _glMapView;
	_NH3DTileCache = _tileCache;
	
	[ pool release ];

}

- (BOOL)windowShouldClose:(id)sender
{
	int choise = NSRunAlertPanel(NSLocalizedString(@"Quit NetHack3D",@""),
								 NSLocalizedString(@"Do you really want to Force Quit?",@""),
								@"Cancel",@"Quit",nil);
	if (choise == NSAlertAlternateReturn)
		{
		[ NSApp terminate:self ];
			return YES;
		}
	else
		return NO;
	
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	BOOL ret;
	
	if ( !iflags.window_inited ) return YES;
	
	if ([ _stDrawer state ] != NSDrawerClosedState) {
		[ _stDrawer close:self ];
	} 
	
	raw_print([ NSLocalizedString(@"NetHack3D say,'See you again.'",@"") cStringUsingEncoding:NH3DTEXTENCODING ]);
	ret = [ _messenger showLogPanel ];
	
	if (ret == YES) { clearlocks(); [ _glMapView setRunnning:NO ]; }
	
	return ret;
	
}


//-------------------------------------------------------------
//  over App delgates. 
//-------------------------------------------------------------


- (void)setTile
{
	if ( _tileCache != nil ) [ _tileCache release ];
	_tileCache = [ [ NH3DTileCache alloc ] initWithNamed:TILE_FILE_NAME ];
	_NH3DTileCache = _tileCache;
	
	[ [NSUserDefaults standardUserDefaults] setObject:[ NSNumber numberWithBool:NO ] forKey:NH3DTraditionalMapModeKey ];
	[ [NSUserDefaults standardUserDefaults] setObject:[ NSNumber numberWithBool:YES ] forKey:NH3DTraditionalMapModeKey ];
	
}



// show user make panel.
- (void)showUserMakeSheet
{
	NH3DUserMakeSheetController *userMakeSheet = nil;
	
	if ([ [ [ _userStatus playerName ] string ] isEqualToString:@"" ]) {
	
		NSString *pName = [ [ NSString alloc ] initWithCString:plname encoding:NH3DTEXTENCODING ];
		[ _userStatus setPlayerName:[ NSString stringWithCString:plname encoding:NH3DTEXTENCODING ] ];
		[ pName release ];
	}
	
	// Display sheet dialog
	
	if (!userMakeSheet) {
		userMakeSheet = [ [[NH3DUserMakeSheetController alloc] init] autorelease ];
	}
		
	[ userMakeSheet startSheet:_userStatus ];

}


- (void)showMainWindow
{
	int i;
	// window fade in 
	for (i=0;i<=10;i++) {
	[ _window setAlphaValue:((float)i)/10 ];
	[ NSThread sleepUntilDate:[ NSDate dateWithTimeIntervalSinceNow:0.1 ] ]; 
	} 
}


- (NSWindow*)mainWindow
{
	return _window;
}


- (void)didPresentError:(NSError *)error
{
			
	int result;
	NSAlert *alert = [ NSAlert alertWithError:error ];
	result = [ alert runModal ];

}


- (void)printGlyph:(winid)wid xPos:(XCHAR_P)x yPos:(XCHAR_P)y glyph:(int)glyph
{
	switch (nh3d_windowlist[ wid ].type) {
	case NHW_MAP:
		[ _mapModel setMapModelGlyph:glyph xPos:x yPos:y ];
		break;
	default:
		break;
	}
	
}	


- (int)nhPosKeyAtX:(int *)x atY:(int *)y keyMod:(int *)mod
{
	int ret = 0;
	unsigned int mask = ( NSAnyEventMask );

	//Wait next Event
	[ _asciiMapView nh3dEventHandlerLoopWithMask:mask ];	
	
	ret = [ _asciiMapView keyBuffer ];

	if (ret == 0) {
		*x = [ _mapModel cursX ];
		*y = [ _mapModel cursY ];
		*mod = [ _asciiMapView clickType ];
	}
	[ _asciiMapView setKeyUpdated:NO ];

	return ret;
}


- (int)nhGetKey
{
	int ret;
	unsigned int mask = ( NSLeftMouseDownMask	|
						  NSKeyDownMask			|
						  NSApplicationDefinedMask);
	
	[ _asciiMapView setGetCharMode:YES ];
	//Wait next Event
	[ _asciiMapView nh3dEventHandlerLoopWithMask:mask ];

	ret = [ _asciiMapView keyBuffer ];
	[ _asciiMapView setKeyUpdated:NO ];
	[ _asciiMapView setGetCharMode:NO ];
	return ret;
}



- (void)updateAll
{
	char buf[ BUFSZ ] = " ";
	[ _asciiMapView setNeedClear:YES ];
	[ _asciiMapView updateMap ];
	[ _glMapView updateMap ];
	[ _userStatus updatePlayerInventory ];
	[ _userStatus updatePlayer ];
	
	Sprintf(buf, "%s, level %d", dungeons[ u.uz.dnum ].dname, depth(&u.uz));
/*
	Sprintf(buf, "%s  地下%d階", jtrns_obj('d',dungeons[ u.uz.dnum ].dname), depth(&u.uz));
*/
	[ _mapModel setDungeonNameString:[ NSString stringWithCString:buf encoding:NH3DTEXTENCODING ] ];
}


- (IBAction)showPreferencePanel:(id)sender
{
	
	if ( _prefPanel == nil )
		_prefPanel = [ [NH3DPreferenceController alloc] init ];
	
	[ _prefPanel showPreferencePanel:self ];
	
	
}


- (void)endPreferencePanel
{
	[ _prefPanel release ];
	_prefPanel = nil;
}

// ---------------------------------------------------------------------------- //
// START NETHACK 3D
// ---------------------------------------------------------------------------- //

- (IBAction)startNetHack3D:(id)sender
{	
	register int fd;
	int argc = NXArgc;
	char **argv = NXArgv;
	char buf[ BUFSZ ];
#ifndef GNUSTEP
#ifdef CHDIR
	const char *dir;
#endif
#endif	
	[ [sender window] close ];
	[ _window makeKeyAndOrderFront:self ];

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
	dir = [ [[NSBundle mainBundle] resourcePath] UTF8String ];
	
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
			if (!strncmp(argv[ 1 ], "-s", 2) && strncmp(argv[ 1 ], "-style", 6)) {
#ifdef CHDIR
				chdirx(dir,0);
#endif
/*
				setkcode('I');
				initoptions();
				init_jtrns();
				prscore(argc, argv);
				jputchar('\0'); /* reset */

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

	initoptions();
	init_nhwindows(&argc,argv);

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




	[ self showMainWindow ];



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
		lockString = [ NSString stringWithFormat:@"%d%@",(int)getuid(),[ NSString stringWithCString:plname encoding:NH3DTEXTENCODING ] ];
		Strcpy(lock,[ lockString UTF8String ]);
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
		
		if(yn("Do you want to keep the save file?") == 'n')
		/*
			if(yn("セーブファイルを残しておきますか？") == 'n')
		 */
				(void) delete_savefile();
			else {
				(void) chmod(fq_save,FCMASK); /* back to readable */
				compress(fq_save);
			}
		}
		flags.move = 0;
		[ _userStatus setPlayerName:[ NSString stringWithCString:plname encoding:NH3DTEXTENCODING ] ];
	} else {
	
not_recovered:
	
		player_selection();
	
		newgame();
		wd_message();
		flags.move = 0;
		set_wear();
		(void) pickup(1);
	}

	[ _userStatus updatePlayer ];
	
	Sprintf(buf, "%s, level %d", dungeons[ u.uz.dnum ].dname, depth(&u.uz));
/*
	Sprintf(buf, "%s  地下%d階", jtrns_obj('d',dungeons[ u.uz.dnum ].dname), depth(&u.uz));
*/

	[ _mapModel setDungeonNameString:[ NSString stringWithCString:buf encoding:NH3DTEXTENCODING ] ];
	[ _mapModel updateAllMaps ];

	moveloop();   

}


@end
