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

//! the Eyes operate even when you really are blind or don't have any eyes.
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

NS_SWIFT_NAME(objectToGlyph(_:))
static inline int Swift_objToGlyph(struct obj *__nonnull obj2)
{
	return obj_to_glyph(obj2);
}


//! returns \c true if the passed-in level is on the astral plane.
NS_SWIFT_NAME(isAstralLevel(_:))
static inline bool Swift_Is_astralevel(d_level *__nonnull xx)
{
	return Is_astralevel(xx);
}

//! returns \c true if the passed-in level is on the plane of earth.
NS_SWIFT_NAME(isEarthLevel(_:))
static inline bool Swift_Is_earthlevel(d_level *__nonnull xx)
{
	return Is_earthlevel(xx);
}

//! returns \c true if the passed-in level is on the plane of water.
NS_SWIFT_NAME(isWaterLevel(_:))
static inline bool Swift_Is_waterlevel(d_level *__nonnull xx)
{
	return Is_waterlevel(xx);
}

//! returns \c true if the passed-in level is on the plane of fire.
NS_SWIFT_NAME(isFireLevel(_:))
static inline bool Swift_Is_firelevel(d_level *__nonnull xx)
{
	return Is_firelevel(xx);
}

//! returns \c true if the passed-in level is on the plane of air.
NS_SWIFT_NAME(isAirLevel(_:))
static inline bool Swift_Is_airlevel(d_level *__nonnull xx)
{
	return Is_airlevel(xx);
}

//! returns \c true if the passed-in level is Medusa's lair.
NS_SWIFT_NAME(isMedusaLevel(_:))
static inline bool Swift_Is_medusa_level(d_level *__nonnull xx)
{
	return Is_medusa_level(xx);
}

//! returns \c true if the passed-in level has the oracle.
NS_SWIFT_NAME(isOracleLevel(_:))
static inline bool Swift_Is_oracle_level(d_level *__nonnull xx)
{
	return Is_oracle_level(xx);
}

//! returns \c true if the passed-in level is the valley.
NS_SWIFT_NAME(isValley(_:))
static inline bool Swift_Is_valley(d_level *__nonnull xx)
{
	return Is_valley(xx);
}

//! returns \c true if the passed-in level is Juiblex's lair.
NS_SWIFT_NAME(isJuiblexLevel(_:))
static inline bool Swift_Is_juiblex_level(d_level *__nonnull xx)
{
	return Is_juiblex_level(xx);
}

//! returns \c true if the passed-in level is Asmodeus' lair.
NS_SWIFT_NAME(isAsmodeusLevel(_:))
static inline bool Swift_Is_asmo_level(d_level *__nonnull xx)
{
	return Is_asmo_level(xx);
}

//! returns \c true if the passed-in level is Ballzebub's lair.
NS_SWIFT_NAME(isBaalzebubLevel(_:))
static inline bool Swift_Is_baal_level(d_level *__nonnull xx)
{
	return Is_baal_level(xx);
}

//! returns \c true if the passed-in level is the first wizard level.
NS_SWIFT_NAME(isWizardLevel1(_:))
static inline bool Swift_Is_wiz1_level(d_level *__nonnull xx)
{
	return Is_wiz1_level(xx);
}

//! returns \c true if the passed-in level is the second wizard level.
NS_SWIFT_NAME(isWizardLevel2(_:))
static inline bool Swift_Is_wiz2_level(d_level *__nonnull xx)
{
	return Is_wiz2_level(xx);
}

//! returns \c true if the passed-in level is the third wizard level.
NS_SWIFT_NAME(isWizardLevel3(_:))
static inline bool Swift_Is_wiz3_level(d_level *__nonnull xx)
{
	return Is_wiz3_level(xx);
}

//! returns \c true if the passed-in level is the sanctum level.
NS_SWIFT_NAME(isSanctum(_:))
static inline bool Swift_Is_sanctum(d_level *__nonnull xx)
{
	return Is_sanctum(xx);
}

//! returns \c true if the passed-in level has the portal.
NS_SWIFT_NAME(isPortalLevel(_:))
static inline bool Swift_Is_portal_level(d_level *__nonnull xx)
{
	return Is_portal_level(xx);
}

//! returns \c true if the passed-in level is the rogue level.
NS_SWIFT_NAME(isRogueLevel(_:))
static inline bool Swift_Is_rogue_level(d_level *__nonnull xx)
{
	return Is_rogue_level(xx);
}

//! returns \c true if the passed-in level is the stronghold level.
NS_SWIFT_NAME(isStrongholdLevel(_:))
static inline bool Swift_Is_stronghold(d_level *__nonnull xx)
{
	return Is_stronghold(xx);
}

//! returns \c true if the passed-in level is a big room.
NS_SWIFT_NAME(isBigRoom(_:))
static inline bool Swift_Is_bigroom(d_level *__nonnull xx)
{
	return Is_bigroom(xx);
}

//! returns \c true if the passed-in level is where the quest starting location is.
NS_SWIFT_NAME(isQuestStart(_:))
static inline bool Swift_Is_qstart(d_level *__nonnull xx)
{
	return Is_qstart(xx);
}

//! returns \c true if the passed-in level is where the quest's destination is.
NS_SWIFT_NAME(isQuestLocation(_:))
static inline bool Swift_Is_qlocate(d_level *__nonnull xx)
{
	return Is_qlocate(xx);
}

//! returns \c true if the passed-in level is where the nemesis starts.
NS_SWIFT_NAME(isNemesis(_:))
static inline bool Swift_Is_nemesis(d_level *__nonnull xx)
{
	return Is_nemesis(xx);
}

//! returns \c true if the passed-in level is Fort Knox.
NS_SWIFT_NAME(isFortKnox(_:))
static inline bool Swift_Is_knox(d_level *__nonnull xx)
{
	return Is_knox(xx);
}

//! returns \c true if the passed-in level is the end of the mines.
NS_SWIFT_NAME(isMineEndLevel(_:))
static inline bool Swift_Is_mineend_level(d_level *__nonnull xx)
{
	return Is_mineend_level(xx);
}

//! returns \c true if the passed-in level is the last Sokoban level.
NS_SWIFT_NAME(isSokobanEndLevel(_:))
static inline bool Swift_Is_sokoend_level(d_level *__nonnull xx)
{
	return Is_sokoend_level(xx);
}

//! returns \c true if the passed-in level is a Sokoban level.
NS_SWIFT_NAME(inSokoban(_:))
static inline bool Swift_In_sokoban(d_level *__nonnull xx)
{
	return In_sokoban(xx);
}

//! returns \c true if the player is in hell, renamed gehennom.
static inline bool Swift_Inhell(void)
{
	return Inhell;
}

//! returns \c true if the passed-in level is near the end.
NS_SWIFT_NAME(inEndgame(_:))
static inline bool Swift_In_endgame(d_level *__nonnull xx)
{
	return In_endgame(xx);
}

//! means blind because of a cover.
static inline bool Swift_Blindfolded()
{
	return Blindfolded;
}

//! blind because of a blindfold, and \b only that.
static inline bool Swift_Blindfolded_only()
{
	return Blindfolded_only;
}

NS_SWIFT_NAME(monsterAt(x:y:))
static inline struct monst * __nullable Swift_m_at(int xx, int yy)
{
	return m_at(xx, yy);
}

NS_SWIFT_NAME(monsterBuriedAt(x:y:))
static inline struct monst * __nullable Swift_m_buried_at(int xx, int yy)
{
	return m_buried_at(xx, yy);
}

#endif /* NH3DSwiftBridging_h */
