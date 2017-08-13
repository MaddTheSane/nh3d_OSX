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
	/// Is `true` if `location` is equal to `NSNotFound`.
	var notFound: Bool {
		return location == NSNotFound
	}
}
