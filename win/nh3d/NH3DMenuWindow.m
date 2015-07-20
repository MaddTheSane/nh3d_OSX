//
//  NH3DMenuWindow.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/09/25.
//  Copyright 2005 Haruumi Yoshino.
//

#import "NH3DMenuWindow.h"
#import "NH3DMapModel.h"


static const int DIALOG_OK		= 128;
static const int DIALOG_CANCEL	= 129;

@implementation NH3DMenuWindow


- (id)init
{
	[ super init ];
	if (self != nil) {
		nh3dMenu = nil;
		isMenu = NO;
		doneRip = NO;
		
		style = [ [NSMutableParagraphStyle alloc] init ];
		darkShadowStrAttributes = [ [NSMutableDictionary alloc] init ];
		lightShadowStrAttributes = [ [NSMutableDictionary alloc] init ];

		
	//for normal text
		darkShadow = [ [NSShadow alloc] init ];
		[ darkShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0.85] ];
		[ darkShadow setShadowOffset:NSMakeSize(2, -2) ];
		[ darkShadow setShadowBlurRadius:4 ];
	//for panel or window.
		lightShadow = [ [NSShadow alloc] init ];
		[ lightShadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.95] ];
		[ lightShadow setShadowOffset:NSMakeSize(-1.5, 1.5) ];
		[ lightShadow setShadowBlurRadius:1.8 ];
		
		pickType = 0;
		
	}
	return self;
}


- (void)dealloc 
{
	[ nh3dMenu release ];
	[ darkShadowStrAttributes release ];
	[ lightShadowStrAttributes release ];
	[ darkShadow release ];
	[ lightShadow release ];
	[ style release ];
	[ super dealloc ];
}

- (void)awakeFromNib {
			
	[ _textPanel setBackgroundColor:[NSColor clearColor] ];
    [ _textPanel setOpaque:NO ];
	[ _menuPanel setBackgroundColor:[NSColor clearColor] ];
    [ _menuPanel setOpaque:NO ];
	[ _textWindow setDrawsBackground:NO ];
	[ _menuTableWindow setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"ScrollParchmentBack"]] ];
	//[_menuTableWindow setBackgroundColor:[NSColor clearColor]];
	[ _textScrollView setDrawsBackground:NO ];
	[ _menuScrollview setDrawsBackground:NO ];
	
	//[_textWindow setAutoresizingMask:NSViewWidthSizable];
	//[_menuTableWindow setAutoresizingMask:NSViewWidthSizable];
	
	// set DubleClicked action
	[ _menuTableWindow setTarget:self ];
	[ _menuTableWindow setDoubleAction:@selector(closeModalDialog:) ];
	
	// set DataCell
	NSButtonCell* cell = [ [NSButtonCell alloc] init ];
	NSTableColumn*	tableColumn = [ _menuTableWindow tableColumnWithIdentifier:@"name" ];
	
	[ cell setBezelStyle:NSRecessedBezelStyle ];
	[ cell setButtonType:NSMomentaryLightButton ];
	[ cell setBordered:YES ];
	[ cell setGradientType:NSGradientNone ];
	[ cell setHighlightsBy:NSNoCellMask ];
	[ cell setWraps:YES ];
	[ cell setLineBreakMode:NSLineBreakByCharWrapping ];
	[ cell setControlView:_menuTableWindow ];
	
	[ tableColumn setDataCell:cell ];
	[ cell release ];
	
}


- (BOOL)doneRip
{
	return doneRip;
}

- (void)setDoneRip:(BOOL)flag
{
	doneRip = flag;
}


- (void)prepareAttributes
{
	[ style setAlignment:NSLeftTextAlignment ];
	[ style setLineSpacing:1 ];
	
	//Text attributes in View or backgrounded text field.
	[ darkShadowStrAttributes setObject:[NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE]
								 forKey:NSFontAttributeName ];
	[ darkShadowStrAttributes setObject:darkShadow
								 forKey:NSShadowAttributeName ];
	[ darkShadowStrAttributes setObject:style
								 forKey:NSParagraphStyleAttributeName ];
	[ darkShadowStrAttributes setObject:[[NSColor brownColor] shadowWithLevel:0.8]
								 forKey:NSForegroundColorAttributeName ];
	
	//Text attributes on Panel or Window.	
	[ lightShadowStrAttributes setObject:[NSFont fontWithName:NH3DWINDOWFONT size: NH3DWINDOWFONTSIZE]
								  forKey:NSFontAttributeName ];
	[ lightShadowStrAttributes setObject:lightShadow
								 forKey:NSShadowAttributeName ];
	[ lightShadowStrAttributes setObject:style
								 forKey:NSParagraphStyleAttributeName ];
	[ lightShadowStrAttributes setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]
								  forKey:NSForegroundColorAttributeName ];
	
}

@synthesize isMenu;
@synthesize isExtendMenu;
@synthesize doneRip;

- (NSMutableArray *)nh3dMenu
{
	return nh3dMenu;
}


- (int)selectedRow
{
	return selectedRow;
}


- (void)putTextMessarge:(NSString *)contents
{
	id textOrRip = nil;
	
	[ self prepareAttributes ];
	
	if ( flags.tombstone && doneRip ) {
		textOrRip = _ripTextwindow;
		[ darkShadowStrAttributes setObject:[NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE - 1.0]
									 forKey:NSFontAttributeName ];

	} else {
		textOrRip = _textWindow;
		[ darkShadowStrAttributes setObject:[NSFont fontWithName:NH3DINVFONT size: NH3DINVFONTSIZE ]
									 forKey:NSFontAttributeName ];

	}
	
	[ textOrRip setTypingAttributes:darkShadowStrAttributes ];

	[ textOrRip setEditable:YES ];
	[ textOrRip insertText:contents ];
	[ textOrRip insertText:@"\n" ];
	[ textOrRip setEditable:NO ];
	//[ textOrRip sizeToFit ];
}




- (void)clearTextMessarge
{
	[ _textWindow setString:@"" ];
}


- (void)showTextPanel
{
	NSAutoreleasePool *pool = [ NSAutoreleasePool new ];
	NSRect frameRect;
	
	if ( flags.tombstone && doneRip ) {
		[ pool release ];
		return;
	}
	
	[ [_window attachedSheet] orderOut:nil ];
	
	[ self fitTextWindowSizeToContents:_textPanel scrollView:_textScrollView ];
	
	frameRect = [ _textPanel frameRectForContentRect:[[_textPanel contentView] frame] ];
	[ _textPanel setFrame:frameRect display:NO ];
	
	if ( [ [_textScrollView verticalScroller] usableParts ] != NSNoScrollerParts ) {
		[ _textWindow scrollRangeToVisible:NSMakeRange(0,0) ];
	}
	
	[ NSApp beginSheet:_textPanel
	    modalForWindow:_window
		 modalDelegate:nil
	    didEndSelector:nil
		   contextInfo:nil ];
	[ NSApp runModalForWindow: _textPanel ];
    // Dialog is up here.

	[ _textWindow setString:@"" ];
	
	[ NSApp stopSpeaking:self ];
	[ pool release ];
}



- (void)createMenuWindow:(int)wid
{
	if ( nh3dMenu != nil ) {
	 [ nh3dMenu removeAllObjects ];
	 [ self updateMenuWindow ];
	} else {
	nh3dMenu = [ [NSMutableArray alloc]init ];
	[ self updateMenuWindow ];
	}
}


- (void)clearMenuWindow
{
	[ nh3dMenu removeAllObjects ];
	[ self updateMenuWindow ];
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [ nh3dMenu count ];
}


- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{
	NSString *identifier = [ aTableColumn identifier ];
	NH3DMenuItem *aMenuItem = [ nh3dMenu objectAtIndex:rowIndex ];
	
	return [ aMenuItem valueForKey:identifier ];
}


// Display TableMenu Items.
- (void)tableView:(NSTableView*)tableView 
                willDisplayCell:(id)cell 
                forTableColumn:(NSTableColumn*)tableColumn 
                row:(int)row
{
	NH3DMenuItem *aMenuItem = [ nh3dMenu objectAtIndex:row ];
	NSString *identifier = [ tableColumn identifier ];
		
	if( [ identifier isEqualToString:@"name" ] ) {

		[ cell setAttributedTitle:[aMenuItem name] ];
		
		[ cell setImagePosition:NSImageLeft ];
		//[ cell setImage:[aMenuItem glyph] ];
		[ cell setImage:[aMenuItem smallGlyph] ];
		
		if ( ![aMenuItem isSelectable] ) {
			[ cell setBordered:NO ];
			[ cell setSelectable:NO ];
		} else {
			[ cell setBordered:YES ];
			[ cell setKeyEquivalent:[NSString stringWithFormat:@"%c",[aMenuItem accelerator]] ];
		}		
	}
	
	if ( [ aMenuItem isPreSelected ] ) {
		[ tableView selectRow:row byExtendingSelection:YES ];
		[ aMenuItem setPreselect:MENU_UNSELECTED ];
	}
}


- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{	
	NH3DMenuItem *aMenuItem = [ nh3dMenu objectAtIndex:rowIndex ];
	return [ aMenuItem isSelectable ];
}


- (void)updateMenuWindow
{
	[ _menuTableWindow reloadData ];
}


- (void)addMenuItem:(winid)wid
					:(int)glyph
					:(const anything *)identifier
					:(char)accelerator
					:(char)group_accel
					:(int)attr 
					:(const char *)str
					:(boolean)presel
{
	
		NH3DMenuItem *aMenuItem = nil;
		aMenuItem = [ [NH3DMenuItem alloc]initWithParameter:str
												 identifier:identifier
												accelerator:accelerator
												group_accel:group_accel
													  glyph:glyph
												  attribute:attr
												  preSelect:presel ];

		[ nh3dMenu addObject:aMenuItem ];
		[ aMenuItem release ];

}					
		
//
//
//
	
- (void)showMenuPanel:(const char *)prompt
{
	NSRect frameRect;
	[ self updateMenuWindow ];
	
	if ( prompt != nil ) {
	[ _menuPanelStrings setStringValue:[NSString stringWithCString:prompt encoding:NH3DTEXTENCODING] ];
	// a-ha,It is difficult each time to make AttributedString, don't you think??
	[ _menuPanelStringsShadow setStringValue:[NSString stringWithCString:prompt encoding:NH3DTEXTENCODING] ];
	} else {
		[ _menuPanelStrings setStringValue:@"" ];
		[ _menuPanelStringsShadow setStringValue:@"" ];
	}
	
	[ self fitMenuWindowSizeToContents:_menuPanel scrollView:_menuScrollview ];

	frameRect = [ _menuPanel frameRectForContentRect:[[_menuPanel contentView] frame] ];
	[ _menuPanel setFrame:frameRect display:YES ];
	
	[ [_window attachedSheet] orderOut:nil ];
	[ NSApp beginSheet:_menuPanel
			 modalForWindow:_window
			 modalDelegate:nil
			 didEndSelector:nil
			 contextInfo:nil ];
	
}

- (int)selectMenu:(winid)wid how:(int)how selected:(menu_item **)selected
{
	int i,ret = 0;
	NH3DMenuItem *aMenuItem;
	menu_item *mi;
	
	NSAutoreleasePool *pool;

	
	switch ( how ) 
	{
		case PICK_ONE:
			[ _menuTableWindow setAllowsMultipleSelection:NO ];
			pickType = PICK_ONE;
		break;
		case PICK_ANY:
			[ _menuTableWindow setAllowsMultipleSelection:YES ];
			pickType = PICK_ANY;
		break;
		case PICK_NONE:
			pickType = PICK_NONE;
		break;
	}
	
	pool = [ NSAutoreleasePool new ];
	ret = [ NSApp runModalForWindow: _menuPanel ];
	[ pool release ];
    // Dialog is up here.
	
	[ NSApp stopSpeaking:self ];
	[ _menuPanelStrings setStringValue:@"" ];
	[ _menuPanelStringsShadow setStringValue:@"" ];

	
	*selected = (menu_item *) 0;
	
	if ( how != PICK_NONE && ret == DIALOG_OK ) {
		ret = [ _menuTableWindow numberOfSelectedRows ];
	} else {
		ret = -1;
	}
	
	if (ret > 0) {
		*selected = mi = ( menu_item * ) alloc( ret * sizeof( menu_item ) );
		for (i=0; i < [ nh3dMenu count ] ; i++) {
			aMenuItem = [ nh3dMenu objectAtIndex:i ];
			if ([ _menuTableWindow isRowSelected:i ]) {
				mi->item = [ aMenuItem identifier ];
				mi->count = -1L;
				mi++;
				
				if ( isExtendMenu && how == PICK_ONE ) {
					selectedRow = i;
					isExtendMenu = NO;
				}
			}
		}
	}
	
	return ret;
}
	

- (IBAction)closeModalDialog: (id)sender
{
	if ( [ sender tag ] )
	{
		[ [sender window] orderOut:self ];
		[ NSApp stopModalWithCode:DIALOG_CANCEL ];
		[ NSApp endSheet: [sender window] ];
	} else { 
		[ [sender window] close ];
		[ NSApp stopModalWithCode:DIALOG_OK ];
		[ NSApp endSheet: [sender window] ];
	}
}

- (void)fitMenuWindowSizeToContents:(id)window scrollView:(NSScrollView *)scrollView
{
	NSSize contentSize,strSize;
	NSRect windowRect = [ window frame ];
	NSSize windowMaxSize = [ window maxSize ];
	NSSize windowMinSize = [ window minSize ];
	const float contentWidthMergin = 44.0;
	const float contentHeightMergin = 99.0;
	int i;
	
	//set height
	windowRect.size.height = ( ([ [scrollView documentView] rowHeight ]+4.0) * [ [scrollView documentView] numberOfRows ] ) + contentHeightMergin;
	
	windowRect.size.height = ( windowRect.size.height > windowMaxSize.height ) ? windowMaxSize.height-16.0 : windowRect.size.height;

	//set width 
/* for Ascii only Strings	
	contentSize = [[[[scrollView documentView] tableColumnWithIdentifier:@"name"] dataCell] cellSize];
*/
//	for 2byte letter Strings (e,g,Japanese)any size method of Cocoa, does not acquire size of a 2byte letter well for some reason. Why?
	contentSize = NSMakeSize( 0,0 );
	for (i=0 ; i < [ nh3dMenu count ] ; i++ ) {
		NH3DMenuItem *aMenuItem = [ [nh3dMenu objectAtIndex:i] retain ];
		unsigned len = [ [aMenuItem name]length ];
		strSize.width = len * ( NH3DINVFONTSIZE + 4.0 ) ;
		//strSize = [[nh3dMenu objectAtIndex:i] stringSize];  // fmm...  does not acquire size of a 2byte letter well, too.
		if ( strSize.width > contentSize.width ) {
			contentSize.width = strSize.width;
		}
		[ aMenuItem release ];
	}

	if ( contentSize.width > 640.0 ) {
		windowRect.size.width = 640.0;
	 
	} else if ( contentSize.width + contentWidthMergin < windowMinSize.width ) {
			windowRect.size.width = windowMinSize.width;
	} else {
		windowRect.size.width = contentSize.width + contentWidthMergin;
	}
	
	//set frame 
	[ window setFrame:windowRect display:NO ];
}



- (void)fitTextWindowSizeToContents:(id)window scrollView:(NSScrollView *)scrollView
{
	NSRect windowRect = [ window frame ];
	NSSize windowMaxSize = [ window maxSize ];
	NSSize windowMinSize = [ window minSize ];
	
	//reset size
	[ window setFrame:NSMakeRect( 0,0,windowMinSize.width, windowMinSize.height ) display:YES ];
	
	//set height
	while  ( [ [scrollView verticalScroller] usableParts ] != NSNoScrollerParts ) {
		windowRect = [ window frame ];
		if ( windowRect.size.height < windowMaxSize.height ) {
			 windowRect.size.height = windowRect.size.height+32.0;
			[ window setFrame:windowRect display:NO ];
		} else {
			windowRect.size.height = windowMaxSize.height-16;
			[ window setFrame:windowRect display:NO ];
			break;
		}
	}
}


- (void)keyDown:(NSEvent*)event
{
	int i;
	unichar key = [ [event charactersIgnoringModifiers] characterAtIndex:0 ];
	
	if (  ( key == NSEnterCharacter || key == NSCarriageReturnCharacter ) 
		  && ( pickType == PICK_NONE || [_menuTableWindow numberOfSelectedRows]) ) {
		[ _menuPanel  orderOut:self ];
		[ NSApp endSheet: _menuPanel ];
		[ NSApp stopModalWithCode:DIALOG_OK ];
		return;
	}
	
	if ( [ event keyCode ] == 53 ) {
		[ _menuPanel close ];
		[ NSApp endSheet: _menuPanel ];
		[ NSApp stopModalWithCode:DIALOG_CANCEL ]; 
		return; 
	}
	
	for ( i=0 ; i<[ nh3dMenu count ] ; i++ ) {
		
		if ( [ [event charactersIgnoringModifiers] isEqualToString:[[[nh3dMenu objectAtIndex:i] accelerator] string] ] ) {
			[ _menuTableWindow selectRow:i byExtendingSelection:NO ];
			
			if ( pickType == PICK_ONE ) {
				[ _menuPanel close ];
				[ NSApp endSheet: _menuPanel ];
				[ NSApp stopModalWithCode:DIALOG_OK ];
				return;
			} else { 
				return;
			}
		} 
	}
	NSBeep();
}


@end
