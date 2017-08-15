//
//  SwiftNetHack bridge.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/8/15.
//
//

import Foundation

@available(*, unavailable, renamed: "NetHackGlyphPetOffset")
var GLYPH_PET_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphInvisibleOffset")
var GLYPH_INVIS_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphDetectOffset")
var GLYPH_DETECT_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphBodyOffset")
var GLYPH_BODY_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphRiddenOffset")
var GLYPH_RIDDEN_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphObjectOffset")
var GLYPH_OBJ_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphCMapOffset")
var GLYPH_CMAP_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphExplodeOffset")
var GLYPH_EXPLODE_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphZapOffset")
var GLYPH_ZAP_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphSwallowOffset")
var GLYPH_SWALLOW_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphWarningOffset")
var GLYPH_WARNING_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphStatueOffset")
var GLYPH_STATUE_OFF: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphMaxGlyph")
var MAX_GLYPH: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphNoGlyph")
var NO_GLYPH: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHackGlyphInvisible")
var GLYPH_INVISIBLE: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicMissile")
var NH3D_ZAP_MAGIC_MISSILE: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicFire")
var NH3D_ZAP_MAGIC_FIRE: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicCold")
var NH3D_ZAP_MAGIC_COLD: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicSleep")
var NH3D_ZAP_MAGIC_SLEEP: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicDeath")
var NH3D_ZAP_MAGIC_DEATH: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicLightning")
var NH3D_ZAP_MAGIC_LIGHTNING: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicPoisonGas")
var NH3D_ZAP_MAGIC_POISONGAS: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DZapMagicAcid")
var NH3D_ZAP_MAGIC_ACID: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeDark")
var NH3D_EXPLODE_DARK: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeNoxious")
var NH3D_EXPLODE_NOXIOUS: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeMuddy")
var NH3D_EXPLODE_MUDDY: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeWet")
var NH3D_EXPLODE_WET: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeMagical")
var NH3D_EXPLODE_MAGICAL: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeFiery")
var NH3D_EXPLODE_FIERY: Int32 {
	fatalError()
}
@available(*, unavailable, renamed: "NetHack3DExplodeFrosty")
var NH3D_EXPLODE_FROSTY: Int32 {
	fatalError()
}

//MARK: for font
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
	return CGFloat(UserDefaults.standard.float(forKey: NH3DMsgFontSizeKey))
}

var NH3DWINDOWFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.float(forKey: NH3DWindowFontSizeKey))
}
var NH3DMAPFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.float(forKey: NH3DMapFontSizeKey))
}
var NH3DBOLDFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.float(forKey: NH3DBoldFontSizeKey))
}
var NH3DINVFONTSIZE: CGFloat {
	return CGFloat(UserDefaults.standard.float(forKey: NH3DInventryFontSizeKey))
}

var TRADITIONAL_MAP: Bool {
	return TRADITIONAL_MAP_func()
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
	return NH3DGL_USETILE_func()
}

var SOUND_MUTE: Bool {
	return SOUND_MUTE_func()
}

var HSee_invisible: Int {
	return u.uprops.12.intrinsic
}

var ESee_invisible: Int {
	return u.uprops.12.extrinsic
}

private func perceives(_ ptr: UnsafePointer<permonst>) -> Bool {
	return (ptr.pointee.mflags1 & UInt(M1_SEE_INVIS)) != 0
}

var See_invisible: Bool {
	return (HSee_invisible != 0 || ESee_invisible != 0 ||
		perceives(youmonst.data))
}

// MARK: Appearance and behavior
var Adornment: Int {
	return u.uprops.9.extrinsic
}

var HInvis: Int {
	return u.uprops.13.intrinsic
}

var EInvis: Int {
	return u.uprops.13.extrinsic
}

var BInvis: Int {
	return u.uprops.13.blocked
}

var Invisible: Bool {
	return (Swift_Invis() && !See_invisible)
}

@available(*, unavailable, renamed: "isDoor(_:)")
func IS_DOOR(_ typ: schar) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is the rogue level
@available(*, unavailable, renamed: "isRogueLevel(_:)")
func Is_rogue_level(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is Fort Knox
@available(*, unavailable, renamed: "isFortKnox(_:)")
func Is_knox(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is the sanctum level
@available(*, unavailable, renamed: "isSanctum(_:)")
func Is_sanctum(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is the stronghold level
@available(*, unavailable, renamed: "isStrongholdLevel(_:)")
func Is_stronghold(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is a Sokoban level
@available(*, unavailable, renamed: "inSokoban(_:)")
func In_sokoban(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is on the plane of earth
@available(*, unavailable, renamed: "isEarthLevel(_:)")
func Is_earthlevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is on the plane of water
@available(*, unavailable, renamed: "isWaterLevel(_:)")
func Is_waterlevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is on the plane of fire
@available(*, unavailable, renamed: "isFireLevel(_:)")
func Is_firelevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is on the plane of air
@available(*, unavailable, renamed: "isAirLevel(_:)")
func Is_airlevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// returns `true` if the passed-in level is on the astral plane
@available(*, unavailable, renamed: "isAstralLevel(_:)")
func Is_astralevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	fatalError()
}

/// Print to the console.
func raw_print(_ str: UnsafePointer<CChar>) {
	if let aRawPrint = windowprocs.win_raw_print {
		aRawPrint(str)
	} else {
		print(String(cString: str))
	}
}

var NH3DTextEncoding: String.Encoding {
	return String.Encoding(rawValue: __NH3DTEXTENCODING)
}

var roomAtCurrentLocation: rm {
	return roomAtLocation(x: u.ux, y: u.uy)
}
