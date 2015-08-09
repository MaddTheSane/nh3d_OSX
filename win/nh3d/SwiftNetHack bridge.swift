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
let MAX_GLYPH: Int32 =			(WARNCOUNT      + GLYPH_WARNING_OFF)

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

@noreturn func panic(str: String) {
	fputs(" ERROR:  ", stderr)
	fputs(str, stderr)
	fflush(stderr)
	abort() /* generate core dump */
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
/*

*/

var See_invisible: Bool {
	return (HSee_invisible != 0 || ESee_invisible != 0 ||
		perceives(youmonst.data))
}

/*** Appearance and behavior ***/
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

