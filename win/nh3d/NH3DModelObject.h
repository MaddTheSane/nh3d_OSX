/*
 *  NH3DModelObject.h
 *  NetHack3D
 *
 *  Created by Haruumi Yoshino on 05/10/20.
 *  Copyright 2005 Haruumi Yoshino. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#include <OpenGL/gltypes.h>
#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"

#undef index

NS_ASSUME_NONNULL_BEGIN

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
	/*! model life */
	float life;
	/*! Fade speed */
	float fade;
	/*! Red value */
	float r;
	/*! Green value */
	float g;
	/*! Blue value */
	float b;
	/*! X position */
	float x;
	/*! Y position */
	float y;
	/*! Z position */
	float z;
	/*! X direction */
	float xi;
	/*! Y direction */
	float yi;
	/*! Z direction */
	float zi;
	/*! X gravity */
	float xg;
	/*! Y gravity */
	float yg;
	/*! Z gravity */
	float zg;
} NH3DParticle;


@interface NH3DModelObject : NSObject <NSFastEnumeration> {
@private
	BOOL				active;
	NSString			*modelName;					/* model name from data */
	NSString			*modelCode;					/* model name from filename */
	unsigned short		verts_qty;					/* vertex counts */
	unsigned short		face_qty;					/* faces counts */
	unsigned short		normal_qty;					/* normal counts */
	unsigned short		texcords_qty;				/* texcoords counts */
	NH3DFaceType		texReference[MAX_POLYGONS];	/* OBJ face optional texture reference */
	NH3DFaceType		normReference[MAX_POLYGONS];/* OBJ face optional normal reference */
	
	NH3DVertexType		*verts;		/* vertex points */
	NH3DVertexType		*norms;		/* normals */
	NH3DFaceType		*faces;		/* faces */
	NH3DMapCoordType	*texcoords;	/* TextureCoords */
	
	NH3DMaterial		currentMaterial;
	
	int					texture;
	GLuint				textures[MAX_TEXTURES];
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
	NSMutableArray<NH3DModelObject*>		*childObjects;
	
	NH3DModelType		modelType;
	
	float				slowdown; 
	float				xspeed;
	float				yspeed;
}

/// init for particle emitter
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// this method work for TRIANGLES ONLY.
/// not yet impliment other mesh type. do not work well texturecood, and face infomation.
/// plz use method '- (id) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag ' and 3ds format files.
/// ---- A kind has too abundant an OBJ file and is hard. I am too unpleasant to accept. hal.
- (nullable instancetype) initWithOBJFile:(NSString *)name withTexture:(BOOL)flag;

- (nullable instancetype) initWithOBJFile:(NSString *)name textureNamed:(nullable NSString*)texName NS_DESIGNATED_INITIALIZER;


- (nullable instancetype) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag;
- (nullable instancetype)initWith3DSFile:(NSString *)name textureNamed:(nullable NSString*)texName NS_DESIGNATED_INITIALIZER; // This is designated initializer.

+ (nullable instancetype)modelNamed:(NSString*)name textureNamed:(nullable NSString*)texName;

- (void)calculateNormals;

@property (getter=isActive) BOOL active;

/*! model name from data */
@property (readonly, copy) NSString *modelName;
/*! vertex counts */
@property (readonly) int verts_qty;
/*! faces counts */
@property (readonly) int face_qty;
/*! normal counts */
@property (readonly) int normal_qty;
/*! texcoords counts */
@property (readonly) int texcords_qty;

/*! vertex points */
@property (readonly) NH3DVertexType *verts NS_RETURNS_INNER_POINTER;
/*! normals */
@property (readonly) NH3DVertexType *norms NS_RETURNS_INNER_POINTER;

/*! faces */
@property (readonly) NH3DFaceType *faces NS_RETURNS_INNER_POINTER;
/*! OBJ face optional texture reference */
- (nullable NH3DFaceType *)texReference NS_RETURNS_INNER_POINTER;
/*! OBJ face optional normal reference */
- (nullable NH3DFaceType *)normReference NS_RETURNS_INNER_POINTER;
/*! TextureCoords */
@property (readonly) NH3DMapCoordType *texcoords NS_RETURNS_INNER_POINTER;

- (GLuint)texture;
- (void)setTexture:(int)tex_id;
- (BOOL)addTexture:(NSString *)textureName;
@property (readonly) NSInteger numberOfTextures;
@property BOOL useEnvironment;

@property (getter=isAnimated) BOOL animated;
@property float animationValue;
@property float animationRate;

- (void)animate;

@property (nonatomic) NH3DVertexType particleGravity;
- (void)setParticleGravityX:(float)x_gravity Y:(float)y_gravity Z:(float)z_gravity;
@property (nonatomic) NH3DParticleType particleType;
@property int particleColor;
- (void)setParticleSpeedX:(float)x Y:(float)y;
@property (nonatomic) float particleSlowdown;
@property (nonatomic) float particleLife;
@property (nonatomic) float particleSize;

@property (readonly) BOOL hasChildren;
@property (readonly) NSInteger countOfChildObjects;

@property BOOL isChild;

- (void)addChildObject:(NSString *)childName type:(NH3DModelType)type;
- (NH3DModelObject *)childObjectAtIndex:(NSUInteger)index;
@property (readonly, strong, nullable) NH3DModelObject *lastChildObject;

@property (readwrite) NH3DVertexType modelShift;
- (void)setModelShiftX:(float)sx shiftY:(float)sy shiftZ:(float)sz;

@property (readwrite) NH3DVertexType modelScale;
- (void)setModelScaleX:(float)scx scaleY:(float)scy scaleZ:(float)scz;

@property (readwrite) NH3DVertexType modelRotate;
- (void)setModelRotateX:(float)rx rotateY:(float)ry rotateZ:(float)rz;

@property (readwrite) NH3DVertexType modelPivot;
- (void)setPivotX:(float)px atY:(float)py atZ:(float)pz;

@property NH3DMaterial currentMaterial;

- (void)drawSelf;

@end

NS_ASSUME_NONNULL_END
