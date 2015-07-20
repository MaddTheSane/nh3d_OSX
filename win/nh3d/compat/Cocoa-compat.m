//
//  Cocoa-compat.m
//  NetHack3D
//
//  Created by Kiyotomo Ide on 05/12/31.
//  Copyright 2005 Kiyotomo Ide.
//

#import "hack.h"
#import <compat/Cocoa-compat.h>


NSString *NSShadowAttributeName = @"";
NSString *kCGDirectMainDisplay = @"";
NSStringDrawingOptions NSStringDrawingUsesDeviceMetrics = 0;
NSStringDrawingOptions NSMappedRead = 0;

// GNUStepだとNXArgc/NXArgvは規定されてないのかな？
int NXArgc;
char **NXArgv;


@implementation NSShadow
-(void) setShadowColor:(NSColor *)color{}
-(void) setShadowOffset:(NSSize )offset{}
-(void) setShadowBlurRadius:(float)val{}
-(void) set{}
@end

@implementation NSUserDefaultsController
+(id) sharedUserDefaultsController{return nil;}
-(NSDictionary *) initialValues{return nil;}
-(void) setInitialValues:(NSDictionary *)initialValues{}
-(id) values{return nil;}
@end

@implementation NSLevelIndicator
@end

//IDE	*.gmodel 読み込みでエラーとなったため追加
//	method の調査も必要
@implementation NSDrawerWindow
@end

@implementation NSNextStepFrame
@end

@implementation NSImageCacheView
@end



// ---------------------------------------

@implementation NSString (CocoaCompat)
+(id) stringWithCString:(const char *)cString encoding:(NSStringEncoding)encoding
{
	return [NSString stringWithCString:cString];
}

+(id) stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)encoding error:(NSError *)error
{
	error = nil;

	return [NSString stringWithContentsOfFile:path];
}

-(void) drawWithRect:(NSRect)rect
	     options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes
{
	[self drawInRect:rect withAttributes:attributes];
}

-(id) initWithCString:(const char *)cString encoding:(NSStringEncoding)encoding
{
	self = [self initWithCString:cString];

	return self;
}

-(const char *) cStringUsingEncoding:(NSStringEncoding)encoding
{
	return [self cString];
}

-(BOOL) isLike:(NSString *)object
{
	return pmatch([object cString], [self cString]);
}
@end

@implementation NSButtonCell (CocoaCompat)
- (void) setLineBreakMode: (NSLineBreakMode)mode{}
-(void) setControlView:(NSView*)view{}
@end

@implementation NSWindow (CocoaCompat)
-(NSWindow *) attachedSheet{return nil;}
-(void) setMovableByWindowBackground:(BOOL)flag{}
@end

@implementation NSPanel (CocoaCompat)
-(NSRect) frameRectForContentRect:(NSRect )contentRect{return contentRect;}
@end

@implementation NSApplication (CocoaCompat)
-(void) stopSpeaking:(id)sender{}
@end

@implementation NSBitmapImageRep (CocoaCompat)
-(void) getPixel:(unsigned int[])pixelData atX:(int)x y:(int)y
{
	unsigned char *img = [self bitmapData];
	int bytesPerRow = [self bytesPerRow];
	int bitsPerPixel= [self bitsPerPixel];
	unsigned int i, data = 0;

	img += ((x*bitsPerPixel)>>3) + y*bytesPerRow;

	for(i=0; i<bitsPerPixel; i+=8, img++) {
		data |= (((int)(*img))<<i);
	}

	pixelData[0] = (data >> ((x*bitsPerPixel) & 0x07)) & ((1<<(bitsPerPixel-1))-1);
}
-(void) setPixel:(unsigned int[])pixelData atX:(int)x y:(int)y
{
	unsigned char *img = [self bitmapData];
	int bytesPerRow = [self bytesPerRow];
	int bitsPerPixel= [self bitsPerPixel];
	unsigned int i, data;

	img += ((x*bitsPerPixel)>>3) + y*bytesPerRow;

	data = (*img) | ((*(img+1))<<8) | ((*(img+1))<<16) | ((*(img+1))<<24);
	data &= (((1<<(bitsPerPixel-1))-1)<<((x*bitsPerPixel) & 0x07));
	data |= ((pixelData[0])<<((x*bitsPerPixel) & 0x07));

	for(i=0; i<4; i++, img++, data >>= 8){
		*img = (data & 0xff);
	}
}
@end

@implementation NSData (CocoaCompat)
+(id) stringWithContentsOfFile:(NSString *)path options:(NSStringDrawingOptions)options error:(NSError *)error
{
	NSData *data = [[NSData alloc] initWithContentsOfFile:path options:options error:error];

	return data;
}

-(id) initWithContentsOfFile:(NSString *)path options:(NSStringDrawingOptions)options error:(NSError *)error
{
	self = [self initWithContentsOfFile:path];

	return self;
}
@end

@implementation NSAlert (CocoaCompat)
+(NSAlert *) alertWithError:(NSError *)error{return nil;}
@end









CFDictionaryRef CGDisplayCurrentMode(NSString* display)
{
	static CFDictionaryRef ref = nil;

	if (ref == nil)
		ref = (CFDictionaryRef)[[NSDictionary alloc] initWithObjectsAndKeys:@"60",@"RefreshRate",nil];

	return ref;
}
