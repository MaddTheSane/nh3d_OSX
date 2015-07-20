/* NH3DMapModel */
//
//  NH3DMapModel.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//


#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

#import "NH3DMapItem.h"
#import "NH3DMapView.h"
#import "NH3DOpenGLView.h"


@interface NH3DMapModel : NSObject
{

	IBOutlet NH3DMapView *_asciiMapView;
    IBOutlet NSTextField *_dungeonName;
    IBOutlet NSLevelIndicator *_enemyIndicator;
    IBOutlet NH3DOpenGLView *_glMapView;
    //IBOutlet NSProgressIndicator *_progressIndicator;
	
	int playerDirection;
	
	NSAttributedString *dungeonNameString;
	NSMutableDictionary *strAttributes;
	NSShadow  *shadow;
	NSMutableParagraphStyle *style;
	
	BOOL indicatorIsActive;
	
	int enemyWarnBase;
	int loadingStatus;
	NSTimer *indicatorTimer;
	
	int cursX;
	int cursY;
	NH3DMapItem *mapArray[MAPSIZE_COLUMN][MAPSIZE_ROW];
	
	NSRecursiveLock	*lock;
}



- (IBAction)toggleIndicator:(id)sender;
- (void)startIndicator;
- (void)stopIndicator;

@property (nonatomic) int playerDirection;

- (void)prepareAttributes;

- (NSAttributedString *)dungeonNameString;
- (void)setDungeonNameString:(NSString *)aStr;
- (int)enemyWarnBase;
- (void)setEnemyWarnBase:(int)aValue;
- (void)updateEnemyIndicator;

//MapBufferCriate

- (void)setMapModelGlyph:(int)glf 
					xPos:(XCHAR_P)x 
					yPos:(XCHAR_P)y;

- (NH3DMapItem *)mapArrayAtX:(int)x atY:(int)y; 

- (IBAction)turnPlayerRight:(id)sender;
- (IBAction)turnPlayerLeft:(id)sender;
- (void)clearMapModel;
- (void)updateAllMaps;
- (void)reloadAllMaps;

- (void)setPosCursorAtX:(int)x atY:(int)y;
@property (readonly) int cursX;
@property (readonly) int cursY;


@end
