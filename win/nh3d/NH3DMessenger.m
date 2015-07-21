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

@interface NH3DMessenger ()
@property (retain) NSMutableDictionary *darkShadowStrAttributes;
@property (retain) NSMutableDictionary *lightShadowStrAttributes;
@property (retain) NSMutableParagraphStyle *style;
@end

@implementation NH3DMessenger
@synthesize darkShadowStrAttributes;
@synthesize lightShadowStrAttributes;
@synthesize style;

- (BOOL)loadSoundConfig
{
	@autoreleasepool {
	NSString *bundlePath = [ [NSBundle mainBundle] bundlePath ];
	NSString* configFile = [ NSString stringWithContentsOfFile:
						   [NSString stringWithFormat:@"%@/nh3dSounds/%@", [bundlePath stringByDeletingLastPathComponent],@"soundconfig.txt"]
													 encoding:NSUTF8StringEncoding
														error:nil ];
	NSString* destText = nil;
	NSScanner* scanner = nil;
	NSCharacterSet* chSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	
	if (configFile == nil) {
		return NO;
	} else
		
	scanner = [NSScanner scannerWithString:configFile];
	//[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
		
	while (![scanner isAtEnd]) {
		
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
	}
	return YES;
}


- (id)init
{
	if (self = [super init]) {
		//for view or backgrounded text field.
		darkShadow = [[NSShadow alloc] init];
		darkShadow.shadowColor = [NSColor colorWithCalibratedWhite:0.2 alpha:0.5];
		darkShadow.shadowOffset = NSMakeSize(2, -2);
		darkShadow.shadowBlurRadius = 0.5;
		//for panel or window.
		lightShadow = [[NSShadow alloc] init];
		lightShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
		lightShadow.shadowOffset = NSMakeSize(-1.5, 1.5);
		lightShadow.shadowBlurRadius = 1.6;
		
		msgArray = [[NSMutableArray alloc] init];
		soundMessageArray = [[NSMutableArray alloc] init];
		soundNameArray = [[NSMutableArray alloc] init];
		soundVolumeArray = [[NSMutableArray alloc] init];
		
		effectMessageArray = [[NSMutableArray alloc] init];
		effectTypeArray = [[NSMutableArray alloc] init];
		
		userSound = [self loadSoundConfig];
		ripFlag = NO;
		
		movieView  = [[QTMovieView alloc] init];
		
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
	[self prepareAttributes];
	_messeageWindow.drawsBackground = NO;
	_messeageScrollView.drawsBackground = NO;
}

- (void)prepareAttributes
{
	self.style = [[[NSMutableParagraphStyle alloc] init] autorelease];
	style.lineSpacing = -2;
	
	self.darkShadowStrAttributes = [[[NSMutableDictionary alloc] init] autorelease];
	self.lightShadowStrAttributes = [[[NSMutableDictionary alloc] init] autorelease];
	
	//Text attributes in View or backgrounded text field.
	
	darkShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DMSGFONT
																   size: NH3DMSGFONTSIZE];
	darkShadowStrAttributes[NSShadowAttributeName] = darkShadow;
	darkShadowStrAttributes[NSParagraphStyleAttributeName] = style;
	darkShadowStrAttributes[NSForegroundColorAttributeName] = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
	
	//Text attributes on Panel or Window.
	
	lightShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DWINDOWFONT
																	size: NH3DWINDOWFONTSIZE];
	lightShadowStrAttributes[NSShadowAttributeName] = lightShadow;
	lightShadowStrAttributes[NSParagraphStyleAttributeName] = style;
	lightShadowStrAttributes[NSForegroundColorAttributeName] = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
}


- (void)putMainMessarge:(int)attr text:(const char *)text
{	
	@autoreleasepool {
	NSMutableAttributedString* putString = nil;
	//NSTextStorage* windowString;
	int i=0;
			
	[self prepareAttributes];
	style.alignment = NSLeftTextAlignment;
	
	if ( !text ) {
		return;
	} else {
		
		if ( userSound && !SOUND_MUTE ) {
			NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
			QTMovie *playSound;
			NSURL      *soundURL;
			
			for ( NSString *msgSoundStr in soundMessageArray ) {
				
				if ( [ [NSString stringWithCString:text encoding:NH3DTEXTENCODING] isLike:msgSoundStr ] ) {
					
					soundURL  = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/nh3dSounds/%@",
																	[bundlePath stringByDeletingLastPathComponent],
																	[soundNameArray objectAtIndex:i]]];

					playSound = [[QTMovie alloc] initWithURL: soundURL error:NULL];
					
					[movieView setMovie:playSound];
					
					[playSound release];
					[soundURL release];
					
					[playSound setVolume:[[soundVolumeArray objectAtIndex:i] floatValue] * 0.01];
					
					//[ movieView  setVolume: [[soundVolumeArray objectAtIndex:i] floatValue] * 0.01 ];
					[movieView play: self];
					
					break;
				} else {
					i++;
				}
				
			}
			
			i = 0;
			for ( NSString *msgEffectStr in effectMessageArray ) {
				
				if ([[NSString stringWithCString:text encoding:NH3DTEXTENCODING] isLike:msgEffectStr] ) {
					
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
				darkShadowStrAttributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
				break;
			case ATR_BOLD:
				darkShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:NH3DBOLDFONT size: NH3DBOLDFONTSIZE];
				break;
			case ATR_BLINK:
			case ATR_INVERSE:
				darkShadowStrAttributes[NSForegroundColorAttributeName] = [NSColor alternateSelectedControlTextColor];
				darkShadowStrAttributes[NSBackgroundColorAttributeName] = [NSColor alternateSelectedControlColor];
		}
		
		putString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",
																	   [NSString stringWithCString:text
																						  encoding:NH3DTEXTENCODING]]
														   attributes:darkShadowStrAttributes ];

		
		if ([msgArray count] < iflags.msg_history) {
			 [msgArray addObject:@([putString length])];
		} else {
			[[_messeageWindow textStorage] deleteCharactersInRange:NSMakeRange(0,[[msgArray objectAtIndex:0] intValue])];
			[msgArray removeObjectAtIndex:0];
			[msgArray addObject:@([putString length])];
		}
				
		[[_messeageWindow textStorage] addAttribute:NSForegroundColorAttributeName
											   value:[NSColor colorWithCalibratedWhite:0.4 alpha:0.7]
											   range:NSMakeRange( 0,[[_messeageWindow textStorage] length])];
		
		[[_messeageWindow textStorage] appendAttributedString:putString];
		[putString release];
		
		[_messeageWindow scrollRangeToVisible:NSMakeRange([[_messeageWindow textStorage] length], 0)];
	
	}
	}
}


- (void)clearMainMessarge
{
	[msgArray removeAllObjects];
	_messeageWindow.string = @"";
}




- (int)showInputPanel:(const char *)messageStr line:(char *)line
{
	NSAttributedString *putString;
	NSString *questionStr = [[NSString alloc] initWithCString:messageStr encoding:NH3DTEXTENCODING];
	NSString *str;
	NSData *inputData;
	int result = 0;
		
	[ self prepareAttributes ];
	style.alignment = NSCenterTextAlignment;
	
	putString = [[NSAttributedString alloc] initWithString:questionStr
												attributes:lightShadowStrAttributes];
	
											   
	[ _questionTextField setAttributedStringValue:putString ];
	
	[NSApp beginSheet:_inputPanel
	   modalForWindow:_window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
	
	
	result = [NSApp runModalForWindow:_inputPanel];
		
	[NSApp endSheet:_inputPanel];
    [_inputPanel orderOut:self];
	
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
	
	if ( [ [_inputTextField stringValue] length ] > BUFSZ ) {
		
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
	
	[_questionTextField setStringValue:@""];
	[_inputTextField setStringValue:@""];
	[questionStr release];
	[putString release];
	[str release];
	
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
	ripFlag = YES;

	
	[self prepareAttributes];
	style.alignment = NSCenterTextAlignment;

	lightShadowStrAttributes[NSParagraphStyleAttributeName] = style;
	lightShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Optima Bold" size:11];
	

	[ _deathDescription setAttributedStringValue:
				[[[NSAttributedString alloc] initWithString:
								[NSString stringWithCString:ripString encoding:NH3DTEXTENCODING]
												 attributes:lightShadowStrAttributes] autorelease] ];
	
	_ripPanel.alphaValue = 0;
	[_ripPanel orderFront:self];
	// window fade out/in
	[NSAnimationContext beginGrouping];
	[NSAnimationContext currentContext].duration = 1.1;
	_window.animator.alphaValue = 0;
	_ripPanel.animator.alphaValue = 1;
	[NSAnimationContext endGrouping];
	
	[ _ripPanel flushWindow ];
}


- (void)putLogMessarge:(NSString *)rawText
{
	NSAttributedString *putStr = nil ;

#ifdef DEBUG
	NSLog(@" %@",rawText);
#endif
	[self prepareAttributes];
	style.alignment = NSLeftTextAlignment;
	
	lightShadowStrAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Courier Bold" size:12];
	
	putStr = [[NSAttributedString alloc] initWithString:rawText
											 attributes:lightShadowStrAttributes];
	
	_rawPrintWindow.editable = YES;
	[_rawPrintWindow.textStorage appendAttributedString:putStr];
	[_rawPrintWindow.textStorage appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
	_rawPrintWindow.editable = NO;
	NSLog(@"%@", rawText);
	
	[putStr release];
}

- (BOOL)showLogPanel
{
	NSWindow *ripOrMainWindow = nil;
	
	_rawPrintPanel.alphaValue = 0;
	[_rawPrintPanel makeKeyAndOrderFront:self];
	// window fade out/in
	
	if ( ripFlag ) {
		ripOrMainWindow = _ripPanel;
		[NSApp runModalForWindow:_ripPanel];
	} else {
		ripOrMainWindow = _window;
	}
	
	[NSAnimationContext beginGrouping];
	[NSAnimationContext currentContext].duration = 1.1;
	ripOrMainWindow.animator.alphaValue = 0;
	_rawPrintPanel.animator.alphaValue = 1;
	[NSAnimationContext endGrouping];
	
	[NSApp runModalForWindow:_rawPrintPanel];
	[_rawPrintPanel orderOut:self];
	
	return YES;
}

- (void)setLastAttackDirection:(int)direction
{
	lastAttackDirection = direction;
}


@end
