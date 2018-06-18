#import "NH3DPanel.h"
#import "NH3DMenuWindow.h"

@implementation NH3DPanel

- (instancetype)initWithContentRect:(NSRect)contentRect 
						  styleMask:(NSWindowStyleMask)aStyle
							backing:(NSBackingStoreType)bufferingType
							  defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect
							styleMask:NSWindowStyleMaskBorderless
							//styleMask:aStyle
							  backing:bufferingType
								defer:flag];
	
	if (self) {
		self.opaque = NO;
		self.backgroundColor = [NSColor clearColor];
	}
	
	return self;
}

/*
- (id)_compositedBackground
{
	return nil;
}

- (unsigned int)styleMask
{
	return NSBorderlessWindowMask;
}
*/


- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}


- (void)keyDown:(NSEvent*)event
{
	[(NH3DMenuWindow*)self.delegate keyDown:event];
}

//
/*
- (void)_orderFrontRelativeToWindow:(id)fp8
{
	//fp8 == NSWindow
	[[fp8 graphicsContext] setCompositingOperation:NSCompositeDestinationOver];
	[super _orderFrontRelativeToWindow:fp8];

}

- (void *)_sheetEffect
{

	void* effect = [super _sheetEffect];
		//_wFlags.showingModalFrame = 0;	
	return effect;
//	return nil;
}

- (BOOL)_hasMetalSheetEffect
{
	return NO;
}

- (void)_adjustSheetEffect
{
	return;
}

- (float)_sheetEffectInset
{
	return -500.0;
}
*/


@end
