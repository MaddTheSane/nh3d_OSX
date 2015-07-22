//
//  NH3DOpenGLViewSwift.swift
//  NetHack3D
//
//  Created by C.W. Betts on 7/21/15.
//
//

import Cocoa
import OpenGL
import GLKit


private let GLYPH_MON_OFF: Int32 = 0
private let GLYPH_PET_OFF   =		(NUMMONS	+ GLYPH_MON_OFF)
private let GLYPH_INVIS_OFF =		(NUMMONS	+ GLYPH_PET_OFF)
private let GLYPH_DETECT_OFF =	(1		+ GLYPH_INVIS_OFF)
private let GLYPH_BODY_OFF	=	(NUMMONS	+ GLYPH_DETECT_OFF)
private let GLYPH_RIDDEN_OFF =	(NUMMONS	+ GLYPH_BODY_OFF)
private let GLYPH_OBJ_OFF	=	(NUMMONS	+ GLYPH_RIDDEN_OFF)
private let GLYPH_CMAP_OFF	=	(NUM_OBJECTS	+ GLYPH_OBJ_OFF)
private let GLYPH_EXPLODE_OFF =	((MAXPCHARS - MAXEXPCHARS) + GLYPH_CMAP_OFF)
private let GLYPH_ZAP_OFF	=	((MAXEXPCHARS * EXPL_MAX) + GLYPH_EXPLODE_OFF)
private let GLYPH_SWALLOW_OFF =	((NUM_ZAP << 2) + GLYPH_ZAP_OFF)
private let GLYPH_WARNING_OFF =	((NUMMONS << 3) + GLYPH_SWALLOW_OFF)
private let MAX_GLYPH		=	(WARNCOUNT      + GLYPH_WARNING_OFF)

private typealias LoadModelBlock = (glyph: Int32) -> NH3DModelObjects?


func loadModelFunc_default(glyph: Int32) -> NH3DModelObjects? {
	return nil
}

class NH3DOpenGLViewSwift: NSOpenGLView {
	private var loadModelBlocks = [LoadModelBlock](count: Int(MAX_GLYPH), repeatedValue: loadModelFunc_default)
	private var modelDictionary = [Int32: NH3DModelObjects]()
	//LoadModelBlock loadModelBlocks[MAX_GLYPH];

	override init?(frame frameRect: NSRect, pixelFormat format: NSOpenGLPixelFormat?) {
		super.init(frame: frameRect, pixelFormat: format)
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
	
	private final func checkLoadedModelsAt(startNum: Int32, to endNum: Int32, offset: Int32, modelName: String, textured flag: Bool, withOut without: Int32, args:CVarArgType...) -> NH3DModelObjects? {
		var wo: Int32 = 0;
		var withoutFlag = false;
		var index = 0
		
		for i in (startNum+offset)...(endNum+offset) {
			if modelDictionary[i] != nil {
				if ( without != 0 ) {
					wo = Int32(args[index++] as! Int)
					while ( wo != 0 ) {
						if ( i == without+offset || i == wo+offset ) {
							withoutFlag = true;
							break;
						}
						wo = Int32(args[index++] as! Int)
					}
					
					if ( withoutFlag ) {
						withoutFlag = false;
						continue;
					} else {
						return modelDictionary[i]
					}
					
				} else{
					return modelDictionary[i]
				}
			}
		}
		
		if modelName == "emitter"  {
			return NH3DModelObjects()
		} else {
			return NH3DModelObjects(with3DSFile: modelName, withTexture: flag)
		}
	}
	
	/*
- ( id )loadModelFunc_insect:(int)glyph
{
// insect class
return [self checkLoadedModelsAt:PM_GIANT_ANT
to:PM_QUEEN_BEE
offset:GLYPH_MON_OFF
modelName:@"lowerA" textured:NO withOut:0];
}


- ( id )loadModelFunc_blob:(int)glyph
{
// blob class
return [self checkLoadedModelsAt:PM_ACID_BLOB
to:PM_GELATINOUS_CUBE
offset:GLYPH_MON_OFF
modelName:@"lowerB" textured:NO withOut:0];
}


- ( id )loadModelFunc_cockatrice:(int)glyph
{
// cockatrice class
return [ self checkLoadedModelsAt:PM_CHICKATRICE
to:PM_PYROLISK
offset:GLYPH_MON_OFF
modelName:@"lowerC" textured:NO withOut:0];
}


- ( id )loadModelFunc_dog:(int)glyph
{
// dog or canine class
return [ self checkLoadedModelsAt:PM_JACKAL
to:PM_HELL_HOUND
offset:GLYPH_MON_OFF
modelName:@"lowerD" textured:NO withOut:0 ];

}


- ( id )loadModelFunc_sphere:(int)glyph
{
// eye or sphere class
return [ self checkLoadedModelsAt:PM_GAS_SPORE
to:PM_SHOCKING_SPHERE
offset:GLYPH_MON_OFF
modelName:@"lowerE" textured:NO withOut:0 ];

}


- ( id )loadModelFunc_cat:(int)glyph
{
// cat or feline class
return [ self checkLoadedModelsAt:PM_KITTEN
to:PM_TIGER
offset:GLYPH_MON_OFF
modelName:@"lowerF" textured:NO withOut:0 ];

}


- ( id )loadModelFunc_gremlins:(int)glyph
{
// gremlins and gagoyles class
return [ self checkLoadedModelsAt:PM_GREMLIN
to:PM_WINGED_GARGOYLE
offset:GLYPH_MON_OFF
modelName:@"lowerG" textured:NO withOut:0 ];

}


- ( id )loadModelFunc_humanoids:(int)glyph
{
// humanoids class
id ret =nil;

if ( glyph ==  PM_DWARF_KING+GLYPH_MON_OFF ) {
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerH" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ret childObjectAtLast] setPivotX:0.0 atY:0.2 atZ:-0.21 ];
[ [ret childObjectAtLast] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
} else {

ret = [ self checkLoadedModelsAt:PM_HOBBIT
to:PM_MASTER_MIND_FLAYER
offset:GLYPH_MON_OFF
modelName:@"lowerH"
textured:NO
withOut:PM_DWARF_KING,nil ];
}

return ret;
}


- ( id )loadModelFunc_imp:(int)glyph
{
// imp and minor demons
return [ self checkLoadedModelsAt:PM_MANES
to:PM_TENGU
offset:GLYPH_MON_OFF
modelName:@"lowerI"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_jellys:(int)glyph
{
// jellys
return [ self checkLoadedModelsAt:PM_BLUE_JELLY
to:PM_OCHRE_JELLY
offset:GLYPH_MON_OFF
modelName:@"lowerJ"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_kobolds:(int)glyph
{
// kobolds
id ret = nil;

switch ( glyph ) {
case PM_KOBOLD+GLYPH_MON_OFF :
case PM_LARGE_KOBOLD+GLYPH_MON_OFF :
ret = [ self checkLoadedModelsAt:PM_KOBOLD
to:PM_LARGE_KOBOLD
offset:GLYPH_MON_OFF
modelName:@"lowerK"
textured:NO
withOut:0 ];
break;

case PM_KOBOLD_LORD+GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerK" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.1 atZ:-0.25 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];

break;

case PM_KOBOLD_SHAMAN + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerK" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.01 atZ:-0.15 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];

break;
}

return ret;

}


- ( id )loadModelFunc_leprechaun:(int)glyph
{
// leprechaun
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerL" withTexture:NO ];

}


- ( id )loadModelFunc_mimics:(int)glyph
{
// mimics
return [ self checkLoadedModelsAt:PM_SMALL_MIMIC
to:PM_GIANT_MIMIC
offset:GLYPH_MON_OFF
modelName:@"lowerM"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_nymphs:(int)glyph
{
// nymphs
return [ self checkLoadedModelsAt:PM_WOOD_NYMPH
to:PM_MOUNTAIN_NYMPH
offset:GLYPH_MON_OFF
modelName:@"lowerN"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_orc:(int)glyph
{
// orc class
id ret = nil;

if ( glyph ==  PM_ORC_SHAMAN + GLYPH_MON_OFF ) {
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerO" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.15 atZ:-0.15 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
} else {

ret = [ self checkLoadedModelsAt:PM_GOBLIN
to:PM_ORC_CAPTAIN
offset:GLYPH_MON_OFF
modelName:@"lowerO"
textured:NO
withOut:PM_ORC_SHAMAN,nil ];
}

return ret;
}


- ( id )loadModelFunc_piercers:(int)glyph
{
// piercers
return [ self checkLoadedModelsAt:PM_ROCK_PIERCER
to:PM_GLASS_PIERCER
offset:GLYPH_MON_OFF
modelName:@"lowerP"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_quadrupeds:(int)glyph
{
// quadrupeds
return [ self checkLoadedModelsAt:PM_ROTHE
to:PM_MASTODON
offset:GLYPH_MON_OFF
modelName:@"lowerQ"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_rodents:(int)glyph
{
// rodents
return [ self checkLoadedModelsAt:PM_SEWER_RAT
to:PM_WOODCHUCK
offset:GLYPH_MON_OFF
modelName:@"lowerR"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_spiders:(int)glyph
{
// spiders
return [ self checkLoadedModelsAt:PM_CAVE_SPIDER
to:PM_SCORPION
offset:GLYPH_MON_OFF
modelName:@"lowerS"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_trapper:(int)glyph
{
// trapper
return [ self checkLoadedModelsAt:PM_LURKER_ABOVE
to:PM_TRAPPER
offset:GLYPH_MON_OFF
modelName:@"lowerT"
textured:NO
withOut:0 ];


}


- ( id )loadModelFunc_unicorns:(int)glyph
{
// unicorns and horses
return [ self checkLoadedModelsAt:PM_WHITE_UNICORN
to:PM_WARHORSE
offset:GLYPH_MON_OFF
modelName:@"lowerU"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_vortices:(int)glyph
{
// vortices
return [ self checkLoadedModelsAt:PM_FOG_CLOUD
to:PM_FIRE_VORTEX
offset:GLYPH_MON_OFF
modelName:@"lowerV"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_worms:(int)glyph
{
// worms
return [ self checkLoadedModelsAt:PM_BABY_LONG_WORM
to:PM_PURPLE_WORM
offset:GLYPH_MON_OFF
modelName:@"lowerW"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_xan:(int)glyph
{
// xan
return [ self checkLoadedModelsAt:PM_GRID_BUG
to:PM_XAN
offset:GLYPH_MON_OFF
modelName:@"lowerX"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_lights:(int)glyph
{
// lights

return [ self checkLoadedModelsAt:PM_YELLOW_LIGHT
to:PM_BLACK_LIGHT
offset:GLYPH_MON_OFF
modelName:@"lowerY"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_zruty:(int)glyph
{
// zruty
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerZ" withTexture:NO ];

}


- ( id )loadModelFunc_Angels:(int)glyph
{
// Angels
return [ self checkLoadedModelsAt:PM_COUATL
to:PM_ARCHON
offset:GLYPH_MON_OFF
modelName:@"upperA"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_Bats:(int)glyph
{
// Bats
return [ self checkLoadedModelsAt:PM_BAT
to:PM_VAMPIRE_BAT
offset:GLYPH_MON_OFF
modelName:@"upperB"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_Centaurs:(int)glyph
{
// Centaurs
return [ self checkLoadedModelsAt:PM_PLAINS_CENTAUR
to:PM_MOUNTAIN_CENTAUR
offset:GLYPH_MON_OFF
modelName:@"upperC"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Dragons:(int)glyph
{
// Dragons
return [ self checkLoadedModelsAt:PM_BABY_GRAY_DRAGON
to:PM_YELLOW_DRAGON
offset:GLYPH_MON_OFF
modelName:@"upperD"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Elementals:(int)glyph
{
// Elementals
return [ self checkLoadedModelsAt:PM_STALKER
to:PM_WATER_ELEMENTAL
offset:GLYPH_MON_OFF
modelName:@"upperE"
textured:NO
withOut:0 ];
}


- ( id )loadModelFunc_Fungi:(int)glyph
{
// Fungi
return [ self checkLoadedModelsAt:PM_LICHEN
to:PM_VIOLET_FUNGUS
offset:GLYPH_MON_OFF
modelName:@"upperF"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Gnomes:(int)glyph
{
// gnomes
id ret = nil;
switch ( glyph ) {
case PM_GNOME+GLYPH_MON_OFF :
case PM_GNOME_LORD+GLYPH_MON_OFF :
ret = [ self checkLoadedModelsAt:PM_GNOME
to:PM_GNOME_LORD
offset:GLYPH_MON_OFF
modelName:@"upperG"
textured:NO
withOut:0 ];

break;
case PM_GNOMISH_WIZARD + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperG" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.01 atZ:-0.15 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
break;

case PM_GNOME_KING + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperG" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.05 atZ:-0.25 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
break;
}

return ret;

}


- ( id )loadModelFunc_giantHumanoids:(int)glyph
{
// Giant Humanoids
return [ self checkLoadedModelsAt:PM_GIANT
to:PM_MINOTAUR
offset:GLYPH_MON_OFF
modelName:@"upperH"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Jabberwock:(int)glyph
{
// Jabberwock
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperJ" withTexture:NO ];

}


- ( id )loadModelFunc_Kops:(int)glyph
{
// Kops
return [ self checkLoadedModelsAt:PM_KEYSTONE_KOP
to:PM_KOP_KAPTAIN
offset:GLYPH_MON_OFF
modelName:@"upperK"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Liches:(int)glyph
{

// Liches
return [ self checkLoadedModelsAt:PM_LICH
to:PM_ARCH_LICH
offset:GLYPH_MON_OFF
modelName:@"upperL"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Mummies:(int)glyph
{
// Mummies
return [ self checkLoadedModelsAt:PM_KOBOLD_MUMMY
to:PM_GIANT_MUMMY
offset:GLYPH_MON_OFF
modelName:@"upperM"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Nagas:(int)glyph
{
// Nagas
return [ self checkLoadedModelsAt:PM_RED_NAGA_HATCHLING
to:PM_GUARDIAN_NAGA
offset:GLYPH_MON_OFF
modelName:@"upperN"
textured:NO
withOut:0 ];


}


- ( id )loadModelFunc_Ogres:(int)glyph
{
// Ogres
id ret = nil;
switch ( glyph ) {

case PM_OGRE + GLYPH_MON_OFF :
case PM_OGRE_LORD + GLYPH_MON_OFF :

ret = [ self checkLoadedModelsAt:PM_OGRE
to:PM_OGRE_LORD
offset:GLYPH_MON_OFF
modelName:@"upperO"
textured:NO
withOut:0 ];
break;

case PM_OGRE_KING + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperO" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.15 atZ:-0.18 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
break;
}

return ret;
}


- ( id )loadModelFunc_Puddings:(int)glyph
{
// Puddings
return [ self checkLoadedModelsAt:PM_GRAY_OOZE
to:PM_GREEN_SLIME
offset:GLYPH_MON_OFF
modelName:@"upperP"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Quantummechanics:(int)glyph
{
// Quantum mechanics
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperQ" withTexture:NO ];
}


- ( id )loadModelFunc_Rustmonster:(int)glyph
{
// Rust monster or disenchanter
return [ self checkLoadedModelsAt:PM_RUST_MONSTER
to:PM_DISENCHANTER
offset:GLYPH_MON_OFF
modelName:@"upperR"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Snakes:(int)glyph
{
// Snakes
return [ self checkLoadedModelsAt:PM_GARTER_SNAKE
to:PM_COBRA
offset:GLYPH_MON_OFF
modelName:@"upperS"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Trolls:(int)glyph
{
// Trolls
return [ self checkLoadedModelsAt:PM_TROLL
to:PM_OLOG_HAI
offset:GLYPH_MON_OFF
modelName:@"upperT"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Umberhulk:(int)glyph
{
// Umber hulk
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperU" withTexture:NO ];

}


- ( id )loadModelFunc_Vampires:(int)glyph
{
// Vampires
id ret = nil;
switch ( glyph ) {
case PM_VAMPIRE + GLYPH_MON_OFF :
case PM_VAMPIRE_LORD + GLYPH_MON_OFF :

ret = [ self checkLoadedModelsAt:PM_VAMPIRE
to:PM_VAMPIRE_LORD
offset:GLYPH_MON_OFF
modelName:@"upperV"
textured:NO
withOut:0 ];

break;

case PM_VLAD_THE_IMPALER + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperV" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.15 atZ:-0.18 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
break;
}

return ret;

}


- ( id )loadModelFunc_Wraiths:(int)glyph
{
// Wraiths
return [ self checkLoadedModelsAt:PM_BARROW_WIGHT
to:PM_NAZGUL
offset:GLYPH_MON_OFF
modelName:@"upperW"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Xorn:(int)glyph
{
// Xorn
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperX" withTexture:NO ];

}


- ( id )loadModelFunc_Yeti:(int)glyph
{
// Yeti and other large beasts
return [ self checkLoadedModelsAt:PM_MONKEY
to:PM_SASQUATCH
offset:GLYPH_MON_OFF
modelName:@"upperY"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Zombie:(int)glyph
{
// Zombie
return [ self checkLoadedModelsAt:PM_KOBOLD_ZOMBIE
to:PM_SKELETON
offset:GLYPH_MON_OFF
modelName:@"upperZ"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_Golems:(int)glyph
{
// Golems
return [ self checkLoadedModelsAt:PM_STRAW_GOLEM
to:PM_IRON_GOLEM
offset:GLYPH_MON_OFF
modelName:@"backslash"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_HumanorElves:(int)glyph
{
// Human or Elves
id ret = nil;
switch ( glyph ) {

case PM_ELVENKING + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.18 atZ:0.0 ];
[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:11.7 rotateZ:0.0 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
break;

case PM_NURSE + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"nurse" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:1.00 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
break;

case PM_HIGH_PRIEST + GLYPH_MON_OFF :
case PM_MEDUSA + GLYPH_MON_OFF :
case PM_CROESUS + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;

case PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
[ [ ret childObjectAtLast ] addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setPivotX:-0.827 atY:1.968 atZ:1.793 ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleGravityX:-3.5 Y:1.5 Z:0.8 ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:1.5 Y:2.00 ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:1.8 ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleLife:0.5 ];
[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSize:6.0 ];

[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setPivotX:0.827 atY:-1.800 atZ:-1.793 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;
default:
ret = [ self checkLoadedModelsAt:PM_HUMAN
to:PM_WIZARD_OF_YENDOR
offset:GLYPH_MON_OFF
modelName:@"atmark"
textured:NO
withOut:PM_ELVENKING ,PM_NURSE ,PM_HIGH_PRIEST ,PM_MEDUSA ,
PM_CROESUS ,PM_WIZARD_OF_YENDOR,nil ];

break;

}

return ret;


}

*/
	private final func loadModelFunc_Ghosts(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModelsAt(PM_GHOST, to: PM_SHADE, offset: GLYPH_INVIS_OFF, modelName: "invisible", textured: false, withOut: 0)
	}
/*

- ( id )loadModelFunc_MajorDamons:(int)glyph
{
// Major Damons

if ( glyph != PM_DJINNI+GLYPH_MON_OFF || glyph != PM_SANDESTIN+GLYPH_MON_OFF ) {
return [ self checkLoadedModelsAt:PM_WATER_DEMON
to:PM_BALROG
offset:GLYPH_MON_OFF
modelName:@"and"
textured:NO
withOut:0 ];
} else {
return [ self checkLoadedModelsAt:PM_DJINNI
to:PM_SANDESTIN
offset:GLYPH_MON_OFF
modelName:@"and"
textured:NO
withOut:0 ];
}
}


- ( id )loadModelFunc_GraterDamons:(int)glyph
{
// Grater Damons
id ret = nil;

if ( glyph == PM_JUIBLEX + GLYPH_MON_OFF ) {
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
} else {

ret = [ self checkLoadedModelsAt:PM_YEENOGHU
to:PM_DEMOGORGON
offset:GLYPH_MON_OFF
modelName:@"and"
textured:NO
withOut:0 ];
if ( ![ ret hasChildObject ] ) {
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.52 atZ:0.0 ];
[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:0.7 rotateZ:0.0 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
}
}
return ret;
}


- ( id )loadModelFunc_Riders:(int)glyph
{
// damon "The Riders"
id ret = nil;

ret = [ self checkLoadedModelsAt:PM_DEATH
to:PM_FAMINE
offset:GLYPH_MON_OFF
modelName:@"and"
textured:NO
withOut:0 ];

if ( ![ ret hasChildObject ] ) {
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:15.0 ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
}

return ret;
}


- ( id )loadModelFunc_seamonsters:(int)glyph
{
// sea monsters
return [ self checkLoadedModelsAt:PM_JELLYFISH
to:PM_KRAKEN
offset:GLYPH_MON_OFF
modelName:@"semicoron"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_lizards:(int)glyph
{
// lizards
return [ self checkLoadedModelsAt:PM_NEWT
to:PM_SALAMANDER
offset:GLYPH_MON_OFF
modelName:@"coron"
textured:NO
withOut:0 ];

}


- ( id )loadModelFunc_wormtail:(int)glyph
{
// wormtail
return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"wormtail" withTexture:NO ];
}


- ( id )loadModelFunc_Adventures:(int)glyph
{
// Adventures
id ret = nil;

if ( glyph == PM_WIZARD + GLYPH_MON_OFF ) {
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
} else {
ret = [ self checkLoadedModelsAt:PM_ARCHEOLOGIST
to:PM_VALKYRIE
offset:GLYPH_MON_OFF
modelName:@"atmark"
textured:NO
withOut:0 ];
}

return ret;

}


- ( id )loadModelFunc_Uniqueperson:(int)glyph
{
// Unique person
id ret = nil;

switch ( glyph ) {

case PM_KING_ARTHUR + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.18 atZ:0.0 ];
[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:11.7 rotateZ:0.0 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;


case PM_NEFERET_THE_GREEN + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;

case PM_MINION_OF_HUHETOTL + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;


case PM_THOTH_AMON + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;


case PM_CHROMATIC_DRAGON + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperD" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

case PM_CYCLOPS + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperH" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

case PM_IXOTH + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperD" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

case PM_MASTER_KAEN + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;

case PM_NALZOK + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;

case PM_SCORPIUS + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerS" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;

case PM_MASTER_ASSASSIN + GLYPH_MON_OFF :
case PM_ASHIKAGA_TAKAUJI + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break ;

case PM_LORD_SURTUR + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperH" withTexture:NO ];
[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.18 atZ:0.0 ];
[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:11.7 rotateZ:0.0 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

case PM_DARK_ONE + GLYPH_MON_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

default:

if ( glyph >=PM_LORD_CARNARVON + GLYPH_MON_OFF && glyph <= PM_NORN + GLYPH_MON_OFF ) {
ret = [ self checkLoadedModelsAt:PM_LORD_CARNARVON
to:PM_NORN
offset:GLYPH_MON_OFF
modelName:@"atmark"
textured:NO
withOut:PM_KING_ARTHUR, 0];

if ( ![ ret hasChildObject ] ) {
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
}
} else {

ret = [ self checkLoadedModelsAt:PM_STUDENT
to:PM_APPRENTICE
offset:GLYPH_MON_OFF
modelName:@"atmark"
textured:NO
withOut:0 ];
}

break;
}

return ret;

}

// -------------------------- Map Symbol Section ----------------------------- //

- ( id )loadModelFunc_MapSymbols:(int)glyph
{
//  Map Symbols
id ret = nil;

switch ( glyph ) {
case S_bars + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"ironbar" withTexture:YES ];
break;

case S_tree + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"tree" withTexture:YES ];
[ ret setModelScaleX:2.5 scaleY:1.7 scaleZ:2.5 ];
break;

case S_upstair + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upStair" withTexture:YES ];
break;

case S_dnstair + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"downStair" withTexture:YES ];
break;

case S_upladder + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upladder" withTexture:YES ];
break;

case S_dnladder + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"downladder" withTexture:YES ];
break;

case S_altar + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"alter" withTexture:YES ];
break;

case S_grave + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"grave" withTexture:YES ];
[ ret setModelScaleX:0.6 scaleY:0.6 scaleZ:0.6 ];
break;

case S_throne + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"opulent_throne" withTexture:YES ];
break;

case S_sink + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"sink" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:1.277 atZ:-0.812 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypePoints ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:-8.8 Z:1.0 ];
[ [ ret childObjectAtLast ] setParticleLife:0.21 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.687 atZ:0.512 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypePoints ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:-5.8 Z:1.0 ];
[ [ ret childObjectAtLast ] setParticleLife:0.3 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

case S_fountain + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"fountain" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:-0.34 atY:2.68 atZ:0.65 ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.1 Z:0.08 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_BLUE ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-130.0 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
[ [ ret childObjectAtLast ] setParticleLife:0.8 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:0.34 atY:-1.70 atZ:-0.65 ];
[ [ ret childObjectAtLast ] setModelScaleX:0.98 scaleY:0.7 scaleZ:0.98 ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.1 Z:0.00 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BLUE ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-130.0 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
[ [ ret childObjectAtLast ] setParticleLife:0.28 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setModelScaleX:0.5 scaleY:0.7 scaleZ:0.5 ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:1.35 atZ:-0.0 ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.4 Z:0.00 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BLUE ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-190.0 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
[ [ ret childObjectAtLast ] setParticleLife:1.2 ];
[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
break;

case S_vodbridge + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridgeUP" withTexture:YES ];
[ ret setModelRotateX:0 rotateY:-90 rotateZ:0 ];
[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
break;

case S_hodbridge + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridge" withTexture:YES ];
[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:4.0 atY:0.0 atZ:0.0 ];
break;

case S_vcdbridge + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridgeUP" withTexture:YES ];
[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
break;

case S_hcdbridge + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridge" withTexture:YES ];
[ ret setModelRotateX:0 rotateY:-90 rotateZ:0 ];
[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
[ [ ret childObjectAtLast ] setPivotX:4.0 atY:0.0 atZ:0.0 ];
break;

}

return ret;

}


- ( id )loadModelFunc_Boulder:(int)glyph
{
// Boulder

return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"boulder" withTexture:YES ];

}


- ( id )loadModelFunc_TrapSymbol:(int)glyph
{
// Trap Symbol
id ret =  nil;

switch ( glyph ) {

case S_arrow_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"arrowtrap" withTexture:YES ];
break;
case S_dart_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"dartstrap" withTexture:YES ];
break;
case S_falling_rock_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"rockfalltrap" withTexture:YES ];
break;
//case S_squeaky_board + GLYPH_CMAP_OFF :
case S_land_mine + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"landmine" withTexture:YES ];
break;
//case S_rolling_boulder_trap + GLYPH_CMAP_OFF :
case S_sleeping_gas_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"gastrap" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.5 atZ:0.0 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.0 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_MAGENTA ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:300 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:5.2 ];
[ [ ret childObjectAtLast ] setParticleLife:0.56 ];
[ [ ret childObjectAtLast ] setParticleSize:5.0 ];
break;

case S_rust_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"gastrap" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.5 atZ:0.0 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.0 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_GREEN ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:300.0 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:5.2 ];
[ [ ret childObjectAtLast ] setParticleLife:0.56 ];
[ [ ret childObjectAtLast ] setParticleSize:5.0 ];
break;

case S_fire_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"gastrap" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.5 atZ:0.0 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
[ [ ret childObjectAtLast ] setParticleSize:4.0 ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-1.0 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_ORANGE ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:200 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:2.0 ];
[ [ ret childObjectAtLast ] setParticleLife:0.5 ];
break;

case S_bear_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"beartrap" withTexture:YES ];
break;
case S_pit + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"pit" withTexture:YES ];
break;
case S_spiked_pit + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"spikepit" withTexture:YES ];
break;
case S_hole + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"pit" withTexture:YES ];
break;
case S_trap_door + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"pit" withTexture:YES ];
break;
case S_teleportation_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"telporter" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:3.82 atZ:0.75917 ];
[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.8 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.23 ];
[ [ ret childObjectAtLast ] setIsChild:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:0.42 atZ:0.75917 ];
[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:4.8 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.25 ];
break;

case S_level_teleporter + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"leveltelporter" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:3.82 atZ:0.75917 ];
[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.8 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.23 ];
[ [ ret childObjectAtLast ] setIsChild:NO ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:0.42 atZ:0.75917 ];
[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:4.8 Z:0 ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_MAGENTA ];
[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.25 ];
break;

case S_magic_portal + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"magicportal" withTexture:YES ];
[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
[ [ ret childObjectAtLast ] setModelScaleX:0.8 scaleY:0.7 scaleZ:0.8 ];
[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_BLUE ];
[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
[ [ ret childObjectAtLast ] setParticleLife:0.4 ];
[ [ ret childObjectAtLast ] setParticleSize:2.0 ];
break;

//case S_web + GLYPH_CMAP_OFF :
//case S_statue_trap + GLYPH_CMAP_OFF :

case S_magic_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelScaleX:0.7 scaleY:0.4 scaleZ:0.7 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_BRIGHT_MAGENTA ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:8.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:10.0 ];
break;

case S_anti_magic_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelScaleX:0.7 scaleY:0.4 scaleZ:0.7 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_CYAN ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:8.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:10.0 ];
break;

case S_polymorph_trap + GLYPH_CMAP_OFF :
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelScaleX:0.7 scaleY:0.4 scaleZ:0.7 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_BROWN ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:8.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:10.0 ];
break;

}

return ret;

}

// ------------------------- Effect Symbols Section. ------------------------- //

// ZAP symbols ( NUM_ZAP * four directions )


- ( id )loadModelFunc_MagicMissile:(int)glyph
{
// type Magic Missile
id ret = nil;

switch ( glyph ) {

case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
break;

case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
break;

case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
break;

case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
break;

}

return ret;

}


- ( id )loadModelFunc_MagicFIRE:(int)glyph
{
// type Magic FIRE
id ret = nil;

switch ( glyph ) {

case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
break;

case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
break;

case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
break;

case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
break;
}

return ret;

}


- ( id )loadModelFunc_MagicCOLD:(int)glyph
{
// type Magic COLD
id ret = nil;

switch ( glyph ) {
case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
break;

case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
break;

case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
break;

case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
break;

}

return ret;
}


- ( id )loadModelFunc_MagicSLEEP:(int)glyph
{
// type Magic SLEEP
id ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setPivotX:0.0 atY:1.2 atZ:0.0 ];
[ ret setModelScaleX:1.0 scaleY:1.0 scaleZ:1.0 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_MAGENTA ];
//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
[ ret setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:3.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:20.0 ];

return ret;
}


- ( id )loadModelFunc_MagicDEATH:(int)glyph
{
// type Magic DEATH
id ret = nil;

switch ( glyph ) {
case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
// :CLR_BLACK ]; // if you want sync to 'zapcolors' from decl.c
break;

case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
break;

case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
break;

case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
break;
}

return ret;

}


- ( id )loadModelFunc_MagicLIGHTNING:(int)glyph
{
// type Magic LIGHTNING
id ret = nil;

switch ( glyph ) {

case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
break;

case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
break;

case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
break;

case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
break;
}

return ret;
}


- ( id )loadModelFunc_MagicPOISONGAS:(int)glyph
{
// type Magic POISONGAS
id ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setPivotX:0.0 atY:1.2 atZ:0.0 ];
[ ret setModelScaleX:1.0 scaleY:1.0 scaleZ:1.0 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_GREEN ];
//[ ret setParticleColor:CLR_YELLOW ]; // if you want sync to 'zapcolors' from decl.c
[ ret setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:3.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:20.0 ];

return ret;
}


- ( id )loadModelFunc_MagicACID:(int)glyph
{
// type Magic ACID
id ret = nil;

switch ( glyph ) {

case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
// :CLR_GREEN ]; // if you want sync to 'zapcolors' from decl.c
break;

case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
break;

case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
break;

case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
break;
}

return ret;
}


- ( id )loadModelFunc_MagicETC:(int)glyph
{
id ret = nil;

switch ( glyph ) {
// dig beam
case S_digbeam + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelScaleX:0.7 scaleY:1.0 scaleZ:0.7 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_BROWN ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:3.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:20.0 ];
break;

// camera flash
case S_flashbeam + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setModelScaleX:1.4 scaleY:1.5 scaleZ:1.4 ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_WHITE ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:3.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:20.0 ];
break;

// boomerang
//case S_boomleft + GLYPH_CMAP_OFF :
//case S_boomright + GLYPH_CMAP_OFF :
}

return ret;
}


- ( id )loadModelFunc_MagicSHILD:(int)glyph
{
// magic shild
id ret = nil;

switch ( glyph ) {
case S_ss1 + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_BRIGHT_BLUE ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:3.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:20.0 ];
break;

case S_ss2 + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_BRIGHT_CYAN ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:8.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:10.0 ];
break;

case S_ss3 + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_WHITE ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:3.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:20.0 ];
break;

case S_ss4 + GLYPH_CMAP_OFF:
ret = [ [ NH3DModelObjects alloc ] init ];
[ ret setParticleType:NH3DParticleTypeAura ];
[ ret setParticleColor:CLR_BLUE ];
[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
[ ret setParticleSpeedX:1.0 Y:1.00 ];
[ ret setParticleSlowdown:8.8 ];
[ ret setParticleLife:0.4 ];
[ ret setParticleSize:10.0 ];
break;
}

return ret;
}

// explotion symbols ( 9 postion * 7 types )
- ( id )loadModelFunc_explotionDARK:(int)glyph
{
id	ret;

//  type DARK
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_DARK
to:NH3D_EXPLODE_DARK + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_GRAY ];

return ret;
}


- ( id )loadModelFunc_explotionNOXIOUS:(int)glyph
{
id	ret;
//  type NOXIOUS
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_NOXIOUS
to:NH3D_EXPLODE_NOXIOUS + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_GREEN ];

return ret;
}


- ( id )loadModelFunc_explotionMUDDY:(int)glyph
{
id	ret;
//  type MUDDY
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_MUDDY
to:NH3D_EXPLODE_MUDDY + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_BROWN ];

return ret;

}


- ( id )loadModelFunc_explotionWET:(int)glyph
{
id	ret;
//  type WET
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_WET
to:NH3D_EXPLODE_WET + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_BLUE ];

return ret;
}


- ( id )loadModelFunc_explotionMAGICAL:(int)glyph
{
id	ret;
//  type MAGICAL
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_MAGICAL
to:NH3D_EXPLODE_MAGICAL + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_BRIGHT_MAGENTA ];

return ret;

}


- ( id )loadModelFunc_explotionFIERY:(int)glyph
{
id	ret;
//  type FIERY
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_FIERY
to:NH3D_EXPLODE_FIERY + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_ORANGE ];

return ret;

}


- ( id )loadModelFunc_explotionFROSTY:(int)glyph
{
id	ret;
//  type FROSTY
ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_FROSTY
to:NH3D_EXPLODE_FROSTY + MAXEXPCHARS
offset:0
modelName:@"emitter"
textured:NO
withOut:0 ];

[ self setParamsForMagicExplotion:ret color:CLR_BRIGHT_CYAN ];

return ret;

}


*/
	
}
