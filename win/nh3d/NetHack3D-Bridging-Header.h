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

NS_SWIFT_NAME(roomAtLocation(x:y:))
static inline struct rm Swift_RoomAtLocation(xchar x, xchar y)
{
	return level.locations[x][y];
}

NS_SWIFT_NAME(isSoft(_:))
static inline BOOL Swift_IsSoft(schar type) {
	return !!IS_SOFT(type);
}

/*! ROOM, STAIRS, furniture.. */
NS_SWIFT_NAME(isRoom(_:))
static inline BOOL Swift_IsRoom(schar type) {
	return !!IS_ROOM(type);
}

NS_SWIFT_NAME(isWall(_:))
static inline BOOL Swift_IsWall(schar type) {
	return !!IS_WALL(type);
}

NS_SWIFT_NAME(isStoneWall(_:))
static inline BOOL Swift_IsStoneWall(schar type) {
	return !!IS_STWALL(type);
}

/*! absolutely nonaccessible */
NS_SWIFT_NAME(isRock(_:))
static inline BOOL Swift_IsRock(schar type) {
	return !!IS_ROCK(type);
}

NS_SWIFT_NAME(isDoor(_:))
static inline BOOL Swift_IsDoor(schar type) {
	return !!IS_DOOR(type);
}

NS_SWIFT_NAME(isTree(_:))
static inline BOOL Swift_IsTree(schar type) {
	return !!IS_TREE(type);
}

/*! good position */
NS_SWIFT_NAME(isAccessible(_:))
static inline BOOL Swift_Accessible(schar type) {
	return !!ACCESSIBLE(type);
}


NS_SWIFT_NAME(isPool(_:))
static inline BOOL Swift_IsPool(schar type) {
	return !!IS_POOL(type);
}

NS_SWIFT_NAME(isThrone(_:))
static inline BOOL Swift_IsThrone(schar type) {
	return !!IS_THRONE(type);
}

NS_SWIFT_NAME(isFountain(_:))
static inline BOOL Swift_IsFountain(schar type) {
	return !!IS_FOUNTAIN(type);
}

NS_SWIFT_NAME(isSink(_:))
static inline BOOL Swift_IsSink(schar type) {
	return !!IS_SINK(type);
}

NS_SWIFT_NAME(isGrave(_:))
static inline BOOL Swift_IsGrave(schar type) {
	return !!IS_GRAVE(type);
}

NS_SWIFT_NAME(isAltar(_:))
static inline BOOL Swift_IsAltar(schar type) {
	return !!IS_ALTAR(type);
}

NS_SWIFT_NAME(isDrawbridge(_:))
static inline BOOL Swift_IsDrawbridge(schar type) {
	return !!IS_DRAWBRIDGE(type);
}

NS_SWIFT_NAME(isFurniture(_:))
static inline BOOL Swift_IsFurniture(schar type) {
	return !!IS_FURNITURE(type);
}

NS_SWIFT_NAME(isAir(_:))
static inline BOOL Swift_IsAir(schar type) {
	return !!IS_AIR(type);
}

/*! from tile.c */
extern int total_tiles_used;

/// Transforms the specified glyph into a tile
static inline short glyphToTile(int i)
{
	extern short glyph2tile[];
	return glyph2tile[i];
}

__dead2 NS_SWIFT_NAME(panic(_:))
static inline void Swift_Panic(const char *panicText)
{
	panic("%s", panicText);
	//should never be called
	abort();
}
