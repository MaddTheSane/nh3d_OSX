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
let GLYPH_DETECT_OFF: Int32 =	(1		+ GLYPH_INVIS_OFF)
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
	return NSUserDefaults.standardUserDefaults().stringForKey(NH3DMsgFontKey)
}

var NH3DWINDOWFONT: String! {
	return NSUserDefaults.standardUserDefaults().stringForKey(NH3DWindowFontKey)
}

var NH3DMAPFONT: String! {
	return NSUserDefaults.standardUserDefaults().stringForKey(NH3DMapFontKey)
}

var NH3DBOLDFONT: String! {
	return NSUserDefaults.standardUserDefaults().stringForKey(NH3DBoldFontKey)
}

var NH3DINVFONT: String! {
	return NSUserDefaults.standardUserDefaults().stringForKey(NH3DInventryFontKey)
}

var NH3DMSGFONTSIZE: CGFloat {
	return CGFloat(NSUserDefaults.standardUserDefaults().floatForKey(NH3DMsgFontSizeKey))
}

var NH3DWINDOWFONTSIZE: CGFloat {
	return CGFloat(NSUserDefaults.standardUserDefaults().floatForKey(NH3DWindowFontSizeKey))
}
var NH3DMAPFONTSIZE: CGFloat {
	return CGFloat(NSUserDefaults.standardUserDefaults().floatForKey(NH3DMapFontSizeKey))
}
var NH3DBOLDFONTSIZE: CGFloat {
	return CGFloat(NSUserDefaults.standardUserDefaults().floatForKey(NH3DBoldFontSizeKey))
}
var NH3DINVFONTSIZE: CGFloat {
	return CGFloat(NSUserDefaults.standardUserDefaults().floatForKey(NH3DInventryFontSizeKey))
}

var TRADITIONAL_MAP: Bool {
	return NSUserDefaults.standardUserDefaults().boolForKey(NH3DUseTraditionalMapKey)
}

var TRADITIONAL_MAP_TILE: Bool {
	return NSUserDefaults.standardUserDefaults().boolForKey(NH3DTraditionalMapModeKey)
}

var TILE_FILE_NAME: String! {
	return NSUserDefaults.standardUserDefaults().stringForKey(NH3DTileNameKey)
}

var TILES_PER_LINE: Int {
	return NSUserDefaults.standardUserDefaults().integerForKey(NH3DTilesPerLineKey)
}

var NUMBER_OF_TILES_ROW: Int {
	return NSUserDefaults.standardUserDefaults().integerForKey(NH3DNumberOfTilesRowKey)
}

var OPENGLVIEW_WAITRATE: Double {
	return NSUserDefaults.standardUserDefaults().doubleForKey(NH3DOpenGLWaitRateKey)
}

var OPENGLVIEW_WAITSYNC: Bool {
	return NSUserDefaults.standardUserDefaults().boolForKey(NH3DOpenGLWaitSyncKey)
}

var OPENGLVIEW_USEWAIT: Bool {
	return NSUserDefaults.standardUserDefaults().boolForKey(NH3DOpenGLUseWaitRateKey)
}

var OPENGLVIEW_NUMBER_OF_THREADS: Int {
	return NSUserDefaults.standardUserDefaults().integerForKey(NH3DOpenGLNumberOfThreadsKey)
}

var NH3DGL_USETILE: Bool {
	return NSUserDefaults.standardUserDefaults().boolForKey(NH3DGLTileKey)
}

var SOUND_MUTE: Bool {
	return NSUserDefaults.standardUserDefaults().boolForKey(NH3DSoundMuteKey)
}

var HSee_invisible: Int {
	return u.uprops.12.intrinsic
}

var ESee_invisible: Int {
	return u.uprops.12.extrinsic
}

private func perceives(ptr: UnsafePointer<permonst>) -> Bool {
	return (ptr.memory.mflags1 & UInt(M1_SEE_INVIS)) != 0
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

func IS_DOOR(typ: schar) -> Bool {
	return Int32(typ) == DOOR
}

func Is_rogue_level(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_rogue_level) != 0
}

func Is_knox(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_knox_level) != 0
}

func Is_sanctum(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_sanctum_level) != 0
}

func Is_stronghold(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_stronghold_level) != 0
}

func In_sokoban(x: UnsafeMutablePointer<d_level>) -> Bool {
	return x.memory.dnum == dungeon_topology.d_sokoban_dnum
}

func Is_earthlevel(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_earth_level) != 0
}

func Is_waterlevel(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_water_level) != 0
}

func Is_firelevel(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_fire_level) != 0
}

func Is_airlevel(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_air_level) != 0
}

func Is_astralevel(x: UnsafeMutablePointer<d_level>) -> Bool {
	return on_level(x, &dungeon_topology.d_astral_level) != 0
}
