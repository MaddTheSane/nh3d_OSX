//
//  NH3DMenuWindow.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DMenuWindow.h"
#include <Carbon/Carbon.h>

#define DIALOG_OK		 128
#define DIALOG_CANCEL	 129

@interface NH3DMenuWindow ()
- (void)fitTextWindowSizeToContents;
@end

@implementation NH3DMenuWindow
@synthesize isMenu;
@synthesize isExtendMenu;
@synthesize doneRip;
@synthesize window = _window;
@synthesize selectedRow;
@synthesize nh3dMenu;

- (BOOL)multipleSelection
{
	return pickType == PICK_ANY;
}

- (instancetype)init
{
	if (self = [super init]) {
		nh3dMenu = [[NSMutableArray alloc] init];
		isMenu = NO;
		doneRip = NO;
		
		style = [[NSMutableParagraphStyle alloc] init];
		darkShadowStrAttributes = [[NSMutableDictionary alloc] init];
		lightShadowStrAttributes = [[NSMutableDictionary alloc] init];
		
		//for normal text
		darkShadow = [[NSShadow alloc] init];
		darkShadow.shadowColor = [NSColor colorWithCalibratedWhite:0.2 alpha:0.85];
		darkShadow.shadowOffset = NSMakeSize(2, -2);
		darkShadow.shadowBlurRadius = 4;
		//for panel or window.
		lightShadow = [[NSShadow alloc] init];
		lightShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.95];
		lightShadow.shadowOffset = NSMakeSize(-1.5, 1.5);
		lightShadow.shadowBlurRadius = 1.8;
		
		pickType = 0;
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	_textPanel.backgroundColor = [NSColor clearColor];
	_textPanel.opaque = NO;
	_menuPanel.backgroundColor = [NSColor clearColor];
	_menuPanel.opaque = NO;
	_textWindow.drawsBackground = NO;
	_menuTableWindow.backgroundColor = [NSColor clearColor];
	_textScrollView.drawsBackground = NO;
	_menuScrollview.drawsBackground = NO;
	
	//[_textWindow setAutoresizingMask:NSViewWidthSizable];
	//[_menuTableWindow setAutoresizingMask:NSViewWidthSizable];
	
	// set DubleClicked action
	_menuTableWindow.target = self;
	_menuTableWindow.doubleAction = @selector(closeModalDialog:);
	
	// set DataCell
	NSButtonCell* cell = [[NSButtonCell alloc] init];
	NSTableColumn* tableColumn = [_menuTableWindow tableColumnWithIdentifier:@"name"];
	
	cell.bezelStyle = NSBezelStyleRecessed;
	cell.buttonType = NSButtonTypeMomentaryLight;
	cell.bordered = YES;
	cell.gradientType = NSGradientNone;
	cell.highlightsBy = NSNoCellMask;
	cell.wraps = YES;
	cell.lineBreakMode = NSLineBreakByCharWrapping;
	cell.controlView = _menuTableWindow;
	
	tableColumn.dataCell = cell;
}

- (void)prepareAttributes
{
	style = [[NSMutableParagraphStyle alloc] init];
	style.alignment = NSTextAlignmentLeft;
	style.lineSpacing = 1;
	
	//Text attributes in View or backgrounded text field.
	darkShadowStrAttributes = [[NSMutableDictionary alloc] initWithCapacity:4];
	darkShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE];
	darkShadowStrAttributes[NSShadowAttributeName] = darkShadow;
	darkShadowStrAttributes[NSParagraphStyleAttributeName] = style;
	darkShadowStrAttributes[NSForegroundColorAttributeName] = [[NSColor brownColor] shadowWithLevel:0.8];
	
	//Text attributes on Panel or Window.
	lightShadowStrAttributes = [[NSMutableDictionary alloc] initWithCapacity:4];
	lightShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT size: NH3DWINDOWFONTSIZE];
	lightShadowStrAttributes[NSShadowAttributeName] = lightShadow;
	lightShadowStrAttributes[NSParagraphStyleAttributeName] = style;
	lightShadowStrAttributes[NSForegroundColorAttributeName] = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
}

- (void)putTextMessage:(NSString *)contents
{
	NSTextView *textOrRip = nil;
	
	[self prepareAttributes];
	
	if (flags.tombstone && doneRip) {
		textOrRip = _ripTextwindow;
		darkShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE - 1.0];
	} else {
		textOrRip = _textWindow;
		darkShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE];
	}
	
	textOrRip.typingAttributes = darkShadowStrAttributes;
	NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[contents stringByAppendingString:@"\n"] attributes:darkShadowStrAttributes];

	[textOrRip.textStorage appendAttributedString:attrStr];
	//[textOrRip sizeToFit];
}

- (void)clearTextMessage
{
	_textWindow.string = @"";
}

- (void)showTextPanel
{
	NSRect frameRect;
	
	if (flags.tombstone && doneRip) {
		return;
	}
	
	if (_window.attachedSheet) {
		NSWindow *attached = _window.attachedSheet;
		[_window endSheet:attached];
		[attached orderOut:nil];
	}
	//[[_window attachedSheet] orderOut:nil];
	//[NSApp stopModalWithCode:-100];
	
	[self fitTextWindowSizeToContents];
	
	frameRect = [_textPanel frameRectForContentRect:((NSView*)_textPanel.contentView).frame];
	[_textPanel setFrame:frameRect display:NO];
	
	if (_textScrollView.verticalScroller.usableParts != NSNoScrollerParts) {
		[_textWindow scrollRangeToVisible:NSMakeRange(0,0)];
	}
	
	[_window beginSheet:_textPanel completionHandler:^(NSModalResponse res){
		[_textWindow stopSpeaking:self];
		_textWindow.string = @"";
	}];
	[NSApp runModalForWindow: _textPanel];
	// Dialog is up here.
}

- (void)createMenuWindow:(winid)wid
{
	[nh3dMenu removeAllObjects];
	[self updateMenuWindow];
}

- (void)clearMenuWindow
{
	[nh3dMenu removeAllObjects];
	[self updateMenuWindow];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return nh3dMenu.count;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	NSString *identifier = aTableColumn.identifier;
	NH3DMenuItem *aMenuItem = nh3dMenu[rowIndex];
	
	return [aMenuItem valueForKey:identifier];
}


// Display TableMenu Items.
- (void)tableView:(NSTableView*)tableView 
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn*)tableColumn
			  row:(NSInteger)row
{
	NH3DMenuItem *aMenuItem = nh3dMenu[row];
	NSString *identifier = tableColumn.identifier;
		
	if ([identifier isEqualToString:@"name"]) {

		[cell setAttributedTitle:[aMenuItem name]];
		
		[cell setImagePosition:NSImageLeft];
		//[ cell setImage:[aMenuItem glyph] ];
		((NSCell*)cell).image = aMenuItem.smallGlyph;
		
		if (!aMenuItem.selectable) {
			[cell setBordered:NO];
			[cell setSelectable:NO];
		} else {
			[cell setBordered:YES];
			NSAttributedString *attrStr = [aMenuItem accelerator];
			if (attrStr) {
				[cell setKeyEquivalent:[NSString stringWithFormat:@"%c",*attrStr.string.UTF8String]];
			}
		}
	}
	
	if (aMenuItem.preselected) {
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
		[aMenuItem setPreselect:MENU_UNSELECTED];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{	
	NH3DMenuItem *aMenuItem = nh3dMenu[rowIndex];
	return aMenuItem.selectable;
}

- (void)updateMenuWindow
{
	[_menuTableWindow reloadData];
}

- (void)addMenuItem:(winid)wid
			  glyph:(int)glyph
		 identifier:(const anything *)identifier
		accelerator:(char)accelerator
		 groupAccel:(char)group_accel
			   attr:(int)attr
				str:(const char *)str
			 presel:(boolean)presel
{
	NH3DMenuItem *aMenuItem;
	aMenuItem = [[NH3DMenuItem alloc] initWithParameter:str
											 identifier:identifier
											accelerator:accelerator
											group_accel:group_accel
												  glyph:glyph
											  attribute:attr
											  preSelect:presel];
	
	[nh3dMenu addObject:aMenuItem];
}

//
//
//
	
- (void)showMenuPanel:(const char *)prompt
{
	NSRect frameRect;
	[self updateMenuWindow];
	
	if (prompt != nil) {
		NSString *promptStr = [[NSString alloc] initWithCString:prompt encoding:NH3DTEXTENCODING];
		_menuPanelStrings.stringValue = promptStr;
		// a-ha,It is difficult each time to make AttributedString, don't you think??
		_menuPanelStringsShadow.stringValue = promptStr;
	} else {
		_menuPanelStrings.stringValue = @"";
		_menuPanelStringsShadow.stringValue = @"";
	}
	
	[self fitMenuWindowSizeToContents:_menuPanel scrollView:_menuScrollview];

	frameRect = [_menuPanel frameRectForContentRect:((NSView*)_menuPanel.contentView).frame];
	[_menuPanel setFrame:frameRect display:YES];
	
	[_menuTableWindow scrollToBeginningOfDocument:nil];
	[_window.attachedSheet orderOut:nil];
	[_window beginSheet:_menuPanel completionHandler:^(NSModalResponse returnCode) {
		//[_menuPanel orderOut:self];
	}];
}

- (int)selectMenu:(winid)wid how:(int)how selected:(menu_item **)selected
{
	int i, ret = 0;
	NH3DMenuItem *aMenuItem;
	menu_item *mi;
	
	[self willChangeValueForKey:@"multipleSelection"];
	switch (how) {
		case PICK_ONE:
			[_menuTableWindow setAllowsMultipleSelection:NO];
			pickType = PICK_ONE;
			break;
			
		case PICK_ANY:
			[_menuTableWindow setAllowsMultipleSelection:YES];
			pickType = PICK_ANY;
			break;
			
		case PICK_NONE:
			[_menuTableWindow setAllowsMultipleSelection:NO];
			pickType = PICK_NONE;
			break;
	}
	[self didChangeValueForKey:@"multipleSelection"];
	
	@autoreleasepool {
		ret = [NSApp runModalForWindow: _menuPanel];
	}
    // Dialog is up here.
	
	[_textWindow stopSpeaking:self];
	_menuPanelStrings.stringValue = @"";
	_menuPanelStringsShadow.stringValue = @"";

	*selected = (menu_item *)0;
	
	if (how != PICK_NONE && ret == DIALOG_OK) {
		ret = _menuTableWindow.numberOfSelectedRows;
	} else {
		ret = -1;
	}
	
	if (ret > 0) {
		*selected = mi = (menu_item *)alloc(ret * sizeof(menu_item));
		for (i = 0; i < nh3dMenu.count; i++) {
			aMenuItem = nh3dMenu[i];
			if ([_menuTableWindow isRowSelected:i]) {
				mi->item = [aMenuItem identifier];
				mi->count = -1L;
				mi++;
				
				if (isExtendMenu && how == PICK_ONE) {
					selectedRow = i;
					isExtendMenu = NO;
				}
			}
		}
	}
	
	return ret;
}

- (IBAction)closeModalDialog:(id)sender
{
	id sendWind = [sender window];
	if ([sender tag]) {
		[_window endSheet: sendWind];
		[NSApp stopModalWithCode:DIALOG_CANCEL];
	} else {
		[_window endSheet: sendWind];
		[NSApp stopModalWithCode:DIALOG_OK];
	}
	for (id oth in _window.sheets) {
		NSLog(@"extra sheet %@!", oth);
	}
	[sendWind orderOut:self];
}

- (void)fitMenuWindowSizeToContents:(NSWindow*)window scrollView:(NSScrollView *)scrollView
{
	NSSize contentSize = NSZeroSize, strSize;
	NSRect windowRect = window.frame;
	NSSize windowMaxSize = window.maxSize;
	NSSize windowMinSize = window.minSize;
	static const CGFloat contentWidthMargin = 44.0;
	static const CGFloat contentHeightMargin = 120.0;
	
	//set height
	windowRect.size.height = (([scrollView.documentView rowHeight] + 4.0) * [scrollView.documentView numberOfRows]) + contentHeightMargin;
	
	windowRect.size.height = MIN(windowRect.size.height, windowMaxSize.height - 16);
	
	//set width
	/* for Ascii only Strings
	 contentSize = [[[[scrollView documentView] tableColumnWithIdentifier:@"name"] dataCell] cellSize];
	 */
	//	for 2byte letter Strings (e,g,Japanese)any size method of Cocoa, does not acquire size of a 2byte letter well for some reason. Why?
	//contentSize = NSMakeSize( 0,0 );
	for (NH3DMenuItem *aMenuItem in nh3dMenu) {
		NSUInteger len = [aMenuItem name].length;
		strSize.width = len * (NH3DINVFONTSIZE + 4.0);
		//strSize = [[nh3dMenu objectAtIndex:i] stringSize];  // fmm...  does not acquire size of a 2byte letter well, too.
		if (strSize.width > contentSize.width) {
			contentSize.width = strSize.width;
		}
	}
	
	if (contentSize.width > 640.0) {
		windowRect.size.width = 640.0;
	} else if (contentSize.width + contentWidthMargin < windowMinSize.width) {
		windowRect.size.width = windowMinSize.width;
	} else {
		windowRect.size.width = contentSize.width + contentWidthMargin;
	}
	
	//set frame
	[window setFrame:windowRect display:NO];
}

- (void)fitTextWindowSizeToContents
{
	static const CGFloat contentWidthMargin = 100;
	static const CGFloat contentHeightMargin = 120.0;
	NSScreen *scr = _window.screen;
	NSRect rect = scr.visibleFrame;
	CGFloat height = NSHeight(rect);
	CGFloat width = NSWidth(rect);
	width -= contentWidthMargin;
	height -= contentHeightMargin;
	NSRect boundRect = [_textWindow.textStorage boundingRectWithSize:NSMakeSize(width, height)
															 options:NSStringDrawingUsesLineFragmentOrigin
															 context:nil];
	boundRect = NSIntegralRect(boundRect);
	height = MIN(height, NSHeight(boundRect));
	//[_textScrollView setFrameSize:NSMakeSize(NSWidth(boundRect), height)];
	[_textPanel setFrame:NSMakeRect(0, 0, NSWidth(boundRect) + contentWidthMargin, height + contentHeightMargin) display:NO];
}

- (void)keyDown:(NSEvent*)event
{
	unichar key = [event.charactersIgnoringModifiers characterAtIndex:0];
	
	if ((key == NSEnterCharacter || key == NSCarriageReturnCharacter)
		&& (pickType == PICK_NONE || _menuTableWindow.numberOfSelectedRows)) {
		[_menuPanel  orderOut:self];
		[_window endSheet:_menuPanel];
		[NSApp stopModalWithCode:DIALOG_OK];
		return;
	}
	
	if (event.keyCode == kVK_Escape) {
		[_menuPanel close];
		[_window endSheet:_menuPanel];
		[NSApp stopModalWithCode:DIALOG_CANCEL];
		return;
	}
	
	for (NSInteger i = 0; i < nh3dMenu.count; i++) {
		if ([event.charactersIgnoringModifiers isEqualToString:[nh3dMenu[i] accelerator].string]) {
			[_menuTableWindow selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
			
			if (pickType == PICK_ONE) {
				[_menuPanel close];
				[_window endSheet:_menuPanel];
				[NSApp stopModalWithCode:DIALOG_OK];
				return;
			} else {
				return;
			}
		} 
	}
	NSBeep();
}

@end
