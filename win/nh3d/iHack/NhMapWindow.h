//
//  NhMapWindow.h
//  SlashEM
//
//  Created by dirk on 12/31/09.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation, version 2
 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import <Foundation/Foundation.h>

#import "NhWindow.h"

#include "hack.h"

#define kNoGlyph (-1)

@interface NhMapWindow : NhWindow {
	int *glyphs;

	xchar cursorX;
	xchar cursorY;
}

- (nonnull instancetype) initWithType:(int)t NS_DESIGNATED_INITIALIZER;
- (void) printGlyph:(int)glyph atX:(xchar)x y:(xchar)y;
- (int) glyphAtX:(xchar)x y:(xchar)y;
- (void)setCursX:(xchar)x y:(xchar)y;
- (void)getCursX:(xchar * __nullable)px y:(xchar * __nullable)py;
		
@end
