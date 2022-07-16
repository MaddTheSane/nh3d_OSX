//
//  SwiftNetHack bridge.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/8/15.
//
//

import Foundation

// MARK: -

// MARK: for font
var NH3DMSGFONT: String! {
	return UserDefaults.standard.string(forKey: NH3DMsgFontKey)
}

var NH3DWINDOWFONT: String! {
	return UserDefaults.standard.string(forKey: NH3DWindowFontKey)
}

var NH3DMAPFONT: String! {
	return UserDefaults.standard.string(forKey: NH3DMapFontKey)
}

var NH3DBOLDFONT: String! {
	return UserDefaults.standard.string(forKey: NH3DBoldFontKey)
}

var NH3DINVFONT: String! {
	return UserDefaults.standard.string(forKey: NH3DInventryFontKey)
}

var NH3DMSGFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.double(forKey: NH3DMsgFontSizeKey))
}

var NH3DWINDOWFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.double(forKey: NH3DWindowFontSizeKey))
}
var NH3DMAPFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.double(forKey: NH3DMapFontSizeKey))
}
var NH3DBOLDFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.double(forKey: NH3DBoldFontSizeKey))
}
var NH3DINVFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.double(forKey: NH3DInventryFontSizeKey))
}

var TRADITIONAL_MAP: Bool {
	return PreferencesManager.shared.useTraditionalMap
}

var TRADITIONAL_MAP_TILE: Bool {
	return UserDefaults.standard.bool(forKey: NH3DTraditionalMapModeKey)
}

var TILE_FILE_NAME: String! {
	return UserDefaults.standard.string(forKey: NH3DTileNameKey)
}

var TILES_PER_LINE: Int {
	return UserDefaults.standard.integer(forKey: NH3DTilesPerLineKey)
}

var NUMBER_OF_TILES_ROW: Int {
	return UserDefaults.standard.integer(forKey: NH3DNumberOfTilesRowKey)
}

var OPENGLVIEW_WAITRATE: Double {
	return UserDefaults.standard.double(forKey: NH3DOpenGLWaitRateKey)
}

var OPENGLVIEW_WAITSYNC: Bool {
	return UserDefaults.standard.bool(forKey: NH3DOpenGLWaitSyncKey)
}

var OPENGLVIEW_USEWAIT: Bool {
	return UserDefaults.standard.bool(forKey: NH3DOpenGLUseWaitRateKey)
}

var OPENGLVIEW_NUMBER_OF_THREADS: Int {
	return UserDefaults.standard.integer(forKey: NH3DOpenGLNumberOfThreadsKey)
}

var NH3DGL_USETILE: Bool {
	return PreferencesManager.shared.useTiles
}

var SOUND_MUTE: Bool {
	return PreferencesManager.shared.isMuted
}

@inlinable var HSee_invisible: Int {
	return u.uprops.12.intrinsic
}

@inlinable var ESee_invisible: Int {
	return u.uprops.12.extrinsic
}

@inlinable func perceives(_ ptr: UnsafePointer<permonst>) -> Bool {
	return (ptr.pointee.mflags1 & UInt(M1_SEE_INVIS)) != 0
}

@inlinable var See_invisible: Bool {
	return (HSee_invisible != 0 || ESee_invisible != 0 ||
		perceives(youmonst.data))
}

// MARK: - Appearance and behavior
@inlinable var Adornment: Int {
	return u.uprops.9.extrinsic
}

@inlinable var HInvis: Int {
	return u.uprops.13.intrinsic
}

@inlinable var EInvis: Int {
	return u.uprops.13.extrinsic
}

@inlinable var BInvis: Int {
	return u.uprops.13.blocked
}

@inlinable var Invisible: Bool {
	return (Swift_Invis() && !See_invisible)
}

//MARK: -

/// Print to the console.
func raw_print(_ str: UnsafePointer<CChar>) {
	if let aRawPrint = windowprocs.win_raw_print {
		aRawPrint(str)
	} else {
		print(String(cString: str, encoding: NH3DTextEncoding)!)
	}
}

var NH3DTextEncoding: String.Encoding {
	return String.Encoding(rawValue: __NH3DTEXTENCODING)
}

@inlinable var roomAtCurrentLocation: rm {
	return roomAtLocation(x: u.ux, y: u.uy)
}

/// Returns `true` if the passed-in level is a wizard level.
@inlinable func isWizardLevel(_ xx: UnsafePointer<d_level>) -> Bool {
	return isWizardLevel1(xx) || isWizardLevel2(xx) || isWizardLevel3(xx)
}
