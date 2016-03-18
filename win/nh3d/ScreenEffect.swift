//
//  ScreenEffect.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/6/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Foundation

final class ScreenEffect {
	private var regex: COpaquePointer
	let effect: Int32
	/// The regex string used to match against.<br>
	/// Useful for debugging
	let str: String
	
	init?(message text: String, effect: Int32) {
		regex = regex_init()
		str = text
		self.effect = effect
		guard regex_compile(text, regex) else {
			raw_print(regex_error_desc(regex))
			
			return nil
		}
	}
	
	deinit {
		regex_free(regex)
	}
	
	func matches(str: String) -> Bool {
		return regex_match(str, regex)
	}
}
