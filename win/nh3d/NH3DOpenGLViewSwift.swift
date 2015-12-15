//
//  NH3DOpenGLViewSwift.swift
//  NetHack3D
//
//  Created by C.W. Betts on 7/21/15.
//
//

import Cocoa
import OpenGL
import GLKit


private let GLYPH_MON_OFF: Int32 = 0
private let TEX_SIZE = 128

private typealias LoadModelBlock = (glyph: Int32) -> NH3DModelObjects?


func loadModelFunc_default(glyph: Int32) -> NH3DModelObjects? {
	return nil
}

// memo.   << MAP_ITEM_SIZE >>
//		y			   +2.0,+6.0			y
//		|			  ( RIGHT,TOP )			|
//		|									|
//		|	  0,0,2.0						|
//		| ( CENTER of Item )					|  -	-2.0 ( BACK )
//		|									|/ z
//		---------------- x					---------------- x
//	-2.0,0.0( LEFT,BOTTOM )				  / +	+2.0 ( FRONT )



private let keyLightAmb: [GLfloat] = [0.1 ,0.1 ,0.1 ,1] ;
private let keyLightspec: [GLfloat] = [1 ,1 ,1 ,1];

private let keyLightAltCol: [GLfloat] = [0.04 ,0.01 ,0.00 ,1];
private let keyLightAltAmb: [GLfloat] = [0.08 ,0.08 ,0.08 ,1];
private let keyLightAltspec: [GLfloat] = [0.04 ,0.09 ,0.18 ,1];

private let defaultBackGroundCol: [GLfloat] = [0.00 ,0.00 ,0.00 ,0] ;
private let underWaterColar: [GLfloat] = [0.00 ,0.00 ,0.80 ,1.0] ;

private let vsincWait: GLint = 1;
private let vsincNoWait: GLint = 0;
////////////////////////////////
// MARK: floor model
////////////////////////////////

private var FloorVerts: [NH3DVertexType] = [
	NH3DVertexType( x: -2.0, y: 0.0, z: -2.0 ),
	NH3DVertexType( x: -2.0, y: 0.0, z: 2.0 ),
	NH3DVertexType( x: 2.0, y: 0.0, z: -2.0 ),
	NH3DVertexType( x: 2.0, y: 0.0, z: 2.0 )
]

private var FloorTexVerts:[NH3DMapCoordType] = [
	NH3DMapCoordType(s: 0.0,t: 0.0),
	NH3DMapCoordType(s: 1.0,t: 0.0),
	NH3DMapCoordType(s: 0.0,t: 1.0),
	NH3DMapCoordType(s: 1.0, t: 1.0)
]

private var FloorVertNorms: [NH3DVertexType] = [
	NH3DVertexType( x: -0.25, y: 0.50, z: 0.25),
	NH3DVertexType( x: -0.25, y: 0.50, z: 0.25),
	NH3DVertexType( x: 0.25, y: 0.50, z: -0.25),
	NH3DVertexType( x: 0.25, y: 0.50, z: -0.25)
]

//////////////////////////////
// MARK: ceiling model
//////////////////////////////

private var CeilingVerts: [NH3DVertexType] = [
	NH3DVertexType( x: 2.0, y: 6.0, z: -2.0 ),
	NH3DVertexType( x: 2.0, y: 6.0, z: 2.0 ),
	NH3DVertexType( x: -2.0, y: 6.0, z: -2.0 ),
	NH3DVertexType( x: -2.0, y: 6.0, z: 2.0 )
]

private var CeilingTexVerts: [NH3DMapCoordType] = [
	NH3DMapCoordType(s: 1.0,t: 1.0),
	NH3DMapCoordType(s: 0.0,t: 1.0),
	NH3DMapCoordType(s: 1.0,t: 0.0),
	NH3DMapCoordType(s: 0.0,t: 0.0)
]


private var CeilingVertNorms: [NH3DVertexType] = [
	NH3DVertexType( x: 0.0, y: -1.0, z: 0.0),
	NH3DVertexType( x: 0.0, y: -1.0, z: 0.0),
	NH3DVertexType( x: 0.0, y: -1.0, z: 0.0),
	NH3DVertexType( x: 0.0, y: -1.0, z: 0.0)
]

////////////////////////////////
// MARK: default model
////////////////////////////////


private var defaultVerts: [NH3DVertexType] = [
	NH3DVertexType( x: -1.5, y: 0.5,  z: 0 ),
	NH3DVertexType(  x: 1.5, y: 0.5,  z: 0 ),
	NH3DVertexType( x: -1.5,  y: 3.5,  z: 0 ),
	NH3DVertexType(  x: 1.5,  y: 3.5,  z: 0 )
]

private var defaultTexVerts: [NH3DMapCoordType] = [
	NH3DMapCoordType(s: 0.0,t: 1.0),
	NH3DMapCoordType(s: 1.0,t: 1.0),
	NH3DMapCoordType(s: 0.0,t: 0.0),
	NH3DMapCoordType(s: 1.0,t: 0.0)
]

private var defaultNorms: [NH3DVertexType] = [
	NH3DVertexType( x: 0.5, y: 0.0, z: 0.5),
	NH3DVertexType( x: 0.5, y: 0.0, z: 0.5)
]



////////////////////////////////
// MARK: null object
////////////////////////////////

private var nullObjectVerts: [NH3DVertexType] = [
	NH3DVertexType(  x: 2, y: 0, z: -2 ), NH3DVertexType( x: -2, y: 0, z: -2 ), NH3DVertexType(  x: 2,  y: 6, z: -2 ), NH3DVertexType( x: -2,  y: 6, z: -2 ), // rear
	NH3DVertexType(  x: 2, y: 0,  z: 2 ), NH3DVertexType(  x: 2, y: 0, z: -2 ), NH3DVertexType(  x: 2,  y: 6,  z: 2 ), NH3DVertexType(  x: 2,  y: 6, z: -2 ), // right
	NH3DVertexType( x: -2, y: 0,  z: 2 ), NH3DVertexType(  x: 2, y: 0,  z: 2 ), NH3DVertexType( x: -2,  y: 6,  z: 2 ), NH3DVertexType(  x: 2,  y: 6,  z: 2 ), // front
	NH3DVertexType( x: -2, y: 0, z: -2 ), NH3DVertexType( x: -2, y: 0,  z: 2 ), NH3DVertexType( x: -2,  y: 6, z: -2 ), NH3DVertexType( x: -2,  y: 6,  z: 2 )  // left
]

private var nullObjectTexVerts: [NH3DMapCoordType] = [
	NH3DMapCoordType(s: 0.0, t: 0.0 ), NH3DMapCoordType( s: 1.0, t: 0.0 ), NH3DMapCoordType( s: 0.0, t: 1.0 ), NH3DMapCoordType( s: 1.0, t: 1.0 ),
	NH3DMapCoordType(s: 0.0, t: 0.0 ), NH3DMapCoordType( s: 1.0, t: 0.0 ), NH3DMapCoordType( s: 0.0, t: 1.0 ), NH3DMapCoordType( s: 1.0, t: 1.0 ),
	NH3DMapCoordType(s: 0.0, t: 0.0 ), NH3DMapCoordType( s: 1.0, t: 0.0 ), NH3DMapCoordType( s: 0.0, t: 1.0 ), NH3DMapCoordType( s: 1.0, t: 1.0 ),
	NH3DMapCoordType(s: 0.0, t: 0.0 ), NH3DMapCoordType( s: 1.0, t: 0.0 ), NH3DMapCoordType( s: 0.0, t: 1.0 ), NH3DMapCoordType( s: 1.0, t: 1.0 )
]


private var nullObjectNorms: [NH3DVertexType] = [
	NH3DVertexType( x: 0.20,  y: 0.50, z: -0.30 ),NH3DVertexType( x: 0.20, y: 0.50, z: -0.30 ),
	NH3DVertexType( x: -0.30,  y: -0.50, z: 0.20 ),NH3DVertexType( x: -0.30, y: -0.50, z: 0.20 ),
	NH3DVertexType( x: 0.20,  y: 0.50, z: 0.30 ),NH3DVertexType( x: 0.20, y: 0.50, z: 0.30 ),
	NH3DVertexType( x: 0.30,  y: -0.50, z: -0.20 ),NH3DVertexType( x: 0.30, y: -0.50, z: -0.20 )
]


// MARK: Material

private var		nh3dMaterialArray: [NH3DMaterial] = [
	// Black
	NH3DMaterial(ambient: ( 0.05, 0.05, 0.05, 1.0 ),		//	ambient color
		diffuse: ( 0.1 , 0.1 , 0.1 , 1.0 ),					//	diffuse color
		specular: ( 0.474597 , 0.474597 , 0.474597 , 1.0),	//	specular color
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),				//  emission
		shininess: 0.01		),								//	shininess
	// Red
	NH3DMaterial(ambient: ( 0.1745 , 0.01175 , 0.01175 , 1.0 ),
		diffuse: ( 0.81424, 0.04136 , 0.04136 , 1.0 ),
		specular: ( 0.427811 , 0.126959 , 0.126959 , 1.0),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// Green
	NH3DMaterial(	ambient: ( 0.0215 , 0.1745 , 0.0215 , 1.0 ),
		diffuse: ( 0.07568 , 0.81424 , 0.07568 , 1.0 ),
		specular: ( 0.133 , 0.427811 , 0.133 , 1.0 ),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// Brown
	NH3DMaterial(	ambient: ( 0.19125 , 0.0735 , 0.0225 , 1.0 ),
		diffuse: ( 0.8038 , 0.37048 , 0.0828 , 1.0 ),
		specular: ( 0.25677 , 0.137622 , 0.086014 , 1.0 ),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// Blue
	NH3DMaterial(ambient: ( 0.0215 , 0.0215 , 0.1745 , 1.0 ),
		diffuse: ( 0.08568 , 0.08568 , 0.81424 , 1.0 ),
		specular: ( 0.133 , 0.133 , 0.427811 , 1.0 ),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// Magenta
	NH3DMaterial(ambient: ( 0.1745 , 0.0215 , 0.1745 , 1.0 ),
		diffuse: ( 0.81424 , 0.07568 , 0.81424 , 1.0 ),
		specular: ( 0.127811 , 0.133 , 0.427811 , 1.0 ),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// Cyan
	NH3DMaterial(ambient: ( 0.0215 , 0.1745 , 0.1745 , 1.0 ),
		diffuse: ( 0.08568 , 0.81424 , 0.81424 , 1.0 ),
		specular: ( 0.133 , 0.427811 , 0.427811 , 1.0 ),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// Gray
	NH3DMaterial(ambient: ( 0.25, 0.25, 0.25, 1.0 ),
		diffuse: ( 0.6 , 0.6 , 0.6 , 1.0 ),
		specular: ( 0.474597 , 0.474597 , 0.474597 , 1.0),
		emission: ( 0.1 , 0.1 , 0.1 , 1.0 ),
		shininess: 0.01),
	// No Color
	NH3DMaterial(ambient: ( 0.5, 0.5, 0.5, 1.0 ),
		diffuse: ( 0.5 , 0.5 , 0.5 , 1.0 ),
		specular: ( 0.5 , 0.5 , 1.5 , 1.0),
		emission: ( 1.0 , 1.0 , 1.0 , 1.0 ),
		shininess: 1.0),
	// Orange
	NH3DMaterial(ambient: ( 0.1745 , 0.05175 , 0.00175 , 1.0 ),
		diffuse: ( 0.91424, 0.41136 , 0.00136 , 1.0 ),
		specular: ( 0.527811 , 0.284959 , 0.026959 , 1.0),
		emission: ( 0.3 , 0.3 , 0.3 , 1.0 ),
		shininess: 0.1),
	// Bright Green
	NH3DMaterial(ambient: ( 0.0615 , 0.1745 , 0.0615 , 1.0 ),
		diffuse: ( 0.17568 , 0.95424 , 0.17568 , 1.0 ),
		specular: ( 0.133 , 0.527811 , 0.133 , 1.0 ),
		emission: ( 0.3 , 0.3 , 0.3 , 1.0 ),
		shininess: 0.1),
	// Yellow
	NH3DMaterial(ambient: ( 0.1745 , 0.1745 , 0.00175 , 1.0 ),
		diffuse: ( 0.91424, 0.91424 , 0.00136 , 1.0 ),
		specular: ( 0.327811 , 0.327811 , 0.026959 , 1.0),
		emission: ( 0.3 , 0.3 , 0.3 , 1.0 ),
		shininess: 0.1),
	// Bright Blue
	NH3DMaterial(	ambient: ( 0.0715 , 0.0715 , 0.1745 , 1.0 ),
		diffuse: ( 0.17568 , 0.27568 , 0.91424 , 1.0 ),
		specular: ( 0.133 , 0.133 , 0.527811 , 1.0 ),
		emission: ( 0.3 , 0.3 , 0.3 , 1.0 ),
		shininess: 0.1),
	// Bright Magenta
	NH3DMaterial(	ambient: ( 0.3745 , 0.1215 , 0.3745 , 1.0 ),
		diffuse: ( 0.91424 , 0.27568 , 0.91424 , 1.0 ),
		specular: ( 0.427811 , 0.133 , 0.427811 , 1.0 ),
		emission: ( 0.3 , 0.3 , 0.3 , 1.0 ),
		shininess: 0.1),
	// Bright Cyan
	NH3DMaterial(ambient: ( 0.0215 , 0.2745 , 0.2745 , 1.0 ),
		diffuse: ( 0.17568 , 0.91424 , 0.91424 , 1.0 ),
		specular: ( 0.133 , 0.427811 , 0.427811 , 1.0 ),
		emission: ( 0.3 , 0.3 , 0.3 , 1.0 ),
		shininess: 0.1),
	// White
	NH3DMaterial(ambient: ( 0.25 , 0.20725 , 0.20725 , 1.0 ),
		diffuse: ( 1.0 , 0.929 , 0.929 , 1.0 ),
		specular: ( 0.296648 , 0.296648 , 0.296648 , 1.0 ),
		emission: ( 0.6 , 0.6 , 0.6 , 1.0 ),
		shininess: 0.088)
];


final class NH3DOpenGLViewSwift: NSOpenGLView {
	private var loadModelBlocks = [LoadModelBlock](count: Int(MAX_GLYPH), repeatedValue: loadModelFunc_default)
	private var modelDictionary = [Int32: NH3DModelObjects]()
	//LoadModelBlock loadModelBlocks[MAX_GLYPH];
	private let viewLock = NSRecursiveLock()
	
	override init?(frame frameRect: NSRect, pixelFormat format: NSOpenGLPixelFormat?) {
		super.init(frame: frameRect, pixelFormat: format)
	}

	override init(frame frameRect: NSRect) {
		var attribs: [NSOpenGLPixelFormatAttribute] = [
			NSOpenGLPixelFormatAttribute(NSOpenGLPFANoRecovery),
			NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),	/* use double buffer */
			NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),	/* use HW accelerate */
			//NSOpenGLPFAStencilSize,32,		/* set Stencil buffer size */
			NSOpenGLPixelFormatAttribute(NSOpenGLPFAAlphaSize), 8,
			NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 24,	/* set Color buffer size */
			NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 16,	/* set Depth buffer size */
			0														/* null termnator */
		]
		
		/* Create a GL Context to use - i.e. init the superclass */
		let pfmt = NSOpenGLPixelFormat(attributes: &attribs)
		super.init(frame: frameRect, pixelFormat: pfmt)!
		openGLContext?.makeCurrentContext()
		
		self.setFrameSize(frameRect.size)
		
		glMatrixMode(GLenum(GL_PROJECTION));
		glLoadIdentity();
		
		glClearColor( 0,0,0,0 );
		glClearDepth( 1.0 );
		do {
			var aMatrix = GLKMatrix4MakePerspective(
				GLKMathDegreesToRadians(76),				/* View angle */
				Float(frameRect.width / frameRect.height),	/*Aspect rasio */
				0.1,										/* Near limit Distance from origin*/
				30)											/* Far limit  */
			var anArr = Array<GLfloat>(count: 16, repeatedValue: 0)
			withUnsafeMutablePointer(&aMatrix) { (arr) -> () in
				memcpy(&anArr, UnsafePointer(arr), sizeof(GLKMatrix4))
			}
			glMultMatrixf(anArr)
		}
		
		// alpha blending
		glEnable(GLenum(GL_BLEND));
		glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		
		//[ self turnOnSmooth ];
		
		glShadeModel(GLenum(GL_SMOOTH))
		//glShadeModel( GL_FLAT );

		/*
- ( instancetype ) initWithFrame: ( NSRect ) theFrame
{	
	
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	glEnable( GL_DEPTH_TEST );
	glEnable( GL_POINT_SMOOTH );
	
	glPolygonMode( GL_FRONT_AND_BACK,GL_FILL );
	//	glPolygonMode( GL_BACK,GL_LINE );
	
	glEnable( GL_CULL_FACE );
	glCullFace( GL_BACK );
	
	glEnable( GL_TEXTURE_2D );
	
	glEnable( GL_LIGHTING );
	glEnable( GL_FOG );
	
	
	// load texture
	
	floorTex = [ self loadImageToTexture:@"floor.tif" ];
	floor2Tex = [ self loadImageToTexture:@"floor2.tif" ];
	//wallTex = [ self loadImageToTexture:@"wall.tif" ];
	cellingTex = [ self loadImageToTexture:@"celling.tif" ];
	waterTex = [ self loadImageToTexture:@"water.tif" ];
	poolTex = [ self loadImageToTexture:@"poolColor.tif" ];
	lavaTex = [ self loadImageToTexture:@"lava.tif" ];
	minesTex = [ self loadImageToTexture:@"rockwall.tif" ];
	airTex = [ self loadImageToTexture:@"air.tif" ];
	cloudTex = [ self loadImageToTexture:@"cloud.tif" ];
	hellTex = [ self loadImageToTexture:@"hell.tif" ];
	nullTex = [ self loadImageToTexture:@"null.tif" ];
	rougeTex = [ self loadImageToTexture:@"rouge.tif" ];
	
	floorCurrent = floorTex;
	cellingCurrent = cellingTex;
	
	// multi texture
	
	glActiveTexture( GL_TEXTURE1 );
	
	envelopTex = [ self loadImageToTexture:@"envlop.tif" ];
	
	glActiveTexture( GL_TEXTURE0 );
	
	lastCameraX = 5.0;
	lastCameraY = 1.8;
	lastCameraZ = 5.0;
	
	lastCameraHead = 0;
	lastCameraPitch = 0;
	lastCameraRoll = 0;
	
	cameraX = 5.0;
	cameraY = 1.8;
	cameraZ = 5.0;
	cameraHead = 0.0;
	cameraPitch = 0.0;
	cameraRoll = 0.0;
	
	drawMargin = 0;
	
	// init speed up function
	[ self cashMethod ];
	
	// init Effect models
	enemyPosition = 0;
	
	effectArray[ 0 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front left
	[ effectArray[ 0 ] setModelShiftX:-1.0 shiftY:1.8 shiftZ:-1.0 ];
	[ effectArray[ 0 ] setParticleGravityX:3.0 Y:-0.5 Z:3.0 ];
	
	effectArray[ 1 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front
	[ effectArray[ 1 ] setModelShiftX:0.0 shiftY:1.8 shiftZ:-1.0 ];
	[ effectArray[ 1 ] setParticleGravityX:0.0 Y:-0.5 Z:3.0 ];
	
	effectArray[ 2 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front right
	[ effectArray[ 2 ] setModelShiftX:1.0 shiftY:1.8 shiftZ:-1.0 ];
	[ effectArray[ 2 ] setParticleGravityX:-3.0 Y:-0.5 Z:3.0 ];
	
	//reight direction
	effectArray[ 3 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front left
	[ effectArray[ 3 ] setModelShiftX:1.0 shiftY:1.8 shiftZ:-1.0 ];
	[ effectArray[ 3 ] setParticleGravityX:3.0 Y:-0.5 Z:3.0 ];

	effectArray[ 4 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front
	[ effectArray[ 4 ] setModelShiftX:1.0 shiftY:1.8 shiftZ:0.0 ];
	[ effectArray[ 4 ] setParticleGravityX:3.0 Y:-0.5 Z:0.0 ];
	
	effectArray[ 5 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front right
	[ effectArray[ 5 ] setModelShiftX:1.0 shiftY:1.8 shiftZ:1.0 ];
	[ effectArray[ 5 ] setParticleGravityX:3.0 Y:-0.5 Z:-3.0 ];
	
	//back direction
	effectArray[ 6 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front left
	[ effectArray[ 6 ] setModelShiftX:1.0 shiftY:1.8 shiftZ:1.0 ];
	[ effectArray[ 6 ] setParticleGravityX:-3.0 Y:-0.5 Z:-3.0 ];
	
	effectArray[ 7 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front
	[ effectArray[ 7 ] setModelShiftX:0.0 shiftY:1.8 shiftZ:1.0 ];
	[ effectArray[ 7 ] setParticleGravityX:0.0 Y:-0.5 Z:-3.0 ];
	
	effectArray[ 8 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front right
	[ effectArray[ 8 ] setModelShiftX:-1.0 shiftY:1.8 shiftZ:1.0 ];
	[ effectArray[ 8 ] setParticleGravityX:3.0 Y:-0.5 Z:-3.0 ];

	//left direction
	effectArray[ 9 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front left
	[ effectArray[ 9 ] setModelShiftX:-1.0 shiftY:1.8 shiftZ:1.0 ];
	[ effectArray[ 9 ] setParticleGravityX:-3.0 Y:-0.5 Z:-3.0 ];
	
	effectArray[ 10 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front
	[ effectArray[ 10 ] setModelShiftX:-1.0 shiftY:1.8 shiftZ:0.0 ];
	[ effectArray[ 10 ] setParticleGravityX:-3.0 Y:-0.5 Z:0.0 ];
	effectArray[ 11 ] = [ [ NH3DModelObjects alloc ] init ]; // hit enemy front right
	[ effectArray[ 11 ] setModelShiftX:-1.0 shiftY:1.8 shiftZ:-1.0 ];
	[ effectArray[ 11 ] setParticleGravityX:-3.0 Y:-0.5 Z:3.0 ];

	
	for ( i=0 ; i < NH3D_MAX_EFFECTS ;i++ ) {
		[ effectArray[ i ] setParticleSize:8.5 ];
		effectArray[ i ].particleType = NH3DParticleTypePoints ;
		[ effectArray[ i ] setParticleColor:CLR_RED ];
		[ effectArray[ i ] setParticleSpeedX:1.0 Y:-1.0 ];
		[ effectArray[ i ] setParticleSlowdown:0.8 ];
		[ effectArray[ i ] setParticleLife:1.0 ];
	}
	
	// create lock
	viewLock = [ [ NSRecursiveLock alloc ] init ];
	// create modelbuffer
	delayDrawing = [ [ NSMutableArray alloc ] init ];
	modelDictionary = [ [NSMutableDictionary alloc] init ];
	keyArray = [ [ NSMutableArray alloc ] init ];
	// load cashed models
	[ self loadModels ];
	// anyflag setup
	oglParamNowChanging = NO;
	firstTime = YES;
	
	return self;
}*/
	}
	
	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
	
	func loadImageToTexture(named filename: String) -> GLuint {
		guard let sourcefile = NSImage(named: filename) else {
			return 0
		}
		var texID: GLuint = 0
		
		guard let sourceTiff = sourcefile.TIFFRepresentation, imgRep = NSBitmapImageRep(data: sourceTiff) else {
			return 0
		}
		
		viewLock.lock()
		
		glGenTextures(1, &texID);
		glBindTexture(GLenum(GL_TEXTURE_2D), texID);
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT);
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT);
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR);
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_GENERATE_MIPMAP), GL_TRUE);
		glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(imgRep.pixelsWide), GLsizei(imgRep.pixelsHigh), 0, GLenum(imgRep.alpha ? GL_RGBA : GL_RGB), GLenum(GL_UNSIGNED_BYTE), imgRep.bitmapData);

		viewLock.unlock()
		
		return texID
	}
	
	private final func checkLoadedModelsAt(startNum: Int32, to endNum: Int32, offset: Int32, modelName: String, textured flag: Bool, withOut without: Int32...) -> NH3DModelObjects? {
		var withoutFlag = false;
		
		for i in (startNum+offset)...(endNum+offset) {
			if modelDictionary[i] != nil {
				if without.count > 1 && without[0] != 0 {
					for wo in without {
						if i == wo+offset {
							withoutFlag = true;
							break;
						}
					}
					
					if withoutFlag {
						withoutFlag = false;
						continue;
					} else {
						return modelDictionary[i]
					}
					
				} else {
					return modelDictionary[i]
				}
			}
		}
		
		if modelName == "emitter"  {
			return NH3DModelObjects()
		} else {
			return NH3DModelObjects(with3DSFile: modelName, withTexture: flag)
		}
	}
	
	func turnOnSmooth() {
		glEnable(GLenum(GL_POLYGON_SMOOTH))
		glHint(GLenum(GL_POLYGON_SMOOTH_HINT), GLenum(GL_NICEST))
	}
	
	func turnOffSmooth() {
		glDisable(GLenum(GL_POLYGON_SMOOTH))
	}

	private func drawNullObject(x x: Float, z: Float, tex: GLuint ) {
		glPushMatrix();
		
		glTranslatef(x, 0.0, z)
		
		glEnableClientState(GLenum(GL_VERTEX_ARRAY));
		glEnableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
		glEnableClientState(GLenum(GL_NORMAL_ARRAY))
		
		glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		
		glActiveTexture( GLenum(GL_TEXTURE0) );
		glEnable( GLenum(GL_TEXTURE_2D) );
		
		glBindTexture( GLenum(GL_TEXTURE_2D), tex );
		glTexEnvf( GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GLfloat(GL_MODULATE) );
		
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_AMBIENT), nh3dMaterialArray[Int(NO_COLOR)].ambient)
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_DIFFUSE), nh3dMaterialArray[Int(NO_COLOR)].diffuse)
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_SPECULAR), nh3dMaterialArray[Int(NO_COLOR)].specular)
		glMaterialf(GLenum(GL_FRONT), GLenum(GL_SHININESS), nh3dMaterialArray[Int(NO_COLOR)].shininess)
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_EMISSION), nh3dMaterialArray[Int(NO_COLOR)].emission)
		
		
		glNormalPointer(GLenum(GL_FLOAT), 0, nullObjectNorms)
		glTexCoordPointer(2, GLenum(GL_FLOAT), 0, nullObjectTexVerts)
		glVertexPointer(3, GLenum(GL_FLOAT), 0, nullObjectVerts)
		glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 16)
		
		
		glDisableClientState(GLenum(GL_NORMAL_ARRAY))
		glDisableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
		glDisableClientState(GLenum(GL_VERTEX_ARRAY))
		
		glDisable(GLenum(GL_TEXTURE_2D))
		
		glPopMatrix()
	}
	
	/*
	private func drawFloorAndCeiling(x x: Float, z: Float, flag: Int32)
	{
	glPushMatrix();
	
	glTranslatef( x,0.0,z );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glEnableClientState( GL_NORMAL_ARRAY );
	
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	glMaterialfv( GL_FRONT , GL_AMBIENT , nh3dMaterialArray[ NO_COLOR ].ambient );
	glMaterialfv( GL_FRONT , GL_DIFFUSE , nh3dMaterialArray[ NO_COLOR ].diffuse );
	glMaterialfv( GL_FRONT , GL_SPECULAR , nh3dMaterialArray[ NO_COLOR ].specular );
	glMaterialf( GL_FRONT , GL_SHININESS , nh3dMaterialArray[ NO_COLOR ].shininess );
	glMaterialfv( GL_FRONT , GL_EMISSION , nh3dMaterialArray[ NO_COLOR ].emission );
	
	// Draw floor
	//drawFloorArray[flag]();
	
	glDisableClientState( GL_NORMAL_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
	glDisableClientState( GL_VERTEX_ARRAY );
	
	glPopMatrix();
	}
	
	
	private func createLightAndFog()
	{
	var gblight = 1.0 - ( Float(u.uhp) / Float(u.uhpmax) );
	
		var AmbLightPos: [ GLfloat ] = [0.0, 4.0, 0.0 ,0];
		var keyLightPos: [ GLfloat ] = [0.01, 3.0, 0.0 ,1]
		var fogColor: [ GLfloat ] = [gblight/4, 0.0, 0.0, 0.0]
		var lightEmisson: [ GLfloat ] = [0.1, 0.1, 0.1 ,1]
	
	self->keyLightCol[0] = 2.0;
	self->keyLightCol[3] = 1.0;
	if ( 1.00 - gblight < 0 )  {
	self-> keyLightCol[ 1 ] = 0.0;
	self->keyLightCol[ 2 ] = 0.0;
	} else {
	self->keyLightCol[ 1 ] = 2.00 - ( gblight * 2.0 );
	self->keyLightCol[ 2 ] = 2.00 - ( gblight * 2.0 );
	}
	
	glPushMatrix();
	
	glTranslatef(self->lastCameraX,
	self->lastCameraY,
	self->lastCameraZ);
	
	glFogi( GL_FOG_MODE , GL_LINEAR );
	glHint( GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST );
	
	glFogf( GL_FOG_START , 0.0 );
	
	switch elementalLevel {
	case 1: glClearColor( fogColor[ 0 ]+0.1, 0.0 , 0.01 ,0.0 );
	break;
	case 2: glClearColor( fogColor[ 0 ], 0.2 , 0.8 ,0.0 );
	break;
	case 3: glClearColor( fogColor[ 0 ]+0.4, 0.00 , 0.0 ,0.0 );
	break;
	case 4: glClearColor( fogColor[ 0 ], 0.6 , 0.9 ,0.0 );
	break;
	case 5: glClearColor( fogColor[ 0 ], 0.6 , 0.6 ,0.0 );
	break;
	default: glClearColor( fogColor[ 0 ], 0.0 ,0.0 ,0.0 );
	break;
	}
	
	if ( self->isReady && ( Blind || u.uswallow ) ) {
	// you blind
	
	glLightfv( GL_LIGHT0, GL_POSITION, AmbLightPos );
	glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, keyLightAltAmb );
	glLightf( GL_LIGHT0, GL_SHININESS, 0.01 );
	
	glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
	glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAltAmb );
	glLightfv( GL_LIGHT1, GL_DIFFUSE, keyLightAltCol );
	glLightfv( GL_LIGHT1, GL_SPECULAR, keyLightAltspec );
	
	glLightf( GL_LIGHT1, GL_SHININESS, 0.01 );
	
	
	glClearColor( 0.0 ,0.0 ,0.0 ,0.0 );
	glFogf( GL_FOG_END ,  6.0 );
	glFogfv( GL_FOG_COLOR,defaultBackGroundCol );
	
	} else if ( self->isReady && Underwater ) {
	
	glLightfv( GL_LIGHT0, GL_POSITION, AmbLightPos );
	glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, self->keyLightCol );
	glLightf( GL_LIGHT0, GL_SHININESS, 1.0 );
	
	glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
	glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
	glLightfv( GL_LIGHT1, GL_DIFFUSE, self->keyLightCol );
	glLightfv( GL_LIGHT1, GL_SPECULAR, keyLightspec );
	glLightfv( GL_LIGHT1, GL_EMISSION, lightEmisson );
	glLightf( GL_LIGHT1, GL_SHININESS, 30.0 );
	
	glClearColor( 0.0 ,0.0 ,0.8 ,0.0 );
	glFogf( GL_FOG_END ,  6.0 );
	glFogfv( GL_FOG_COLOR,underWaterColar );
	
	} else if ( IS_ROOM( levl[ u.ux ][ u.uy ].typ ) || IS_DOOR( levl[ u.ux ][ u.uy ].typ ) ) {
	// in room
	int i;
	
	glLightfv( GL_LIGHT0, GL_POSITION, AmbLightPos );
	glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, self->keyLightCol );
	glLightf( GL_LIGHT0, GL_SHININESS, 0.01 );
	
	glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
	glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
	glLightfv( GL_LIGHT1, GL_DIFFUSE, self->keyLightCol );
	glLightfv( GL_LIGHT1, GL_SPECULAR, keyLightspec );
	glLightfv( GL_LIGHT1, GL_EMISSION, lightEmisson );
	glLightf( GL_LIGHT1, GL_SHININESS, 30.0 );
	
	// check lit position.
	glFogf( GL_FOG_END , 4.5 + MAP_MARGIN * NH3DGL_TILE_SIZE );
	
	for ( i=1 ; i<=MAP_MARGIN ; i++ ) {
	if ( ( IS_ROOM( levl[ u.ux ][ u.uy + i ].typ ) || IS_DOOR( levl[ u.ux ][ u.uy + i ].typ ) )
	&& levl[ u.ux ][ u.uy + i ].glyph == S_stone + GLYPH_CMAP_OFF ) {
	glFogf( GL_FOG_END ,  4.5 + i * NH3DGL_TILE_SIZE );
	break;
	} else if ( ( IS_ROOM( levl[ u.ux ][ u.uy - i ].typ ) || IS_DOOR( levl[ u.ux ][ u.uy - i ].typ ) )
	&& levl[ u.ux ][ u.uy - i ].glyph == S_stone + GLYPH_CMAP_OFF ) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	} else if ( ( IS_ROOM( levl[ u.ux + i ][ u.uy + i ].typ ) || IS_DOOR( levl[ u.ux + i ][ u.uy ].typ ) )
	&& levl[ u.ux + i ][ u.uy ].glyph == S_stone + GLYPH_CMAP_OFF ) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	
	} else if ( ( IS_ROOM( levl[ u.ux - i ][ u.uy ].typ ) || IS_DOOR( levl[ u.ux - i ][ u.uy ].typ ) )
	&& levl[ u.ux - i ][ u.uy ].glyph == S_stone + GLYPH_CMAP_OFF ) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	}
	}
	
	glFogfv( GL_FOG_COLOR,fogColor );
	
	} else if ( levl[ u.ux ][ u.uy ].typ == CORR ) {
	// in corr
	int i;
	
	glLightfv( GL_LIGHT0, GL_POSITION, AmbLightPos );
	glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, self->keyLightCol );
	glLightf( GL_LIGHT0, GL_SHININESS, 0.01 );
	
	glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
	glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
	glLightfv( GL_LIGHT1, GL_DIFFUSE, self->keyLightCol );
	glLightfv( GL_LIGHT1, GL_SPECULAR, keyLightspec );
	glLightfv( GL_LIGHT1, GL_EMISSION, lightEmisson );
	glLightf( GL_LIGHT1, GL_SHININESS, 30.0 );
	
	for ( i=1 ; i<=MAP_MARGIN ; i++ ) {
	if ( 			levl[ u.ux ][ u.uy+i ].typ == CORR
	&&   !levl[ u.ux ][ u.uy+i ].lit
	) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	} else if ( 		  levl[ u.ux ][ u.uy-i ].typ == CORR
	&&   !levl[ u.ux ][ u.uy-i ].lit
	) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	} else if ( 		  levl[ u.ux + i ][ u.uy ].typ == CORR
	&&   !levl[ u.ux + i ][ u.uy ].lit
	) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	} else if ( 	  levl[ u.ux - i ][ u.uy ].typ == CORR
	&&   !levl[ u.ux - i ][ u.uy ].lit
	) {
	glFogf( GL_FOG_END , 4.5 + i * NH3DGL_TILE_SIZE );
	break;
	}
	
	}
	
	
	} else {
	glLightfv( GL_LIGHT0, GL_POSITION, AmbLightPos );
	glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, self->keyLightCol );
	glLightf( GL_LIGHT0, GL_SHININESS, 1.0 );
	
	glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
	glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
	glLightfv( GL_LIGHT1, GL_DIFFUSE, self->keyLightCol );
	glLightfv( GL_LIGHT1, GL_SPECULAR, keyLightspec );
	glLightfv( GL_LIGHT1, GL_EMISSION, lightEmisson );
	glLightf( GL_LIGHT1, GL_SHININESS, 10.0 );
	
	glFogf( GL_FOG_END ,  4.5 + u.nv_range * NH3DGL_TILE_SIZE );
	glFogfv( GL_FOG_COLOR,fogColor );
	
	}
	
	glEnable( GL_LIGHT0 );
	glEnable( GL_LIGHT1 );
	
	glPopMatrix();
	
	}*/
	
	
	//---------- draw floor function ----------------
	
	
	private func floorfunc_default() {
	return;
	}

	/*
@implementation NH3DOpenGLView
@synthesize cameraHead;


//------------------------------------------------------------------
// for speed up functions. (replace 'switch' method)
//------------------------------------------------------------------


//#define NH3DOpenGLViewCast( self )  \
//( ( struct { @defs( NH3DOpenGLView ) } * ) self )
//#define NH3DOpenGLViewCast( self ) ((NH3DOpenGLView*)self)




- ( BOOL )isOpaque
{
	return ( !firstTime ) ? YES : NO ;
}



- ( void ) dealloc
{
	int i,j;
	
	[ delayDrawing removeAllObjects ];

	[ modelDictionary removeAllObjects ];
	
	for ( i=0 ; i<NH3D_MAX_EFFECTS ;i++ ) {
		effectArray[i] = nil;
	}
	
	for ( i=0 ; i<NH3DGL_MAPVIEWSIZE_COLUMN ;i++ ) {
		for ( j=0 ; j<NH3DGL_MAPVIEWSIZE_ROW ; j++ ) {
			mapItemValue [ i ][ j ] = nil;
		}
	}
	
	for ( i = 0 ; i < MAX_GLYPH ; i++ ) {
		GLuint texid = defaultTex[ i ];
		glDeleteTextures( 1 , &texid );
	}
	
	glDeleteTextures( 1 , &floorTex );
	glDeleteTextures( 1 , &floor2Tex );
	glDeleteTextures( 1 , &cellingTex );
	glDeleteTextures( 1 , &waterTex );
	glDeleteTextures( 1 , &poolTex );
	glDeleteTextures( 1 , &lavaTex );
	glDeleteTextures( 1 , &envelopTex );
	glDeleteTextures( 1 , &minesTex );
	glDeleteTextures( 1 , &airTex );
	glDeleteTextures( 1 , &cloudTex );
	glDeleteTextures( 1 , &hellTex );
	glDeleteTextures( 1 , &nullTex );
	glDeleteTextures( 1 , &rougeTex );
}


-(void)detachOpenGLThread
{
	int i;
	threadRunning = YES;
	
	for ( i=0 ; i<OPENGLVIEW_NUMBER_OF_THREADS ;i++ )
	[ NSThread detachNewThreadSelector:@selector( timerFired: ) toTarget:self withObject:self ];
}


- (void)awakeFromNib
{
	[super awakeFromNib];
	NSNotificationCenter *nCenter =[ NSNotificationCenter defaultCenter ];
	[ nCenter addObserver:self
				 selector:@selector(defaultDidChange:)
					 name:@"NSUserDefaultsDidChangeNotification"
				   object:nil ];
	
	CGDisplayModeRef curCfg = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
	dRefreshRate = CGDisplayModeGetRefreshRate(curCfg);
	CGDisplayModeRelease(curCfg);

	runnning = YES;
	threadRunning = NO;
	
	// set drawflag for Nh3d Titles
	[self setNeedsDisplay:YES];

	// setup from defaults
	[self defaultDidChange:nil];
	
	useTile = NH3DGL_USETILE;
	
	// Create and detach to other thread for OpenGL update and drawing.  
	if ( !TRADITIONAL_MAP )
		[self detachOpenGLThread];
}


// OpenGL update method.
- (void)timerFired:(id)sender
{
	@autoreleasepool {
	
		[self.openGLContext makeCurrentContext];
		
		[viewLock lock];
		
		if ( OPENGLVIEW_WAITSYNC )
			[ self.openGLContext setValues:&vsincWait forParameter:NSOpenGLCPSwapInterval ];
		else 
			[ self.openGLContext setValues:&vsincNoWait forParameter:NSOpenGLCPSwapInterval ];
		[ viewLock unlock ];
		
		while ( runnning && !TRADITIONAL_MAP ) {
			@autoreleasepool {

			if ( isReady && !nowUpdating && ! self.needsDisplay ) {
			//if ( isReady && !nowUpdating ) {
				[self updateGlView];
			}
			
			
			if ( hasWait ) [ NSThread sleepUntilDate:[ NSDate dateWithTimeIntervalSinceNow:( 1.0 / waitRate ) ] ];
			
			}
		}
	
	}
	[NSThread exit];
}


// draw title.
- (void) drawRect:(NSRect) theRect
{
	
	if ( isReady || !firstTime ) {
		return; 
	} else {
		NSMutableDictionary *attributes = [ [ NSMutableDictionary alloc ] init ];
		attributes[NSFontAttributeName] = [ NSFont fontWithName:@"Copperplate"
											  size: 20 ];
		attributes[NSForegroundColorAttributeName] = [ NSColor colorWithCalibratedWhite:0.5 alpha:0.6 ];
	
		[ self lockFocusIfCanDraw ];
	
		[ [ NSColor clearColor ] set ];
		[ NSBezierPath fillRect: self.bounds ];
	
		[[NSImage imageNamed:@"nh3d"] drawAtPoint:NSMakePoint( 156.0 ,88.0 ) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.7];
		//[ [ NSImage imageNamed:@"nh3d" ] dissolveToPoint:NSMakePoint( 156.0 ,88.0 ) fraction:0.7 ];
		[ @"NetHack3D" drawAtPoint:NSMakePoint( 168.0 ,70.0 ) withAttributes:attributes ];
		attributes[NSFontAttributeName] = [ NSFont fontWithName:@"Copperplate"
												size: 14 ];
		[ @"by Haruumi Yoshino 2005" drawAtPoint:NSMakePoint( 130.0 ,56.0 ) withAttributes:attributes ];
		[ @"NetHack" drawAtPoint:NSMakePoint( 192.0 ,29.0 ) withAttributes:attributes ];
		attributes[NSFontAttributeName] = [ NSFont fontWithName:@"Copperplate"
												size: 11 ];
		[ @"Copyright ( c ) Stichting Mathematisch Centrum  Amsterdam, 1985. \n   NetHack may be freely redistributed. See license for details."
						drawAtPoint:NSMakePoint( 38.0 ,3.0 ) withAttributes:attributes ];
	
		[ self unlockFocus ];
	
		firstTime = NO;
	
	}
}

- (void)drawGlView:(int)x z:(int)z
{
	NH3DMapItem *mapItem = mapItemValue[ x ][ z ];
	int			type = [ mapItem modelDrawingType ];
				
	if ( type != 10 ) {
		switchMethodArray[type](mapItem.posX,
								mapItem.posY,
								x, z);
	} else {
		// delay drawing for alphablending.
		NSNumber *numX = @(x);
		NSNumber *numZ = @(z);
		
		[ delayDrawing addObject:mapItem ];
		[ delayDrawing addObject:numX ];
		[ delayDrawing addObject:numZ ];
		// if you want use this method from difference thread,
		// you must do some tricky technique for using collectionclass. 
		// e.g;
		// [ NSMutableArrayobject addObject:[ [ [ NSNumber numberWithInt:x ] retain ] autorelease ] ];
		// [ NSDictionaryobject addObject:[ [ mapItem retain ] autorelease ] ];
	}
}

// Drawing OpenGL functions.
- ( void )updateGlView
{
	if ( nowUpdating || TRADITIONAL_MAP ) return;
	
	if ( [ viewLock tryLock ] ) {
		
		static int clearCnt;
		int x,z;
		nowUpdating = YES;
		
		if (!Hallucination || clearCnt == 10) {
			glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
			clearCnt=0;
		} else clearCnt++;
		
		
		glPushMatrix();
		
		[self panCamera];
		[self dorryCamera];
		
		if ( isFloating )
			[self floatingCamera];
		if ( isShocked )
			[self shockedCamera];
		
		// draw models
		// at first. normal objects
		switch ( (int)_mapModel.playerDirection) {
			case PL_DIRECTION_FORWARD:
				for ( x=0 ; x < NH3DGL_MAPVIEWSIZE_COLUMN ; x++ ) {
					for ( z=0 ; z < MAP_MARGIN+drawMargin ; z++ ) {
						[self drawGlView:x z:z];
					}
				}
				break;
			case PL_DIRECTION_RIGHT:
				for ( z=0 ; z < NH3DGL_MAPVIEWSIZE_ROW ; z++ ) {
					for ( x=NH3DGL_MAPVIEWSIZE_COLUMN-1 ; x > MAP_MARGIN-drawMargin ; x-- ) {
						[self drawGlView:x z:z];
					}
				}
				break;
			case PL_DIRECTION_BACK:
				for ( x=0 ; x < NH3DGL_MAPVIEWSIZE_COLUMN ; x++ ) {
					for ( z=NH3DGL_MAPVIEWSIZE_ROW-1 ; z > MAP_MARGIN-drawMargin ; z-- ) {
						[self drawGlView:x z:z];
					}
				}
				break;
			case PL_DIRECTION_LEFT:
				for ( z=0 ; z < NH3DGL_MAPVIEWSIZE_ROW ; z++ ) {
					for ( x=0 ; x < MAP_MARGIN+drawMargin ; x++ ) {
						[self drawGlView:x z:z];
					}
				}
				break;
		}
				
		// next. particle objects
		for ( x=0 ; x < delayDrawing.count ; x+=3 ) {
			NH3DMapItem *mapItem = delayDrawing[x];
			int lx = [ delayDrawing[x+1] intValue ];
			int lz = [ delayDrawing[x+2] intValue ];
			switchMethodArray[ [ mapItem modelDrawingType ] ]( mapItem.posX ,
															   mapItem.posY ,lx,lz);
		} // end for x
		
		
		if ( enemyPosition ) {
			[ self doEffect ];
		}
		
		
		createLightAndFog( self );
		
		glPopMatrix();
		
		[self.openGLContext flushBuffer];
		
		[ delayDrawing removeAllObjects ];
		
		nowUpdating = NO;
		[viewLock unlock];
	}
}


- (void)setFrameSize:(NSSize) newSize
{
	[super setFrameSize:newSize];
	
	glViewport( 0, 0, newSize.width, newSize.height );
}


- (void)clearGLView
{
	glClearColor( 0, 0, 0, 0 );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
}


- (void)drawModelArray:(NH3DMapItem *)mapItem
{
	int glyph = [ mapItem glyph ];
	
	if ( glyph != S_room + GLYPH_CMAP_OFF ) {
		[ viewLock lock ];
		static GLfloat rot;
		float posx = mapItem.posX * NH3DGL_TILE_SIZE;
		float posz = mapItem.posY * NH3DGL_TILE_SIZE;
		
		NSNumber *modelNum = @(glyph);
		id model = modelDictionary[modelNum];
		
		if ( model == nil && !defaultTex[ glyph ] ) {
			
			NH3DModelObjects *newModel = loadModelBlocks[glyph](glyph);
			if ( newModel != nil ) {
				if ( glyph >= PM_GIANT_ANT+GLYPH_MON_OFF && glyph <= PM_APPRENTICE + GLYPH_MON_OFF ) {
					newModel.animated = YES;
					newModel.animationRate = ( ( float )( random() %5 )*0.1 )+0.5 ;
					[ newModel setPivotX:0.0 atY:0.3 atZ:0.0 ];
					[ newModel setUseEnvironment:YES ];
					newModel.texture = envelopTex ;
				}
				//NSLog(@"bf retaincount %d",[ newModel retainCount ]);
				modelDictionary[modelNum] = newModel;
				//NSLog(@"af retaincount %d",[ newModel retainCount ]);
				[ keyArray addObject:@(glyph) ];
				
				model = modelDictionary[modelNum];
			}
		}
		
		if ( rot >= 360.0 ) rot -= 360.0;
		
		
		glPushMatrix();
		glTranslatef(posx, 0.0, posz);
		
		if ( model == nil
			 && !( glyph >= S_stone+GLYPH_CMAP_OFF
				   && glyph <= S_water+GLYPH_CMAP_OFF ) ) { // Draw alternate object.
			
			float f,angle;
			
			glPushMatrix();
			glRotatef(rot, 0.0, 1.0, 0.0);
			
			if ( !defaultTex[ glyph ] ) {
				if ( NH3DGL_USETILE )
					defaultTex[glyph] = [self createTextureFromSymbol:mapItem.tile withColor:nil];
				else 
					defaultTex[glyph] = [self createTextureFromSymbol:[mapItem symbol] withColor:[mapItem color]];
			}
			glActiveTexture( GL_TEXTURE0 );
			glEnable( GL_TEXTURE_2D );
			
			glEnable( GL_ALPHA_TEST );
			glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
			
			glBindTexture( GL_TEXTURE_2D, defaultTex[ glyph ] );
			glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
			
			glMaterialfv( GL_FRONT , GL_AMBIENT , nh3dMaterialArray[ NO_COLOR ].ambient );
			glMaterialfv( GL_FRONT , GL_DIFFUSE , nh3dMaterialArray[ NO_COLOR ].diffuse );
			glMaterialfv( GL_FRONT , GL_SPECULAR , nh3dMaterialArray[ NO_COLOR ].specular );
			glMaterialf( GL_FRONT , GL_SHININESS , nh3dMaterialArray[ NO_COLOR ].shininess );
			glMaterialfv( GL_FRONT , GL_EMISSION , nh3dMaterialArray[ NO_COLOR ].emission );
			
			
			glAlphaFunc( GL_GREATER, 0.5 );
			
			glEnableClientState( GL_VERTEX_ARRAY );
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glEnableClientState( GL_NORMAL_ARRAY );
			
			glNormalPointer( GL_FLOAT, 0 ,defaultNorms );
			glTexCoordPointer( 2,GL_FLOAT,0, defaultTexVerts );
			glVertexPointer( 3 , GL_FLOAT , 0 , defaultVerts );
			
			
			glDisable( GL_CULL_FACE );
			angle = 5.0;
			for ( f = 0.0 ; f < 0.02 ; f += 0.002 ) {
				angle *= -1.0;
				glTranslatef( 0.0 ,0.0 ,f );
				glRotatef(angle,	0, 1.0, 0);
				glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
			}
			glEnable( GL_CULL_FACE );
			
			glDisableClientState( GL_NORMAL_ARRAY );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glDisableClientState( GL_VERTEX_ARRAY );
			
			glDisable( GL_ALPHA_TEST );
			glDisable( GL_TEXTURE_2D );
			
			
			glPopMatrix();
			
		} else { // Draw model 
			
			if ( [ model isAnimated ] ) {
				glRotatef( [ model animationValue ],   0.0, 1.0, 0.0 );
			}
			
			if ( glyph >= PM_GIANT_ANT+GLYPH_MON_OFF && glyph <= NUMMONS ) {
				int materialCol = [ mapItem material ];
				// setMaterial
				[ model setCurrentMaterial: nh3dMaterialArray[ materialCol ] ];
				
			} else if ( glyph == S_vwall + GLYPH_CMAP_OFF ) {
				
				[ model setCurrentMaterial: nh3dMaterialArray[ NO_COLOR ] ];
				if ( (( int )posz) % 5 ) { 
					[ [model childObjectAtIndex:0] setActive:NO ];
				} else {
					[ [model childObjectAtIndex:0] setActive:YES ];
				}
				
			} else if ( glyph == S_hwall + GLYPH_CMAP_OFF ) {
				
				[ model setCurrentMaterial: nh3dMaterialArray[ NO_COLOR ] ];
				if ( (( int )posx) % 5 ) { 
					[ [model childObjectAtIndex:0] setActive:NO ];
				} else {
					[ [model childObjectAtIndex:0] setActive:YES ];
				}
				
			} else {
				[ model setCurrentMaterial: nh3dMaterialArray[ NO_COLOR ] ];
			}
			
			
			[ model drawSelf ];
			[ model animate ];
			
		}
		
		glPopMatrix();
		
		rot += 0.05;
		[ viewLock unlock ];
	}
	
}


- (void)updateMap
{
	
	if ( !isReady || TRADITIONAL_MAP ) {
		return;
	} else {
		
		[viewLock lock];
		int x,z;
		int localx = 0;
		int localz = 0;
		
		nowUpdating = YES;
		
		for ( x = centerX-MAP_MARGIN;x < centerX+1+MAP_MARGIN;x++ ) {
			for ( z = centerZ-MAP_MARGIN;z < centerZ+1+MAP_MARGIN;z++ ) {
				NH3DMapItem *mapItem = [ _mapModel mapArrayAtX:x atY:z ];
				mapItemValue[ localx ][ localz ] = mapItem;			
				localz++;
			}
			localx++;
			localz=0;
		}
		
		isFloating = NO;
		isRiding = NO;
		cameraPitch = 0;
		
		if ( Levitation ) { cameraY = 2.8; cameraPitch = -1.0; isFloating = YES; }
		if ( Flying ) { cameraY = 3.8; cameraPitch = -8.0; isFloating = YES; }

#ifdef STEED
		if ( u.usteed ) { cameraY = 2.4; isFloating = YES; isRiding = YES; }
#endif
		if ( u.utrap && u.utraptype == TT_PIT ) cameraY = 0.1;
		if ( Underwater ) { cameraY = 0.1; isFloating = YES; }
	
		nowUpdating = NO;
		[ viewLock unlock ];
	
	}	
}


- ( void )changeWallsTexture:(int)tex_id
{
	[ modelDictionary[@(S_vwall + GLYPH_CMAP_OFF)] setTexture:tex_id ];
	[ modelDictionary[@(S_hwall + GLYPH_CMAP_OFF)] setTexture:tex_id ];
	[ modelDictionary[@(S_tlcorn + GLYPH_CMAP_OFF)] setTexture:tex_id ];	
}

- ( void )setCenterAtX:( int )x z:( int )z depth:( int )depth
{
	
	[ viewLock lock ];
	nowUpdating = YES;
	
	centerX = x;
	centerZ = z;
	
	if ( playerdepth != depth ) {
		elementalLevel = 0;
		isReady = NO;
		
		// Clear modelDictionary
		//@synchronized( modelDictionary ) {
		//	@synchronized( keyArray ) {
				[ modelDictionary removeObjectsForKeys:keyArray ];
				[ keyArray removeAllObjects ];
		//	}
		//}
		
		// Setup speciallevels
		if ( In_mines( &u.uz ) ) {
			[ self changeWallsTexture:1 ];			
			floorCurrent = minesTex;
			cellingCurrent = cellingTex;
			elementalLevel = 0;
			
		} else 	if ( In_hell( &u.uz ) ) {
			[ self changeWallsTexture:2 ];
			floorCurrent = hellTex;
			cellingCurrent = cellingTex;
			elementalLevel = 0;
			
			//glPolygonMode( GL_FRONT_AND_BACK,GL_FILL );
			
		} else 	if ( Is_knox( &u.uz ) || Is_sanctum( &u.uz ) || Is_stronghold( &u.uz ) ) {
			[ self changeWallsTexture:3 ];
			floorCurrent = floor2Tex;
			cellingCurrent = floor2Tex;
			elementalLevel = 0;
	
		} else 	if ( In_sokoban( &u.uz ) ) {
			[ self changeWallsTexture:0 ];
			floorCurrent = floorTex;
			cellingCurrent = floorTex;
			elementalLevel = 0;
			/* not yat */
	
		} else if ( Is_earthlevel( &u.uz )  ) {
			[ self changeWallsTexture:3 ];
			floorCurrent = floor2Tex;
			cellingCurrent = floor2Tex;
			
			elementalLevel = 1;	
			
		} else if ( Is_waterlevel( &u.uz )  ) {
			[ self changeWallsTexture:3 ];
			floorCurrent = floor2Tex;
			cellingCurrent = floor2Tex;
			
			elementalLevel = 2;	
			
		} else if ( Is_firelevel( &u.uz )  ) {
			[ self changeWallsTexture:3 ];
			floorCurrent = floor2Tex;
			cellingCurrent = floor2Tex;
			
			elementalLevel = 3;
			
		} else if ( Is_airlevel( &u.uz )  ) {
			[ self changeWallsTexture:3 ];
			floorCurrent = floor2Tex;
			cellingCurrent = floor2Tex;
			
			elementalLevel = 4;
			
		} else if ( Is_astralevel( &u.uz )  ) {
			[ self changeWallsTexture:3 ];
			floorCurrent = floor2Tex;
			cellingCurrent = floor2Tex;
			
			elementalLevel = 5;
		
		} else if ( Is_rogue_level( &u.uz ) ) {
			[ self changeWallsTexture:4 ];
			floorCurrent = rougeTex;
			cellingCurrent = rougeTex;
			
		} else if ( floorCurrent != floorTex ) {
			[ self changeWallsTexture:0 ];
			floorCurrent = floorTex;
			cellingCurrent = cellingTex;
			elementalLevel = 0;
			
		}
		
		playerdepth = depth;
		
	} else {
		playerdepth = depth;
	}
	
	[ viewLock unlock ];
	
	[ self setCameraAtX:( float )x*NH3DGL_TILE_SIZE atY:1.8 atZ:( float )z*NH3DGL_TILE_SIZE ];
	
}


- ( void )setCameraHead:( float )head pitching:( float )pitch rolling:( float )roll
{
	[ viewLock lock ];
	{
		nowUpdating = YES;
		
		drawMargin = 3;
		
		if ( head >= 360 ) { 
			head -= 360;
			lastCameraHead -= 360;
		}
		if ( head < 0 ) {
			head += 360;
			lastCameraHead += 360;
		}
		
		cameraHead = head;
		cameraPitch = pitch;
		cameraRoll = roll;
		
		nowUpdating = NO;
	}
	[ viewLock unlock ];
}


- ( void )setCameraAtX:( float )x atY:( float )y atZ:( float )z
{	
	
	[ viewLock lock ];
	{
		nowUpdating = YES;
		NSSound *footstep = [NSSound soundNamed:@"footStep.wav"];
		
		drawMargin = 1;
		
		cameraX = x;
		cameraY = y;
		cameraZ = z;
		
		
		if ( !isReady ) {
			lastCameraX = cameraX;
			lastCameraY = cameraY;
			lastCameraZ = cameraZ;
			isReady = YES;
		} else 	if ( footstep.playing && ( (!isFloating || isRiding) && !IS_SOFT( levl[ u.ux ][ u.uy ].typ )) && !SOUND_MUTE ) {
			[ footstep stop ];
			[ footstep play ];
		} else if ( (!isFloating || isRiding) && !IS_SOFT( levl[ u.ux ][ u.uy ].typ ) && !SOUND_MUTE ) {
			[ footstep play ];
		}
		
		nowUpdating = NO;
	}
	[ viewLock unlock ];
	
	if (TRADITIONAL_MAP) {
		self.hidden = YES;
	} else if (!TRADITIONAL_MAP && !threadRunning) {
		self.openGLContext.view = self;
		[self detachOpenGLThread];
	}
	
}


// ---------------------------------
// effect and visual function.
// ---------------------------------

/*
- ( void )applyCIFilters
{
	CIContext *myCIContext;
	myCIContext = [CIContext contextWithCGLContext:CGLGetCurrentContext()  
										   options:nil]; 
}
*/





- ( void )setIsShocked:( BOOL )flag
{
	[ viewLock lock ];
	nowUpdating = YES;
	isShocked = flag;
	nowUpdating = NO;
	[ viewLock unlock ];
}


- ( void )setEnemyPosition:( int )direction
{
	[ viewLock lock ];
	nowUpdating = YES;
	enemyPosition = direction;
	nowUpdating = NO;
	[ viewLock unlock ];

}

// ---------------------------------

- ( void )doEffect
{
	static int effectCount;
	NH3DVertexType localPos = effectArray[ enemyPosition-1 ].modelShift ;
	
	[ effectArray[ enemyPosition-1 ] setPivotX:cameraX+localPos.x
										 atY:localPos.y
										 atZ:cameraZ+localPos.z ];
	
	if ( effectCount < ( int )waitRate / 2 ) {
		[ effectArray[ enemyPosition-1 ] drawSelf ];
		effectCount++;
	} else {
		effectCount = 0;
		enemyPosition = 0;
	}

}



- ( void )floatingCamera
{
	static float fltCamera;
	static BOOL	floatDirection;	
	
	fltCamera = ( floatDirection ) ? fltCamera+0.003 : fltCamera-0.003;
	if ( fltCamera > 0.08 ) floatDirection = NO;
	if ( fltCamera < -0.08 ) floatDirection = YES;
	
	glTranslatef( 0.0 ,fltCamera ,0.0 );
	
}

- ( void )shockedCamera
{
	static float cameraShock;
	static int shockCount;
	static BOOL	shockDirection;
	
	//cameraShock = ( shockDirection ) ? cameraShock+( float )( ( random() %4 )*0.01 ) : cameraShock-( float )( ( random() %4 )*0.01 );
	cameraShock = ( shockDirection ) ? cameraShock+0.04 : cameraShock-0.04;
	if ( cameraShock > 0.08 ) shockDirection = NO;
	if ( cameraShock < -0.08 ) shockDirection = YES;
	
	shockCount++;
	
	if ( shockCount > waitRate / 2 ) {
		isShocked = NO;
		shockCount = 0;
	}
	
	glTranslatef( 0.0 ,cameraShock ,0.0 );
	
}
	


- ( void )dorryCamera
{
	GLfloat xstep,ystep,zstep;
	
	if ( !isReady ) {
		glTranslatef( -cameraX,-cameraY,-cameraZ );
	} else if ( lastCameraX == cameraX && lastCameraY == cameraY && lastCameraZ == cameraZ ) {
		glTranslatef( -cameraX,-cameraY,-cameraZ );
		if ( drawMargin != 3 ) drawMargin = 0;
	} else {		
		xstep = ( cameraX - lastCameraX ) / cameraStep;	
		ystep = ( cameraY - lastCameraY ) / cameraStep;
		zstep = ( cameraZ - lastCameraZ ) / cameraStep;
		
		lastCameraZ += zstep;
		lastCameraY += ystep;
		lastCameraX += xstep;
		
		if ( xstep < 0.001 && xstep > -0.001 ) lastCameraX = cameraX;
		if ( ystep < 0.001 && ystep > -0.001 ) lastCameraY = cameraY;
		if ( zstep < 0.001 && zstep > -0.001 ) lastCameraZ = cameraZ;
		
		glTranslatef( -lastCameraX,-lastCameraY,-lastCameraZ );
		
	} 
	
}


- ( void )panCamera
{
	GLfloat rollstep,pitchstep,headstep;
	
	if ( !isReady ) {
		glRotatef( cameraRoll,		0,0,1 );
		glRotatef( -cameraPitch,	1,0,0 );
		glRotatef( -cameraHead,		0,1,0 );	
	} else if ( lastCameraHead == cameraHead ) {
		if ( drawMargin != 1 ) drawMargin  = 0;
		glRotatef( cameraRoll,		0,0,1 );
		glRotatef( -cameraPitch,	1,0,0 );
		glRotatef( -cameraHead,		0,1,0 );
	} else {
		rollstep = ( cameraRoll - lastCameraRoll ) / cameraStep;
		pitchstep = ( cameraPitch - lastCameraPitch ) / cameraStep;
		headstep = ( cameraHead - lastCameraHead ) / cameraStep;
		
		lastCameraRoll += rollstep;
		lastCameraPitch += pitchstep;
		lastCameraHead += headstep;
		
		if ( (rollstep < 0.01 && rollstep > -0.01) || rollstep > 90.0 ) lastCameraRoll = cameraRoll;
		if ( (pitchstep < 0.01 && pitchstep > -0.01) || pitchstep > 90.0 ) lastCameraPitch = cameraPitch;
		if ( (headstep < 0.01 && headstep > -0.01) || headstep > 90.0 ) lastCameraHead = cameraHead;
		
		glRotatef( lastCameraRoll,		0,0,1 );
		glRotatef( -lastCameraPitch,	1,0,0 );
		glRotatef( -lastCameraHead,		0,1,0 );

	}
	
}


//---------------------------------------------------


- ( GLuint )loadImageToTexture:( NSString * )filename
{
	NSImage				*sourcefile = [NSImage imageNamed:filename];
	NSBitmapImageRep	*imgrep;
	GLuint				tex_id;
	
	imgrep = [[NSBitmapImageRep alloc] initWithData:sourcefile.TIFFRepresentation];
	
	[ viewLock lock ];
	
	glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );

	glGenTextures( 1, &tex_id );
	glBindTexture( GL_TEXTURE_2D, tex_id );
	
	glTexParameterf( GL_TEXTURE_2D,GL_GENERATE_MIPMAP,GL_TRUE );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

	// create texture
/*	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 
				  [ imgrep pixelsWide ], [ imgrep pixelsHigh ], 
				  0,
				  [ imgrep hasAlpha ] ? GL_RGBA : GL_RGB, 
				  GL_UNSIGNED_BYTE, 
				  [ imgrep bitmapData ] ); // */
	
	// create automipmap texture
	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGBA,
					  imgrep.pixelsWide, imgrep.pixelsHigh,
					  imgrep.alpha ? GL_RGBA : GL_RGB,
					  GL_UNSIGNED_BYTE,imgrep.bitmapData);
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );

	[viewLock unlock];
	
	return tex_id;
}


- ( GLuint )createTextureFromSymbol:( id )symbol withColor:( NSColor* )color
{
	[ viewLock lock ];
	
	GLuint tex_id;
	NSImage				*img = [[NSImage alloc] initWithSize:NSMakeSize( TEX_SIZE , TEX_SIZE )];
	NSBitmapImageRep	*imgrep;
	NSSize				symbolsize;
	
	img.backgroundColor = [NSColor clearColor];
	
	if ( !NH3DGL_USETILE ) {
		NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		NSString *fontName = [[NSUserDefaults standardUserDefaults] stringForKey:NH3DWindowFontKey];
		
		
		attributes[NSFontAttributeName] = [NSFont fontWithName: fontName
														  size: TEX_SIZE];
		attributes[NSForegroundColorAttributeName] = color;
		attributes[NSBackgroundColorAttributeName] = [NSColor clearColor];
		
		symbolsize = [symbol sizeWithAttributes:attributes];
	
		// Draw texture
		[img lockFocus];
		
		[symbol drawAtPoint:NSMakePoint( ( TEX_SIZE/2 ) - ( symbolsize.width/2 ) ,( TEX_SIZE/2 ) - ( symbolsize.height/2 ) )
			  withAttributes:attributes];
		
		[img unlockFocus];
		
	} else {
		symbolsize = [symbol size];
		// Draw Tiled texture 
		[img lockFocus ];
		[symbol drawInRect:NSMakeRect( TEX_SIZE/4 ,0 ,(TEX_SIZE/4)*3 ,(TEX_SIZE/4)*3 )
				   fromRect:NSMakeRect( 0 ,0 ,symbolsize.width ,symbolsize.height )
				  operation:NSCompositeSourceOver
				   fraction:1.0];
		[img unlockFocus];
	}
	
	
	imgrep = [[NSBitmapImageRep alloc] initWithData:img.TIFFRepresentation];
	
	
	glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
	
	glGenTextures( 1, &tex_id );
	glBindTexture( GL_TEXTURE_2D, tex_id );
	
	glTexParameterf( GL_TEXTURE_2D,GL_GENERATE_MIPMAP,GL_TRUE );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	// create automipmap texture
	
	if (imgrep.alpha) {
		gluBuild2DMipmaps( GL_TEXTURE_2D,GL_RGBA,
						   imgrep.pixelsWide , imgrep.pixelsHigh ,
						   GL_RGBA,
						   GL_UNSIGNED_BYTE, imgrep.bitmapData );
	} else {
		gluBuild2DMipmaps( GL_TEXTURE_2D,GL_RGB,
						   imgrep.pixelsWide , imgrep.pixelsHigh ,
						   GL_RGB,
						   GL_UNSIGNED_BYTE, imgrep.bitmapData );
	}		
		
	
	// setup texture status
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
	
	glAlphaFunc( GL_GREATER, 0.5 );
	
	
	[viewLock unlock];
	
	return tex_id;
	
}


- ( void )loadModels
{
	//load models first time.
	@autoreleasepool {
	NH3DModelObjects *model;
	
//  -------------------------- Map Symbols Section. -------------------------- //
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"vwall" withTexture:YES];
	[ model addTexture:@"wall_mines" ];
	[ model addTexture:@"wall_hell" ];
	[ model addTexture:@"wall_knox" ];
	[ model addTexture:@"wall_rouge" ];
		[ model addChildObject:@"touch" type:NH3DModelTypeTexturedObject ];
		[ [ model childObjectAtLast ] setPivotX:0.478 atY:2.834 atZ:0.007 ];
		[ [ model childObjectAtLast ] addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setPivotX:0.593 atY:1.261 atZ:0 ];
			[ [ model childObjectAtLast ] childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_ORANGE ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleGravityX:0.0 Y:2.0 Z:0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:6.0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleLife:0.30 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSize:10.0 ];
	modelDictionary[@(S_vwall + GLYPH_CMAP_OFF)] = model;
				
	model = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"hwall" withTexture:YES ];
	[ model addTexture:@"wall_mines" ];
	[ model addTexture:@"wall_hell" ];
	[ model addTexture:@"wall_knox" ];
	[ model addTexture:@"wall_rouge" ];
		[ model addChildObject:@"touch" type:NH3DModelTypeTexturedObject ];
		[ [ model childObjectAtLast ] setPivotX:-0.005 atY:2.834 atZ:0.483 ];
		[ [ model childObjectAtLast ] addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setPivotX:0.593 atY:1.261 atZ:0 ];
			[ [ model childObjectAtLast ] childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_ORANGE ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleGravityX:0.0 Y:2.0 Z:0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:6.0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleLife:0.30 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSize:10.0 ];
		[ [ model childObjectAtLast ] setModelRotateX:0.0 rotateY:-90.0 rotateZ:0.0 ];
	modelDictionary[@(S_hwall + GLYPH_CMAP_OFF)] = model;
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"corner" withTexture:YES];
	[model addTexture:@"corner_mines"];
	[model addTexture:@"corner_hell"];
	[model addTexture:@"corner_knox"];
	[model addTexture:@"corner_rouge"];
	
	modelDictionary[@(S_tlcorn + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_trcorn + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_blcorn + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_brcorn + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_crwall + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_tuwall + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_tdwall + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_tlwall + GLYPH_CMAP_OFF)] = model;
	modelDictionary[@(S_trwall + GLYPH_CMAP_OFF)] = model;
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"vopendoor" withTexture:YES];
	modelDictionary[@(S_vodoor + GLYPH_CMAP_OFF)] = model;
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"hopendoor" withTexture:YES];
	modelDictionary[@(S_hodoor + GLYPH_CMAP_OFF)] = model;
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"vdoor" withTexture:YES];
	modelDictionary[@(S_vcdoor + GLYPH_CMAP_OFF)] = model;
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"hdoor" withTexture:YES];
	modelDictionary[@(S_hcdoor + GLYPH_CMAP_OFF)] = model;
			
		
	}
}


- (id)checkLoadedModelsAt:(int)startNum
					   to:(int)endNum
				   offset:(int)offset
				modelName:(NSString *)mName
				 textured:(BOOL)flag
				  withOut:(int)without, ...
{
	int i;
	va_list argumentList;
	int wo;
	BOOL withoutFlag = NO;
	
	for ( i = startNum+offset ; i <= endNum+offset ; i++ ) {
		if ( modelDictionary[@(i)] != nil ) {
			if ( without ) {
				va_start(argumentList, without);
				wo = va_arg(argumentList, int);
					while ( wo ) {
						if ( i == without+offset || i == wo+offset ) {
							withoutFlag = YES;
							break;
						}
						wo = va_arg(argumentList, int);
					}
				va_end(argumentList);
				
				if ( withoutFlag ) {
					withoutFlag = NO;
					continue;
				} else																	// Increment retain count
					return modelDictionary[@(i)];
					
			} else																	// Increment retain count
				return modelDictionary[@(i)];
		}
	}
	
	if ( [ mName isEqualToString:@"emitter" ] ) {
		return [[NH3DModelObjects alloc] init];
	} else {
		return [[NH3DModelObjects alloc] initWith3DSFile:mName withTexture:flag];
	}
}


- (void)setParamsForMagicEffect:(NH3DModelObjects*)magicItem color:(int)color
{
	[ magicItem setPivotX:0.0 atY:1.2 atZ:0.0 ];
	[ magicItem setModelScaleX:0.4 scaleY:1.0 scaleZ:0.4 ];
	magicItem.particleType = NH3DParticleTypeAura ;
	magicItem.particleColor = color ;
	[ magicItem setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
	[ magicItem setParticleSpeedX:1.0 Y:1.00 ];
	[ magicItem setParticleSlowdown:3.8 ];
	[ magicItem setParticleLife:0.4 ];
	[ magicItem setParticleSize:20.0 ];	
}


- (void)setParamsForMagicExplotion:(NH3DModelObjects*)magicItem color:(int)color
{
	magicItem.particleType = NH3DParticleTypeAura ;
	magicItem.particleColor = color ;
	[magicItem setParticleGravityX:0.0 Y:15.5 Z:0.0 ];
	[magicItem setParticleSpeedX:1.0 Y:15.00 ];
	[magicItem setParticleSlowdown:8.8 ];
	[magicItem setParticleLife:0.4 ];
	[magicItem setParticleSize:35.0 ];
}
	

- ( id )loadModelFunc_insect:(int)glyph
{
	// insect class
	return [self checkLoadedModelsAt:PM_GIANT_ANT
								  to:PM_QUEEN_BEE
							  offset:GLYPH_MON_OFF
						   modelName:@"lowerA" textured:NO withOut:0];
}


- ( id )loadModelFunc_blob:(int)glyph
{
	// blob class
	return [self checkLoadedModelsAt:PM_ACID_BLOB
								  to:PM_GELATINOUS_CUBE
							  offset:GLYPH_MON_OFF
						   modelName:@"lowerB" textured:NO withOut:0];
}


- ( id )loadModelFunc_cockatrice:(int)glyph
{
		// cockatrice class
	return [ self checkLoadedModelsAt:PM_CHICKATRICE
								   to:PM_PYROLISK
							   offset:GLYPH_MON_OFF
							modelName:@"lowerC" textured:NO withOut:0];
}


- ( id )loadModelFunc_dog:(int)glyph
{
	// dog or canine class
	return [ self checkLoadedModelsAt:PM_JACKAL
								   to:PM_HELL_HOUND
							   offset:GLYPH_MON_OFF
							modelName:@"lowerD" textured:NO withOut:0 ];
	
}


- ( id )loadModelFunc_sphere:(int)glyph
{
	// eye or sphere class
	return [ self checkLoadedModelsAt:PM_GAS_SPORE
								   to:PM_SHOCKING_SPHERE
							   offset:GLYPH_MON_OFF
							modelName:@"lowerE" textured:NO withOut:0 ];
	
}


- ( id )loadModelFunc_cat:(int)glyph
{	
	// cat or feline class
	return [ self checkLoadedModelsAt:PM_KITTEN
								   to:PM_TIGER
							   offset:GLYPH_MON_OFF
							modelName:@"lowerF" textured:NO withOut:0 ];
	
}


- ( id )loadModelFunc_gremlins:(int)glyph
{
	// gremlins and gagoyles class
	return [ self checkLoadedModelsAt:PM_GREMLIN
								   to:PM_WINGED_GARGOYLE
							   offset:GLYPH_MON_OFF
							modelName:@"lowerG" textured:NO withOut:0 ];
	
}


- ( id )loadModelFunc_humanoids:(int)glyph
{
	// humanoids class
	id ret =nil;
	
	if ( glyph ==  PM_DWARF_KING+GLYPH_MON_OFF ) {
		ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerH" withTexture:NO ];
		[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
		[ [ret childObjectAtLast] setPivotX:0.0 atY:0.2 atZ:-0.21 ];
		[ret childObjectAtLast].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
	} else {
		
		ret = [ self checkLoadedModelsAt:PM_HOBBIT
									  to:PM_MASTER_MIND_FLAYER
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerH"
								textured:NO
								 withOut:PM_DWARF_KING,nil ];
	}
	
	return ret;
}


- ( id )loadModelFunc_imp:(int)glyph
{
	// imp and minor demons
	return [ self checkLoadedModelsAt:PM_MANES
								   to:PM_TENGU
							   offset:GLYPH_MON_OFF
							modelName:@"lowerI"
							 textured:NO
							  withOut:0 ];
}


- ( id )loadModelFunc_jellys:(int)glyph
{
	// jellys
	return [ self checkLoadedModelsAt:PM_BLUE_JELLY
								   to:PM_OCHRE_JELLY
							   offset:GLYPH_MON_OFF
							modelName:@"lowerJ"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_leprechaun:(int)glyph
{
	// leprechaun
		return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerL" withTexture:NO ];
	
}


- ( id )loadModelFunc_mimics:(int)glyph
{
	// mimics
	return [ self checkLoadedModelsAt:PM_SMALL_MIMIC
								   to:PM_GIANT_MIMIC
							   offset:GLYPH_MON_OFF
							modelName:@"lowerM"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_nymphs:(int)glyph
{
	// nymphs
	return [ self checkLoadedModelsAt:PM_WOOD_NYMPH
								   to:PM_MOUNTAIN_NYMPH
							   offset:GLYPH_MON_OFF
							modelName:@"lowerN"
							 textured:NO
							  withOut:0 ];	
}


- ( id )loadModelFunc_orc:(int)glyph
{
	// orc class
	id ret = nil;
	
	if ( glyph ==  PM_ORC_SHAMAN + GLYPH_MON_OFF ) {
		ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerO" withTexture:NO ];
		[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
		[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.15 atZ:-0.15 ];
		[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
	} else {
		
		ret = [ self checkLoadedModelsAt:PM_GOBLIN
									  to:PM_ORC_CAPTAIN
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerO"
								textured:NO
								 withOut:PM_ORC_SHAMAN,nil ];
	}
	
	return ret;
}


- ( id )loadModelFunc_piercers:(int)glyph
{
	// piercers
	return [ self checkLoadedModelsAt:PM_ROCK_PIERCER
								   to:PM_GLASS_PIERCER
							   offset:GLYPH_MON_OFF
							modelName:@"lowerP"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_quadrupeds:(int)glyph
{
	// quadrupeds
	return [ self checkLoadedModelsAt:PM_ROTHE
								   to:PM_MASTODON
							   offset:GLYPH_MON_OFF
							modelName:@"lowerQ"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_rodents:(int)glyph
{
	// rodents
	return [ self checkLoadedModelsAt:PM_SEWER_RAT
								   to:PM_WOODCHUCK
							   offset:GLYPH_MON_OFF
							modelName:@"lowerR"
							 textured:NO
							  withOut:0 ];
		
}


- ( id )loadModelFunc_spiders:(int)glyph
{
	// spiders
	return [ self checkLoadedModelsAt:PM_CAVE_SPIDER
								   to:PM_SCORPION
							   offset:GLYPH_MON_OFF
							modelName:@"lowerS"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_trapper:(int)glyph
{
	// trapper
	return [ self checkLoadedModelsAt:PM_LURKER_ABOVE
								   to:PM_TRAPPER
							   offset:GLYPH_MON_OFF
							modelName:@"lowerT"
							 textured:NO
							  withOut:0 ];
	
	
}


- ( id )loadModelFunc_unicorns:(int)glyph
{
	// unicorns and horses
	return [ self checkLoadedModelsAt:PM_WHITE_UNICORN
								   to:PM_WARHORSE
							   offset:GLYPH_MON_OFF
							modelName:@"lowerU"
							 textured:NO
							  withOut:0 ];
		
}


- ( id )loadModelFunc_vortices:(int)glyph
{
	// vortices
	return [ self checkLoadedModelsAt:PM_FOG_CLOUD
								   to:PM_FIRE_VORTEX
							   offset:GLYPH_MON_OFF
							modelName:@"lowerV"
							 textured:NO
							  withOut:0 ];
}


- ( id )loadModelFunc_worms:(int)glyph
{
	// worms
	return [ self checkLoadedModelsAt:PM_BABY_LONG_WORM
								   to:PM_PURPLE_WORM
							   offset:GLYPH_MON_OFF
							modelName:@"lowerW"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_xan:(int)glyph
{
	// xan
	return [ self checkLoadedModelsAt:PM_GRID_BUG
								   to:PM_XAN
							   offset:GLYPH_MON_OFF
							modelName:@"lowerX"
							 textured:NO
							  withOut:0 ];	
}


- ( id )loadModelFunc_lights:(int)glyph
{
	// lights
	
	return [ self checkLoadedModelsAt:PM_YELLOW_LIGHT
								   to:PM_BLACK_LIGHT
							   offset:GLYPH_MON_OFF
							modelName:@"lowerY"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_zruty:(int)glyph
{
	// zruty
		return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerZ" withTexture:NO ];

}


- ( id )loadModelFunc_Angels:(int)glyph
{
	// Angels
	return [ self checkLoadedModelsAt:PM_COUATL
								   to:PM_ARCHON
							   offset:GLYPH_MON_OFF
							modelName:@"upperA"
							 textured:NO
							  withOut:0 ];
}


- ( id )loadModelFunc_Bats:(int)glyph
{
	// Bats
	return [ self checkLoadedModelsAt:PM_BAT
								   to:PM_VAMPIRE_BAT
							   offset:GLYPH_MON_OFF
							modelName:@"upperB"
							 textured:NO
							  withOut:0 ];
}


- ( id )loadModelFunc_Centaurs:(int)glyph
{
	// Centaurs
	return [ self checkLoadedModelsAt:PM_PLAINS_CENTAUR
								   to:PM_MOUNTAIN_CENTAUR
							   offset:GLYPH_MON_OFF
							modelName:@"upperC"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Dragons:(int)glyph
{
	// Dragons
	return [ self checkLoadedModelsAt:PM_BABY_GRAY_DRAGON
								   to:PM_YELLOW_DRAGON
							   offset:GLYPH_MON_OFF
							modelName:@"upperD"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Elementals:(int)glyph
{
	// Elementals
	return [ self checkLoadedModelsAt:PM_STALKER
								   to:PM_WATER_ELEMENTAL
							   offset:GLYPH_MON_OFF
							modelName:@"upperE"
							 textured:NO
							  withOut:0 ];
}


- ( id )loadModelFunc_Fungi:(int)glyph
{
	// Fungi
	return [ self checkLoadedModelsAt:PM_LICHEN
								   to:PM_VIOLET_FUNGUS
							   offset:GLYPH_MON_OFF
							modelName:@"upperF"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Gnomes:(int)glyph
{
	// gnomes
	id ret = nil;
	switch ( glyph ) {
		case PM_GNOME+GLYPH_MON_OFF :
		case PM_GNOME_LORD+GLYPH_MON_OFF :
			ret = [ self checkLoadedModelsAt:PM_GNOME
										  to:PM_GNOME_LORD
									  offset:GLYPH_MON_OFF
								   modelName:@"upperG"
									textured:NO
									 withOut:0 ];
			
			break;
		case PM_GNOMISH_WIZARD + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperG" withTexture:NO ];
			[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.01 atZ:-0.15 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			break;
			
		case PM_GNOME_KING + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperG" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.05 atZ:-0.25 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			break;
	}
	
	return ret;
	
}


- ( id )loadModelFunc_giantHumanoids:(int)glyph
{
	// Giant Humanoids
	return [ self checkLoadedModelsAt:PM_GIANT
								   to:PM_MINOTAUR
							   offset:GLYPH_MON_OFF
							modelName:@"upperH"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Jabberwock:(int)glyph
{
	// Jabberwock
	return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperJ" withTexture:NO ];

}


- ( id )loadModelFunc_Kops:(int)glyph
{
	// Kops
	return [ self checkLoadedModelsAt:PM_KEYSTONE_KOP
								   to:PM_KOP_KAPTAIN
							   offset:GLYPH_MON_OFF
							modelName:@"upperK"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Liches:(int)glyph
{
	
	// Liches
	return [ self checkLoadedModelsAt:PM_LICH
								   to:PM_ARCH_LICH
							   offset:GLYPH_MON_OFF
							modelName:@"upperL"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Mummies:(int)glyph
{
	// Mummies
	return [ self checkLoadedModelsAt:PM_KOBOLD_MUMMY
								   to:PM_GIANT_MUMMY
							   offset:GLYPH_MON_OFF
							modelName:@"upperM"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Nagas:(int)glyph
{
	// Nagas
	return [ self checkLoadedModelsAt:PM_RED_NAGA_HATCHLING
								   to:PM_GUARDIAN_NAGA
							   offset:GLYPH_MON_OFF
							modelName:@"upperN"
							 textured:NO
							  withOut:0 ];
	
	
}


- ( id )loadModelFunc_Ogres:(int)glyph
{
	// Ogres
	id ret = nil;
	switch ( glyph ) {
		
		case PM_OGRE + GLYPH_MON_OFF :
		case PM_OGRE_LORD + GLYPH_MON_OFF :
			
			ret = [ self checkLoadedModelsAt:PM_OGRE
										  to:PM_OGRE_LORD
									  offset:GLYPH_MON_OFF
								   modelName:@"upperO"
									textured:NO
									 withOut:0 ];
			break;
			
		case PM_OGRE_KING + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperO" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.15 atZ:-0.18 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			break;
	}
	
	return ret;	
}


- ( id )loadModelFunc_Puddings:(int)glyph
{
	// Puddings
	return [ self checkLoadedModelsAt:PM_GRAY_OOZE
								   to:PM_GREEN_SLIME
							   offset:GLYPH_MON_OFF
							modelName:@"upperP"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Quantummechanics:(int)glyph
{
	// Quantum mechanics
	return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperQ" withTexture:NO ];
}


- ( id )loadModelFunc_Rustmonster:(int)glyph
{
	// Rust monster or disenchanter
	return [ self checkLoadedModelsAt:PM_RUST_MONSTER
								   to:PM_DISENCHANTER
							   offset:GLYPH_MON_OFF
							modelName:@"upperR"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Snakes:(int)glyph
{
	// Snakes
	return [ self checkLoadedModelsAt:PM_GARTER_SNAKE
								   to:PM_COBRA
							   offset:GLYPH_MON_OFF
							modelName:@"upperS"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Trolls:(int)glyph
{
	// Trolls
	return [ self checkLoadedModelsAt:PM_TROLL
								   to:PM_OLOG_HAI
							   offset:GLYPH_MON_OFF
							modelName:@"upperT"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Umberhulk:(int)glyph
{
	// Umber hulk	
	return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperU" withTexture:NO ];

}


- ( id )loadModelFunc_Vampires:(int)glyph
{
	// Vampires
	id ret = nil;
	switch ( glyph ) {
		case PM_VAMPIRE + GLYPH_MON_OFF :
		case PM_VAMPIRE_LORD + GLYPH_MON_OFF :
			
			ret = [ self checkLoadedModelsAt:PM_VAMPIRE
										  to:PM_VAMPIRE_LORD
									  offset:GLYPH_MON_OFF
								   modelName:@"upperV"
									textured:NO
									 withOut:0 ];
			
			break;
			
		case PM_VLAD_THE_IMPALER + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperV" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.15 atZ:-0.18 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			break;
	}
	
	return ret;
	
}


- ( id )loadModelFunc_Wraiths:(int)glyph
{
	// Wraiths
	return [ self checkLoadedModelsAt:PM_BARROW_WIGHT
								   to:PM_NAZGUL
							   offset:GLYPH_MON_OFF
							modelName:@"upperW"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Xorn:(int)glyph
{
	// Xorn
	return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperX" withTexture:NO ];
	
}


- ( id )loadModelFunc_Yeti:(int)glyph
{
	// Yeti and other large beasts
	return [ self checkLoadedModelsAt:PM_MONKEY
								   to:PM_SASQUATCH
							   offset:GLYPH_MON_OFF
							modelName:@"upperY"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Zombie:(int)glyph
{
	// Zombie
	return [ self checkLoadedModelsAt:PM_KOBOLD_ZOMBIE
								   to:PM_SKELETON
							   offset:GLYPH_MON_OFF
							modelName:@"upperZ"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_Golems:(int)glyph
{
	// Golems
	return [ self checkLoadedModelsAt:PM_STRAW_GOLEM
								   to:PM_IRON_GOLEM
							   offset:GLYPH_MON_OFF
							modelName:@"backslash"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_HumanorElves:(int)glyph
{
	// Human or Elves
	id ret = nil;
	switch ( glyph ) {
		
		case PM_ELVENKING + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.18 atZ:0.0 ];
			[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:11.7 rotateZ:0.0 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			break;
			
		case PM_NURSE + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"nurse" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:1.00 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			break;
			
		case PM_HIGH_PRIEST + GLYPH_MON_OFF :
		case PM_MEDUSA + GLYPH_MON_OFF :
		case PM_CROESUS + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;
			
		case PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			[ [ ret childObjectAtLast ] addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setPivotX:-0.827 atY:1.968 atZ:1.793 ];
			[ [ ret childObjectAtLast ] childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleGravityX:-3.5 Y:1.5 Z:0.8 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:1.5 Y:2.00 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleLife:0.5 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSize:6.0 ];
			
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setPivotX:0.827 atY:-1.800 atZ:-1.793 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
		default:
			ret = [ self checkLoadedModelsAt:PM_HUMAN
										  to:PM_WIZARD_OF_YENDOR
									  offset:GLYPH_MON_OFF
								   modelName:@"atmark"
									textured:NO
									 withOut:PM_ELVENKING ,PM_NURSE ,PM_HIGH_PRIEST ,PM_MEDUSA ,
											 PM_CROESUS ,PM_WIZARD_OF_YENDOR,nil ];
			
			break;
			
	}
	
	return ret;
	
	
}

	*/
	private final func loadModelFunc_Ghosts(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModelsAt(PM_GHOST, to: PM_SHADE, offset: GLYPH_INVIS_OFF, modelName: "invisible", textured: false)
	}
	/*

- ( id )loadModelFunc_MajorDamons:(int)glyph
{
	// Major Damons
	
	if ( glyph != PM_DJINNI+GLYPH_MON_OFF || glyph != PM_SANDESTIN+GLYPH_MON_OFF ) {
		return [ self checkLoadedModelsAt:PM_WATER_DEMON
									   to:PM_BALROG
								   offset:GLYPH_MON_OFF
								modelName:@"and"
								 textured:NO
								  withOut:0 ];
	} else {
		return [ self checkLoadedModelsAt:PM_DJINNI
									   to:PM_SANDESTIN
								   offset:GLYPH_MON_OFF
								modelName:@"and"
								 textured:NO
								  withOut:0 ];
	}		
}


- ( id )loadModelFunc_GraterDamons:(int)glyph
{
	// Grater Damons 
	id ret = nil;

	if ( glyph == PM_JUIBLEX + GLYPH_MON_OFF ) {
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
	} else {
							
			ret = [ self checkLoadedModelsAt:PM_YEENOGHU
										  to:PM_DEMOGORGON
									  offset:GLYPH_MON_OFF
								   modelName:@"and"
									textured:NO
									 withOut:0 ];
			if ( ![ ret hasChildObject ] ) {
				[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
				[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
				[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
				[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
				[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
				[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
				[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
				[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
				[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
				[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.52 atZ:0.0 ];
				[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:0.7 rotateZ:0.0 ];
				[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			}
	}
	return ret;		
}


- ( id )loadModelFunc_Riders:(int)glyph
{
	// damon "The Riders"
	id ret = nil;
		
		ret = [ self checkLoadedModelsAt:PM_DEATH
									  to:PM_FAMINE
								  offset:GLYPH_MON_OFF
							   modelName:@"and"
								textured:NO
								 withOut:0 ];
		
		if ( ![ ret hasChildObject ] ) {
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:15.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
		}
		
		return ret;
}


- ( id )loadModelFunc_seamonsters:(int)glyph
{
	// sea monsters
	return [ self checkLoadedModelsAt:PM_JELLYFISH
								   to:PM_KRAKEN
							   offset:GLYPH_MON_OFF
							modelName:@"semicoron"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_lizards:(int)glyph
{
	// lizards
	return [ self checkLoadedModelsAt:PM_NEWT
								   to:PM_SALAMANDER
							   offset:GLYPH_MON_OFF
							modelName:@"coron"
							 textured:NO
							  withOut:0 ];
	
}


- ( id )loadModelFunc_wormtail:(int)glyph
{
	// wormtail
	return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"wormtail" withTexture:NO ];
}


- ( id )loadModelFunc_Adventures:(int)glyph
{
	// Adventures
	id ret = nil;
	
	if ( glyph == PM_WIZARD + GLYPH_MON_OFF ) {
		ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
		[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
		[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
	} else {		
		ret = [ self checkLoadedModelsAt:PM_ARCHEOLOGIST
									  to:PM_VALKYRIE
								  offset:GLYPH_MON_OFF
							   modelName:@"atmark"
								textured:NO
								 withOut:0 ];
	}
	
	return ret;	
	
}


- ( id )loadModelFunc_Uniqueperson:(int)glyph
{
	// Unique person
	id ret = nil;
	
	switch ( glyph ) {
		
		case PM_KING_ARTHUR + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.18 atZ:0.0 ];
			[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:11.7 rotateZ:0.0 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
			
		case PM_NEFERET_THE_GREEN + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;
			
		case PM_MINION_OF_HUHETOTL + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;
			
			
		case PM_THOTH_AMON + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;
			
			
		case PM_CHROMATIC_DRAGON + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperD" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
		case PM_CYCLOPS + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperH" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
		case PM_IXOTH + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperD" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
		case PM_MASTER_KAEN + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;		
			
		case PM_NALZOK + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;		
			
		case PM_SCORPIUS + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerS" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;	
			
		case PM_MASTER_ASSASSIN + GLYPH_MON_OFF :
		case PM_ASHIKAGA_TAKAUJI + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break ;		
			
		case PM_LORD_SURTUR + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperH" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.18 atZ:0.0 ];
			[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:11.7 rotateZ:0.0 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
		case PM_DARK_ONE + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:-0.15 ];
			[ ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[ NO_COLOR ] ;
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
		default:
			
			if ( glyph >=PM_LORD_CARNARVON + GLYPH_MON_OFF && glyph <= PM_NORN + GLYPH_MON_OFF ) { 
				 ret = [ self checkLoadedModelsAt:PM_LORD_CARNARVON
											   to:PM_NORN
										   offset:GLYPH_MON_OFF
										modelName:@"atmark"
										 textured:NO
										  withOut:PM_KING_ARTHUR, nil];
				 
				 if ( ![ ret hasChildObject ] ) {
					 [ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
					 [ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
					 [ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
					 [ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
					 [ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
					 [ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
					 [ [ ret childObjectAtLast ] setParticleLife:0.24 ];
					 [ [ ret childObjectAtLast ] setParticleSize:8.0 ];
				 }
			} else {
				 
			ret = [ self checkLoadedModelsAt:PM_STUDENT
										  to:PM_APPRENTICE
									  offset:GLYPH_MON_OFF
								   modelName:@"atmark"
									textured:NO
									 withOut:0 ];
			}
			
			break;
	}
	
	return ret;
	
}

// -------------------------- Map Symbol Section ----------------------------- //

- ( id )loadModelFunc_MapSymbols:(int)glyph
{
	//  Map Symbols
	id ret = nil;
	
	switch ( glyph ) {
		case S_bars + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"ironbar" withTexture:YES ];
			break;
			
		case S_tree + GLYPH_CMAP_OFF:	
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"tree" withTexture:YES ];
			[ ret setModelScaleX:2.5 scaleY:1.7 scaleZ:2.5 ];
			break;
		
		case S_upstair + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upStair" withTexture:YES ];
			break;
			
		case S_dnstair + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"downStair" withTexture:YES ];
			break;
		
		case S_upladder + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upladder" withTexture:YES ];
			break;
			
		case S_dnladder + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"downladder" withTexture:YES ];
			break;
			
		case S_altar + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"alter" withTexture:YES ];
			break;
			
		case S_grave + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"grave" withTexture:YES ];
			[ ret setModelScaleX:0.6 scaleY:0.6 scaleZ:0.6 ];
			break;
			
		case S_throne + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"opulent_throne" withTexture:YES ];
			break;		
			
		case S_sink + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"sink" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:1.277 atZ:-0.812 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypePoints ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:-8.8 Z:1.0 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.21 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.687 atZ:0.512 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypePoints ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_CYAN ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:-5.8 Z:1.0 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.3 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;		
			
		case S_fountain + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"fountain" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.34 atY:2.68 atZ:0.65 ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.1 Z:0.08 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_BLUE ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-130.0 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.8 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.34 atY:-1.70 atZ:-0.65 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.98 scaleY:0.7 scaleZ:0.98 ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.1 Z:0.00 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BLUE ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-130.0 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.28 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.5 scaleY:0.7 scaleZ:0.5 ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:1.35 atZ:-0.0 ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.4 Z:0.00 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BLUE ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-190.0 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:1.2 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			break;
			
		case S_vodbridge + GLYPH_CMAP_OFF: 
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridgeUP" withTexture:YES ];
			[ ret setModelRotateX:0 rotateY:-90 rotateZ:0 ];
			[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
			break;
			
		case S_hodbridge + GLYPH_CMAP_OFF: 
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridge" withTexture:YES ];
			[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:4.0 atY:0.0 atZ:0.0 ];
			break;
			
		case S_vcdbridge + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridgeUP" withTexture:YES ];
			[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
			break;
			
		case S_hcdbridge + GLYPH_CMAP_OFF: 
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"bridge" withTexture:YES ];
			[ ret setModelRotateX:0 rotateY:-90 rotateZ:0 ];
			[ ret addChildObject:@"bridge_opt" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:4.0 atY:0.0 atZ:0.0 ];
			break;
			
	}
	
	return ret;
	
}


- ( id )loadModelFunc_Boulder:(int)glyph
{
	// Boulder
	
	return [ [ NH3DModelObjects alloc ] initWith3DSFile:@"boulder" withTexture:YES ];

}


- ( id )loadModelFunc_TrapSymbol:(int)glyph
{
	// Trap Symbol 
	id ret =  nil;
	
	switch ( glyph ) {
		
		case S_arrow_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"arrowtrap" withTexture:YES ];
			break;
		case S_dart_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"dartstrap" withTexture:YES ];
			break;
		case S_falling_rock_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"rockfalltrap" withTexture:YES ];
			break;
			//case S_squeaky_board + GLYPH_CMAP_OFF :
		case S_land_mine + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"landmine" withTexture:YES ];
			break;
			//case S_rolling_boulder_trap + GLYPH_CMAP_OFF :
		case S_sleeping_gas_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"gastrap" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.5 atZ:0.0 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.0 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_MAGENTA ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:300 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:5.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.56 ];
			[ [ ret childObjectAtLast ] setParticleSize:5.0 ];
			break;
			
		case S_rust_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"gastrap" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.5 atZ:0.0 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.0 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_GREEN ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:300.0 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:5.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.56 ];
			[ [ ret childObjectAtLast ] setParticleSize:5.0 ];
			break;
			
		case S_fire_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"gastrap" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.5 atZ:0.0 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeBoth ;
			[ [ ret childObjectAtLast ] setParticleSize:4.0 ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-1.0 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_ORANGE ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:200 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:2.0 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.5 ];
			break;
		
		case S_bear_trap + GLYPH_CMAP_OFF :	
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"beartrap" withTexture:YES ];
			break;
		case S_pit + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"pit" withTexture:YES ];
			break;
		case S_spiked_pit + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"spikepit" withTexture:YES ];
			break;
		case S_hole + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"pit" withTexture:YES ];
			break;
		case S_trap_door + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"pit" withTexture:YES ];
			break;
		case S_teleportation_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"telporter" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:3.82 atZ:0.75917 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.8 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.23 ];
			[ [ ret childObjectAtLast ] setIsChild:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:0.42 atZ:0.75917 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:4.8 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.25 ];
			break;
			
		case S_level_teleporter + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"leveltelporter" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:3.82 atZ:0.75917 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.8 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.23 ];
			[ [ ret childObjectAtLast ] setIsChild:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:0.42 atZ:0.75917 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:4.8 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_MAGENTA ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.25 ];
			break;
			
		case S_magic_portal + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"magicportal" withTexture:YES ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.8 scaleY:0.7 scaleZ:0.8 ];
			[ ret childObjectAtLast ].particleType = NH3DParticleTypeAura ;
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_BLUE ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.4 ];
			[ [ ret childObjectAtLast ] setParticleSize:2.0 ];
			break;
			
			//case S_web + GLYPH_CMAP_OFF :
			//case S_statue_trap + GLYPH_CMAP_OFF :
			
		case S_magic_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelScaleX:0.7 scaleY:0.4 scaleZ:0.7 ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_BRIGHT_MAGENTA ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:8.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:10.0 ];
			break;
			
		case S_anti_magic_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelScaleX:0.7 scaleY:0.4 scaleZ:0.7 ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_CYAN ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:8.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:10.0 ];
			break;
			
		case S_polymorph_trap + GLYPH_CMAP_OFF :
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelScaleX:0.7 scaleY:0.4 scaleZ:0.7 ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_BROWN ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:8.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:10.0 ];
			break;
			
	}
	
	return ret;
	
}

// ------------------------- Effect Symbols Section. ------------------------- //

// ZAP symbols ( NUM_ZAP * four directions )


- ( id )loadModelFunc_MagicMissile:(int)glyph
{
	// type Magic Missile
	id ret = nil;
	
	switch ( glyph ) {
		
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
			//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
			//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
			//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_WHITE ];
			//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
	}
	
	return ret;

}


- ( id )loadModelFunc_MagicFIRE:(int)glyph
{
	// type Magic FIRE
	id ret = nil;
	
	switch ( glyph ) {
		
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
			break;
			
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
			break;
			
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT:	
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
			break;
			
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_ORANGE ];
			break;
	}
	
	return ret;
	
}


- ( id )loadModelFunc_MagicCOLD:(int)glyph
{
	// type Magic COLD
	id ret = nil;
	
	switch ( glyph ) {
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
			// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
			break;
			
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT:	
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
			break;
			
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_CYAN ];
			break;
			
		}
	
	return ret;
}


- ( id )loadModelFunc_MagicSLEEP:(int)glyph
{
	// type Magic SLEEP
	id ret = [ [ NH3DModelObjects alloc ] init ];
	[ ret setPivotX:0.0 atY:1.2 atZ:0.0 ];
	[ ret setModelScaleX:1.0 scaleY:1.0 scaleZ:1.0 ];
	[ ret setParticleType:NH3DParticleTypeAura ];
	[ ret setParticleColor:CLR_MAGENTA ];
	//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
	[ ret setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
	[ ret setParticleSpeedX:1.0 Y:1.00 ];
	[ ret setParticleSlowdown:3.8 ];
	[ ret setParticleLife:0.4 ];
	[ ret setParticleSize:20.0 ];
	
	return ret;
}


- ( id )loadModelFunc_MagicDEATH:(int)glyph
{
	// type Magic DEATH
	id ret = nil;
	
	switch ( glyph ) {
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
			// :CLR_BLACK ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
			break;
			
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT:	
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
			break;
			
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_GRAY ];
			break;
	}
	
	return ret;
	
}


- ( id )loadModelFunc_MagicLIGHTNING:(int)glyph
{
	// type Magic LIGHTNING
	id ret = nil;
	
	switch ( glyph ) {
		
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
			// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
			break;
			
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
			[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
			break;
			
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT:	
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
			[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
			break;
			
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_YELLOW ];
			[ ret setModelScaleX:0.2 scaleY:1.0 scaleZ:0.2 ];
			break;
	}	
	
	return ret;
}


- ( id )loadModelFunc_MagicPOISONGAS:(int)glyph
{
	// type Magic POISONGAS
	id ret = [ [ NH3DModelObjects alloc ] init ];
	[ ret setPivotX:0.0 atY:1.2 atZ:0.0 ];
	[ ret setModelScaleX:1.0 scaleY:1.0 scaleZ:1.0 ];
	[ ret setParticleType:NH3DParticleTypeAura ];
	[ ret setParticleColor:CLR_GREEN ];
	//[ ret setParticleColor:CLR_YELLOW ]; // if you want sync to 'zapcolors' from decl.c
	[ ret setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
	[ ret setParticleSpeedX:1.0 Y:1.00 ];
	[ ret setParticleSlowdown:3.8 ];
	[ ret setParticleLife:0.4 ];
	[ ret setParticleSize:20.0 ];
	
	return ret;
}


- ( id )loadModelFunc_MagicACID:(int)glyph
{
	// type Magic ACID
	id ret = nil;
	
	switch ( glyph ) {
		
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:0.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
			// :CLR_GREEN ]; // if you want sync to 'zapcolors' from decl.c
			break;
			
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:0.0 rotateY:0.0 rotateZ:-90.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
			break;
			
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT:	
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:-45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
			break;
			
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelRotateX:-90.0 rotateY:45.0 rotateZ:0.0 ];
			[ self setParamsForMagicEffect:ret color:CLR_BRIGHT_GREEN ];
			break;
	}	
	
	return ret;
}


- ( id )loadModelFunc_MagicETC:(int)glyph
{
	id ret = nil;
	
	switch ( glyph ) {
		// dig beam
		case S_digbeam + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelScaleX:0.7 scaleY:1.0 scaleZ:0.7 ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_BROWN ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:3.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:20.0 ];
			break;
			
			// camera flash
		case S_flashbeam + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setModelScaleX:1.4 scaleY:1.5 scaleZ:1.4 ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_WHITE ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:3.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:20.0 ];
			break;
			
			// boomerang
			//case S_boomleft + GLYPH_CMAP_OFF :
			//case S_boomright + GLYPH_CMAP_OFF :
	}
	
	return ret;
}


- ( id )loadModelFunc_MagicSHILD:(int)glyph
{
	// magic shild
	id ret = nil;
	
	switch ( glyph ) {
		case S_ss1 + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_BRIGHT_BLUE ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:3.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:20.0 ];
			break;
			
		case S_ss2 + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_BRIGHT_CYAN ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:8.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:10.0 ];
			break;
			
		case S_ss3 + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_WHITE ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:3.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:20.0 ];
			break;
			
		case S_ss4 + GLYPH_CMAP_OFF:
			ret = [ [ NH3DModelObjects alloc ] init ];
			[ ret setParticleType:NH3DParticleTypeAura ];
			[ ret setParticleColor:CLR_BLUE ];
			[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
			[ ret setParticleSpeedX:1.0 Y:1.00 ];
			[ ret setParticleSlowdown:8.8 ];
			[ ret setParticleLife:0.4 ];
			[ ret setParticleSize:10.0 ];
			break;
	}
	
	return ret;
}

// explotion symbols ( 9 postion * 7 types )
- ( id )loadModelFunc_explotionDARK:(int)glyph
{
	id	ret;
	
	//  type DARK
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_DARK
								  to:NH3D_EXPLODE_DARK + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];
	
	[ self setParamsForMagicExplotion:ret color:CLR_GRAY ];
	
	return ret;
}


- ( id )loadModelFunc_explotionNOXIOUS:(int)glyph
{
	id	ret;	
	//  type NOXIOUS
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_NOXIOUS
								  to:NH3D_EXPLODE_NOXIOUS + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];
	
	[ self setParamsForMagicExplotion:ret color:CLR_GREEN ];
	
	return ret;
}


- ( id )loadModelFunc_explotionMUDDY:(int)glyph
{
	id	ret;	
	//  type MUDDY
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_MUDDY
								  to:NH3D_EXPLODE_MUDDY + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];
	
	[ self setParamsForMagicExplotion:ret color:CLR_BROWN ];
	
	return ret;
	
}


- ( id )loadModelFunc_explotionWET:(int)glyph
{
	id	ret;	
	//  type WET
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_WET
								  to:NH3D_EXPLODE_WET + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];
	
	[ self setParamsForMagicExplotion:ret color:CLR_BLUE ];
	
	return ret;
}


- ( id )loadModelFunc_explotionMAGICAL:(int)glyph
{
	id	ret;	
	//  type MAGICAL
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_MAGICAL
								  to:NH3D_EXPLODE_MAGICAL + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];

	[ self setParamsForMagicExplotion:ret color:CLR_BRIGHT_MAGENTA ];
	
	return ret;
	
}


- ( id )loadModelFunc_explotionFIERY:(int)glyph
{
	id	ret;	
	//  type FIERY
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_FIERY
								  to:NH3D_EXPLODE_FIERY + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];

	[ self setParamsForMagicExplotion:ret color:CLR_ORANGE ];
	
	return ret;
	
}


- ( id )loadModelFunc_explotionFROSTY:(int)glyph
{
	id	ret;	
	//  type FROSTY
	ret = [ self checkLoadedModelsAt:NH3D_EXPLODE_FROSTY
								  to:NH3D_EXPLODE_FROSTY + MAXEXPCHARS
							  offset:0
						   modelName:@"emitter"
							textured:NO
							 withOut:0 ];

	[ self setParamsForMagicExplotion:ret color:CLR_BRIGHT_CYAN ];
	
	return ret;
	
}


- ( id )loadModelFunc_default:(int)glyph
{
	return nil;
}


/*
- ( id )loadModelToArray:(int)glyph
{
	return ret;

}
*/

- ( void )setNowUpdating:( BOOL )flag
{
	[ viewLock lock ];
	nowUpdating = flag;
	[ viewLock unlock ];
}


- ( void )setRunnning:( BOOL )flag
{
	[ viewLock lock ];
	runnning = flag;
	[ viewLock unlock ];
}


- ( IBAction )drawAllFrameFunction:( id )sender // wait for vSync...
{
	[ viewLock lock ];
	nowUpdating = YES;
	
		[ [NSUserDefaults standardUserDefaults] setBool:! ((NSCell*)sender).state forKey:NH3DOpenGLWaitSyncKey ];
		[ [NSUserDefaultsController sharedUserDefaultsController].values setValue:[ NSNumber numberWithBool:! ((NSCell*)sender).state ]
																			 forKey:NH3DOpenGLWaitSyncKey ];
		
	nowUpdating = NO;
	[ viewLock unlock ];
		if ( OPENGLVIEW_WAITSYNC )
			[ self.openGLContext setValues:&vsincWait forParameter:NSOpenGLCPSwapInterval ];
		else 
			[ self.openGLContext setValues:&vsincNoWait forParameter:NSOpenGLCPSwapInterval ];

}	

/*
- ( IBAction )useAntiAlias:( id )sender
{
	[ viewLock lock ];
	nowUpdating = YES;
	if ( [ sender state ] == NSOffState ) {
		[ self turnOnSmooth ];
		[ sender setState:NSOnState ];
	} else {
		[ self turnOffSmooth ];
		[ sender setState:NSOffState ];
	}
	nowUpdating = NO;
	[ viewLock unlock ];
}
*/

- ( IBAction )setWaitRate:( id )sender
{
	CGDisplayModeRef curCfg = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
	dRefreshRate = CGDisplayModeGetRefreshRate(curCfg);
	
	[ viewLock lock ];
		nowUpdating = YES;
		oglParamNowChanging = YES;
	switch ( [ sender tag ] ) {
		case 1003 : // no wait			
			waitRate = dRefreshRate;
			((NSCell*) sender).state = NSOnState ;
			[ [NSUserDefaults standardUserDefaults] setBool:NO forKey:NH3DOpenGLUseWaitRateKey ];
			[ [NSUserDefaultsController sharedUserDefaultsController].values setValue:@NO
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[[ sender menu ] itemWithTag:1004 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1005 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1006 ].state = NSOffState ;
			break;
		case 1004 :
			waitRate = WAIT_FAST;
			((NSCell*)sender).state = NSOnState ;
			[ [NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DOpenGLUseWaitRateKey ];
			[ [NSUserDefaultsController sharedUserDefaultsController].values setValue:@YES
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[[ sender menu ] itemWithTag:1003 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1005 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1006 ].state = NSOffState ;			
			break;
		case 1005 :
			waitRate = WAIT_NORMAL;
			((NSCell*)sender).state = NSOnState ;
			[ [NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DOpenGLUseWaitRateKey ];
			[ [NSUserDefaultsController sharedUserDefaultsController].values setValue:@YES
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[[ sender menu ] itemWithTag:1003 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1004 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1006 ].state = NSOffState ;			
			break;
		case 1006 :
			waitRate = WAIT_SLOW;
			((NSCell*)sender).state = NSOnState ;
			[ [NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DOpenGLUseWaitRateKey ];
			[ [NSUserDefaultsController sharedUserDefaultsController].values setValue:@YES
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[[ sender menu ] itemWithTag:1003 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1004 ].state = NSOffState ;
			[[ sender menu ] itemWithTag:1005 ].state = NSOffState ;			
			break;
	}
	
	cameraStep = waitRate / 8.5;
	
	nowUpdating = NO;
	oglParamNowChanging = NO;
	[ viewLock unlock ];
	
	[ [NSUserDefaults standardUserDefaults] setFloat:waitRate forKey:NH3DOpenGLWaitRateKey ];
	[ [NSUserDefaultsController sharedUserDefaultsController].values setValue:@(waitRate)
																		 forKey:NH3DOpenGLWaitRateKey ];
	
	CGDisplayModeRelease(curCfg);
}


- (void)defaultDidChange:(NSNotification *)notification
{
	
	if ( oglParamNowChanging ) return;
	
	if ( TRADITIONAL_MAP && !firstTime ) {
		[ _mapModel setPlayerDirection:PL_DIRECTION_FORWARD ];
		//[ self clearGLContext ];
		[ self.openGLContext clearDrawable ];
		[ self setHidden:YES ];
		//[ [self openGLContext] setView:nil ];
		threadRunning = NO;
		//[ self update ];
	}
	if ( !TRADITIONAL_MAP && !firstTime ) {
		[ self setHidden:NO ];
		self.openGLContext.view = self ;
		if ( !threadRunning )
			[ self detachOpenGLThread ];
	}
	
	[ viewLock lock ];
	
	NSMenu *oglFrameRateMenu = [[ self.menu itemWithTag:1000].submenu itemWithTag:1002].submenu ;
	
	nowUpdating = YES;
	hasWait = OPENGLVIEW_USEWAIT;
	
	if ( !hasWait ) {
		CGDisplayModeRef curCfg = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
		dRefreshRate = CGDisplayModeGetRefreshRate(curCfg);
		waitRate = dRefreshRate;
		[oglFrameRateMenu itemWithTag:1004 ].state = NSOffState ;
		[oglFrameRateMenu itemWithTag:1005 ].state = NSOffState ;
		[oglFrameRateMenu itemWithTag:1006 ].state = NSOffState ;
		CGDisplayModeRelease(curCfg);
	} else if ( OPENGLVIEW_WAITRATE == WAIT_FAST ) {
		waitRate = WAIT_FAST;
		[oglFrameRateMenu itemWithTag:1004 ].state = NSOnState ;
		[oglFrameRateMenu itemWithTag:1005 ].state = NSOffState ;
		[oglFrameRateMenu itemWithTag:1006 ].state = NSOffState ;
	} else if ( OPENGLVIEW_WAITRATE == WAIT_NORMAL ) {
		waitRate = WAIT_NORMAL;
		[oglFrameRateMenu itemWithTag:1004 ].state = NSOffState ;
		[oglFrameRateMenu itemWithTag:1005 ].state = NSOnState ;
		[oglFrameRateMenu itemWithTag:1006 ].state = NSOffState ;
		
	} else {
		waitRate = WAIT_SLOW;
		[oglFrameRateMenu itemWithTag:1004 ].state = NSOffState ;
		[oglFrameRateMenu itemWithTag:1005 ].state = NSOffState ;
		[oglFrameRateMenu itemWithTag:1006 ].state = NSOnState ;
	}
	
	cameraStep = waitRate / 8.5;
	
	if ( OPENGLVIEW_WAITSYNC )
		[ self.openGLContext setValues:&vsincWait forParameter:NSOpenGLCPSwapInterval ];
	else 
		[ self.openGLContext setValues:&vsincNoWait forParameter:NSOpenGLCPSwapInterval ];
	
	if ( useTile != NH3DGL_USETILE ) {
		int i;
		for ( i = 0 ; i < MAX_GLYPH ; i++ ) {
			GLuint texid = defaultTex[ i ];
			glDeleteTextures( 1 , &texid );
			defaultTex[ i ] = nil;
		}
		useTile = NH3DGL_USETILE;
	}
	
	nowUpdating = NO;
	[ viewLock unlock ];

}


//----------------------------//
// cash func address
//----------------------------//

- ( void )cashMethod
{
	int i;
	for( i = 0;i < 11;i++ ) {
		switchMethodArray[ i ] = [^(int x ,int z ,int lx ,int lz) {
			return;
		} copy];
		drawFloorArray[ i ] = [^(void) {
			
		} copy];
	}
	
	switchMethodArray[ 0 ] = ^(int x, int z, int lx, int lz) {
		drawNullObject( ( float )x*NH3DGL_TILE_SIZE,( float )z*NH3DGL_TILE_SIZE, self-> nullTex );

	};
	switchMethodArray[ 1 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							2,self );
	};
	switchMethodArray[ 2 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							1,self );
		[self drawModelArray:self->mapItemValue[lx][lz]];
	};
	switchMethodArray[ 3 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							2, self);
		[self drawModelArray:self->mapItemValue[lx][lz]];
	};
	switchMethodArray[ 4 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							3, self);
	};
	switchMethodArray[ 5 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							4, self);
	};
	switchMethodArray[ 6 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							5, self);
	};
	switchMethodArray[ 7 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							6, self);
	};
	switchMethodArray[ 8 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							7, self);
	};
	switchMethodArray[ 9 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							8, self);
	};
	switchMethodArray[ 10 ] = ^(int x, int z, int lx, int lz) {
		drawFloorAndCeiling(x*NH3DGL_TILE_SIZE,
							z*NH3DGL_TILE_SIZE,
							2, self);
		[self drawModelArray: self->mapItemValue[lx][lz]];
	};
	
	drawFloorArray[ 0 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->floorCurrent );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	drawFloorArray[ 1 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->cellingCurrent );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	drawFloorArray[ 2 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->floorCurrent);
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glBindTexture( GL_TEXTURE_2D, self->cellingCurrent);
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	//Draw pool
	drawFloorArray[ 3 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glAlphaFunc( GL_GREATER, 0.5 );
		glBindTexture( GL_TEXTURE_2D, self->poolTex);
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glActiveTexture( GL_TEXTURE1 );
		
		glBindTexture( GL_TEXTURE_2D, self->envelopTex );
		
		glEnable( GL_TEXTURE_2D );
		glEnable( GL_TEXTURE_GEN_S );
		glEnable( GL_TEXTURE_GEN_T );
		
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );
		glTexEnvf( GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_INTERPOLATE );
		glTexEnvf( GL_TEXTURE_ENV, GL_SOURCE2_RGB, GL_PREVIOUS );
		glTexEnvf( GL_TEXTURE_ENV, GL_OPERAND2_RGB, GL_ONE_MINUS_SRC_ALPHA );
		
		
		glTexGenf( GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
		glTexGenf( GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_GEN_S );
		glDisable( GL_TEXTURE_GEN_T );
		glDisable( GL_TEXTURE_2D );
		
		glTexEnvf( GL_TEXTURE_ENV, GL_SOURCE2_RGB, GL_CONSTANT );
		glTexEnvf( GL_TEXTURE_ENV, GL_OPERAND2_RGB, GL_SRC_ALPHA );
		
		glActiveTexture( GL_TEXTURE0 );
		
		glBindTexture( GL_TEXTURE_2D, self->cellingCurrent );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	//Draw ice
	drawFloorArray[ 4 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->floorCurrent );
		
		glMaterialf( GL_FRONT , GL_EMISSION , 10.0 );
		
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glActiveTexture( GL_TEXTURE1 );
		
		glBindTexture( GL_TEXTURE_2D, self->envelopTex );
		
		glEnable( GL_TEXTURE_2D );
		glEnable( GL_TEXTURE_GEN_S );
		glEnable( GL_TEXTURE_GEN_T );
		
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ADD );
		
		glTexGenf( GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
		glTexGenf( GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
		
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_GEN_S );
		glDisable( GL_TEXTURE_GEN_T );
		glDisable( GL_TEXTURE_2D );
		
		glActiveTexture( GL_TEXTURE0 );
		
		glBindTexture( GL_TEXTURE_2D, self->cellingCurrent );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	//Draw lava
	drawFloorArray[ 5 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->lavaTex );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		GLfloat emisson[ 4 ] = { 1.0, 1.0, 1.0, 1.0 };
		glMaterialfv( GL_FRONT , GL_EMISSION , emisson );
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glBindTexture( GL_TEXTURE_2D, self->cellingCurrent );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT , 0 , CeilingVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	//draw air
	drawFloorArray[ 6 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->airTex );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT , 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	//draw cloud
	drawFloorArray[ 7 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self-> cloudTex );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	//draw water
	drawFloorArray[ 8 ] = ^() {
		glActiveTexture( GL_TEXTURE0 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->waterTex );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glActiveTexture( GL_TEXTURE1 );
		glEnable( GL_TEXTURE_2D );
		
		glBindTexture( GL_TEXTURE_2D, self->envelopTex );
		
		glEnable( GL_TEXTURE_GEN_S );
		glEnable( GL_TEXTURE_GEN_T );
		
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );
		glTexEnvf( GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_INTERPOLATE );
		
		GLfloat blend[ 4 ] = { 1.0, 1.0, 1.0, 0.18 };
		glTexEnvfv( GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, blend );
		
		glTexGenf( GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
		glTexGenf( GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
		
		
		glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_GEN_S );
		glDisable( GL_TEXTURE_GEN_T );
		glDisable( GL_TEXTURE_2D );
		
		glActiveTexture( GL_TEXTURE0 );
		
		glBindTexture( GL_TEXTURE_2D, self->cellingCurrent );
		glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
		
		glNormalPointer( GL_FLOAT , 0 , CeilingVertNorms );
		glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
		glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
		glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
		
		glDisable( GL_TEXTURE_2D );
	};
	
	{
		LoadModelBlock defaultBlock = ^(int glyph) {
			return (id)nil;
		};
		for ( i = 0; i < MAX_GLYPH ; i++ ) {
			loadModelBlocks[i] = [defaultBlock copy];
		}
	}
	
	// insect class
	LoadModelBlock insectBlock = ^(int glyph) {
		return [self loadModelFunc_insect:glyph];
	};
	loadModelBlocks[PM_GIANT_ANT+GLYPH_MON_OFF ] =		[insectBlock copy];
	loadModelBlocks[PM_KILLER_BEE+GLYPH_MON_OFF ] =		[insectBlock copy];
	loadModelBlocks[PM_SOLDIER_ANT+GLYPH_MON_OFF ] =	[insectBlock copy];
	loadModelBlocks[PM_FIRE_ANT+GLYPH_MON_OFF ] =		[insectBlock copy];
	loadModelBlocks[PM_GIANT_BEETLE+GLYPH_MON_OFF ] =	[insectBlock copy];
	loadModelBlocks[PM_QUEEN_BEE+GLYPH_MON_OFF ] =		[insectBlock copy];
	
	// blob class
	LoadModelBlock blobBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_ACID_BLOB
									  to:PM_GELATINOUS_CUBE
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerB" textured:NO withOut:0];
	};
	loadModelBlocks[ PM_ACID_BLOB+GLYPH_MON_OFF ] =			[blobBlock copy];
	loadModelBlocks[ PM_QUIVERING_BLOB+GLYPH_MON_OFF ] =	[blobBlock copy];
	loadModelBlocks[ PM_GELATINOUS_CUBE+GLYPH_MON_OFF ] =	[blobBlock copy];
	
	// cockatrice class
	LoadModelBlock cockatriceBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_CHICKATRICE
									  to:PM_PYROLISK
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerC" textured:NO withOut:0];
	};
	loadModelBlocks[ PM_CHICKATRICE+GLYPH_MON_OFF ] =	[cockatriceBlock copy];
	loadModelBlocks[ PM_COCKATRICE+GLYPH_MON_OFF ] =	[cockatriceBlock copy];
	loadModelBlocks[ PM_PYROLISK+GLYPH_MON_OFF ] =		[cockatriceBlock copy];
	
	// dog or canine class
	LoadModelBlock dogBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_JACKAL
									  to:PM_HELL_HOUND
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerD" textured:NO withOut:0];
	};
	loadModelBlocks[ PM_JACKAL+GLYPH_MON_OFF ] =		[dogBlock copy];
	loadModelBlocks[ PM_FOX+GLYPH_MON_OFF ] =			[dogBlock copy];
	loadModelBlocks[ PM_COYOTE+GLYPH_MON_OFF ] =		[dogBlock copy];
	loadModelBlocks[ PM_WEREJACKAL+GLYPH_MON_OFF ] =	[dogBlock copy];
	loadModelBlocks[ PM_LITTLE_DOG+GLYPH_MON_OFF ] =	[dogBlock copy];
	loadModelBlocks[ PM_DOG+GLYPH_MON_OFF ] =			[dogBlock copy];
	loadModelBlocks[ PM_LARGE_DOG+GLYPH_MON_OFF ] =		[dogBlock copy];
	loadModelBlocks[ PM_DINGO+GLYPH_MON_OFF ] =			[dogBlock copy];
	loadModelBlocks[ PM_WOLF+GLYPH_MON_OFF ] =			[dogBlock copy];
	loadModelBlocks[ PM_WEREWOLF+GLYPH_MON_OFF ] =		[dogBlock copy];
	loadModelBlocks[ PM_WARG+GLYPH_MON_OFF ] =			[dogBlock copy];
	loadModelBlocks[PM_WINTER_WOLF_CUB+GLYPH_MON_OFF] = [dogBlock copy];
	loadModelBlocks[ PM_WINTER_WOLF+GLYPH_MON_OFF ] =	[dogBlock copy];
	loadModelBlocks[PM_HELL_HOUND_PUP+GLYPH_MON_OFF] =	[dogBlock copy];
	loadModelBlocks[ PM_HELL_HOUND+GLYPH_MON_OFF ] =	[dogBlock copy];
	
	// eye or sphere class
	LoadModelBlock sphereBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_GAS_SPORE
									  to:PM_SHOCKING_SPHERE
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerE" textured:NO withOut:0];
	};
	loadModelBlocks[PM_GAS_SPORE+GLYPH_MON_OFF] =		[sphereBlock copy];
	loadModelBlocks[PM_FLOATING_EYE+GLYPH_MON_OFF] =	[sphereBlock copy];
	loadModelBlocks[PM_FREEZING_SPHERE+GLYPH_MON_OFF] =	[sphereBlock copy];
	loadModelBlocks[PM_FLAMING_SPHERE+GLYPH_MON_OFF] =	[sphereBlock copy];
	loadModelBlocks[PM_SHOCKING_SPHERE+GLYPH_MON_OFF] =	[sphereBlock copy];
	
	// cat or feline class
	LoadModelBlock catBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_KITTEN
									  to:PM_TIGER
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerF" textured:NO withOut:0];
	};
	loadModelBlocks[ PM_KITTEN+GLYPH_MON_OFF ] =	[catBlock copy];
	loadModelBlocks[ PM_HOUSECAT+GLYPH_MON_OFF ] =	[catBlock copy];
	loadModelBlocks[ PM_JAGUAR+GLYPH_MON_OFF ] =	[catBlock copy];
	loadModelBlocks[ PM_LYNX+GLYPH_MON_OFF ] =		[catBlock copy];
	loadModelBlocks[ PM_PANTHER+GLYPH_MON_OFF ] =	[catBlock copy];
	loadModelBlocks[ PM_LARGE_CAT+GLYPH_MON_OFF ] = [catBlock copy];
	loadModelBlocks[ PM_TIGER+GLYPH_MON_OFF ] =		[catBlock copy];
	
	// gremlins and gagoyles class
	LoadModelBlock gremlinsBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_GREMLIN
									  to:PM_WINGED_GARGOYLE
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerG" textured:NO withOut:0];
	};
	loadModelBlocks[PM_GREMLIN+GLYPH_MON_OFF] =			[gremlinsBlock copy];
	loadModelBlocks[PM_GARGOYLE+GLYPH_MON_OFF] =		[gremlinsBlock copy];
	loadModelBlocks[PM_WINGED_GARGOYLE+GLYPH_MON_OFF] =	[gremlinsBlock copy];
	
	// humanoids class
	LoadModelBlock humanoidsBlock = ^(int glyph) {
		// humanoids class
		NH3DModelObjects *ret =nil;
		
		if (glyph == PM_DWARF_KING+GLYPH_MON_OFF) {
			ret = [[NH3DModelObjects alloc] initWith3DSFile:@"lowerH" withTexture:NO];
			[ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject];
			[[ret childObjectAtLast] setPivotX:0.0 atY:0.2 atZ:-0.21];
			[ret childObjectAtLast].currentMaterial = nh3dMaterialArray[NO_COLOR];
		} else {
			
			ret = [self checkLoadedModelsAt:PM_HOBBIT
										 to:PM_MASTER_MIND_FLAYER
									 offset:GLYPH_MON_OFF
								  modelName:@"lowerH"
								   textured:NO
									withOut:PM_DWARF_KING,nil];
		}
		
		return ret;
	};
	loadModelBlocks[PM_DWARF_KING+GLYPH_MON_OFF ] =			[humanoidsBlock copy];
	loadModelBlocks[PM_HOBBIT+GLYPH_MON_OFF ] =				[humanoidsBlock copy];
	loadModelBlocks[PM_DWARF+GLYPH_MON_OFF ] =				[humanoidsBlock copy];
	loadModelBlocks[PM_BUGBEAR+GLYPH_MON_OFF ] =			[humanoidsBlock copy];
	loadModelBlocks[PM_DWARF_LORD+GLYPH_MON_OFF ] =			[humanoidsBlock copy];
	loadModelBlocks[PM_MIND_FLAYER+GLYPH_MON_OFF ] =		[humanoidsBlock copy];
	loadModelBlocks[PM_MASTER_MIND_FLAYER+GLYPH_MON_OFF ] =	[humanoidsBlock copy];
	// imp and minor demons
	LoadModelBlock impBlock = ^(int glyph) {
		return [self loadModelFunc_imp:glyph];
	};
	loadModelBlocks[ PM_MANES+GLYPH_MON_OFF ] =			[impBlock copy];
	loadModelBlocks[ PM_HOMUNCULUS+GLYPH_MON_OFF ] =	[impBlock copy];
	loadModelBlocks[ PM_IMP+GLYPH_MON_OFF ] =			[impBlock copy];
	loadModelBlocks[ PM_LEMURE+GLYPH_MON_OFF ] =		[impBlock copy];
	loadModelBlocks[ PM_QUASIT+GLYPH_MON_OFF ] =		[impBlock copy];
	loadModelBlocks[ PM_TENGU+GLYPH_MON_OFF ] =			[impBlock copy];
	
	// jellys
	LoadModelBlock jellyBlock = ^(int glyph) {
		return [self loadModelFunc_jellys:glyph];
	};
	loadModelBlocks[ PM_BLUE_JELLY+GLYPH_MON_OFF ] =	[jellyBlock copy];
	loadModelBlocks[ PM_SPOTTED_JELLY+GLYPH_MON_OFF ] =	[jellyBlock copy];
	loadModelBlocks[ PM_OCHRE_JELLY+GLYPH_MON_OFF ] =	[jellyBlock copy];
	
	// kobolds
	LoadModelBlock koboldBlock = ^(int glyph) {
		// kobolds
		NH3DModelObjects *ret = nil;
		
		switch ( glyph ) {
			case PM_KOBOLD+GLYPH_MON_OFF :
			case PM_LARGE_KOBOLD+GLYPH_MON_OFF :
				ret = [self checkLoadedModelsAt:PM_KOBOLD
											  to:PM_LARGE_KOBOLD
										  offset:GLYPH_MON_OFF
									   modelName:@"lowerK"
										textured:NO
										 withOut:0];
				break;
				
			case PM_KOBOLD_LORD+GLYPH_MON_OFF :
				ret = [[NH3DModelObjects alloc] initWith3DSFile:@"lowerK" withTexture:NO];
				[ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject];
				[[ret childObjectAtLast] setPivotX:0.0 atY:0.1 atZ:-0.25];
				[ret childObjectAtLast].currentMaterial = nh3dMaterialArray[NO_COLOR];
				
				break;
				
			case PM_KOBOLD_SHAMAN + GLYPH_MON_OFF :
				ret = [[NH3DModelObjects alloc] initWith3DSFile:@"lowerK" withTexture:NO];
				[ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
				[[ret childObjectAtLast ] setPivotX:0.0 atY:-0.01 atZ:-0.15 ];
				[ret childObjectAtLast ].currentMaterial = nh3dMaterialArray[NO_COLOR];
				
				break;
		}
		
		return ret;
	};
	loadModelBlocks[ PM_KOBOLD+GLYPH_MON_OFF ] =			[koboldBlock copy];
	loadModelBlocks[ PM_LARGE_KOBOLD+GLYPH_MON_OFF ] =		[koboldBlock copy];
	loadModelBlocks[ PM_KOBOLD_LORD+GLYPH_MON_OFF ] =		[koboldBlock copy];
	loadModelBlocks[ PM_KOBOLD_SHAMAN + GLYPH_MON_OFF ] =	[koboldBlock copy];
	// leprechaun
	loadModelBlocks[ PM_LEPRECHAUN+GLYPH_MON_OFF ] = [^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"lowerL" withTexture:NO];
	} copy];
	// mimics
	LoadModelBlock mimicBlock = ^(int glyph) {
		return [self loadModelFunc_mimics:glyph];
	};
	loadModelBlocks[ PM_SMALL_MIMIC+GLYPH_MON_OFF ] = [mimicBlock copy];
	loadModelBlocks[ PM_LARGE_MIMIC+GLYPH_MON_OFF ] = [mimicBlock copy];
	loadModelBlocks[ PM_GIANT_MIMIC+GLYPH_MON_OFF ] = [mimicBlock copy];
	// nymphs
	LoadModelBlock nymphBlock = ^(int glyph) {
		return [self loadModelFunc_nymphs:glyph];
	};
	loadModelBlocks[ PM_WOOD_NYMPH+GLYPH_MON_OFF ] = [nymphBlock copy];
	loadModelBlocks[ PM_WATER_NYMPH+GLYPH_MON_OFF ] = [nymphBlock copy];
	loadModelBlocks[ PM_MOUNTAIN_NYMPH+GLYPH_MON_OFF ] = [nymphBlock copy];
	// orc class
	LoadModelBlock orcBlock = ^(int glyph) {
		return [self loadModelFunc_orc:glyph];
	};
	loadModelBlocks[ PM_ORC_SHAMAN + GLYPH_MON_OFF ] =	[orcBlock copy];
	loadModelBlocks[ PM_GOBLIN+GLYPH_MON_OFF ] =		[orcBlock copy];
	loadModelBlocks[ PM_HOBGOBLIN+GLYPH_MON_OFF ] =		[orcBlock copy];
	loadModelBlocks[ PM_ORC+GLYPH_MON_OFF ] =			[orcBlock copy];
	loadModelBlocks[ PM_HILL_ORC+GLYPH_MON_OFF ] =		[orcBlock copy];
	loadModelBlocks[ PM_MORDOR_ORC+GLYPH_MON_OFF ] =	[orcBlock copy];
	loadModelBlocks[ PM_URUK_HAI+GLYPH_MON_OFF ] =		[orcBlock copy];
	loadModelBlocks[ PM_ORC_CAPTAIN+GLYPH_MON_OFF ] =	[orcBlock copy];
	// piercers
	LoadModelBlock piercersBlock = ^(int glyph) {
		return [self loadModelFunc_piercers:glyph];
	};
	loadModelBlocks[ PM_ROCK_PIERCER+GLYPH_MON_OFF ] = [piercersBlock copy];
	loadModelBlocks[ PM_IRON_PIERCER+GLYPH_MON_OFF ] = [piercersBlock copy];
	loadModelBlocks[ PM_GLASS_PIERCER+GLYPH_MON_OFF ] = [piercersBlock copy];
	// quadrupeds
	LoadModelBlock quadrupedsBlock = ^(int glyph) {
		return [self loadModelFunc_quadrupeds:glyph];
	};
	loadModelBlocks[ PM_ROTHE+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	loadModelBlocks[ PM_MUMAK+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	loadModelBlocks[ PM_LEOCROTTA+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	loadModelBlocks[ PM_WUMPUS+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	loadModelBlocks[ PM_TITANOTHERE+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	loadModelBlocks[ PM_BALUCHITHERIUM+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	loadModelBlocks[ PM_MASTODON+GLYPH_MON_OFF ] = [quadrupedsBlock copy];
	// rodents
	LoadModelBlock rodentsBlock = ^(int glyph) {
		return [self loadModelFunc_rodents:glyph];
	};
	loadModelBlocks[ PM_SEWER_RAT+GLYPH_MON_OFF ] = [rodentsBlock copy];
	loadModelBlocks[ PM_GIANT_RAT+GLYPH_MON_OFF ] = [rodentsBlock copy];
	loadModelBlocks[ PM_RABID_RAT+GLYPH_MON_OFF ] = [rodentsBlock copy];
	loadModelBlocks[ PM_WERERAT+GLYPH_MON_OFF ] = [rodentsBlock copy];
	loadModelBlocks[ PM_ROCK_MOLE+GLYPH_MON_OFF ] = [rodentsBlock copy];
	loadModelBlocks[ PM_WOODCHUCK+GLYPH_MON_OFF ] = [rodentsBlock copy];
	// spiders
	LoadModelBlock spiderBlock = ^(int glyph) {
		return [self loadModelFunc_spiders:glyph];
	};
	loadModelBlocks[ PM_CAVE_SPIDER+GLYPH_MON_OFF ] = [spiderBlock copy];
	loadModelBlocks[ PM_CENTIPEDE+GLYPH_MON_OFF ] = [spiderBlock copy];
	loadModelBlocks[ PM_GIANT_SPIDER+GLYPH_MON_OFF ] = [spiderBlock copy];
	loadModelBlocks[ PM_SCORPION+GLYPH_MON_OFF ] = [spiderBlock copy];
	// trapper
	LoadModelBlock trapperBlock = ^(int glyph) {
		return [self loadModelFunc_trapper:glyph];
	};
	loadModelBlocks[ PM_LURKER_ABOVE+GLYPH_MON_OFF ] = [trapperBlock copy];
	loadModelBlocks[ PM_TRAPPER+GLYPH_MON_OFF ] = [trapperBlock copy];
	// unicorns and horses
	LoadModelBlock unicornBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_WHITE_UNICORN
									  to:PM_WARHORSE
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerU"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_WHITE_UNICORN+GLYPH_MON_OFF ] = [unicornBlock copy];
	loadModelBlocks[ PM_GRAY_UNICORN+GLYPH_MON_OFF ] = [unicornBlock copy];
	loadModelBlocks[ PM_BLACK_UNICORN+GLYPH_MON_OFF ] = [unicornBlock copy];
	loadModelBlocks[ PM_PONY+GLYPH_MON_OFF ] = [unicornBlock copy];
	loadModelBlocks[ PM_HORSE+GLYPH_MON_OFF ] = [unicornBlock copy];
	loadModelBlocks[ PM_WARHORSE+GLYPH_MON_OFF ] = [unicornBlock copy];
	// vortices
	LoadModelBlock vortexBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_FOG_CLOUD
									  to:PM_FIRE_VORTEX
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerV"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_FOG_CLOUD+GLYPH_MON_OFF ] = [vortexBlock copy];
	loadModelBlocks[ PM_DUST_VORTEX+GLYPH_MON_OFF ] = [vortexBlock copy];
	loadModelBlocks[ PM_ICE_VORTEX+GLYPH_MON_OFF ] = [vortexBlock copy];
	loadModelBlocks[ PM_ENERGY_VORTEX+GLYPH_MON_OFF ] = [vortexBlock copy];
	loadModelBlocks[ PM_STEAM_VORTEX+GLYPH_MON_OFF ] = [vortexBlock copy];
	loadModelBlocks[ PM_FIRE_VORTEX+GLYPH_MON_OFF ] = [vortexBlock copy];
	// worms
	LoadModelBlock wormBlock = ^(int glyph) {
		// worms
		return [self checkLoadedModelsAt:PM_BABY_LONG_WORM
									  to:PM_PURPLE_WORM
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerW"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_BABY_LONG_WORM+GLYPH_MON_OFF ] = [wormBlock copy];
	loadModelBlocks[ PM_BABY_PURPLE_WORM+GLYPH_MON_OFF ] = [wormBlock copy];
	loadModelBlocks[ PM_LONG_WORM+GLYPH_MON_OFF ] = [wormBlock copy];
	loadModelBlocks[ PM_PURPLE_WORM+GLYPH_MON_OFF ] = [wormBlock copy];
	// xan
	LoadModelBlock xanBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_GRID_BUG
									  to:PM_XAN
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerX"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_GRID_BUG+GLYPH_MON_OFF ] = [xanBlock copy];
	loadModelBlocks[ PM_XAN+GLYPH_MON_OFF ] = [xanBlock copy];
	// lights
	LoadModelBlock lightsBlock = ^(int glyph) {
		// lights
		
		return [self checkLoadedModelsAt:PM_YELLOW_LIGHT
									  to:PM_BLACK_LIGHT
								  offset:GLYPH_MON_OFF
							   modelName:@"lowerY"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_YELLOW_LIGHT+GLYPH_MON_OFF ] = [lightsBlock copy];
	loadModelBlocks[ PM_BLACK_LIGHT+GLYPH_MON_OFF ] = [lightsBlock copy];
	// zruty
	loadModelBlocks[ PM_ZRUTY+GLYPH_MON_OFF ] = [^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"lowerZ" withTexture:NO];
	} copy];
	// Angels
	LoadModelBlock angelBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_COUATL
									  to:PM_ARCHON
								  offset:GLYPH_MON_OFF
							   modelName:@"upperA"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_COUATL+GLYPH_MON_OFF ] = [angelBlock copy];
	loadModelBlocks[ PM_ALEAX+GLYPH_MON_OFF ] = [angelBlock copy];
	loadModelBlocks[ PM_ANGEL+GLYPH_MON_OFF ] = [angelBlock copy];
	loadModelBlocks[ PM_KI_RIN+GLYPH_MON_OFF ] = [angelBlock copy];
	loadModelBlocks[ PM_ARCHON+GLYPH_MON_OFF ] = [angelBlock copy];
	// Bats
	LoadModelBlock batBlock = ^(int glyph) {
		// Bats
		return [self checkLoadedModelsAt:PM_BAT
									  to:PM_VAMPIRE_BAT
								  offset:GLYPH_MON_OFF
							   modelName:@"upperB"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_BAT+GLYPH_MON_OFF ] = [batBlock copy];
	loadModelBlocks[ PM_GIANT_BAT+GLYPH_MON_OFF ] = [batBlock copy];
	loadModelBlocks[ PM_RAVEN+GLYPH_MON_OFF ] = [batBlock copy];
	loadModelBlocks[ PM_VAMPIRE_BAT+GLYPH_MON_OFF ] = [batBlock copy];
	// Centaurs
	LoadModelBlock centaurBlock = ^(int glyph) {
		return [self loadModelFunc_Centaurs:glyph];
	};
	loadModelBlocks[ PM_PLAINS_CENTAUR+GLYPH_MON_OFF ] = [centaurBlock copy];
	loadModelBlocks[ PM_FOREST_CENTAUR+GLYPH_MON_OFF ] = [centaurBlock copy];
	loadModelBlocks[ PM_MOUNTAIN_CENTAUR+GLYPH_MON_OFF ] = [centaurBlock copy];
	// Dragons
	LoadModelBlock dragonBlock = ^(int glyph) {
		return [self loadModelFunc_Dragons:glyph];
	};
	loadModelBlocks[ PM_BABY_GRAY_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_SILVER_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_RED_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_WHITE_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_ORANGE_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_BLACK_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_BLUE_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_GREEN_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BABY_YELLOW_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_GRAY_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_SILVER_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_RED_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_WHITE_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_ORANGE_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BLACK_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_BLUE_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_GREEN_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	loadModelBlocks[ PM_YELLOW_DRAGON+GLYPH_MON_OFF ] = [dragonBlock copy];
	// Elementals
	LoadModelBlock elementalsBlock = ^(int glyph) {
		return [self loadModelFunc_Elementals:glyph];
	};
	loadModelBlocks[ PM_STALKER+GLYPH_MON_OFF ] = [elementalsBlock copy];
	loadModelBlocks[ PM_AIR_ELEMENTAL+GLYPH_MON_OFF ] = [elementalsBlock copy];
	loadModelBlocks[ PM_FIRE_ELEMENTAL+GLYPH_MON_OFF ] = [elementalsBlock copy];
	loadModelBlocks[ PM_EARTH_ELEMENTAL+GLYPH_MON_OFF ] = [elementalsBlock copy];
	loadModelBlocks[ PM_WATER_ELEMENTAL+GLYPH_MON_OFF ] = [elementalsBlock copy];
	// Fungi
	LoadModelBlock fungusBlock = ^(int glyph) {
		return [self loadModelFunc_Fungi:glyph];
	};
	loadModelBlocks[ PM_LICHEN+GLYPH_MON_OFF ] = [fungusBlock copy];
	loadModelBlocks[ PM_BROWN_MOLD+GLYPH_MON_OFF ] = [fungusBlock copy];
	loadModelBlocks[ PM_YELLOW_MOLD+GLYPH_MON_OFF ] = [fungusBlock copy];
	loadModelBlocks[ PM_GREEN_MOLD+GLYPH_MON_OFF ] = [fungusBlock copy];
	loadModelBlocks[ PM_RED_MOLD+GLYPH_MON_OFF ] = [fungusBlock copy];
	loadModelBlocks[ PM_SHRIEKER+GLYPH_MON_OFF ] = [fungusBlock copy];
	loadModelBlocks[ PM_VIOLET_FUNGUS+GLYPH_MON_OFF ] = [fungusBlock copy];
	// Gnomes
	LoadModelBlock gnomeBlock = ^(int glyph) {
		return [self loadModelFunc_Gnomes:glyph];
	};
	loadModelBlocks[ PM_GNOME+GLYPH_MON_OFF ] = [gnomeBlock copy];
	loadModelBlocks[ PM_GNOME_LORD+GLYPH_MON_OFF ] = [gnomeBlock copy];
	loadModelBlocks[ PM_GNOMISH_WIZARD + GLYPH_MON_OFF ] = [gnomeBlock copy];
	loadModelBlocks[ PM_GNOME_KING + GLYPH_MON_OFF ] = [gnomeBlock copy];
	// Giant Humanoids
	LoadModelBlock giantsBlock = ^(int glyph) {
		return [self loadModelFunc_giantHumanoids:glyph];
	};
	loadModelBlocks[ PM_GIANT + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_STONE_GIANT + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_HILL_GIANT + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_FIRE_GIANT + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_FROST_GIANT + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_STORM_GIANT + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_ETTIN + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_TITAN + GLYPH_MON_OFF ] = [giantsBlock copy];
	loadModelBlocks[ PM_MINOTAUR + GLYPH_MON_OFF ] = [giantsBlock copy];
	// Jabberwock
	loadModelBlocks[ PM_JABBERWOCK + GLYPH_MON_OFF ] = [^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"upperJ" withTexture:NO];
	} copy];
	// Kops
	LoadModelBlock kopBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_KEYSTONE_KOP
									  to:PM_KOP_KAPTAIN
								  offset:GLYPH_MON_OFF
							   modelName:@"upperK"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_KEYSTONE_KOP + GLYPH_MON_OFF ] = [kopBlock copy];
	loadModelBlocks[ PM_KOP_SERGEANT + GLYPH_MON_OFF ] = [kopBlock copy];
	loadModelBlocks[ PM_KOP_LIEUTENANT + GLYPH_MON_OFF ] = [kopBlock copy];
	loadModelBlocks[ PM_KOP_KAPTAIN + GLYPH_MON_OFF ] = [kopBlock copy];
	// Liches
	LoadModelBlock lichBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_LICH
									  to:PM_ARCH_LICH
								  offset:GLYPH_MON_OFF
							   modelName:@"upperL"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_LICH + GLYPH_MON_OFF ] = [lichBlock copy];
	loadModelBlocks[ PM_DEMILICH + GLYPH_MON_OFF ] = [lichBlock copy];
	loadModelBlocks[ PM_MASTER_LICH + GLYPH_MON_OFF ] = [lichBlock copy];
	loadModelBlocks[ PM_ARCH_LICH + GLYPH_MON_OFF ] = [lichBlock copy];
	// Mummies
	LoadModelBlock mummyBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_KOBOLD_MUMMY
									  to:PM_GIANT_MUMMY
								  offset:GLYPH_MON_OFF
							   modelName:@"upperM"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_KOBOLD_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_GNOME_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_ORC_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_DWARF_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_ELF_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_HUMAN_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_ETTIN_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	loadModelBlocks[ PM_GIANT_MUMMY + GLYPH_MON_OFF ] = [mummyBlock copy];
	// Nagas
	LoadModelBlock nagaBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_RED_NAGA_HATCHLING
									  to:PM_GUARDIAN_NAGA
								  offset:GLYPH_MON_OFF
							   modelName:@"upperN"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_RED_NAGA_HATCHLING + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_BLACK_NAGA_HATCHLING + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_GOLDEN_NAGA_HATCHLING + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_GUARDIAN_NAGA_HATCHLING + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_RED_NAGA + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_BLACK_NAGA + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_GOLDEN_NAGA + GLYPH_MON_OFF ] = [nagaBlock copy];
	loadModelBlocks[ PM_GUARDIAN_NAGA + GLYPH_MON_OFF ] = [nagaBlock copy];
	// Ogres
	LoadModelBlock ogresBlock = ^(int glyph) {
		return [self loadModelFunc_Ogres:glyph];
	};
	loadModelBlocks[ PM_OGRE + GLYPH_MON_OFF ] = [ogresBlock copy];
	loadModelBlocks[ PM_OGRE_LORD + GLYPH_MON_OFF ] = [ogresBlock copy];
	loadModelBlocks[ PM_OGRE_KING + GLYPH_MON_OFF ] = [ogresBlock copy];
	// Puddings
	LoadModelBlock puddingBlock = ^(int glyph) {
		return [self loadModelFunc_Puddings:glyph];
	};
	loadModelBlocks[ PM_GRAY_OOZE + GLYPH_MON_OFF ] = [puddingBlock copy];
	loadModelBlocks[ PM_BROWN_PUDDING + GLYPH_MON_OFF ] = [puddingBlock copy];
	loadModelBlocks[ PM_BLACK_PUDDING + GLYPH_MON_OFF ] = [puddingBlock copy];
	loadModelBlocks[ PM_GREEN_SLIME + GLYPH_MON_OFF ] = [puddingBlock copy];
	// Quantum mechanics
	loadModelBlocks[ PM_QUANTUM_MECHANIC + GLYPH_MON_OFF ] = [ ^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"upperQ" withTexture:NO];
	} copy];
	// Rust monster or disenchanter
	LoadModelBlock rustMonsterBlock = ^(int glyph) {
		return [self loadModelFunc_Rustmonster:glyph];
	};
	loadModelBlocks[ PM_RUST_MONSTER + GLYPH_MON_OFF ] = [rustMonsterBlock copy];
	loadModelBlocks[ PM_DISENCHANTER + GLYPH_MON_OFF ] = [rustMonsterBlock copy];
	// Snakes
	LoadModelBlock snakeBlock = ^(int glyph) {
		return [self loadModelFunc_Snakes:glyph];
	};
	loadModelBlocks[ PM_GARTER_SNAKE + GLYPH_MON_OFF ] = [snakeBlock copy];
	loadModelBlocks[ PM_SNAKE + GLYPH_MON_OFF ] = [snakeBlock copy];
	loadModelBlocks[ PM_WATER_MOCCASIN + GLYPH_MON_OFF ] = [snakeBlock copy];
	loadModelBlocks[ PM_PIT_VIPER + GLYPH_MON_OFF ] = [snakeBlock copy];
	loadModelBlocks[ PM_PYTHON + GLYPH_MON_OFF ] = [snakeBlock copy];
	loadModelBlocks[ PM_COBRA + GLYPH_MON_OFF ] = [snakeBlock copy];
	// Trolls
	LoadModelBlock trollBlock = ^(int glyph) {
		return [self loadModelFunc_Trolls:glyph];
	};
	loadModelBlocks[ PM_TROLL + GLYPH_MON_OFF ] = [trollBlock copy];
	loadModelBlocks[ PM_ICE_TROLL + GLYPH_MON_OFF ] = [trollBlock copy];
	loadModelBlocks[ PM_ROCK_TROLL + GLYPH_MON_OFF ] = [trollBlock copy];
	loadModelBlocks[ PM_WATER_TROLL + GLYPH_MON_OFF ] = [trollBlock copy];
	loadModelBlocks[ PM_OLOG_HAI + GLYPH_MON_OFF ] = [trollBlock copy];
	// Umber hulk
	loadModelBlocks[ PM_UMBER_HULK + GLYPH_MON_OFF ] = [^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"upperU" withTexture:NO];
	} copy];
	// Vampires
	LoadModelBlock vampireBlock = ^(int glyph) {
		return [self loadModelFunc_Vampires:glyph];
	};
	loadModelBlocks[ PM_VAMPIRE + GLYPH_MON_OFF ] = [vampireBlock copy];
	loadModelBlocks[ PM_VAMPIRE_LORD + GLYPH_MON_OFF ] = [vampireBlock copy];
	loadModelBlocks[ PM_VLAD_THE_IMPALER + GLYPH_MON_OFF ] = [vampireBlock copy];
	// Wraiths
	LoadModelBlock wraithBlock = ^(int glyph) {
		return [self loadModelFunc_Wraiths:glyph];
	};
	loadModelBlocks[ PM_BARROW_WIGHT + GLYPH_MON_OFF ] = [wraithBlock copy];
	loadModelBlocks[ PM_WRAITH + GLYPH_MON_OFF ] = [wraithBlock copy];
	loadModelBlocks[ PM_NAZGUL + GLYPH_MON_OFF ] = [wraithBlock copy];
	// Xorn
	loadModelBlocks[ PM_XORN + GLYPH_MON_OFF ] = [^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"upperX" withTexture:NO];
	} copy];
	// Yeti and other large beasts
	LoadModelBlock yetiBlock = ^(int glyph) {
		return [self loadModelFunc_Yeti:glyph];
	};
	loadModelBlocks[ PM_MONKEY + GLYPH_MON_OFF ] = [yetiBlock copy];
	loadModelBlocks[ PM_APE + GLYPH_MON_OFF ] = [yetiBlock copy];
	loadModelBlocks[ PM_OWLBEAR + GLYPH_MON_OFF ] = [yetiBlock copy];
	loadModelBlocks[ PM_YETI + GLYPH_MON_OFF ] = [yetiBlock copy];
	loadModelBlocks[ PM_CARNIVOROUS_APE + GLYPH_MON_OFF ] = [yetiBlock copy];
	loadModelBlocks[ PM_SASQUATCH + GLYPH_MON_OFF ] = [yetiBlock copy];
	// Zombie
	LoadModelBlock zombieBlock = ^(int glyph) {
		return [self loadModelFunc_Zombie:glyph];
	};
	loadModelBlocks[ PM_KOBOLD_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_GNOME_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_ORC_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_DWARF_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_ELF_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_HUMAN_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_ETTIN_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_GIANT_ZOMBIE + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_GHOUL + GLYPH_MON_OFF ] = [zombieBlock copy];
	loadModelBlocks[ PM_SKELETON + GLYPH_MON_OFF ] = [zombieBlock copy];
	// Golems
	LoadModelBlock golemBlock = ^(int glyph) {
		return [self loadModelFunc_Golems:glyph];
	};
	loadModelBlocks[ PM_STRAW_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_PAPER_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_ROPE_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_GOLD_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_LEATHER_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_WOOD_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_FLESH_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_CLAY_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_STONE_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_GLASS_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	loadModelBlocks[ PM_IRON_GOLEM + GLYPH_MON_OFF ] = [golemBlock copy];
	// Human or Elves
	LoadModelBlock humanOrElfBlock = ^(int glyph) {
		return [self loadModelFunc_HumanorElves:glyph];
	};
	loadModelBlocks[ PM_ELVENKING + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_NURSE + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_HIGH_PRIEST + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_MEDUSA + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_CROESUS + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_HUMAN + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_HUMAN_WERERAT + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_HUMAN_WEREJACKAL + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_HUMAN_WEREWOLF + GLYPH_MON_OFF ] = [humanOrElfBlock copy];	
	loadModelBlocks[ PM_ELF + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_WOODLAND_ELF + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_GREEN_ELF + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_GREY_ELF + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_ELF_LORD + GLYPH_MON_OFF ] = [humanOrElfBlock copy];	
	loadModelBlocks[ PM_DOPPELGANGER + GLYPH_MON_OFF ] = [humanOrElfBlock copy];		
	loadModelBlocks[ PM_SHOPKEEPER + GLYPH_MON_OFF ] = [humanOrElfBlock copy];	
	loadModelBlocks[ PM_GUARD + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_PRISONER + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_ORACLE + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_ALIGNED_PRIEST + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_SOLDIER + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_SERGEANT + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_LIEUTENANT + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_CAPTAIN + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_WATCHMAN + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_WATCH_CAPTAIN + GLYPH_MON_OFF ] = [humanOrElfBlock copy];
	loadModelBlocks[ PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF ] = [humanOrElfBlock copy];	
	// Ghosts
	LoadModelBlock ghostBlock = ^(int glyph) {
		return [self loadModelFunc_Ghosts:glyph];
	};
	loadModelBlocks[ PM_GHOST + GLYPH_INVIS_OFF ] = [ghostBlock copy];
	loadModelBlocks[ PM_SHADE + GLYPH_INVIS_OFF ] = [ghostBlock copy];
	// Major Damons
	LoadModelBlock majorDemonBlock = ^(int glyph) {
		return [self loadModelFunc_MajorDamons:glyph];
	};
	loadModelBlocks[ PM_WATER_DEMON + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_HORNED_DEVIL + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_SUCCUBUS + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_INCUBUS + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_ERINYS + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_BARBED_DEVIL + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_MARILITH + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_VROCK + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_HEZROU + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_BONE_DEVIL + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_ICE_DEVIL + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_NALFESHNEE + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_PIT_FIEND + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_BALROG + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_DJINNI + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	loadModelBlocks[ PM_SANDESTIN + GLYPH_MON_OFF ] = [majorDemonBlock copy];
	// Grater Damons 
	LoadModelBlock greaterDemonBlock = ^(int glyph) {
		return [self loadModelFunc_GraterDamons:glyph];
	};
	loadModelBlocks[ PM_JUIBLEX + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_YEENOGHU + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_ORCUS + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_GERYON + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_DISPATER + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_BAALZEBUB + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_ASMODEUS + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	loadModelBlocks[ PM_DEMOGORGON + GLYPH_MON_OFF ] = [greaterDemonBlock copy];
	// damon "The Riders"
	LoadModelBlock riderDemonBlock = ^(int glyph) {
		return [self loadModelFunc_Riders:glyph];
	};
	loadModelBlocks[ PM_DEATH + GLYPH_MON_OFF ] = [riderDemonBlock copy];
	loadModelBlocks[ PM_PESTILENCE + GLYPH_MON_OFF ] = [riderDemonBlock copy];
	loadModelBlocks[ PM_FAMINE + GLYPH_MON_OFF ] = [riderDemonBlock copy];
	// sea monsters
	LoadModelBlock seaMonsterBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_JELLYFISH
									  to:PM_KRAKEN
								  offset:GLYPH_MON_OFF
							   modelName:@"semicoron"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_JELLYFISH + GLYPH_MON_OFF ] = [seaMonsterBlock copy];
	loadModelBlocks[ PM_PIRANHA + GLYPH_MON_OFF ] = [seaMonsterBlock copy];
	loadModelBlocks[ PM_SHARK + GLYPH_MON_OFF ] = [seaMonsterBlock copy];
	loadModelBlocks[ PM_GIANT_EEL + GLYPH_MON_OFF ] = [seaMonsterBlock copy];
	loadModelBlocks[ PM_ELECTRIC_EEL + GLYPH_MON_OFF ] = [seaMonsterBlock copy];
	loadModelBlocks[ PM_KRAKEN + GLYPH_MON_OFF ] = [seaMonsterBlock copy];
	// lizards
	LoadModelBlock lizardBlock = ^(int glyph) {
		return [self checkLoadedModelsAt:PM_NEWT
									  to:PM_SALAMANDER
								  offset:GLYPH_MON_OFF
							   modelName:@"coron"
								textured:NO
								 withOut:0];
	};
	loadModelBlocks[ PM_NEWT + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_GECKO + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_IGUANA + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_BABY_CROCODILE + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_LIZARD + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_CHAMELEON + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_CROCODILE + GLYPH_MON_OFF ] = [lizardBlock copy];
	loadModelBlocks[ PM_SALAMANDER + GLYPH_MON_OFF ] = [lizardBlock copy];
	// wormtail
	loadModelBlocks[ PM_LONG_WORM_TAIL + GLYPH_MON_OFF ] = [^(int glyph) {
		return [[NH3DModelObjects alloc] initWith3DSFile:@"wormtail" withTexture:NO];
	} copy];;
	// Adventures
	LoadModelBlock adventurerBlock = ^(int glyph) {
		return [self loadModelFunc_Adventures:glyph];
	};
	loadModelBlocks[ PM_ARCHEOLOGIST + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_BARBARIAN + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_CAVEMAN + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_CAVEWOMAN + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_HEALER + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_KNIGHT + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_MONK + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_PRIEST + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_PRIESTESS + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_RANGER + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_ROGUE + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_SAMURAI + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_TOURIST + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_VALKYRIE + GLYPH_MON_OFF ] = [adventurerBlock copy];
	loadModelBlocks[ PM_WIZARD + GLYPH_MON_OFF ] = [adventurerBlock copy];
	// Unique person
	LoadModelBlock uniquePersonBlock = ^(int glyph) {
		return [self loadModelFunc_Uniqueperson:glyph];
	};
	loadModelBlocks[ PM_LORD_CARNARVON + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_PELIAS + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_SHAMAN_KARNOV + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_HIPPOCRATES + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_GRAND_MASTER + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ARCH_PRIEST + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ORION + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_MASTER_OF_THIEVES + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_LORD_SATO + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_TWOFLOWER + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_NORN + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_KING_ARTHUR + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_NEFERET_THE_GREEN + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_MINION_OF_HUHETOTL + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_THOTH_AMON + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_CHROMATIC_DRAGON + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_CYCLOPS + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_IXOTH + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_MASTER_KAEN + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_NALZOK + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_SCORPIUS + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_MASTER_ASSASSIN + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ASHIKAGA_TAKAUJI + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_LORD_SURTUR + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_DARK_ONE + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_STUDENT + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_CHIEFTAIN + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_NEANDERTHAL + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ATTENDANT + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_PAGE + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ABBOT + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ACOLYTE + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_HUNTER + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_THUG + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_NINJA + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_ROSHI + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_GUIDE + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_WARRIOR + GLYPH_MON_OFF ] = [uniquePersonBlock copy];
	loadModelBlocks[ PM_APPRENTICE + GLYPH_MON_OFF ] = [uniquePersonBlock copy];

// -------------------------- Map Symbol Section ----------------------------- //
	
	LoadModelBlock mapSymbolBlock = ^(int glyph) {
		return [self loadModelFunc_MapSymbols:glyph];
	};
	loadModelBlocks[ S_bars + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_tree + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_upstair + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_dnstair + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_upladder + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_dnladder + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_altar + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_grave + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_throne + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_sink + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_fountain + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_vodbridge + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy]; 
	loadModelBlocks[ S_hodbridge + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy]; 
	loadModelBlocks[ S_vcdbridge + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy];
	loadModelBlocks[ S_hcdbridge + GLYPH_CMAP_OFF ] = [mapSymbolBlock copy]; 
//  ------------------------------  Boulder ---------------------------------- //
	
	loadModelBlocks[ BOULDER + GLYPH_OBJ_OFF ] = [^(int glyph) {
		return [self loadModelFunc_Boulder:glyph];
	} copy];
// --------------------------  Trap Symbol Section --------------------------- // 
	
	LoadModelBlock trapSymbolBlock = ^(int glyph) {
		return [self loadModelFunc_TrapSymbol:glyph];
	};
	loadModelBlocks[ S_arrow_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_dart_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_falling_rock_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	//loadModelBlocks[ S_squeaky_board + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_land_mine + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	//loadModelBlocks[ S_rolling_boulder_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_sleeping_gas_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_rust_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_fire_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_bear_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_pit + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_spiked_pit + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_hole + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_trap_door + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_teleportation_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_level_teleporter + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_magic_portal + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	//loadModelBlocks[ S_web + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	//loadModelBlocks[ S_statue_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];	
	loadModelBlocks[ S_magic_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_anti_magic_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	loadModelBlocks[ S_polymorph_trap + GLYPH_CMAP_OFF ] = [trapSymbolBlock copy];
	// ------------------------- Effect Symbols Section. ------------------------- //
	
	// ZAP symbols ( NUM_ZAP * four directions )
	
	// type Magic Missile
	LoadModelBlock magicMissileBlock = ^(int glyph) {
		return [self loadModelFunc_MagicMissile:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM ] = [magicMissileBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM ] = [magicMissileBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT ] = [magicMissileBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT ] = [magicMissileBlock copy];
	// type Magic FIRE
	LoadModelBlock magicFireBlock = ^(int glyph) {
		return [self loadModelFunc_MagicFIRE:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM ] = [magicFireBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM ] = [magicFireBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT ] = [magicFireBlock copy];	
	loadModelBlocks[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT ] = [magicFireBlock copy];
	// type Magic COLD
	LoadModelBlock magicColdBlock = ^(int glyph) {
		return [self loadModelFunc_MagicCOLD:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM ] = [magicColdBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM ] = [magicColdBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT ] = [magicColdBlock copy];	
	loadModelBlocks[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT ] = [magicColdBlock copy];
	// type Magic SLEEP
	LoadModelBlock magicSleepBlock = ^(int glyph) {
		return [self loadModelFunc_MagicSLEEP:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_VBEAM ] = [magicSleepBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_HBEAM ] = [magicSleepBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_LSLANT ] = [magicSleepBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_RSLANT ] = [magicSleepBlock copy];
	// type Magic DEATH
	LoadModelBlock magicDeathBlock = ^(int glyph) {
		return [self loadModelFunc_MagicDEATH:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM ] = [magicDeathBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM ] = [magicDeathBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT ] = [magicDeathBlock copy];	
	loadModelBlocks[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT ] = [magicDeathBlock copy];
	// type Magic LIGHTNING
	LoadModelBlock magicLightningBlock = ^(int glyph) {
		return [self loadModelFunc_MagicLIGHTNING:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM ] = [magicLightningBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM ] = [magicLightningBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT ] = [magicLightningBlock copy];	
	loadModelBlocks[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT ] = [magicLightningBlock copy];
	// type Magic POISONGAS
	LoadModelBlock magicPoisonGasBlock = ^(int glyph) {
		return [self loadModelFunc_MagicPOISONGAS:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_VBEAM ] = [magicPoisonGasBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_HBEAM ] = [magicPoisonGasBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_LSLANT ] = [magicPoisonGasBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_RSLANT ] = [magicPoisonGasBlock copy];
	// type Magic ACID
	LoadModelBlock magicAcidBlock = ^(int glyph) {
		return [self loadModelFunc_MagicACID:glyph];
	};
	loadModelBlocks[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM ] = [magicAcidBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM ] = [magicAcidBlock copy];
	loadModelBlocks[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT ] = [magicAcidBlock copy];	
	loadModelBlocks[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT ] = [magicAcidBlock copy];
	// dig beam
	loadModelBlocks[ S_digbeam + GLYPH_CMAP_OFF ] = [^(int glyph) {
		NH3DModelObjects *ret = [[NH3DModelObjects alloc] init];
		[ ret setModelScaleX:0.7 scaleY:1.0 scaleZ:0.7 ];
		ret.particleType = NH3DParticleTypeAura ;
		[ ret setParticleColor:CLR_BROWN ];
		[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
		[ ret setParticleSpeedX:1.0 Y:1.00 ];
		[ ret setParticleSlowdown:3.8 ];
		[ ret setParticleLife:0.4 ];
		[ ret setParticleSize:20.0 ];

		return ret;
	} copy];
	// camera flash
	loadModelBlocks[ S_flashbeam + GLYPH_CMAP_OFF ] = [^(int glyph) {
		NH3DModelObjects *ret = [ [ NH3DModelObjects alloc ] init ];
		[ ret setModelScaleX:1.4 scaleY:1.5 scaleZ:1.4 ];
		ret.particleType = NH3DParticleTypeAura ;
		ret.particleColor = CLR_WHITE;
		[ ret setParticleColor:CLR_WHITE ];
		[ ret setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
		[ ret setParticleSpeedX:1.0 Y:1.00 ];
		[ ret setParticleSlowdown:3.8 ];
		[ ret setParticleLife:0.4 ];
		[ ret setParticleSize:20.0 ];

		return ret;
	} copy];
	// boomerang
	//loadModelBlocks[ S_boomleft + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];
	//loadModelBlocks[ S_boomright + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];

	// magic shild
	{
		LoadModelBlock magicShildBlock = ^(int glyph) {
			return [self loadModelFunc_MagicSHILD:glyph];
		};
		loadModelBlocks[ S_ss1 + GLYPH_CMAP_OFF ] = [magicShildBlock copy];
		loadModelBlocks[ S_ss2 + GLYPH_CMAP_OFF ] = [magicShildBlock copy];
		loadModelBlocks[ S_ss3 + GLYPH_CMAP_OFF ] = [magicShildBlock copy];
		loadModelBlocks[ S_ss4 + GLYPH_CMAP_OFF ] = [magicShildBlock copy];
	}
	// explotion symbols ( 9 postion * 7 types )
	// type DARK
	{
	LoadModelBlock DarkBlock = ^(int glyph) {
		return [self loadModelFunc_explotionDARK:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_DARK + i ] = [DarkBlock copy];
	}
	}
	// type NOXIOUS
	{
	LoadModelBlock NOXIOUSBlock = ^(int glyph) {
		return [self loadModelFunc_explotionNOXIOUS:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_NOXIOUS + i ] = [NOXIOUSBlock copy];
	}
	}
	// type MUDDY
	{
	LoadModelBlock MUDDYBlock = ^(int glyph) {
		return [self loadModelFunc_explotionMUDDY:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_MUDDY + i ] = [MUDDYBlock copy];
	}
	}
	// type WET
	{
	LoadModelBlock wetBlock = ^(int glyph) {
		return [self loadModelFunc_explotionWET:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_WET + i ] = [wetBlock copy];
	}
	}
	// type MAGICAL
	{
	LoadModelBlock magicalBlock = ^(int glyph) {
		return [self loadModelFunc_explotionMAGICAL:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_MAGICAL + i ] = [magicalBlock copy];
	}
	}
	// type FIERY
	{
	LoadModelBlock fieryBlock = ^(int glyph) {
		return [self loadModelFunc_explotionFIERY:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_FIERY + i ] = [fieryBlock copy];
	}
	}
	// type FROSTY
	{
	LoadModelBlock frostyBlock = ^(int glyph) {
		return [self loadModelFunc_explotionFROSTY:glyph];
	};
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelBlocks[ NH3D_EXPLODE_FROSTY + i ] = [frostyBlock copy];
	}
	}
}



@end



*/
	
}
