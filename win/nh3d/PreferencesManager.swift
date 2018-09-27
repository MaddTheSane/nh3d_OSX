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
		let defaults = UserDefaults.standard
		useTraditionalMap = defaults.bool(forKey: NH3DUseTraditionalMapKey)
		useTiles = defaults.bool(forKey: NH3DGLTileKey)
		isMuted = defaults.bool(forKey: NH3DSoundMuteKey)
		
		super.init()
		
		var toOb = defaults.observe(\.UseTraditionalMap) { [weak self] (defaults2, cng) in
			let newVal = cng.newValue ?? defaults2.bool(forKey: NH3DUseTraditionalMapKey)
			self?.useTraditionalMap = newVal
		}
		kvoo.append(toOb)
		
		toOb = defaults.observe(\.OpenGLViewUseTile) { [weak self] (defaults2, cng) in
			let newVal = cng.newValue ?? defaults2.bool(forKey: NH3DGLTileKey)
			self?.useTiles = newVal
		}
		kvoo.append(toOb)
		
		toOb = defaults.observe(\.SoundMute) { [weak self] (defaults2, cng) in
			let newVal = cng.newValue ?? defaults2.bool(forKey: NH3DSoundMuteKey)
			self?.isMuted = newVal
		}
		kvoo.append(toOb)
	}
}
