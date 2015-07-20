//
//  NH3DMenuItem.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"

#import "NH3DTileCache.h"
#import "NH3DUserDefaultsExtern.h"

@interface NH3DMenuItem : NSObject {
	
	NSString		*name;
	anything		identifier;
	char			accelerator;
	char			group_accel;
	int				glyph;
	int				attribute;
	boolean			preselect;
	BOOL			selectable;
	BOOL			selected;
	
	//NSImage			*img;
	NSSize			stringSize;
	unsigned		strLength;
	
}

// This is designated initializer.
-(id)initWithParameter:(const char*)cName
			identifier:(const anything *)ident
		   accelerator:(char)accel
		   group_accel:(char)gaccel
				 glyph:(int)glf
			 attribute:(int)attr
			 preSelect:(boolean)presel;

- (NSAttributedString *)name;
- (NSAttributedString *)accelerator;
- (NSImage *)glyph;
- (NSImage *)smallGlyph;
- (anything)identifier;
- (BOOL)isSelectable;
- (BOOL)isPreSelected;
- (BOOL)isSelected;

- (NSSize)stringSize;
- (unsigned)strLength;


- (void)setName:(const char*)nameStr;
- (void)setIdentifier:(const ANY_P *)identifierValue;
- (void)setAccelerator:(CHAR_P)acceleratorValue;
- (void)setGroup_accel:(CHAR_P)group_accelValue;
- (void)setGlyph:(int)glyphValue;
- (void)setAttribute:(int)attrValue;

- (void)setPreselect:(BOOLEAN_P)preselectValue;
- (void)setSelectable:(BOOL)flag;
- (void)setSelected:(BOOL)flag;
@end
