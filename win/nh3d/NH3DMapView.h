/* NH3DMapView */
//
//  NH3DMapView.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DMapItem.h"
#import "NH3DUserDefaultsExtern.h"

@class MapModel;
@class NH3DBindController;
@class NH3DMessaging;

NS_ASSUME_NONNULL_BEGIN

@interface NH3DMapView : NSView
{
	IBOutlet MapModel *_mapModel;
	IBOutlet NH3DBindController *_bindController;
	IBOutlet NH3DMessaging *_messenger;
	IBOutlet NSImageView *_mapLview;
	IBOutlet NSPanel	*_mapLpanel;
@private
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
	
@package
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

@private
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

	CGFloat	cursOpacity;
		
	NH3DMapItem *mapItemValue[MAPVIEWSIZE_COLUMN][MAPVIEWSIZE_ROW];
	
	int enemyCatch;
	
	NSRecursiveLock *lock;
}

@property (nonatomic, strong) NSColor *bgColor;

- (void)setCenterAtX:(int)x y:(int)y depth:(int)depth;
@property BOOL isReady;

@property BOOL needClear;

- (void)makeTraditionalMap;
- (void)drawTraditionalMapAtX:(int)x atY:(int)y;
- (void)updateMap;
- (void)drawAsciiItemAtX:(int)x atY:(int)y;
- (void)reloadMap;
- (void)enemyCheck;

@property (nonatomic) CGFloat cursorOpacity;
- (void)drawMask;

@property (nonatomic) int keyBuffer;
@property (atomic) BOOL keyUpdated;
@property int extendKey;
@property BOOL getCharMode;

@property (readonly) int clickType;

- (void)nh3dEventHandlerLoopWithMask:(NSUInteger)mask;

// Notification
- (void)defaultDidChange:(NSNotification *)notification;

//-----------------------------------------------------------------------------//
//				Actions
//-----------------------------------------------------------------------------//

- (IBAction)gearMenuActions:(nullable id)sender;
- (IBAction)actionMenuActions:(nullable id)sender;
- (IBAction)magicMenuActions:(nullable id)sender;
- (IBAction)infoMenuActions:(nullable id)sender;
- (IBAction)otherMenuActions:(nullable id)sender;
- (IBAction)controllerActions:(nullable id)sender;
- (IBAction)setRestrictedView:(nullable id)sender;
- (IBAction)showGlobalMap:(nullable id)sender;
- (IBAction)setUseTileInGlobalMap:(nullable id)sender;
- (IBAction)closeModalDialog:(nullable id)sender;
- (IBAction)zoomLevelMap:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
