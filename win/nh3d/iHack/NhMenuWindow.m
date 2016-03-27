//
//  NhMenuWindow.m
//  SlashEM
//
//  Created by dirk on 1/4/10.
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

#import "NhMenuWindow.h"
#import "NhItemGroup.h"
#import "NSIndexPath+Z.h"

@implementation NhMenuWindow

@synthesize how;
@synthesize itemGroups;
@synthesize selected;
@synthesize prompt;

- (instancetype) initWithType:(int)t {
	if (self = [super initWithType:t]) {
	}
	return self;
}

- (void) addItemGroup:(NhItemGroup *)g {
	[itemGroups addObject:g];
	currentItemGroup = g;
}

- (NhItemGroup *) currentItemGroup {
	if (!currentItemGroup) {
		NhItemGroup *g = [[NhItemGroup alloc] initWithTitle:@"All" dummy:YES];
		[itemGroups addObject:g];
		currentItemGroup = g;
	}
	return currentItemGroup;
}

- (NhItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
	NhItemGroup *g = itemGroups[indexPath.section];
	NhItem *i = (g.items)[indexPath.row];
	return i;
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
	if ( indexPath.length == 1 ) {
		// remove a group
		[itemGroups removeObjectAtIndex:indexPath.section];
	} else {
		// remove an item in a group
		NhItemGroup *g = itemGroups[indexPath.section];
		[g removeItemAtIndex:indexPath.row];
	}
}

- (void)startMenu {
	currentItemGroup = nil;
	itemGroups = [[NSMutableArray alloc] init];
	selected = [[NSMutableArray alloc] init];
}


-(char)runModal
{
	NSString * text = self.text;
	if ( text.length ) {
		NSAlert * alert = [NSAlert alertWithMessageText:text defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
		return [alert runModal];
	}
	// cancelled
	return 0;
}

@end
