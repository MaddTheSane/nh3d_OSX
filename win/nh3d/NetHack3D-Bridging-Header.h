//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include "C99Bool.h"
#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"
#import "NH3DMapItem.h"
#import "NH3DMapView.h"
#import "NH3DModelObject.h"
#import "winnh3d.h"
#include "extern.h"

#import "Hearse.h"

static inline BOOL Swift_Invis() {
	return !!Invis;
}

/// Returns \c true if player is stealthy.
static inline BOOL Swift_Stealth() {
	return !!Stealth;
}

/// Returns \c true if player is blind.
static inline BOOL Swift_Blind() {
	return !!Blind;
}

/// Returns \c true if player is underwater.
static inline BOOL Swift_Underwater() {
	return !!Underwater;
}

static inline BOOL Swift_Teleportation() {
	return !!Teleportation;
}

/// Returns \c true if player has teleportation control
static inline BOOL Swift_Teleport_control() {
	return !!Teleport_control;
}

static inline BOOL Swift_Hallucination() {
	return !!Hallucination;
}

static inline BOOL Swift_Flying() {
	return !!Flying;
}

/// Returns \c true if player is levitating
static inline BOOL Swift_Levitation() {
	return !!Levitation;
}

static inline BOOL Swift_Swimming() {
	return !!Swimming;
}

static inline BOOL Swift_Amphibious() {
	return !!Amphibious;
}

/// Returns \c true if player has infravision.
static inline BOOL Swift_Infravision() {
	return !!Infravision;
}

static inline struct rm Swift_RoomAtLocation(xchar x, xchar y)
{
	return level.locations[x][y];
}

static inline BOOL Swift_IsSoft(schar type) {
	return !!IS_SOFT(type);
}

static inline BOOL Swift_IsRoom(schar type) {
	return !!IS_ROOM(type);
}

/* from tile.c */
extern int total_tiles_used;

/// Transforms the specified glyph into a tile
static inline short glyphToTile(int i)
{
	extern short glyph2tile[];
	return glyph2tile[i];
}

__dead2
static inline void Swift_Panic(const char *panicText)
{
	panic("%s", panicText);
	//should never be called
	abort();
}
