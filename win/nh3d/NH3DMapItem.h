//
//  NH3DMapItem.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/06.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface NH3DMapItem : NSObject

- (instancetype)initWithParameter:(char)ch
							glyph:(int)glf
							color:(int)col
							 posX:(int)x
							 posY:(int)y
						  special:(int)sp DEPRECATED_ATTRIBUTE;


/// This is the designated initializer.
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
@property (readonly, strong, nullable) NSImage *tile;

@property (readonly, strong, nullable) NSImage *foregroundTile;
@property (readonly, strong, nullable) NSImage *backgroundTile;

@property (readonly) int modelDrawingType;

@end

NS_ASSUME_NONNULL_END
