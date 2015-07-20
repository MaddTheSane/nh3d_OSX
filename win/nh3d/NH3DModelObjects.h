/*
 *  NH3DModelObjects.h"
 *  NetHack3D
 *
 *  Created by Haruumi Yoshino on 05/10/20.
 *  Copyright 2005 Haruumi Yoshino. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
//#import <OpenGL/gl.h>
#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"

typedef struct nh3d_point3 {
	float x, y, z;
} NH3DVertexType;


typedef struct nh3d_face3 {
    unsigned short  a,b,c;
} NH3DFaceType;


typedef struct {
    float s,t;
} NH3DMapCoordType;


typedef float NH3DMaterialType[4];


typedef struct {
	NH3DMaterialType	ambient;
	NH3DMaterialType	diffuse;
	NH3DMaterialType	specular;
	NH3DMaterialType	emission;
	float				shininess;
} NH3DMaterial;


typedef struct {
	BOOL active;	
	float life;    /* model life */
	float fade;    /* Fade speed */	
	float r;       /* Red value */
	float g;       /* Green value */
	float b;       /* Blue value */	
	float x;       /* X position */
	float y;       /* Y position */
	float z;       /* Z position */
	float xi;      /* X direction */
	float yi;      /* Y direction */
	float zi;      /* Z direction */	
	float xg;      /* X gravity */
	float yg;      /* Y gravity */
	float zg;      /* Z gravity */
} NH3DParticle;


@interface NH3DModelObjects : NSObject {
	
	BOOL				active;
	NSString			*modelName;					/* model name from data */
	NSString			*modelCode;					/* model name from filename */
	unsigned short		verts_qty;					/* vertex counts */
	unsigned short		face_qty;					/* faces counts */
	unsigned short		normal_qty;					/* normal counts */
	unsigned short		texcords_qty;				/* texcoords counts */
//	NH3DFaceType		texReference[MAX_POLYGONS];	/* OBJ face optional texture reference */
//	NH3DFaceType		normReference[MAX_POLYGONS];/* OBJ face optional normal reference */
	
	NH3DVertexType		*verts;		/* vertex points */
	NH3DVertexType		*norms;		/* normals */
	NH3DFaceType		*faces;		/* faces */
	NH3DMapCoordType	*texcoords;	/* TextureCoords */
	
	NH3DMaterial		currentMaterial;
	
	int					texture;
	int					textures[MAX_TEXTURES];
	int					numberOfTextures;
	BOOL				useEnvironment;
	
	NH3DParticle		*particles;			/* particle Array */
	int					particleType;
	NH3DVertexType		particleGravity;
	int					particleColor;
	float				particleLife;
	float				particleSize;
	
	BOOL				animate;
	float				animationValue;
	float				animationRate;
	
	BOOL				hasChildObject;
	BOOL				isChild;
	unsigned int		numberOfChildObjects;
	NSMutableArray		*childObjects;
	
	int					modelType;
	
	float				slowdown; 
	float				xspeed;
	float				yspeed;
	
	NH3DVertexType		modelShift;
	NH3DVertexType		modelPivot;
	NH3DVertexType		modelScale;
	NH3DVertexType		modelRotate;
	
}


- (id)init; // init for particle emitter
/*
- (id) initWithOBJFile:(NSString *)name withTexture:(BOOL)flag; // 
																// NOTICE.
																// this method work for TRIANGLES ONLY 
																// not yat impliment other mesh type. do not work well texturecood, and faceinfomation.
																// plz use method '- (id) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag ' and 3ds format files.
																// ---- A kind has too abundant an OBJ file and is hard. I am too unpleasant to accept. hal.
*/
- (id) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag; // This is designated initializer.

- (void)calculateNormals;

- (BOOL)isActive;
- (void)setActive:(BOOL)flag;

- (NSString *)modelName;
- (int)verts_qty;
- (int)face_qty;
- (int)normal_qty;
- (int)texcords_qty;

- (NH3DVertexType *)verts;
- (NH3DVertexType *)norms;

- (NH3DFaceType *)faces;
//- (NH3DFaceType *)texReference;
//- (NH3DFaceType *)normReference;
- (NH3DMapCoordType *)texcoords;

- (int)texture;
- (void)setTexture:(int)tex_id;
- (BOOL)addTexture:(NSString *)textureName;
- (BOOL)useEnvironment;
- (void)setUseEnvironment:(BOOL)flag;

- (BOOL)isAnimate;
- (void)setAnimate:(BOOL)flag;

- (float)animationValue;
- (void)setAnimationValue:(float)value;

- (float)animationRate;
- (void)setAnimationRate:(float)rate;

- (void)animate;

- (NH3DVertexType )particleGravity;
- (void)setParticleGravityX:(float)x_gravity Y:(float)y_gravity Z:(float)z_gravity;
- (void)setParticleType:(int)type;
- (int)particleColor;
- (void)setParticleColor:(int)col;
- (void)setParticleSpeedX:(float)x Y:(float)y;
- (void)setParticleSlowdown:(float)value;
- (void)setParticleLife:(float)value;
- (void)setParticleSize:(float)value;


- (BOOL)hasChildObject;
- (unsigned int)numberOfChildObjects;

- (BOOL)isChild;
- (void)setIsChild:(BOOL)flag;

- (void)addChildObject:(NSString *)childName type:(int)type;
- (NH3DModelObjects *)childObjectAtIndex:(unsigned int)index;
- (NH3DModelObjects *)childObjectAtLast;

- (NH3DVertexType )modelShift;
- (void)setModelShiftX:(float)sx shiftY:(float)sy shiftZ:(float)sz;

- (NH3DVertexType )modelScale;
- (void)setModelScaleX:(float)scx scaleY:(float)scy scaleZ:(float)scz;

- (NH3DVertexType )modelRotate;
- (void)setModelRotateX:(float)rx rotateY:(float)ry rotateZ:(float)rz;

- (NH3DVertexType )modelPivot;
- (void)setPivotX:(float)px atY:(float)py atZ:(float)pz;

- (NH3DMaterial )currentMaterial;
- (void)setCurrentMaterial:(NH3DMaterial)material;

- (void)drawSelf;

// 


@end
