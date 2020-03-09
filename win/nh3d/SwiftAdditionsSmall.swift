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

import Cocoa

extension NSRange {
	/// Is `true` if `location` is equal to `NSNotFound`.
	@inlinable var notFound: Bool {
		return location == NSNotFound
	}
}

extension CGBitmapInfo {
	/// The native 32-bit byte order format.
	@inlinable static var byteOrder32Host: CGBitmapInfo {
		#if _endian(little)
			return .byteOrder32Little
		#elseif _endian(big)
			return .byteOrder32Big
		#else
			fatalError("Unknown endianness")
		#endif
	}
}

extension NSBitmapImageRep.Format {
	/// The native 32-bit byte order format.
	@inlinable static var thirtyTwoBitNativeEndian: NSBitmapImageRep.Format {
		#if _endian(little)
			return .thirtyTwoBitLittleEndian
		#elseif _endian(big)
			return .thirtyTwoBitBigEndian
		#else
			fatalError("Unknown endianness")
		#endif
	}
}
