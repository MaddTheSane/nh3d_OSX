/* NH3DMapView */
//
//  NH3DMapView.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

//#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DMapItem.h"
#import "NH3DUserDefaultsExtern.h"

@class NH3DMapModel;
@class NH3DBindController;
@class NH3DMessenger;


@interface NH3DMapView : NSView
{
	
	IBOutlet NH3DMapModel *_mapModel;
	IBOutlet NH3DBindController *_bindController;
	IBOutlet NH3DMessenger *_messenger;
	IBOutlet NSImageView *_mapLview;
	IBOutlet NSPanel	*_mapLpanel;
	NSColor	*bgColor;
	int	centerX;
	int centerY;
	int plDepth;
	BOOL isReady;
	BOOL needClear;
	
	int keyBuffer;
	int lastKeyBuffer;
	int modKeyFlag;
	BOOL keyUpdated;
	
	BOOL getCharMode;
	
	//-----------------------------------------------------------//
	// NOTE
	// extendKey is set row position of extcmdlist[startis0] (see cmd.c)
	// ----------------------------------------------------------//
	int extendKey;
	
	IBOutlet NSButton *_num1;
	IBOutlet NSButton *_num2;
	IBOutlet NSButton *_num3;
	IBOutlet NSButton *_num4;
	IBOutlet NSButton *_num5;
	IBOutlet NSButton *_num6;
	IBOutlet NSButton *_num7;
	IBOutlet NSButton *_num8;
	IBOutlet NSButton *_num9;
	
	IBOutlet NSButton *_turnRight;
	IBOutlet NSButton *_turnLeft;
	
	IBOutlet NSMatrix *_cmdGroup1;
	IBOutlet NSMatrix *_cmdGroup2;
	
	IBOutlet NSButton *_help1;
	IBOutlet NSButton *_help2;
	
	NSPoint downPoint;
	int		clickType;
	int		viewCursX;
	int		viewCursY;
	//NSPoint cursPos;
	
	NSImage *posCursor;
	NSImage *mapBezel;
	NSImage *mapBase;
	NSImage *mapRestrictedBezel;
	
	NSImage *mapImage;
	NSImage *trMapImage;
	
	//NSShadow *fontShadow;
	//NSMutableDictionary *fontAttributes;

	float	cursOpacity;
		
	NH3DMapItem *mapItemValue[MAPVIEWSIZE_COLUMN][MAPVIEWSIZE_ROW];
	
	int enemyCatch;
	
	NSRecursiveLock *lock;
	
}

- (void)setBgColor:(NSColor *)colr;
- (NSColor *)bgColor;

- (void)setCenter:(int)x:(int)y:(int)depth;
- (BOOL)isReady;
- (void)setIsReady:(BOOL)flag;

- (BOOL)needClear;
- (void)setNeedClear:(BOOL)flag;

- (void)makeTraditionalMap;
- (void)drawTraditionalMapAtX:(int)x atY:(int)y;
- (void)updateMap;
- (void)drawAsciiItemAtX:(int)x atY:(int)y;
- (void)reloadMap;
- (void)enemyCheck;

- (void)setCursOpacity:(float)opaq;
- (void)drawMask;

- (int)keyBuffer;
- (void)setKeyBufffer:(int)value;

- (BOOL)keyUpdated;
- (void)setKeyUpdated:(BOOL)flag;

- (int)extendKey;
- (void)setExtendKey:(int)value;

- (BOOL)getCharMode;
- (void)setGetCharMode:(BOOL)flag;

- (int)clickType;

- (void)nh3dEventHandlerLoopWithMask:(unsigned int)mask;

// Notification
- (void)defaultDidChange:(NSNotification *)notification;

//-----------------------------------------------------------------------------//
//				Actions
//-----------------------------------------------------------------------------//

- (IBAction)gearMenuActions:(id)sender;
- (IBAction)actionMenuActions:(id)sender;
- (IBAction)magicMenuActions:(id)sender;
- (IBAction)infoMenuActions:(id)sender;
- (IBAction)otherMenuActions:(id)sender;
- (IBAction)controllerActions:(id)sender;
- (IBAction)setRestrictedView:(id)sender;
- (IBAction)showGlobalMap:(id)sender;
- (IBAction)setUseTileInGlobalMap:(id)sender;
- (IBAction)closeModalDialog: (id)sender;
- (IBAction)zoomLevelMap: (id)sender;

@end
