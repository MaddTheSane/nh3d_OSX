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
#include <simd/vector_types.h>
#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"

#undef index

NS_ASSUME_NONNULL_BEGIN

typedef struct nh3d_point3 {
	GLfloat x, y, z;
} NH3DVertexType;

typedef struct nh3d_face3 {
    unsigned short  a, b, c;
} NH3DFaceType;

typedef struct nh3d_coord2 {
    GLfloat s, t;
} NH3DMapCoordType;

typedef GLfloat NH3DMaterialType[4];

typedef struct NH3DMaterial {
	NH3DMaterialType	ambient;
	NH3DMaterialType	diffuse;
	NH3DMaterialType	specular;
	NH3DMaterialType	emission;
	GLfloat				shininess;
} NH3DMaterial;

typedef struct NH3DParticle {
	BOOL active;
	/*! model life */
	GLfloat life;
	/*! Fade speed */
	GLfloat fade;
	/*! Red value */
	GLfloat r;
	/*! Green value */
	GLfloat g;
	/*! Blue value */
	GLfloat b;
	/*! X position */
	GLfloat x;
	/*! Y position */
	GLfloat y;
	/*! Z position */
	GLfloat z;
	/*! X direction */
	GLfloat xi;
	/*! Y direction */
	GLfloat yi;
	/*! Z direction */
	GLfloat zi;
	/*! X gravity */
	GLfloat xg;
	/*! Y gravity */
	GLfloat yg;
	/*! Z gravity */
	GLfloat zg;
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
	
	vector_float3		*verts;		/* vertex points */
	vector_float3		*norms;		/* normals */
	NH3DFaceType		*faces;		/* faces */
	NH3DMapCoordType	*texcoords;	/* TextureCoords */
	
	NH3DMaterial		currentMaterial;
	
	int					texture;
	GLuint				textures[MAX_TEXTURES];
	NSInteger			numberOfTextures;
	BOOL				useEnvironment;
	
	NH3DParticle		*particles;			/* particle Array */
	NH3DParticleType	particleType;
	NH3DVertexType		particleGravity;
	int					particleColor;
	GLfloat				particleLife;
	GLfloat				particleSize;
	
	BOOL				animate;
	GLfloat				animationValue;
	GLfloat				animationRate;
	
	BOOL				hasChildObject;
	BOOL				isChild;
	NSMutableArray<NH3DModelObject*>		*childObjects;
	
	NH3DModelType		modelType;
	
	GLfloat				slowdown;
	GLfloat				xspeed;
	GLfloat				yspeed;
}

@property (readonly) NH3DModelType modelType;

/// init for particle emitter
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// this method work for <b>TRIANGLES ONLY</b>.
/// not yet impliment other mesh type. Does not work well texturecood, and face infomation.
/// plz use method <code>- (id) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag</code> and 3ds format files.
/// ---- A kind has too abundant an OBJ file and is hard. I am too unpleasant to accept. hal.
- (nullable instancetype) initWithOBJFile:(NSString *)name withTexture:(BOOL)flag;

- (nullable instancetype) initWithOBJFile:(NSString *)name textureNamed:(nullable NSString*)texName NS_DESIGNATED_INITIALIZER;

- (nullable instancetype) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag NS_SWIFT_NAME(init(with3DSFile:withTexture:));
- (nullable instancetype)initWith3DSFile:(NSString *)name textureNamed:(nullable NSString*)texName NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(with3DSFile:textureNamed:)); // This is a designated initializer.

+ (nullable instancetype)modelNamed:(NSString*)name withTexture:(BOOL)flag;

+ (nullable instancetype)modelNamed:(NSString*)name textureNamed:(nullable NSString*)texName;

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
@property (readonly) vector_float3 *verts NS_RETURNS_INNER_POINTER;
/*! normals */
@property (readonly) vector_float3 *norms NS_RETURNS_INNER_POINTER;

/*! faces */
@property (readonly) NH3DFaceType *faces NS_RETURNS_INNER_POINTER;
/*! OBJ face optional texture reference */
@property (readonly) NH3DFaceType *texReference NS_RETURNS_INNER_POINTER;
/*! OBJ face optional normal reference */
@property (readonly) NH3DFaceType *normReference NS_RETURNS_INNER_POINTER;
/*! TextureCoords */
@property (readonly) NH3DMapCoordType *texcoords NS_RETURNS_INNER_POINTER;

- (GLuint)texture;
- (void)setTexture:(int)tex_id;
- (BOOL)addTexture:(NSString *)textureName;
@property (readonly) NSInteger numberOfTextures;
@property BOOL useEnvironment;

@property (getter=isAnimated) BOOL animated;
@property GLfloat animationValue;
@property GLfloat animationRate;

@property (nonatomic) NH3DVertexType particleGravity;
- (void)setParticleGravityX:(GLfloat)x_gravity Y:(GLfloat)y_gravity Z:(GLfloat)z_gravity NS_SWIFT_NAME(setParticleGravity(x:y:z:));
@property (nonatomic) NH3DParticleType particleType;
@property int particleColor;
- (void)setParticleSpeedX:(GLfloat)x Y:(GLfloat)y NS_SWIFT_NAME(setParticleSpeed(x:y:));
@property (nonatomic) GLfloat particleSlowdown;
@property (nonatomic) GLfloat particleLife;
@property (nonatomic) GLfloat particleSize;

@property (readonly) BOOL hasChildren;
@property (readonly) NSInteger countOfChildObjects;

@property BOOL isChild;

- (void)addChildObject:(NSString *)childName type:(NH3DModelType)type;
- (NH3DModelObject *)childObjectAtIndex:(NSUInteger)index;
@property (readonly, strong, nullable) NH3DModelObject *lastChildObject;

@property (readwrite) NH3DVertexType modelShift;
- (void)setModelShiftX:(GLfloat)sx shiftY:(GLfloat)sy shiftZ:(GLfloat)sz NS_SWIFT_NAME(setModelShift(x:y:z:));

@property (readwrite) NH3DVertexType modelScale;
- (void)setModelScaleX:(GLfloat)scx scaleY:(GLfloat)scy scaleZ:(GLfloat)scz NS_SWIFT_NAME(setModelScale(x:y:z:));

@property (readwrite) NH3DVertexType modelRotate;
- (void)setModelRotateX:(GLfloat)rx rotateY:(GLfloat)ry rotateZ:(GLfloat)rz NS_SWIFT_NAME(setModelRotate(x:y:z:));

@property (readwrite) NH3DVertexType modelPivot;
- (void)setPivotX:(GLfloat)px atY:(GLfloat)py atZ:(GLfloat)pz NS_SWIFT_NAME(setPivot(x:y:z:));

@property NH3DMaterial currentMaterial;

- (void)drawSelf;

- (void)animate;

@end

NS_ASSUME_NONNULL_END
