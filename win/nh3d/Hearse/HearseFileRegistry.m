//
//  HearseFileRegistry.m
//  iNetHack
//
//  Created by dirk on 10/21/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
//

//  This file is part of iNetHack.
//
//  iNetHack is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 2 of the License only.
//
//  iNetHack is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with iNetHack.  If not, see <http://www.gnu.org/licenses/>.

#import "HearseFileRegistry.h"
#import "Hearse.h"

static NSString *const hearseFileRegistryKey = @"hearseFileRegistryKey";
static NSString *const hearseFileRegistryKeyUploads = @"hearseFileRegistryKeyUploads";
static NSString *const hearseFileRegistryKeyDownloads = @"hearseFileRegistryKeyDownloads";

static HearseFileRegistry *instance;

@implementation HearseFileRegistry

+ (void)load {
	@autoreleasepool {
		NSDictionary *registry = @{
								   hearseFileRegistryKeyUploads: [NSDictionary dictionary],
								   hearseFileRegistryKeyDownloads: [NSDictionary dictionary],
								  };
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{hearseFileRegistryKey: registry}];
	}
}

+ (void) retainInstance {
	if (!instance) {
		instance = [[HearseFileRegistry alloc] init]; //Returns with +1 already
	} else {
		[instance retain];
	}
}

+ (void) releaseInstance {
	HearseFileRegistry *tmpInstance = instance;
	if ([tmpInstance retainCount] == 1) {
		instance = nil;
	}
	[tmpInstance release];
}


+ (HearseFileRegistry *) instance {
	return instance;
}

- (id) init {
	if (self = [super init]) {
		NSDictionary *registry = [[NSUserDefaults standardUserDefaults] objectForKey:hearseFileRegistryKey];
		uploads = [[registry objectForKey:hearseFileRegistryKeyUploads] mutableCopy];
		downloads = [[registry objectForKey:hearseFileRegistryKeyDownloads] mutableCopy];
	}
	[Hearse dumpDictionary:downloads];
	instance = self;
	return self;
}

- (void) synchronize {
	NSDictionary *registry = @{
							   hearseFileRegistryKeyUploads: uploads,
							   hearseFileRegistryKeyDownloads: downloads,
							  };
	[[NSUserDefaults standardUserDefaults] setObject:registry forKey:hearseFileRegistryKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) registerDownloadedFile:(NSString *)filename withMd5:(NSString *)md5 {
	NSString *file = [filename lastPathComponent];
	[downloads setObject:md5 forKey:file];
	[self synchronize];
}

- (BOOL) haveDownloadedFile:(NSString *)filename {
	NSString *file = [filename lastPathComponent];
	if ([[filename pathExtension] isEqualToString:@"gz"]) {
		file = [file stringByDeletingPathExtension];
	}
	NSString *md5 = [downloads objectForKey:file];
	if (md5) {
		NSString *actualMd5 = [Hearse md5HexForFile:filename];
		return [md5 isEqual:actualMd5];
	} else {
		return NO;
	}
}
		
- (void) clear {
	[uploads removeAllObjects];
	[downloads removeAllObjects];
	[self synchronize];
}

- (void) dealloc {
	[uploads release];
	[downloads release];
	[super dealloc];
}

@end
