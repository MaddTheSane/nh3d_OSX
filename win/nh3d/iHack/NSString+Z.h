//
//  NSString+Regexp.h
//  SlashEM
//
//  Created by dirk on 8/6/09.
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

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Z)

- (BOOL) containsString:(NSString *)s;
- (BOOL) startsWithString:(NSString *)s;
- (BOOL) containsChar:(char)c;
- (BOOL) endsWithString:(NSString *)s;
- (nullable NSString *) substringBetweenDelimiters:(NSString *)del;
- (nullable NSString *) substringStartingWithString:(NSString *)start;
@property (readonly, copy) NSString *stringWithTrimmedWhitespaces;
- (NSRange) rangeOfString:(NSString *)text withDelimiter:(NSString *)delim;

@end

NS_ASSUME_NONNULL_END
