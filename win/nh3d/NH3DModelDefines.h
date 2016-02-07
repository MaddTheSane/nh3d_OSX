//
//  NH3DModelDefines.h
//  NetHack3D
//
//  Created by C.W. Betts on 2/7/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

#ifndef NH3DModelDefines_h
#define NH3DModelDefines_h

#include <stdio.h>

//checkLoadedModels(at startNum: Int32, to endNum: Int32, offset: Int32 = GLYPH_MON_OFF, modelName: String, textured flag: Bool, without: Int32...)
typedef struct NH3DModelRange {
	int startNum;
	int endNum;
	int offset;
	const char *rangeName;
} NH3DModelRange;

typedef struct NH3DMonsterDefines {
	int number;
	const char* string;
} NH3DMonsterDefines;

//There's no guantee that these are all in order...
extern NH3DMonsterDefines* monsterDefines;
extern const long numberOfMonsters;

#endif /* NH3DModelDefines_h */
