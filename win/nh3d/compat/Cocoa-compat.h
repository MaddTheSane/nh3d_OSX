//
//  Cocoa-compat.h
//  NetHack3D
//
//  Created by Kiyotomo Ide on 05/12/22.
//  Copyright 2005 Kiyotomo Ide.
//

#import <Foundation/NSString.h>
#import <Foundation/Foundation.h>

#import <AppKit/AppKit.h>
#import <AppKit/NSStringDrawing.h>
#import <AppKit/NSOpenGL.h>
#import <AppKit/NSOpenGLView.h>
#import <AppKit/NSMovie.h>
#import <AppKit/NSMovieView.h>
#import <AppKit/NSAlert.h>
#import <GNUstepGUI/GSHbox.h>
#import <GNUstepGUI/GSVbox.h>

typedef float CGRefreshRate;
typedef int NSStringDrawingOptions;
typedef NSDictionary * CFDictionaryRef;


//hal	NSShadowは文字の装飾用に使ってるだけなので無理して実装することもないかもしれないです。
//		ちょっぴり見づらくなるかもしれませんが・・・
@interface NSShadow : NSObject <NSCopying, NSCoding> {
    /*All instance variables are private*/
//    unsigned int _shadowFlags;
//    NSSize _shadowOffset;
//    float _shadowBlurRadius;
//    NSColor *_shadowColor;
//    float _reservedFloat[3];
//    void *_reserved;
}
//@interface NSShadow : NSView
-(void) setShadowColor:(NSColor *)color;
-(void) setShadowOffset:(NSSize )offset;
-(void) setShadowBlurRadius:(float)val;
-(void) set;
@end

//hal	NSControllerクラスがないっぽいので、Cocoa-Bindingがらみのところは全部
//		自前でコントローラを書く必要があるかもしれません。
//@interface NSUserDefaultsController : NSController {
@interface NSUserDefaultsController : NSObject {
	@private
	void *_reserved3;
	void *_reserved4;
    NSUserDefaults *_defaults;
    NSMutableDictionary *_valueBuffer;
    NSDictionary *_initialValues;
    struct __userDefaultsControllerFlags {
        unsigned int _sharedInstance:1;
        unsigned int _appliesImmediately:1;
        unsigned int _reservedUserDefaultsController:30;
    } _userDefaultsControllerFlags;
}

//@interface NSUserDefaultsController : NSWindowController
+ (NSUserDefaults *)standardUserDefaults;
//+(id) sharedUserDefaultsController;
-(NSDictionary *) initialValues;
-(void) setInitialValues:(NSDictionary *)initialValues;
-(id) values;
@end

//hal	10.4から標準になったレベル表示インジケータです。
//		HP表示用とレーダーに使われていますが、これも表示方法次第なので後回しにできるかも。
@interface NSLevelIndicator : NSControl
@end

//IDE	*.gmodel 読み込みでエラーとなったため追加
//	super class, method の調査も必要
@interface NSDrawerWindow : NSWindow
@end

@interface NSNextStepFrame : NSObject
@end

@interface NSImageCacheView : NSObject
@end


// ---------------------------------------

//hal	エンコーディングがらみのものは、GNUStepのリファレンス見た限りでは実装されているようです。
//		日本語環境にするとそのまま使えるようになりそうな気がします。

@interface NSString (CocoaCompat)
+(id) stringWithCString:(const char *)cString encoding:(NSStringEncoding)encoding;
+(id) stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)encoding error:(NSError *)error;

-(void) drawWithRect:(NSRect)rect
	options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes;
-(id) initWithCString:(const char *)cString encoding:(NSStringEncoding)encoding;
-(const char *) cStringUsingEncoding:(NSStringEncoding)encoding;
-(BOOL) isLike:(NSString *)object;
@end

@interface NSButtonCell (CocoaCompat)
- (void) setLineBreakMode: (NSLineBreakMode)mode;
-(void) setControlView:(NSView*)view;
@end

@interface NSWindow (CocoaCompat)
//hal	Sheetは、GnuStepではメソッドはあるけど未実装で普通のパネルになるようです。
-(NSWindow *) attachedSheet;
-(void) setMovableByWindowBackground:(BOOL)flag;
@end

@interface NSPanel (CocoaCompat)
-(NSRect) frameRectForContentRect:(NSRect )contentRect;
@end

//hal	これは音声合成用なので、未実装でもいいかもしれません。OSX版でも英語テキストしかしゃべれませんし。
@interface NSApplication (CocoaCompat)
-(void) stopSpeaking:(id)sender;
@end

@interface NSBitmapImageRep (CocoaCompat)
-(void) getPixel:(unsigned int[])pixelData atX:(int)x y:(int)y;
-(void) setPixel:(unsigned int[])pixelData atX:(int)x y:(int)y;
@end

@interface NSData (CocoaCompat)
+(id) stringWithContentsOfFile:(NSString *)path options:(NSStringDrawingOptions)options error:(NSError *)error;
-(id) initWithContentsOfFile:(NSString *)path options:(NSStringDrawingOptions)options error:(NSError *)error;
@end

@interface NSAlert (CocoaCompat)
+(NSAlert *) alertWithError:(NSError *)error;
@end




extern NSString *NSShadowAttributeName;
extern NSString *kCGDirectMainDisplay;
extern NSStringDrawingOptions NSStringDrawingUsesDeviceMetrics;
extern NSStringDrawingOptions NSMappedRead;


#define NSRecessedBezelStyle NSRegularSquareBezelStyle



CFDictionaryRef CGDisplayCurrentMode(NSString*);
