//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"
#import "NH3DMapItem.h"
#import "NH3DMapView.h"
#import "NH3DModelObject.h"
#import "winnh3d.h"
#include "NH3DModelDefines.h"

static inline BOOL Swift_Invis() {
	return !!Invis;
}

static inline BOOL Swift_Blind() {
	return !!Blind;
}

static inline BOOL Swift_Underwater() {
	return !!Underwater;
}

static inline struct rm Swift_RoomAtLocation(xchar x, xchar y)
{
	return levl[x][y];
}

static inline BOOL Swift_IsSoft(schar type) {
	return !!IS_SOFT(type);
}

static inline BOOL Swift_IsRoom(schar type) {
	return !!IS_ROOM(type);
}

/* from tile.c */
extern int total_tiles_used;

static inline short glyphToTile(size_t i)
{
	extern short glyph2tile[];
	return glyph2tile[i];
}

static inline BOOL Swift_Hallucination() {
	return !!Hallucination;
}

static inline BOOL Swift_Flying() {
	return !!Flying;
}

static inline BOOL Swift_Levitation() {
	return !!Levitation;
}

__dead2
static inline void Swift_Panic(const char *panicText)
{
	panic("%s", panicText);
	//should never be called
	abort();
}
