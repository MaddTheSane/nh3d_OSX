//
//  Action.m
//  NetHack
//
//  Created by dirk on 2/4/10.
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

#import "Action.h"
#import "ARCBridge.h"

@implementation Action

@synthesize title;

- (instancetype)initWithTitle:(NSString *)t {
	if (self = [super init]) {
		title = [t copy];
	}
	return self;
}

- (NSMutableArray *)invocations {
	if (!invocations) {
		invocations = [[NSMutableArray alloc] init];
	}
	return invocations;
}

- (void)invoke:(id)sender {
	if (invocations.count > 0) {
		for (NSInvocation *inv in invocations) {
			[inv invoke];
		}
	}
}

- (void)addTarget:(id)target action:(SEL)action arg:(__unsafe_unretained id)arg {
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
	inv.target = target;
	inv.selector = action;
	if (arg) {
		[inv setArgument:&arg atIndex:2];
	}
	[inv retainArguments];
	[self.invocations addObject:inv];
}

- (void)addInvocation:(NSInvocation *)inv {
	[self.invocations addObject:inv];
}

#if !__has_feature(objc_arc)
- (void)dealloc {
	[title release];
	if (invocations) { // guard against auto-creation
		[invocations release];
	}
	[super dealloc];
}
#endif

@end
