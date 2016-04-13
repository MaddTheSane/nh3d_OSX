//
//  NH3DMenuWindow.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DMenuItem.h"

@class NH3DMessaging;

#import "NH3DUserDefaultsExtern.h"

@interface NH3DMenuWindow : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
	IBOutlet NSPanel *_menuPanel;
	IBOutlet NSTableView *_menuTableWindow;
	IBOutlet NSTextField *_menuPanelStrings;
	IBOutlet NSTextField *_menuPanelStringsShadow;
	IBOutlet NSScrollView *_menuScrollview;
	
	IBOutlet NSTextView *_textWindow;
	
	IBOutlet NSScrollView *_textScrollView;
	IBOutlet NSPanel *_textPanel;
	/* I am going to collect it.Probably. Perhaps.... */
	IBOutlet NH3DMessaging *_messenger;
	IBOutlet NSTextView *_ripTextwindow;
	
@private
	NSMutableArray<NH3DMenuItem*> *nh3dMenu;
	NSMutableDictionary *darkShadowStrAttributes;
	NSMutableDictionary *lightShadowStrAttributes;
	NSShadow *darkShadow;
	NSShadow *lightShadow;
	NSMutableParagraphStyle  *style;
	
	BOOL isMenu;
	BOOL isExtendMenu;
	NSInteger selectedRow;
	BOOL doneRip;
	int pickType;
}

@property (weak) IBOutlet NSWindow *window;

@property BOOL isMenu;

@property BOOL isExtendMenu;
@property (readonly) NSInteger selectedRow;

@property BOOL doneRip;
@property (readonly) BOOL multipleSelection;

@property (readonly, strong) NSMutableArray<NH3DMenuItem*> *nh3dMenu;

- (void)putTextMessage:(NSString *)contents;
- (void)clearTextMessage;
- (void)showTextPanel;

- (void)createMenuWindow:(int)wid;
- (void)clearMenuWindow;


- (void)updateMenuWindow;
- (void)addMenuItem:(winid)wid
			  glyph:(int)glyph
		 identifier:(const anything *)identifier
		accelerator:(char)accelerator
		 groupAccel:(char)group_accel
			   attr:(int)attr
				str:(const char *)str
			 presel:(boolean)presel;

- (void)showMenuPanel:(const char *)prompt;
- (int)selectMenu:(winid)wid how:(int)how selected:(menu_item **)selected;

- (IBAction)closeModalDialog:(id)sender;

- (void)fitMenuWindowSizeToContents:(NSWindow*)window scrollView:(NSScrollView *)scrollView;

- (void)keyDown:(NSEvent*)event;

@end
