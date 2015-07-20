/* NH3DMessenger */
//
//  NH3DMessenger.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//


//#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

#import "func_tab.h"
#import "dlb.h"
#import "patchlevel.h"


@class NH3DOpenGLView;

@interface NH3DMessenger : NSObject
{
    IBOutlet NSTextView *_messeageWindow;
	IBOutlet NSScrollView *_messeageScrollView;
	IBOutlet NSTextView *_rawPrintWindow;
	IBOutlet NSPanel	*_rawPrintPanel;
	IBOutlet NH3DOpenGLView *_glView;

	IBOutlet NSWindow *_window;
	IBOutlet NSPanel *_ripPanel;

	IBOutlet NSPanel *_inputPanel;

	IBOutlet NSTextField *_deathDescription;
	IBOutlet NSTextField *_inputTextField;
	IBOutlet NSTextField *_questionTextField;
	
	NSMutableDictionary *darkShadowStrAttributes;
	NSMutableDictionary *lightShadowStrAttributes;
	NSShadow *darkShadow;
	NSShadow *lightShadow;
	NSMutableParagraphStyle *style;
	
	NSMutableArray *msgArray;
	NSMutableArray *soundMessageArray;
	NSMutableArray *soundNameArray;
	NSMutableArray *soundVolumeArray;
	
	NSMutableArray *effectMessageArray;
	NSMutableArray *effectTypeArray;
	
	
	BOOL ripFlag;
	BOOL userSound;
	
	int lastAttackDirection;
	
	NSMovieView *movieView;
	
}

- (void)prepareAttributes;

- (void)putMainMessarge:(int)attr:(const char *)text;
- (void)clearMainMessarge;

- (int)showInputPanel:(const char *)messageStr:(char *)line;
- (IBAction)closeInputPanel:(id)sender;

- (void)showOutRip:(const char *)ripString;

- (void)putLogMessarge:(NSString *)rawText;
- (BOOL)showLogPanel;

- (void)setLastAttackDirection:(int)direction;




@end
