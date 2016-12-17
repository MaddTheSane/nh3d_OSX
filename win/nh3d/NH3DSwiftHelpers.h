//
//  NH3DSwiftBridging.h
//  NetHack3D
//
//  Created by C.W. Betts on 11/22/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

#ifndef NH3DSwiftBridging_h
#define NH3DSwiftBridging_h

#include <stdbool.h>
#include "C99Bool.h"
//#import "NH3Dcommon.h"
#import <Foundation/NSObjCRuntime.h>

#include "extern.h"

static inline BOOL Swift_Invis() {
	return (bool)Invis;
}

/// Returns \c true if player is stealthy.
static inline BOOL Swift_Stealth() {
	return (bool)Stealth;
}

/// Returns \c true if player is blind.
static inline BOOL Swift_Blind() {
	return (bool)Blind;
}

/// Returns \c true if player is underwater.
static inline BOOL Swift_Underwater() {
	return (bool)Underwater;
}

/// Returns \c true if player can teleport at will
static inline BOOL Swift_Teleportation() {
	return (bool)Teleportation;
}

/// Returns \c true if player has teleportation control
static inline BOOL Swift_Teleport_control() {
	return (bool)Teleport_control;
}

/// Returns \c true if player is hallucinating
static inline BOOL Swift_Hallucination() {
	return (bool)Hallucination;
}

/// Returns \c true if player is flying
static inline BOOL Swift_Flying() {
	return (bool)Flying;
}

/// Returns \c true if player is levitating
static inline BOOL Swift_Levitation() {
	return (bool)Levitation;
}

/// Returns \c true if player can levitate at will
static inline BOOL Swift_LevitationAtWill() {
	return Lev_at_will;
}

/// Returns \c true if player is swimming underwater
static inline BOOL Swift_Swimming() {
	return (bool)Swimming;
}

static inline BOOL Swift_Amphibious() {
	return (bool)Amphibious;
}

/// Returns \c true if player has infravision.
static inline BOOL Swift_Infravision() {
	return (bool)Infravision;
}

NS_SWIFT_NAME(roomAtLocation(x:y:))
static inline struct rm Swift_RoomAtLocation(xchar x, xchar y)
{
	return level.locations[x][y];
}

NS_SWIFT_NAME(isSoft(_:))
static inline BOOL Swift_IsSoft(schar type) {
	return IS_SOFT(type);
}

/*! ROOM, STAIRS, furniture.. */
NS_SWIFT_NAME(isRoom(_:))
static inline BOOL Swift_IsRoom(schar type) {
	return IS_ROOM(type);
}

NS_SWIFT_NAME(isWall(_:))
static inline BOOL Swift_IsWall(schar type) {
	return IS_WALL(type);
}

NS_SWIFT_NAME(isStoneWall(_:))
static inline BOOL Swift_IsStoneWall(schar type) {
	return IS_STWALL(type);
}

/*! absolutely nonaccessible */
NS_SWIFT_NAME(isRock(_:))
static inline BOOL Swift_IsRock(schar type) {
	return IS_ROCK(type);
}

NS_SWIFT_NAME(isDoor(_:))
static inline BOOL Swift_IsDoor(schar type) {
	return IS_DOOR(type);
}

NS_SWIFT_NAME(isTree(_:))
static inline BOOL Swift_IsTree(schar type) {
	return IS_TREE(type);
}

/*! good position */
NS_SWIFT_NAME(isAccessible(_:))
static inline BOOL Swift_Accessible(schar type) {
	return ACCESSIBLE(type);
}


NS_SWIFT_NAME(isPool(_:))
static inline BOOL Swift_IsPool(schar type) {
	return IS_POOL(type);
}

NS_SWIFT_NAME(isThrone(_:))
static inline BOOL Swift_IsThrone(schar type) {
	return IS_THRONE(type);
}

NS_SWIFT_NAME(isFountain(_:))
static inline BOOL Swift_IsFountain(schar type) {
	return IS_FOUNTAIN(type);
}

NS_SWIFT_NAME(isSink(_:))
static inline BOOL Swift_IsSink(schar type) {
	return IS_SINK(type);
}

NS_SWIFT_NAME(isGrave(_:))
static inline BOOL Swift_IsGrave(schar type) {
	return IS_GRAVE(type);
}

NS_SWIFT_NAME(isAltar(_:))
static inline BOOL Swift_IsAltar(schar type) {
	return IS_ALTAR(type);
}

NS_SWIFT_NAME(isDrawbridge(_:))
static inline BOOL Swift_IsDrawbridge(schar type) {
	return IS_DRAWBRIDGE(type);
}

NS_SWIFT_NAME(isFurniture(_:))
static inline BOOL Swift_IsFurniture(schar type) {
	return IS_FURNITURE(type);
}

NS_SWIFT_NAME(isAir(_:))
static inline BOOL Swift_IsAir(schar type) {
	return IS_AIR(type);
}

/// Returns the amount of tiles used by NetHack.
static inline int totalTilesUsed()
{
	/* from tile.c */
	extern int total_tiles_used;
	return total_tiles_used;
}

/// Transforms the specified glyph into a tile
static inline short glyphToTile(int i)
{
	/* from tile.c */
	extern short glyph2tile[];
	return glyph2tile[i];
}

NS_SWIFT_NAME(glyphIsMonster(_:))
static inline BOOL Swift_glyphIsMonster(int glyph1)
{
	return glyph_is_monster(glyph1);
}

/// Something really bad happened!
__dead2 NS_SWIFT_NAME(panic(_:))
static inline void Swift_Panic(const char *__nonnull panicText)
{
	panic("%s", panicText);
	//should never be called
	abort();
}


#endif /* NH3DSwiftBridging_h */
