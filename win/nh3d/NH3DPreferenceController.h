//
//  NH3DPreferenceController.h
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/12/26.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "NH3DUserDefaultsExtern.h"

@class NH3DBindController;

@interface NH3DPreferenceController : NSWindowController {
	
	NH3DBindController	*bindController;
	int					_fontButtonTag;

}

- (BOOL)windowShouldClose:(id)sender;
- (void)showPreferencePanel:(id)sender;

- (IBAction)showFontPanelAction:(id)sender;
- (IBAction)chooseTileFile:(id)sender;
- (IBAction)applyTileSettings:(id)sender;
- (IBAction)resetTileSettings:(id)sender;
- (IBAction)resetFontFamily:(id)sender;

@end
