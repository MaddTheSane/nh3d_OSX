/*
 *  NH3DUserDefaultsExtern.h
 *  NetHack3D
 *
 *  Created by Haruumi Yoshino on 05/12/23.
 *  Copyright 2005 Haruumi Yoshino. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import "NH3Dcommon.h"
#import "hack.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const NH3DMsgFontKey;
extern NSString *const NH3DMapFontKey;
extern NSString *const NH3DBoldFontKey;
extern NSString *const NH3DInventryFontKey;
extern NSString *const NH3DWindowFontKey;

extern NSString *const NH3DMsgFontSizeKey;
extern NSString *const NH3DMapFontSizeKey;
extern NSString *const NH3DBoldFontSizeKey;
extern NSString *const NH3DInventryFontSizeKey;
extern NSString *const NH3DWindowFontSizeKey;

extern const NSStringEncoding NH3DTEXTENCODING NS_REFINED_FOR_SWIFT;

// for font
#define NH3DMSGFONT		[[NSUserDefaults standardUserDefaults] stringForKey:NH3DMsgFontKey]
#define NH3DWINDOWFONT  [[NSUserDefaults standardUserDefaults] stringForKey:NH3DWindowFontKey]
#define NH3DMAPFONT		[[NSUserDefaults standardUserDefaults] stringForKey:NH3DMapFontKey]
#define NH3DBOLDFONT	[[NSUserDefaults standardUserDefaults] stringForKey:NH3DBoldFontKey]
#define NH3DINVFONT		[[NSUserDefaults standardUserDefaults] stringForKey:NH3DInventryFontKey]
// for fontsize
#define NH3DMSGFONTSIZE		[[NSUserDefaults standardUserDefaults] floatForKey:NH3DMsgFontSizeKey]
#define NH3DWINDOWFONTSIZE  [[NSUserDefaults standardUserDefaults] floatForKey:NH3DWindowFontSizeKey]
#define NH3DMAPFONTSIZE		[[NSUserDefaults standardUserDefaults] floatForKey:NH3DMapFontSizeKey]
#define NH3DBOLDFONTSIZE	[[NSUserDefaults standardUserDefaults] floatForKey:NH3DBoldFontSizeKey]
#define NH3DINVFONTSIZE		[[NSUserDefaults standardUserDefaults] floatForKey:NH3DInventryFontSizeKey]

extern NSString *const NH3DOpenGLWaitRateKey;
extern NSString *const NH3DOpenGLWaitSyncKey;
extern NSString *const NH3DOpenGLUseWaitRateKey;
extern NSString *const NH3DOpenGLNumberOfThreadsKey;
extern NSString *const NH3DUseRetinaOpenGL;

#define OPENGLVIEW_WAITRATE [[NSUserDefaults standardUserDefaults] doubleForKey:NH3DOpenGLWaitRateKey]
#define OPENGLVIEW_WAITSYNC	[[NSUserDefaults standardUserDefaults] boolForKey:NH3DOpenGLWaitSyncKey]
#define OPENGLVIEW_USEWAIT	[[NSUserDefaults standardUserDefaults] boolForKey:NH3DOpenGLUseWaitRateKey]
#define OPENGLVIEW_NUMBER_OF_THREADS	[[NSUserDefaults standardUserDefaults] integerForKey:NH3DOpenGLNumberOfThreadsKey]

extern NSString *const NH3DUseTileInLevelMapKey;
extern NSString *const NH3DUseSightRestrictionKey;

#define RESTRICTED_VIEW	[[NSUserDefaults standardUserDefaults] boolForKey:NH3DUseSightRestrictionKey]
#define TILED_LEVELMAP	[[NSUserDefaults standardUserDefaults] boolForKey:NH3DUseTileInLevelMapKey]

// Sound Mute
extern NSString *const NH3DSoundMuteKey;
static inline BOOL SOUND_MUTE_func() {
	return [[NSUserDefaults standardUserDefaults] boolForKey:NH3DSoundMuteKey];
}

#define SOUND_MUTE	PreferencesManager.shared.isMuted

// Map Mode

extern NSString *const NH3DUseTraditionalMapKey;
extern NSString *const NH3DTraditionalMapModeKey;

static inline BOOL TRADITIONAL_MAP_func() {
	return [[NSUserDefaults standardUserDefaults] boolForKey:NH3DUseTraditionalMapKey];
}

#define TRADITIONAL_MAP			PreferencesManager.shared.useTraditionalMap
#define TRADITIONAL_MAP_TILE	[[NSUserDefaults standardUserDefaults] boolForKey:NH3DTraditionalMapModeKey]

// Tile settings

extern NSString *const NH3DTileNameKey;
extern NSString *const NH3DTileSizeWidthKey;
extern NSString *const NH3DTileSizeHeightKey;
extern NSString *const NH3DTilesPerLineKey;
extern NSString *const NH3DNumberOfTilesRowKey;

extern NSString *const NH3DIsFirstLaunch;


#define TILE_FILE_NAME			[[NSUserDefaults standardUserDefaults] stringForKey:NH3DTileNameKey]
#define TILE_SIZE_X				[[NSUserDefaults standardUserDefaults] integerForKey:NH3DTileSizeWidthKey]
#define TILE_SIZE_Y				[[NSUserDefaults standardUserDefaults] integerForKey:NH3DTileSizeHeightKey]

#define TILES_PER_LINE			[[NSUserDefaults standardUserDefaults] integerForKey:NH3DTilesPerLineKey ]
#define NUMBER_OF_TILES_ROW		[[NSUserDefaults standardUserDefaults] integerForKey:NH3DNumberOfTilesRowKey]

//! Player Directions
typedef NS_ENUM(int, NH3DPlayerDirection) {
	NH3DPlayerDirectionForward	= 0,
	NH3DPlayerDirectionRight	= 1,
	NH3DPlayerDirectionBack		= 2,
	NH3DPlayerDirectionLeft		= 3,
};

/// default colmun + MapView number of column.
#define MAPSIZE_COLUMN 90
/// default row + MapView number of row.
#define MAPSIZE_ROW 32
/// for MapView
#define MAP_MARGIN 5

#define MAPVIEWSIZE_COLUMN	11
#define MAPVIEWSIZE_ROW		11

// OpenGLView

extern NSString *const NH3DGLTileKey;

#define NH3DGL_TILE_SIZE			4.00f
#define NH3DGL_MAPVIEWSIZE_COLUMN	11
#define NH3DGL_MAPVIEWSIZE_ROW		11
#define NH3D_MAX_EFFECTS			12l

static inline BOOL NH3DGL_USETILE_func()
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:NH3DGLTileKey];
}

#define NH3DGL_USETILE PreferencesManager.shared.useTiles

#define ENEMY_IS_NONE	0
#define ENEMY_IS_LEFT	1
#define ENEMY_IS_FRONT	2
#define ENEMY_IS_RIGHT	3

#define WAIT_NONE		0.0
#define WAIT_FAST		60.0
#define WAIT_NORMAL		45.0
#define WAIT_SLOW		30.0



// Effect Symbol Glyph
// ZAP Directons
#define NH3D_ZAP_DIRECTION	4
#define NH3D_ZAP_VBEAM		0
#define NH3D_ZAP_HBEAM		1
#define NH3D_ZAP_LSLANT		2
#define NH3D_ZAP_RSLANT		3
// ZAP Types  * AD_xxx defined from monattk.h
#define NH3D_ZAP_MAGIC_MISSILE		(GLYPH_ZAP_OFF + ((AD_MAGM - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_FIRE			(GLYPH_ZAP_OFF + ((AD_FIRE - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_COLD			(GLYPH_ZAP_OFF + ((AD_COLD - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_SLEEP		(GLYPH_ZAP_OFF + ((AD_SLEE - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_DEATH		(GLYPH_ZAP_OFF + ((AD_DISN - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_LIGHTNING	(GLYPH_ZAP_OFF + ((AD_ELEC - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_POISONGAS	(GLYPH_ZAP_OFF + ((AD_DRST - 1) * NH3D_ZAP_DIRECTION))
#define NH3D_ZAP_MAGIC_ACID			(GLYPH_ZAP_OFF + ((AD_ACID - 1) * NH3D_ZAP_DIRECTION))
// Explotion types * EXPL_xxx defined from hack.h
#define NH3D_EXPLODE_DARK			(GLYPH_EXPLODE_OFF + (EXPL_DARK * MAXEXPCHARS))
#define NH3D_EXPLODE_NOXIOUS		(GLYPH_EXPLODE_OFF + (EXPL_NOXIOUS * MAXEXPCHARS))
#define NH3D_EXPLODE_MUDDY			(GLYPH_EXPLODE_OFF + (EXPL_MUDDY * MAXEXPCHARS))
#define NH3D_EXPLODE_WET			(GLYPH_EXPLODE_OFF + (EXPL_WET * MAXEXPCHARS))
#define NH3D_EXPLODE_MAGICAL		(GLYPH_EXPLODE_OFF + (EXPL_MAGICAL * MAXEXPCHARS))
#define NH3D_EXPLODE_FIERY			(GLYPH_EXPLODE_OFF + (EXPL_FIERY * MAXEXPCHARS))
#define NH3D_EXPLODE_FROSTY			(GLYPH_EXPLODE_OFF + (EXPL_FROSTY * MAXEXPCHARS))

// Model Settings
#define MAX_VERTICES 16000 // Max number of vertices (for each object)
#define MAX_POLYGONS 8000 // Max number of polygons (for each object)
#define MAX_PARTICLES 150 // Max number of Particle effects

typedef NS_ENUM(NSInteger, NH3DModelType) {
	NH3DModelTypeObject = 0,
	NH3DModelTypeTexturedObject = 1,
	NH3DModelTypeEmitter = 2
};

typedef NS_ENUM(NSInteger, NH3DParticleType) {
	NH3DParticleTypePoints = 0,
	NH3DParticleTypeLines = 1,
	NH3DParticleTypeBoth = 2,
	NH3DParticleTypeAura = 3
};

#define MAX_TEXTURES 10

#pragma mark - General NetHack preference Keys
extern NSString * const NHUseNumPad;
extern NSString * const NHMaxMessages;

NS_ASSUME_NONNULL_END
