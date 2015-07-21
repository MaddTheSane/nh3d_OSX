//
//  NH3DPreferenceController.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/12/26.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

#import "NH3DPreferenceController.h"
#import "winnh3d.h"


@implementation NH3DPreferenceController

- (id) init {
	self = [ super initWithWindowNibName:@"PreferencePanel" ];
	if (self != nil) {
		

	}
	return self;
}

- (BOOL)windowShouldClose:(id)sender
{
	
	[ bindController endPreferencePanel ];
	
	return YES;
}

- (void)showPreferencePanel:(id)sender
{
	bindController = sender;
	[[self window] makeKeyAndOrderFront:self];
}


- (void)changeFont:(id)sender
{
    // Convert font
	NSFont* font;
	NSFont* convertedFont;
	font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
	convertedFont = [sender convertFont:font];
	
    // Get preferences key
	NSString*   key = nil;
	NSString*	sizeKey = nil;

	switch ( _fontButtonTag ) {
		case 1:
			key = NH3DMsgFontKey;
			sizeKey = NH3DMsgFontSizeKey;
			break;
			
		case 2:
			key = NH3DWindowFontKey;
			sizeKey = NH3DWindowFontSizeKey;
			break;
			
		case 3:
			key = NH3DMapFontKey;
			sizeKey = NH3DMapFontSizeKey;
			break;
			
		case 4:
			key = NH3DBoldFontKey;
			sizeKey = NH3DBoldFontSizeKey;
			break;
			
		case 5:
			key = NH3DInventryFontKey;
			sizeKey = NH3DInventryFontSizeKey;
			break;
	}

	if (key == nil)
		return;
	
	[[NSUserDefaults standardUserDefaults] setObject:[convertedFont fontName] forKey:key];
	[[NSUserDefaults standardUserDefaults] setFloat:[convertedFont pointSize] forKey:sizeKey];
}


- (IBAction)showFontPanelAction:(id)sender
{
	
	NSString	*key = nil;
	NSString	*familyName = nil;
	_fontButtonTag = [ sender selectedTag ];
	
	switch (_fontButtonTag) {
		case 1:
			key = NH3DMsgFontKey;
			break;
			
		case 2:
			key = NH3DWindowFontKey;
			break;
			
		case 3:
			key = NH3DMapFontKey;
			break;
			
		case 4:
			key = NH3DBoldFontKey;
			break;
			
		case 5:
			key = NH3DInventryFontKey;
			break;
	}
	
	//NSLog(key);
	
	if (key == nil)
		return;
       
	familyName = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	
	//NSLog(familyName);

    // Set font font manager
    NSFontManager*  fontMgr;
    fontMgr = [NSFontManager sharedFontManager];
	[fontMgr setSelectedFont:[NSFont fontWithName:familyName size:[NSFont systemFontSize]] isMultiple:NO];
    [fontMgr setDelegate:self];
	
    // Shoe font panel
	NSFontPanel*	fontPanel;
	fontPanel = [NSFontPanel sharedFontPanel];
	if (!fontPanel.visible) {
		[fontPanel orderFront:self];
	}
	[[self window] makeFirstResponder:nil];
}


- (IBAction)resetFontFamily:(id)sender
{
	NSDictionary *initialValues = [ [NSUserDefaultsController sharedUserDefaultsController] initialValues ];
	
	[[NSUserDefaults standardUserDefaults] setObject:[initialValues objectForKey:NH3DMsgFontKey]
											  forKey:NH3DMsgFontKey];
	[[NSUserDefaults standardUserDefaults] setObject:[initialValues objectForKey:NH3DMapFontKey]
											  forKey:NH3DMapFontKey];
	[[NSUserDefaults standardUserDefaults] setObject:[initialValues objectForKey:NH3DBoldFontKey]
											  forKey:NH3DBoldFontKey];
	[[NSUserDefaults standardUserDefaults] setObject:[initialValues objectForKey:NH3DWindowFontKey]
											  forKey:NH3DWindowFontKey];
	[[NSUserDefaults standardUserDefaults] setObject:[initialValues objectForKey:NH3DInventryFontKey]
											  forKey:NH3DInventryFontKey];
	
	
	[[NSUserDefaults standardUserDefaults] setFloat:[[initialValues objectForKey:NH3DMsgFontSizeKey] floatValue]
											 forKey:NH3DMsgFontSizeKey];
	[[NSUserDefaults standardUserDefaults] setFloat:[[initialValues objectForKey:NH3DMapFontSizeKey] floatValue]
											 forKey:NH3DMapFontSizeKey];
	[[NSUserDefaults standardUserDefaults] setFloat:[[initialValues objectForKey:NH3DBoldFontSizeKey] floatValue]
											 forKey:NH3DBoldFontSizeKey];
	[[NSUserDefaults standardUserDefaults] setFloat:[[initialValues objectForKey:NH3DWindowFontSizeKey] floatValue]
											 forKey:NH3DWindowFontSizeKey];
	[[NSUserDefaults standardUserDefaults] setFloat:[[initialValues objectForKey:NH3DInventryFontSizeKey] floatValue]
											 forKey:NH3DInventryFontSizeKey];
}


- (IBAction)chooseTileFile:(id)sender
{
	NSOpenPanel* openPanel;
	//NSArray *fileTypes = [ NSArray arrayWithObjects:@"jpg",@"jpeg",@"png",@"tiff",@"tif",@"gif",@"bmp",nil ];
	//NSArray *fileTypes = [ NSArray arrayWithObjects:@"tiff",@"tif",nil ];
	
	openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	openPanel.allowedFileTypes = [NSImage imageTypes];
	openPanel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
	NSInteger result = [openPanel runModal];
	if (result == NSFileHandlingPanelOKButton) {
		[[NSUserDefaults standardUserDefaults] setObject:[[openPanel URL] path] forKey:NH3DTileNameKey];
	}
}


- (IBAction)resetTileSettings:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:@"nhtiles.tiff" forKey:NH3DTileNameKey];
	[[NSUserDefaults standardUserDefaults] setObject:@(16) forKey:NH3DTileSizeWidthKey];
	[[NSUserDefaults standardUserDefaults] setObject:@(16) forKey:NH3DTileSizeHeightKey];
	[[NSUserDefaults standardUserDefaults] setObject:@(40) forKey:NH3DTilesPerLineKey];
	[[NSUserDefaults standardUserDefaults] setObject:@(30) forKey:NH3DNumberOfTilesRowKey];
}


- (IBAction)applyTileSettings:(id)sender;
{
	[bindController setTile];
}


@end
