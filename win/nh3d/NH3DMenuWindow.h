//
//  NH3DMenuWindow.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

//#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DMenuItem.h"
#import "NH3DMessenger.h"

#import "NH3DUserDefaultsExtern.h"

@interface NH3DMenuWindow : NSObject {
	
		IBOutlet NSPanel *_menuPanel;
		IBOutlet NSTableView *_menuTableWindow;
		IBOutlet NSWindow *_window;
		IBOutlet NSTextField *_menuPanelStrings;
		IBOutlet NSTextField *_menuPanelStringsShadow;
		IBOutlet NSScrollView *_menuScrollview;
		
		IBOutlet NSTextView *_textWindow;
		
		IBOutlet NSScrollView *_textScrollView;
		IBOutlet NSPanel *_textPanel;
		/* I am going to collect it.Probably. Perhaps.... */
		IBOutlet NH3DMessenger *_messenger;
		IBOutlet NSTextView *_ripTextwindow;
		
		NSMutableArray *nh3dMenu;
		NSMutableDictionary *darkShadowStrAttributes;
		NSMutableDictionary *lightShadowStrAttributes;
		NSShadow *darkShadow;
		NSShadow *lightShadow;
		NSMutableParagraphStyle  *style;
		
		
		BOOL isMenu;
		BOOL isExtendMenu;
		int selectedRow;
		BOOL doneRip;
		int pickType;
}

- (BOOL)isMenu;
- (void)setIsMenu:(BOOL)flag;

- (BOOL)isExtendMenu;
- (void)setIsExtendMenu:(BOOL)flag;
- (int)selectedRow;

- (BOOL)doneRip;
- (void)setDoneRip:(BOOL)flag;

- (NSMutableArray *)nh3dMenu;

- (void)putTextMessarge:(NSString *)contents;
- (void)clearTextMessarge;
- (void)showTextPanel;

- (void)createMenuWindow:(int)wid;
- (void)clearMenuWindow;

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex;
		
- (void)tableView:(NSTableView *)tableView 
        willDisplayCell:(id)cell 
        forTableColumn:(NSTableColumn *)tableColumn 
        row:(int)row;
		
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex;

/*
- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object 
   forTableColumn:(NSTableColumn *)tableColumn 
			  row:(int)rowIndex;
*/


- (void)updateMenuWindow;
- (void)addMenuItem:(winid)wid
					:(int)glyph
					:(const anything *)identifier
					:(char)accelerator
					:(char)group_accel
					:(int)attr 
					:(const char *)str
					:(boolean)presel;

- (void)showMenuPanel:(const char *)prompt;
- (int)selectMenu:(winid)wid:(int)how:(menu_item **)selected;

- (IBAction)closeModalDialog:(id)sender;

- (void)fitMenuWindowSizeToContents:(id)window scrollView:(NSScrollView *)scrollView;
- (void)fitTextWindowSizeToContents:(id)window scrollView:(NSScrollView *)scrollView;

- (void)keyDown:(NSEvent*)event;


@end
