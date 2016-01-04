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

NS_ASSUME_NONNULL_BEGIN

@interface NH3DMenuItem : NSObject {
@private
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
	NSUInteger		strLength;
	
}

// This is designated initializer.
-(instancetype)initWithParameter:(const char*)cName
			identifier:(const anything *)ident
		   accelerator:(char)accel
		   group_accel:(char)gaccel
				 glyph:(int)glf
			 attribute:(int)attr
			 preSelect:(boolean)presel NS_DESIGNATED_INITIALIZER;

- (NSAttributedString *)name;
- (NSAttributedString *)accelerator;
- (nullable NSImage *)glyph;
@property (readonly, copy, nullable) NSImage *smallGlyph;
- (anything)identifier;
@property (readwrite, getter=isSelectable) BOOL selectable;
@property (readonly, getter=isPreSelected) BOOL preSelected;
@property (readwrite, getter=isSelected) BOOL selected;

@property (readonly) NSSize stringSize;
@property (readonly) NSUInteger strLength;


- (void)setName:(const char*)nameStr;
- (void)setIdentifier:(const ANY_P *)identifierValue;
- (void)setAccelerator:(CHAR_P)acceleratorValue;
- (void)setGroup_accel:(CHAR_P)group_accelValue;
- (void)setGlyph:(int)glyphValue;
- (void)setAttribute:(int)attrValue;

- (void)setPreselect:(BOOLEAN_P)preselectValue;
@end

NS_ASSUME_NONNULL_END
