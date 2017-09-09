//
//  NH3DTextureObject.m
//  NetHack3D
//
//  Created by C.W. Betts on 5/19/17.
//  Copyright © 2017 Haruumi Yoshino. All rights reserved.
//

#import "NH3DTextureObject.h"
#import "NSBitmapImageRep+NH3DAdditions.h"
#include <OpenGL/gl.h>

@implementation NH3DTextureObject
@synthesize texture;

- (instancetype)initWithURL:(NSURL*)aURL
{
	NSImage *sourceFile = [[NSImage alloc] initWithContentsOfURL:aURL];
	if (!sourceFile) {
		return nil;
	}
	NSBitmapImageRep *imgrep = [[NSBitmapImageRep alloc] initWithData:sourceFile.TIFFRepresentation];
	
	return [self initWithBitmapImageRep:imgrep];
}

- (instancetype)initWithBitmapImageRep:(NSBitmapImageRep*)preImgRep
{
	if (self = [super init]) {
		NSBitmapImageRep *imgrep = [preImgRep forceRGBColorSpace];
		
		if (!imgrep) {
			return nil;
		}
		
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		
		glGenTextures(1, &texture);
		glBindTexture(GL_TEXTURE_2D, texture);
		
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		
		// create automipmap texture
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
					 imgrep.pixelsWide, imgrep.pixelsHigh,
					 0, imgrep.alpha ? GL_RGBA : GL_RGB,
					 GL_UNSIGNED_BYTE, imgrep.bitmapData);

	}
	return self;
}

- (instancetype)initWithImageNamed:(NSString*)fileName
{
	NSImage	*sourcefile = [NSImage imageNamed:fileName];
	NSBitmapImageRep	*imgrep;
	
	if (sourcefile == nil) {
		sourcefile = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:fileName]];
		
		if (sourcefile == nil) {
			NSLog(@"texture file %@ was not found.",fileName);
			return nil;
		}
	}
	
	imgrep = [[NSBitmapImageRep alloc] initWithData:sourcefile.TIFFRepresentation];

	return [self initWithBitmapImageRep:imgrep];
}

- (nullable instancetype)initWithFilePath:(NSString*)path;
{
	return [self initWithURL:[NSURL fileURLWithPath:path]];
}

- (void)dealloc
{
	glDeleteTextures(1, &texture);
}

@end
