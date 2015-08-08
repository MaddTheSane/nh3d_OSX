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

#undef index

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


@interface NH3DModelObjects : NSObject <NSFastEnumeration> {
	
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
	NH3DParticleType	particleType;
	NH3DVertexType		particleGravity;
	int					particleColor;
	float				particleLife;
	float				particleSize;
	
	BOOL				animate;
	float				animationValue;
	float				animationRate;
	
	BOOL				hasChildObject;
	BOOL				isChild;
	NSUInteger			numberOfChildObjects;
	NSMutableArray		*childObjects;
	
	NH3DModelType		modelType;
	
	float				slowdown; 
	float				xspeed;
	float				yspeed;
	
	NH3DVertexType		modelShift;
	NH3DVertexType		modelPivot;
	NH3DVertexType		modelScale;
	NH3DVertexType		modelRotate;
	
}


- (instancetype)init NS_DESIGNATED_INITIALIZER; // init for particle emitter
/*
- (id) initWithOBJFile:(NSString *)name withTexture:(BOOL)flag; // 
																// NOTICE.
																// this method work for TRIANGLES ONLY 
																// not yat impliment other mesh type. do not work well texturecood, and faceinfomation.
																// plz use method '- (id) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag ' and 3ds format files.
																// ---- A kind has too abundant an OBJ file and is hard. I am too unpleasant to accept. hal.
*/
- (instancetype) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag NS_DESIGNATED_INITIALIZER; // This is designated initializer.

- (void)calculateNormals;

@property (getter=isActive) BOOL active;

@property (readonly, copy) NSString *modelName;
@property (readonly) int verts_qty;
@property (readonly) int face_qty;
@property (readonly) int normal_qty;
@property (readonly) int texcords_qty;

@property (readonly) NH3DVertexType *verts;
@property (readonly) NH3DVertexType *norms;

@property (readonly) NH3DFaceType *faces;
//- (NH3DFaceType *)texReference;
//- (NH3DFaceType *)normReference;
@property (readonly) NH3DMapCoordType *texcoords;

@property int texture;
- (BOOL)addTexture:(NSString *)textureName;
@property BOOL useEnvironment;

@property (getter=isAnimated) BOOL animated;
@property float animationValue;
@property float animationRate;

- (void)animate;

@property (readonly) NH3DVertexType particleGravity;
- (void)setParticleGravityX:(float)x_gravity Y:(float)y_gravity Z:(float)z_gravity;
@property (nonatomic) NH3DParticleType particleType;
@property int particleColor;
- (void)setParticleSpeedX:(float)x Y:(float)y;
- (void)setParticleSlowdown:(float)value;
- (void)setParticleLife:(float)value;
- (void)setParticleSize:(float)value;


@property (readonly) BOOL hasChildObject;
@property (readonly) NSInteger numberOfChildObjects;

@property BOOL isChild;

- (void)addChildObject:(NSString *)childName type:(NH3DModelType)type;
- (NH3DModelObjects *)childObjectAtIndex:(NSUInteger)index;
@property (readonly, strong) NH3DModelObjects *childObjectAtLast;

@property (readonly) NH3DVertexType modelShift;
- (void)setModelShiftX:(float)sx shiftY:(float)sy shiftZ:(float)sz;

@property (readonly) NH3DVertexType modelScale;
- (void)setModelScaleX:(float)scx scaleY:(float)scy scaleZ:(float)scz;

@property (readonly) NH3DVertexType modelRotate;
- (void)setModelRotateX:(float)rx rotateY:(float)ry rotateZ:(float)rz;

@property (readonly) NH3DVertexType modelPivot;
- (void)setPivotX:(float)px atY:(float)py atZ:(float)pz;

@property NH3DMaterial currentMaterial;

- (void)drawSelf;

// 


@end
