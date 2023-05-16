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
#import <GLKit/GLKTextureLoader.h>

@implementation NH3DTextureObject
@synthesize texture;

- (void)loadFromTextureInfo:(GLKTextureInfo*)texInfo
{
	texture = texInfo.name;
	
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
}

- (instancetype)initWithURL:(NSURL*)aURL
{
	if (self = [super init]) {
		GLKTextureInfo *texInfo = [GLKTextureLoader textureWithContentsOfURL:aURL options:@{GLKTextureLoaderGenerateMipmaps: @YES} error:nil];
		if (!texInfo) {
			return nil;
		}
		[self loadFromTextureInfo:texInfo];
	}
	return self;
}

- (instancetype)initWithImageNamed:(NSString*)fileName
{
	if (self = [super init]) {
		NSError *err = nil;
		GLKTextureInfo *texInfo = [GLKTextureLoader textureWithName:fileName scaleFactor:1 bundle:[NSBundle mainBundle] options:@{GLKTextureLoaderGenerateMipmaps: @YES} error:&err];
		if (!texInfo) {
//			NSLog(@"%@", err);
			NSImage	*sourcefile = [NSImage imageNamed:fileName];
			
			if (sourcefile == nil) {
				sourcefile = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:fileName]];
				
				if (sourcefile == nil) {
					NSLog(@"texture file %@ was not found.",fileName);
					return nil;
				}
			}
			
			err = nil;
			GLKTextureInfo *texInfo = [GLKTextureLoader textureWithContentsOfData:sourcefile.TIFFRepresentation options:@{GLKTextureLoaderGenerateMipmaps: @YES} error:&err];
			
			if (!texInfo) {
				NSLog(@"%@", err);
				return nil;
			}
			[self loadFromTextureInfo:texInfo];
			return self;
		}
		[self loadFromTextureInfo:texInfo];
	}
	return self;
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
