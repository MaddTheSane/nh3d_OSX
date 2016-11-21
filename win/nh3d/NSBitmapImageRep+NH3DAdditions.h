//
//  NSBitmapImageRep+NH3DAdditions.h
//  NetHack3D
//
//  Created by C.W. Betts on 11/21/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBitmapImageRep (NH3DAdditions)

- (nonnull NSBitmapImageRep*)forceRGBColorSpace;

@end
