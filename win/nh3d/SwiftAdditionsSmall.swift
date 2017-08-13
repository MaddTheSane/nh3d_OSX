//
//  SwiftAdditionsSmall.swift
//  NetHack3D
//
//  Created by C.W. Betts on 1/12/17.
//  Copyright © 2017 Haruumi Yoshino. All rights reserved.
//
//	Contains some code that can be found in my SwiftAdditions (SwiftMacTypes)
//	framework.
//

import Foundation

extension NSRange {
	/// An `NSRange` with a `location` of `NSNotFound` and a `length` of `0`.
	public static let notFound = NSRange(location: NSNotFound, length: 0)
	
	/// Returns a range from a textual representation.
	///
	/// Scans `string` for two integers which are used as the `location`
	/// and `length` values, in that order, to create an `NSRange` struct.
	/// If `string` only contains a single integer, it is used as the location
	/// value. If `string` does not contain any integers, this function returns
	/// an `NSRange` whose location and length values are both `0`.
	public init(string: String) {
		self = NSRangeFromString(string)
	}
	
	/// Is `true` if `location` is equal to `NSNotFound`.
	public var notFound: Bool {
		return location == NSNotFound
	}
	
	/// The maximum value from the range.
	public var max: Int {
		return NSMaxRange(self)
	}
	
	/// Make a new `NSRange` by intersecting this range and another.
	/// - parameter otherRange: the other range to intersect with.
	public func intersection(_ otherRange: NSRange) -> NSRange {
		return NSIntersectionRange(self, otherRange)
	}
	
	/// Set the current `NSRange` to an intersection of this range and another.
	/// - parameter otherRange: the other range to intersect with.
	public mutating func intersect(_ otherRange: NSRange) {
		self = NSIntersectionRange(self, otherRange)
	}
	
	/// A string representation of the current range.
	/// Returns a string of the form *“{a, b}”*, where *a* and *b* are
	/// non-negative integers representing `self`.
	public var stringValue: String {
		return NSStringFromRange(self)
	}
	
	/// Make a new `NSRange` from a union of this range and another.
	/// - parameter otherRange: the other range to create a union with.
	public func union(_ otherRange: NSRange) -> NSRange {
		return NSUnionRange(self, otherRange)
	}
	
	/// Set the current `NSRange` to a union of this range and another.
	/// - parameter otherRange: the other range to create a union with.
	public mutating func formUnion(_ otherRange: NSRange) {
		self = NSUnionRange(self, otherRange)
	}
}
