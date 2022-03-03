//
//  NH3DEnums.h
//  NetHack3D
//
//  Created by C.W. Betts on 12/6/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

#ifndef NH3DEnums_h
#define NH3DEnums_h

#include "C99Bool.h"
#import <Foundation/NSObjCRuntime.h>

#include "extern.h"
#import "NH3DUserDefaultsExtern.h"

NS_ENUM(int) {
	NetHackGlyphMonsterOffset = GLYPH_MON_OFF,
	NetHackGlyphPetOffset = GLYPH_PET_OFF,
	NetHackGlyphInvisibleOffset = GLYPH_INVIS_OFF,
	NetHackGlyphDetectOffset = GLYPH_DETECT_OFF,
	NetHackGlyphBodyOffset = GLYPH_BODY_OFF,
	NetHackGlyphRiddenOffset = GLYPH_RIDDEN_OFF,
	NetHackGlyphObjectOffset = GLYPH_OBJ_OFF,
	NetHackGlyphCMapOffset = GLYPH_CMAP_OFF,
	NetHackGlyphExplodeOffset = GLYPH_EXPLODE_OFF,
	NetHackGlyphZapOffset = GLYPH_ZAP_OFF,
	NetHackGlyphSwallowOffset = GLYPH_SWALLOW_OFF,
	NetHackGlyphWarningOffset = GLYPH_WARNING_OFF,
	NetHackGlyphStatueOffset = GLYPH_STATUE_OFF,
	NetHackGlyphMaxGlyph = MAX_GLYPH,
	
	NetHackGlyphNoGlyph = NO_GLYPH,
	NetHackGlyphInvisible = GLYPH_INVISIBLE,
	
	//! ZAP Types  * AD_xxx defined from monattk.h
	NetHack3DZapMagicMissile = NH3D_ZAP_MAGIC_MISSILE,
	NetHack3DZapMagicFire = NH3D_ZAP_MAGIC_FIRE,
	NetHack3DZapMagicCold = NH3D_ZAP_MAGIC_COLD,
	NetHack3DZapMagicSleep = NH3D_ZAP_MAGIC_SLEEP,
	NetHack3DZapMagicDeath = NH3D_ZAP_MAGIC_DEATH,
	NetHack3DZapMagicLightning = NH3D_ZAP_MAGIC_LIGHTNING,
	NetHack3DZapMagicPoisonGas = NH3D_ZAP_MAGIC_POISONGAS,
	NetHack3DZapMagicAcid = NH3D_ZAP_MAGIC_ACID,
	
	//! Explosion types * EXPL_xxx defined from hack.h
	NetHack3DExplodeDark = NH3D_EXPLODE_DARK,
	NetHack3DExplodeNoxious = NH3D_EXPLODE_NOXIOUS,
	NetHack3DExplodeMuddy = NH3D_EXPLODE_MUDDY,
	NetHack3DExplodeWet = NH3D_EXPLODE_WET,
	NetHack3DExplodeMagical = NH3D_EXPLODE_MAGICAL,
	NetHack3DExplodeFiery = NH3D_EXPLODE_FIERY,
	NetHack3DExplodeFrosty = NH3D_EXPLODE_FROSTY,
};

#endif /* NH3DEnums_h */
