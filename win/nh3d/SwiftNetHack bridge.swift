//
//  SwiftNetHack bridge.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/8/15.
//
//

import Foundation


//#define GLYPH_MON_OFF		0

let GLYPH_PET_OFF: Int32 =		(NUMMONS	+ GLYPH_MON_OFF)
let GLYPH_INVIS_OFF: Int32 =	(NUMMONS	+ GLYPH_PET_OFF)
let GLYPH_DETECT_OFF: Int32 =	(1			+ GLYPH_INVIS_OFF)
let GLYPH_BODY_OFF: Int32 =		(NUMMONS	+ GLYPH_DETECT_OFF)
let GLYPH_RIDDEN_OFF: Int32 =	(NUMMONS	+ GLYPH_BODY_OFF)
let GLYPH_OBJ_OFF: Int32 =		(NUMMONS	+ GLYPH_RIDDEN_OFF)
let GLYPH_CMAP_OFF: Int32 =		(NUM_OBJECTS	+ GLYPH_OBJ_OFF)
let GLYPH_EXPLODE_OFF: Int32 =	((MAXPCHARS - MAXEXPCHARS) + GLYPH_CMAP_OFF)
let GLYPH_ZAP_OFF: Int32 =		((MAXEXPCHARS * EXPL_MAX) + GLYPH_EXPLODE_OFF)
let GLYPH_SWALLOW_OFF: Int32 =	((NUM_ZAP << 2) + GLYPH_ZAP_OFF)
let GLYPH_WARNING_OFF: Int32 =	((NUMMONS << 3) + GLYPH_SWALLOW_OFF)
let GLYPH_STATUE_OFF: Int32 =	(WARNCOUNT + GLYPH_WARNING_OFF)
let MAX_GLYPH: Int32 =			(NUMMONS + GLYPH_STATUE_OFF)

let NO_GLYPH		= MAX_GLYPH
let GLYPH_INVISIBLE	= GLYPH_INVIS_OFF


// ZAP Types  * AD_xxx defined from monattk.h
let NH3D_ZAP_MAGIC_MISSILE: Int32 =		(GLYPH_ZAP_OFF + ((AD_MAGM-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_FIRE: Int32 =		(GLYPH_ZAP_OFF + ((AD_FIRE-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_COLD: Int32 =		(GLYPH_ZAP_OFF + ((AD_COLD-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_SLEEP: Int32 =		(GLYPH_ZAP_OFF + ((AD_SLEE-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_DEATH: Int32 =		(GLYPH_ZAP_OFF + ((AD_DISN-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_LIGHTNING: Int32 =	(GLYPH_ZAP_OFF + ((AD_ELEC-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_POISONGAS: Int32 =	(GLYPH_ZAP_OFF + ((AD_DRST-1) * NH3D_ZAP_DIRECTION))
let NH3D_ZAP_MAGIC_ACID: Int32 =		(GLYPH_ZAP_OFF + ((AD_ACID-1) * NH3D_ZAP_DIRECTION))
// Explosion types * EXPL_xxx defined from hack.h
let NH3D_EXPLODE_DARK: Int32 =			(GLYPH_EXPLODE_OFF + (EXPL_DARK * MAXEXPCHARS))
let NH3D_EXPLODE_NOXIOUS: Int32 =		(GLYPH_EXPLODE_OFF + (EXPL_NOXIOUS * MAXEXPCHARS))
let NH3D_EXPLODE_MUDDY: Int32 =			(GLYPH_EXPLODE_OFF + (EXPL_MUDDY * MAXEXPCHARS))
let NH3D_EXPLODE_WET: Int32 =			(GLYPH_EXPLODE_OFF + (EXPL_WET * MAXEXPCHARS))
let NH3D_EXPLODE_MAGICAL: Int32 =		(GLYPH_EXPLODE_OFF + (EXPL_MAGICAL * MAXEXPCHARS))
let NH3D_EXPLODE_FIERY: Int32 =			(GLYPH_EXPLODE_OFF + (EXPL_FIERY * MAXEXPCHARS))
let NH3D_EXPLODE_FROSTY: Int32 =		(GLYPH_EXPLODE_OFF + (EXPL_FROSTY * MAXEXPCHARS))

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

func IS_DOOR(_ typ: schar) -> Bool {
	return Int32(typ) == DOOR
}

/// returns `true` if the passed-in level is the rogue level
func Is_rogue_level(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_rogue_level)
}

/// returns `true` if the passed-in level is Fort Knox
func Is_knox(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_knox_level)
}

/// returns `true` if the passed-in level is the sanctum level
func Is_sanctum(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_sanctum_level)
}

/// returns `true` if the passed-in level is the stronghold level
func Is_stronghold(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_stronghold_level)
}

/// returns `true` if the passed-in level is a Sokoban level
func In_sokoban(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return x.pointee.dnum == dungeon_topology.d_sokoban_dnum
}

/// returns `true` if the passed-in level is on the plane of earth
func Is_earthlevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_earth_level)
}

/// returns `true` if the passed-in level is on the plane of water
func Is_waterlevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_water_level)
}

/// returns `true` if the passed-in level is on the plane of fire
func Is_firelevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_fire_level)
}

/// returns `true` if the passed-in level is on the plane of air
func Is_airlevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_air_level)
}

/// returns `true` if the passed-in level is on the astral plane
func Is_astralevel(_ x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_astral_level) 
}

/// Print to the console.
func raw_print(_ str: UnsafePointer<CChar>) {
	windowprocs.win_raw_print?(str)
}

var NH3DTextEncoding: String.Encoding {
	return String.Encoding(rawValue: NH3DTEXTENCODING)
}
