//
//  NH3DTextureObject.h
//  NetHack3D
//
//  Created by C.W. Betts on 5/19/17.
//  Copyright © 2017 Haruumi Yoshino. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <OpenGL/gltypes.h>

NS_ASSUME_NONNULL_BEGIN

//! For shared OpenGL textures
@interface NH3DTextureObject : NSObject
@property (readonly) GLuint texture;

- (nullable instancetype)initWithBitmapImageRep:(NSBitmapImageRep*)imgRep NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithImageNamed:(NSImageName)named;
- (nullable instancetype)initWithURL:(NSURL*)aURL;
- (nullable instancetype)initWithFilePath:(NSString*)path;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
