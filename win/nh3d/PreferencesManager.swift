//
//  PreferencesManager.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/26/17.
//  Copyright © 2017 Haruumi Yoshino. All rights reserved.
//

import Foundation

extension UserDefaults {
	@objc dynamic var WindowFontName: String {
		return string(forKey: NH3DWindowFontKey)!
	}
	
	@objc dynamic var WindowFontSize: CGFloat.NativeType {
		return CGFloat.NativeType(double(forKey: NH3DWindowFontSizeKey))
	}
	
	@objc dynamic var UseTraditionalMap: Bool {
		return bool(forKey: NH3DUseTraditionalMapKey)
	}
	
	@objc dynamic var OpenGLViewUseTile: Bool {
		return bool(forKey: NH3DGLTileKey)
	}
	
	@objc dynamic var SoundMute: Bool {
		return bool(forKey: NH3DSoundMuteKey)
	}
}

class PreferencesManager: NSObject {
	@objc static let shared = PreferencesManager()
	private var kvoo: [NSKeyValueObservation] = []
	@objc private(set) var useTraditionalMap: Bool
	@objc private(set) var useTiles: Bool
	@objc private(set) var isMuted: Bool

	private override init() {
		var kvoo2 = [NSKeyValueObservation]()
		let defaults = UserDefaults.standard
		useTraditionalMap = defaults.bool(forKey: NH3DUseTraditionalMapKey)
		useTiles = defaults.bool(forKey: NH3DGLTileKey)
		isMuted = defaults.bool(forKey: NH3DSoundMuteKey)
		
		super.init()
		
		var toOb = defaults.observe(\.UseTraditionalMap) { (defaults, cng) in
			let newVal = cng.newValue ?? defaults.bool(forKey: NH3DUseTraditionalMapKey)
			self.useTraditionalMap = newVal
		}
		kvoo2.append(toOb)
		
		toOb = defaults.observe(\.OpenGLViewUseTile) { (defaults, cng) in
			let newVal = cng.newValue ?? defaults.bool(forKey: NH3DGLTileKey)
			self.useTiles = newVal
		}
		kvoo2.append(toOb)
		
		toOb = defaults.observe(\.SoundMute) { (defaults, cng) in
			let newVal = cng.newValue ?? defaults.bool(forKey: NH3DSoundMuteKey)
			self.isMuted = newVal
		}
		kvoo2.append(toOb)

		self.kvoo = kvoo2
	}
}
