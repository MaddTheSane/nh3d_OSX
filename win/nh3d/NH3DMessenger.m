//
//  NH3DMessenger.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//



#import "NH3DMessenger.h"
#import "NH3DOpenGLView.h"

static const int DIALOG_OK		= 128;
static const int DIALOG_CANCEL	= 129;

@implementation NH3DMessenger


- (BOOL)loadSoundConfig
{
	NSAutoreleasePool *pool = [ [NSAutoreleasePool alloc] init ];
	NSString *bundlePath = [ [NSBundle mainBundle] bundlePath ];
	NSString* configFile = [ NSString stringWithContentsOfFile:
						   [NSString stringWithFormat:@"%@/nh3dSounds/%@", [bundlePath stringByDeletingLastPathComponent],@"soundconfig.txt"]
													 encoding:NSUTF8StringEncoding
														error:nil ];
	NSString* destText;
	NSScanner* scanner ;
	NSCharacterSet* chSet = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
	
	
	if (configFile == nil) {
		[ pool release ];
		return NO;
	} else
		
	scanner = [NSScanner scannerWithString:configFile];
	//[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
		
	while(![ scanner isAtEnd ]) {
		
		[ scanner scanUpToCharactersFromSet:chSet intoString:&destText ];
		
		if ([ destText isEqualToString:@"SOUND=MESG" ]) {
			[ scanner scanUpToCharactersFromSet:chSet intoString:&destText ];
			[ soundMessageArray addObject:[destText description] ];
			
			[ scanner scanUpToCharactersFromSet:chSet intoString:&destText ];
			[ soundNameArray addObject:[destText description] ];
			
			[ scanner scanUpToCharactersFromSet:chSet intoString:&destText ];
			[ soundVolumeArray addObject:[destText description] ];
			
			//NSLog(@" %@ , %@ , %d",[soundMessageArray lastObject],[soundNameArray lastObject],[[soundVolumeArray lastObject] intValue]);
		} else if ([destText isEqualToString:@"EFFECT=MESG" ]) {
			[ scanner scanUpToCharactersFromSet:chSet intoString:&destText ];
			[ effectMessageArray addObject:[destText description] ];
			
			[ scanner scanUpToCharactersFromSet:chSet intoString:&destText ];
			[ effectTypeArray addObject:[destText description] ];

		}

	}
	
	[scanner scanCharactersFromSet:chSet intoString:nil];
	
	[ destText release ];
	[ pool release ];
	return YES;
}


- (id)init
{
		self = [ super init ];
	if (self != nil) {
		//for view or backgrounded text field.
		darkShadow = [ [NSShadow alloc] init ];
			[ darkShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0.5] ];
            [ darkShadow setShadowOffset:NSMakeSize(2, -2) ];
            [ darkShadow setShadowBlurRadius:0.5 ];
		//for panel or window.
		lightShadow = [[NSShadow alloc] init];
			[ lightShadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] ];
            [ lightShadow setShadowOffset:NSMakeSize(-1.5, 1.5) ];
            [ lightShadow setShadowBlurRadius:1.6 ];
		
		msgArray = [ [NSMutableArray alloc] init ];
		soundMessageArray = [ [NSMutableArray alloc] init ];
		soundNameArray = [ [NSMutableArray alloc] init ];
		soundVolumeArray = [ [NSMutableArray alloc] init ];
		
		effectMessageArray = [ [NSMutableArray alloc] init ];
		effectTypeArray = [ [NSMutableArray alloc] init ];

		userSound = [ self loadSoundConfig ];
		ripFlag = NO;
		
		movieView  = [ [NSMovieView alloc] init ];
		
	}
		return self;
}


- (void)dealloc
{
	[ msgArray release ];
	[ soundMessageArray release ];
	[ soundNameArray release ];
	[ soundVolumeArray release ];

	[ effectMessageArray release ];
	[ effectTypeArray release ];
	[ darkShadowStrAttributes release ];
	[ lightShadowStrAttributes release ];
	[ darkShadow release ];
	[ lightShadow release ];
	[ style release ];
	[ movieView release ];
	[ super dealloc ];
}

- (void)awakeFromNib 
{
	[ self prepareAttributes ];
	[ _messeageWindow setDrawsBackground:NO ];
	[ _messeageScrollView setDrawsBackground:NO ];
}

- (void)prepareAttributes
{

	
	style = [ [[NSMutableParagraphStyle alloc] init] autorelease ];
	[ style setLineSpacing:-2 ];
	
	darkShadowStrAttributes = [ [[NSMutableDictionary alloc] init] autorelease ];
	lightShadowStrAttributes = [ [[NSMutableDictionary alloc] init] autorelease ];
	
	//Text attributes in View or backgrounded text field.
	
	[ darkShadowStrAttributes setObject:[NSFont fontWithName:NH3DMSGFONT
													   size: NH3DMSGFONTSIZE ]
								 forKey:NSFontAttributeName ];
	[ darkShadowStrAttributes setObject:darkShadow
								 forKey:NSShadowAttributeName ];
	[ darkShadowStrAttributes setObject:style
								 forKey:NSParagraphStyleAttributeName ];
	[ darkShadowStrAttributes setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.8]
								 forKey:NSForegroundColorAttributeName ];
	
	//Text attributes on Panel or Window.
	
	[ lightShadowStrAttributes setObject:[NSFont fontWithName:NH3DWINDOWFONT
														 size: NH3DWINDOWFONTSIZE]
								  forKey:NSFontAttributeName ];
	[ lightShadowStrAttributes setObject:lightShadow
								  forKey:NSShadowAttributeName ];
	[ lightShadowStrAttributes setObject:style
								  forKey:NSParagraphStyleAttributeName ];
	[ lightShadowStrAttributes setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.8]
								  forKey:NSForegroundColorAttributeName ];
	

}


- (void)putMainMessarge:(int)attr:(const char *)text
{	
	NSAutoreleasePool *pool = [ [NSAutoreleasePool alloc] init ];
	NSMutableAttributedString* putString = nil;
	//NSTextStorage* windowString;
	int i=0;
			
	[ self prepareAttributes ];
	[ style setAlignment:NSLeftTextAlignment] ;
	
	if ( !text ) {
		[ pool release ];
		return ;
	} else {
		
		if ( userSound && !SOUND_MUTE ) {
			NSString *msgSoundStr = nil;
			NSString *msgEffectStr = nil;
			NSString *bundlePath = [ [NSBundle mainBundle] bundlePath ];
			NSEnumerator *msgSoundEnum = [ soundMessageArray objectEnumerator ];
			NSEnumerator *msgEffectEnum = [ effectMessageArray objectEnumerator ];
			NSMovie *playSound;
			NSURL      *soundURL;
			
			while ( msgSoundStr = [ msgSoundEnum nextObject ] ) {
				
				if ( [ [NSString stringWithCString:text encoding:NH3DTEXTENCODING] isLike:msgSoundStr ] ) {
					
					soundURL  = [ [NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/nh3dSounds/%@",
																	[bundlePath stringByDeletingLastPathComponent],
																	[soundNameArray objectAtIndex:i]] ];

					playSound = [ [NSMovie alloc] initWithURL: soundURL byReference: YES ];
					
					[ movieView setMovie:playSound ];
					
					[ playSound release ];
					[ soundURL release ];
					
					[ movieView  setVolume: [[soundVolumeArray objectAtIndex:i] floatValue] * 0.01 ];
					[ movieView  start: self ];
					
					break;
				} else {
					i++;
				}
				
			}
			
			i = 0;
			while ( msgEffectStr = [ msgEffectEnum nextObject ] ) {
				
				if ( [ [NSString stringWithCString:text encoding:NH3DTEXTENCODING] isLike:msgEffectStr ] ) {
					
					switch ( [ [effectTypeArray objectAtIndex:i] intValue ] ) {
					case 1: // hit enemy attack to player
						[ _glView setIsShocked:YES ];
						break;
					case 2: // hit player attack to enemy
						[ _glView setEnemyPosition:lastAttackDirection ];
						break;
						
					default:
						break;
					}
				
				} else {
					i++;
				}
				
			}
		}
		
		switch ( attr )
		{
			case ATR_NONE:
				break;
			case ATR_ULINE:
				[ darkShadowStrAttributes setObject:[NSNumber numberWithInt:1]
											 forKey:NSUnderlineStyleAttributeName ];
				break;
			case ATR_BOLD:
				[ darkShadowStrAttributes setObject:[NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE]
											 forKey:NSFontAttributeName ];
				break;
			case ATR_BLINK:
			case ATR_INVERSE:
				[ darkShadowStrAttributes setObject:[NSColor alternateSelectedControlTextColor]
											 forKey:NSForegroundColorAttributeName ];
				[darkShadowStrAttributes setObject:[NSColor alternateSelectedControlColor]
											forKey:NSBackgroundColorAttributeName ];
		}
		
		putString = [ [NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",
																			[NSString stringWithCString:text
																							   encoding:NH3DTEXTENCODING]]
														   attributes:darkShadowStrAttributes ];

		
		if ( [ msgArray count ] < iflags.msg_history ) {
			 [ msgArray addObject:[NSNumber numberWithInt:[putString length]] ];
		} else {
			[ [_messeageWindow textStorage] deleteCharactersInRange:NSMakeRange(0,[[msgArray objectAtIndex:0] intValue]) ];
			[ msgArray removeObjectAtIndex:0 ];
			[ msgArray addObject:[NSNumber numberWithInt:[putString length]] ];
		}
				
		[ [_messeageWindow textStorage] addAttribute:NSForegroundColorAttributeName
											   value:[NSColor colorWithCalibratedWhite:0.4 alpha:0.7]
											   range:NSMakeRange( 0,[[_messeageWindow textStorage] length]) ];
		
		[ [_messeageWindow textStorage] appendAttributedString:putString ];
		[ putString release ];
		
		[ _messeageWindow scrollRangeToVisible:NSMakeRange([[_messeageWindow textStorage] length], 0) ];
	
		[ pool release ];
	}
}


- (void)clearMainMessarge
{
	[ msgArray removeAllObjects ];
	[ _messeageWindow setString:@"" ];
}




- (int)showInputPanel:(const char *)messageStr:(char *)line
{
	NSAttributedString *putString;
	NSString *questionStr = [ [NSString alloc] initWithCString:messageStr encoding:NH3DTEXTENCODING ];
	NSString *str;
	NSData *inputData;
	int result = 0;
		
	[ self prepareAttributes ];
	[ style setAlignment:NSCenterTextAlignment ];
	
	putString = [ [NSAttributedString alloc] initWithString:questionStr
												 attributes:lightShadowStrAttributes ];
	
											   
	[ _questionTextField setAttributedStringValue:putString ];
	
	[ NSApp beginSheet:_inputPanel
		modalForWindow:_window
		 modalDelegate:nil
		didEndSelector:nil
		   contextInfo:nil ];
	
	
	result = [ NSApp runModalForWindow:_inputPanel ];
		
	[ NSApp endSheet:_inputPanel ];
    [ _inputPanel orderOut:self ];
	
	if ( result == DIALOG_CANCEL )
	{
		[ _questionTextField setStringValue:@"" ];
		[ _inputTextField setStringValue:@"" ];
		[ questionStr release ];
		[ putString release ];
		return -1;
	}
	if ( ![ _inputTextField stringValue ] )
	{
		[ _questionTextField setStringValue:@"" ];
		[ questionStr release ];
		[ putString release ];
		return -1;
	}
	
	if ( [ [_inputTextField stringValue] cStringLength ] > BUFSZ ) {
		
		NSRunAlertPanel( NSLocalizedString(@"There is too much number of the letters.",@""), 
						@" ", 
						@"OK", 
						nil,nil,nil );
		[ _questionTextField setStringValue:@"" ];
		[ _inputTextField setStringValue:@"" ];
		[ questionStr release ];
		[ putString release ];
		return -1;
	}
			
	inputData = [ [_inputTextField stringValue] dataUsingEncoding:NH3DTEXTENCODING allowLossyConversion:YES ];
	str = [ [NSString alloc] initWithData:inputData encoding:NH3DTEXTENCODING ];
	
	Strcpy( line,[ str cStringUsingEncoding:NH3DTEXTENCODING ] );
	
	[ _questionTextField setStringValue:@"" ];
	[ _inputTextField setStringValue:@"" ];
	[ questionStr release ];
	[ putString release ];
	[ str release ];
	
	return 0;
		
}

- (IBAction)closeInputPanel:(id)sender
{
	if ( ![ sender tag ] )
		{
			[ NSApp stopModalWithCode:DIALOG_OK ];
		} else { 
			[ NSApp stopModalWithCode:DIALOG_CANCEL ];
		}
}


- (void)showOutRip:(const char *)ripString
{
	int i;
	
	ripFlag = YES;

	
	[ self prepareAttributes ];
	[ style setAlignment:NSCenterTextAlignment ];

	[ lightShadowStrAttributes setObject:style
								  forKey:NSParagraphStyleAttributeName ];
	[ lightShadowStrAttributes setObject:[NSFont fontWithName:@"Optima Bold" size:11] 
								  forKey:NSFontAttributeName ];
		

	[ _deathDescription setAttributedStringValue:
				[[[NSAttributedString alloc] initWithString:
								[NSString stringWithCString:ripString encoding:NH3DTEXTENCODING]
												 attributes:lightShadowStrAttributes] autorelease] ];
	
	[ _ripPanel setAlphaValue:0 ];
	[ _ripPanel orderFront:self ];
	// window fade out/in 
	for ( i=10 ; i>=0 ; i-- ) {
		[ _window setAlphaValue: i*0.1 ];
		[ _ripPanel setAlphaValue: (i-10)*-0.1 ];
		[ NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1] ]; 
	}
	[ _ripPanel flushWindow ];
}


- (void)putLogMessarge:(NSString *)rawText
{
	NSAttributedString *putStr = nil ;

#ifdef DEBUG
	NSLog(@" %@",rawText);
#endif
	[ self prepareAttributes ];
	[ style setAlignment:NSLeftTextAlignment ];
	
	
	[ lightShadowStrAttributes setObject:[NSFont fontWithName:@"Courier Bold" size:12]
								  forKey:NSFontAttributeName ];
		
	putStr = [ [NSAttributedString alloc] initWithString:rawText
											   attributes:lightShadowStrAttributes ];
		
	[ _rawPrintWindow setEditable:YES ];
	[ _rawPrintWindow insertText:putStr ];
	[ _rawPrintWindow insertText:@"\n" ];
	[ _rawPrintWindow setEditable:NO ];
	
	[ putStr release ];

}

- (BOOL)showLogPanel
{
	int i;
	id ripOrMainWindow = nil;
	
	[ _rawPrintPanel setAlphaValue:0 ];
	[ _rawPrintPanel makeKeyAndOrderFront:self ];
	// window fade out/in 
	
	if ( ripFlag ) {
		ripOrMainWindow = _ripPanel;
		[ NSApp runModalForWindow:_ripPanel ];
	} else {
		ripOrMainWindow = _window;
	}
		
		for ( i=10 ; i>=0 ; i-- ) {
			[ ripOrMainWindow setAlphaValue: i*0.1 ];
			[ _rawPrintPanel setAlphaValue: (i-10)*-0.1 ];
			[ NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1] ]; 
		}

	[ NSApp runModalForWindow:_rawPrintPanel ];
	[ _rawPrintPanel orderOut:self ];
	
	return YES;

}

- (void)setLastAttackDirection:(int)direction
{
	lastAttackDirection = direction;
}


@end
