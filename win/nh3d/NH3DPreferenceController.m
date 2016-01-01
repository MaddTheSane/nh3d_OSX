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

- (instancetype) init {
	self = [super initWithWindowNibName:@"PreferencePanel"];
	if (self != nil) {
		

	}
	return self;
}

- (BOOL)windowShouldClose:(id)sender
{
	[bindController endPreferencePanel];
	
	return YES;
}

- (void)showPreferencePanel:(NH3DBindController*)sender
{
	bindController = sender;
	[self.window makeKeyAndOrderFront:self];
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
	
	[[NSUserDefaults standardUserDefaults] setObject:convertedFont.fontName forKey:key];
	[[NSUserDefaults standardUserDefaults] setFloat:convertedFont.pointSize forKey:sizeKey];
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
    fontMgr.delegate = self;
	
    // Shoe font panel
	NSFontPanel*	fontPanel;
	fontPanel = [NSFontPanel sharedFontPanel];
	if (!fontPanel.visible) {
		[fontPanel orderFront:self];
	}
	[self.window makeFirstResponder:nil];
}

- (IBAction)resetFontFamily:(id)sender
{
	NSDictionary *initialValues = [NSUserDefaultsController sharedUserDefaultsController].initialValues;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:initialValues[NH3DMsgFontKey]
				 forKey:NH3DMsgFontKey];
	[defaults setObject:initialValues[NH3DMapFontKey]
				 forKey:NH3DMapFontKey];
	[defaults setObject:initialValues[NH3DBoldFontKey]
				 forKey:NH3DBoldFontKey];
	[defaults setObject:initialValues[NH3DWindowFontKey]
				 forKey:NH3DWindowFontKey];
	[defaults setObject:initialValues[NH3DInventryFontKey]
				 forKey:NH3DInventryFontKey];
	
	
	[defaults setObject:initialValues[NH3DMsgFontSizeKey]
				 forKey:NH3DMsgFontSizeKey];
	[defaults setObject:initialValues[NH3DMapFontSizeKey]
				 forKey:NH3DMapFontSizeKey];
	[defaults setObject:initialValues[NH3DBoldFontSizeKey]
				 forKey:NH3DBoldFontSizeKey];
	[defaults setObject:initialValues[NH3DWindowFontSizeKey]
				 forKey:NH3DWindowFontSizeKey];
	[defaults setObject:initialValues[NH3DInventryFontSizeKey]
				 forKey:NH3DInventryFontSizeKey];
}

- (IBAction)chooseTileFile:(id)sender
{
	NSOpenPanel* openPanel;
	
	openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseDirectories = NO;
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = [NSImage imageTypes];
	openPanel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
	NSInteger result = [openPanel runModal];
	if (result == NSFileHandlingPanelOKButton) {
		[[NSUserDefaults standardUserDefaults] setObject:openPanel.URL.path forKey:NH3DTileNameKey];
	}
}

- (IBAction)resetTileSettings:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"nhtiles.tiff" forKey:NH3DTileNameKey];
	[defaults setInteger:16 forKey:NH3DTileSizeWidthKey];
	[defaults setInteger:16 forKey:NH3DTileSizeHeightKey];
	[defaults setInteger:40 forKey:NH3DTilesPerLineKey];
	[defaults setInteger:30 forKey:NH3DNumberOfTilesRowKey];
}

- (IBAction)applyTileSettings:(id)sender;
{
	[bindController setTile];
}

@end
