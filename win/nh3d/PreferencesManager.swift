//
//  PreferencesManager.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/26/17.
//  Copyright © 2017 Haruumi Yoshino. All rights reserved.
//

import Foundation

extension UserDefaults {
	@objc(WindowFontName) dynamic var windowFontName: String {
		return string(forKey: NH3DWindowFontKey)!
	}
	
	@objc(WindowFontSize) dynamic var windowFontSize: CGFloat.NativeType {
		return CGFloat.NativeType(double(forKey: NH3DWindowFontSizeKey))
	}
	
	@objc(UseTraditionalMap) dynamic var useTraditionalMap: Bool {
		return bool(forKey: NH3DUseTraditionalMapKey)
	}
	
	@objc(OpenGLViewUseTile) dynamic var openGLViewUseTile: Bool {
		return bool(forKey: NH3DGLTileKey)
	}
	
	@objc(SoundMute) dynamic var soundMute: Bool {
		return bool(forKey: NH3DSoundMuteKey)
	}
}

@objcMembers class PreferencesManager: NSObject {
	@objc(sharedManager) static let shared = PreferencesManager()
	private var kvoo: [NSKeyValueObservation] = []
	private(set) var useTraditionalMap: Bool
	private(set) var useTiles: Bool
	private(set) var isMuted: Bool

	private override init() {
		let defaults = UserDefaults.standard
		useTraditionalMap = defaults.bool(forKey: NH3DUseTraditionalMapKey)
		useTiles = defaults.bool(forKey: NH3DGLTileKey)
		isMuted = defaults.bool(forKey: NH3DSoundMuteKey)
		
		super.init()
		
		var toOb = defaults.observe(\.useTraditionalMap) { [weak self] (defaults2, cng) in
			let newVal = cng.newValue ?? defaults2.bool(forKey: NH3DUseTraditionalMapKey)
			self?.useTraditionalMap = newVal
		}
		kvoo.append(toOb)
		
		toOb = defaults.observe(\.openGLViewUseTile) { [weak self] (defaults2, cng) in
			let newVal = cng.newValue ?? defaults2.bool(forKey: NH3DGLTileKey)
			self?.useTiles = newVal
		}
		kvoo.append(toOb)
		
		toOb = defaults.observe(\.soundMute) { [weak self] (defaults2, cng) in
			let newVal = cng.newValue ?? defaults2.bool(forKey: NH3DSoundMuteKey)
			self?.isMuted = newVal
		}
		kvoo.append(toOb)
	}
}
