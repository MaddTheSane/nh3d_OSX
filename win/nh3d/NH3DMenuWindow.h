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
@private
	IBOutlet NSTextView *_textWindow;
	IBOutlet NSTextView *_ripTextwindow;
	
	NSMutableArray<NH3DMenuItem*> *nh3dMenu;
	NSMutableDictionary<NSAttributedStringKey,id> *darkShadowStrAttributes;
	NSMutableDictionary<NSAttributedStringKey,id> *lightShadowStrAttributes;
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
@property (weak) IBOutlet NSPanel *menuPanel;
@property (weak) IBOutlet NSTableView *menuTableWindow;
@property (weak) IBOutlet NSTextField *menuPanelStrings;
@property (weak) IBOutlet NSTextField *menuPanelStringsShadow;
@property (weak) IBOutlet NSScrollView *menuScrollview;

//@property (weak) IBOutlet NSTextView *textWindow;

@property (weak) IBOutlet NSScrollView *textScrollView;
@property (weak) IBOutlet NSPanel *textPanel;
/* I am going to collect it.Probably. Perhaps.... */
@property (weak) IBOutlet NH3DMessaging *messenger;
//@property (weak) IBOutlet NSTextView *ripTextwindow;

@property BOOL isMenu;

@property BOOL isExtendMenu;
@property (readonly) NSInteger selectedRow;

@property BOOL doneRip;
@property (readonly) BOOL multipleSelection;

@property (readonly, strong) NSMutableArray<NH3DMenuItem*> *nh3dMenu;

- (void)putTextMessage:(NSString *)contents;
- (void)clearTextMessage;
- (void)showTextPanel;

- (void)createMenuWindow:(winid)wid;
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
