//
//  NH3DMapItem.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/06.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NH3DModelDrawingTypes) {
	NH3DModelDrawingBlackWall = 0,
	NH3DModelDrawingPlayerPosition = 1,
	NH3DModelDrawingHole = 2,
	NH3DModelDrawingCorridor = 3,
	NH3DModelDrawingPool = 4,
	NH3DModelDrawingIce = 5,
	NH3DModelDrawingLava = 6,
	NH3DModelDrawingAir = 7,
	NH3DModelDrawingCloud = 8,
	NH3DModelDrawingWater = 9,
	NH3DModelDrawingModel3D = 10,
};

@interface NH3DMapItem : NSObject

- (instancetype)initWithParameter:(char)ch
							glyph:(int)glf
							color:(int)col
							 posX:(int)x
							 posY:(int)y
						  special:(int)sp
						  bgGlyph:(int)bg NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSString *symbol;
@property (readonly) int glyph;
@property (readonly, copy) NSColor *color;
@property (readonly) int material;
@property (readonly) int posX;
@property (readonly) int posY;
@property (readonly) unsigned int special;
@property (readonly) int bgGlyph;

@property (nonatomic, getter=isPlayer) BOOL player;

@property (nonatomic, setter=setCSymbol:) char cSymbol;

@property (nonatomic) BOOL hasAlternateSymbol;
@property (nonatomic) BOOL hasCursor;
@property (readonly) BOOL hasBackground;
- (nullable NSString*)alternateSymbolForDirection:(NH3DPlayerDirection)direction;

/// The foreground tile layered over the background tile.
@property (readonly, strong, nullable) NSImage *tile;

@property (readonly, strong, nullable) NSImage *foregroundTile;
@property (readonly, strong, nullable) NSImage *backgroundTile;

@property (readonly) NH3DModelDrawingTypes modelDrawingType;

- (void)clearTileCache;

/// Returns \c YES if the tile has a corpse.
@property (readonly, getter=isCorpse) BOOL corpse;

@property (readonly, getter=isInvis) BOOL invis;

@property (readonly, getter=isDetected) BOOL detected;

/// Returns \c YES if the tile has a player's pet.
@property (readonly, getter=isPet) BOOL pet;

@property (readonly) BOOL wasRidden;

/// Returns \c YES if there is a pile of objects on the block.
@property (readonly, getter=isPile) BOOL pile;

@end

NS_ASSUME_NONNULL_END
