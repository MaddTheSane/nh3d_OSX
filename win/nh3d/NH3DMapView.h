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
	
	NSPoint downPoint;
	int		clickType;
	int		viewCursX;
	int		viewCursY;
	//NSPoint cursPos;
	
	NSImage *posCursor;
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
@property (weak) IBOutlet MapModel *mapModel;
@property (weak) IBOutlet NH3DBindController *bindController;
@property (weak) IBOutlet NH3DMessaging *messenger;
@property (weak) IBOutlet NSImageView *mapLview;
@property (weak) IBOutlet NSPanel	*mapLpanel;

@property (weak) IBOutlet NSButton *num1;
@property (weak) IBOutlet NSButton *num2;
@property (weak) IBOutlet NSButton *num3;
@property (weak) IBOutlet NSButton *num4;
@property (weak) IBOutlet NSButton *num5;
@property (weak) IBOutlet NSButton *num6;
@property (weak) IBOutlet NSButton *num7;
@property (weak) IBOutlet NSButton *num8;
@property (weak) IBOutlet NSButton *num9;

@property (weak) IBOutlet NSButton *turnRight;
@property (weak) IBOutlet NSButton *turnLeft;

@property (weak) IBOutlet NSButton *help1;
@property (weak) IBOutlet NSButton *help2;


@property (nonatomic, copy) NSColor *bgColor;
@property (weak) IBOutlet NSButton *fireArrowButton;
@property (weak) IBOutlet NSButton *kickButton;
@property (weak) IBOutlet NSButton *zapSpellButton;
@property (weak) IBOutlet NSButton *throwButton;
@property (weak) IBOutlet NSButton *openButton;

@property (weak) IBOutlet NSButton *againButton;
@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSButton *pickUpButton;


- (void)setCenterAtX:(int)x y:(int)y depth:(int)depth NS_SWIFT_NAME(setCenter(x:y:depth:));
@property BOOL isReady;

@property BOOL needClear;

- (void)makeTraditionalMap;
- (void)drawTraditionalMapAtX:(int)x atY:(int)y  NS_SWIFT_NAME(drawTraditionalMapAt(x:y:));
- (void)updateMap;
- (void)drawAsciiItemAtX:(int)x atY:(int)y NS_SWIFT_NAME(drawAsciiItemAt(x:y:));
- (void)reloadMap;
- (void)enemyCheck;

@property (nonatomic) CGFloat cursorOpacity;
- (void)drawMask;

@property (nonatomic) int keyBuffer;
@property (atomic) BOOL keyUpdated;
@property int extendKey;
@property BOOL getCharMode;

@property (readonly) int clickType;

- (void)nh3dEventHandlerLoopWithMask:(NSEventMask)mask;

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
