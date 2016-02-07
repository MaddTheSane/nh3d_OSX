//
//  NH3DModelBundle.swift
//  NetHack3D
//
//  Created by C.W. Betts on 2/7/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

/*
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

@property (readonly) BOOL hasChildObject;
@property (readonly) NSInteger numberOfChildObjects;

@property BOOL isChild;

- (void)addChildObject:(NSString *)childName type:(NH3DModelType)type;
- (NH3DModelObject *)childObjectAtIndex:(NSUInteger)index;
@property (readonly, strong, nullable) NH3DModelObject *childObjectAtLast;

@property (readwrite) NH3DVertexType modelShift;
- (void)setModelShiftX:(float)sx shiftY:(float)sy shiftZ:(float)sz;

@property (readwrite) NH3DVertexType modelScale;
- (void)setModelScaleX:(float)scx scaleY:(float)scy scaleZ:(float)scz;

@property (readwrite) NH3DVertexType modelRotate;
- (void)setModelRotateX:(float)rx rotateY:(float)ry rotateZ:(float)rz;

@property (readwrite) NH3DVertexType modelPivot;
- (void)setPivotX:(float)px atY:(float)py atZ:(float)pz;

@property NH3DMaterial currentMaterial;
*/

/*
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
*/

class NH3DModelBundle: NSObject {

}
