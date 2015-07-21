//
//  NH3DMapItem.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/10/06.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"

@interface NH3DMapItem : NSObject {
	
	char				symbol;
	int					glyph;
	int					color;
	int					posX;
	int					posY;
	unsigned			special;
	
	BOOL				player;
	BOOL				hasAlternateSymbol;
	BOOL				hasCursor;
	
	//NSImage				*tile;
	
	int					modelDrawingType;
	
	NSRecursiveLock		*lock;
}

// This is designated initializer.
- (id)initWithParameter:(char)ch 
				  glyph:(int)glf 
				  color:(int)col 
				   posX:(int)x 
				   posY:(int)y 
				special:(int)sp;


- (NSString *)symbol;
- (int)glyph;
- (NSColor *)color;
- (int)material;
@property (readonly) int posX;
@property (readonly) int posY;
- (unsigned)special;

@property (nonatomic, getter=isPlayer) BOOL player;

- (char)cSymbol;

- (void)setSymbol:(char)chr;

@property (nonatomic) BOOL hasAlternateSymbol;
@property (nonatomic) BOOL hasCursor;
@property (readonly, strong) NSImage *tile;

- (int)modelDrawingType;

@end
