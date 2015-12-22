//
//  NH3DOpenGLViewSwift.swift
//  NetHack3D
//
//  Created by C.W. Betts on 7/21/15.
//
//

import Cocoa
import OpenGL.GL
import OpenGL.GL.Ext
import OpenGL.GL.GLU
import GLKit.GLKMatrix4
import GLKit.GLKMathUtils


private let GLYPH_MON_OFF: Int32 = 0
private let TEX_SIZE = 128

private typealias LoadModelBlock = (glyph: Int32) -> NH3DModelObjects?
private func loadModelFunc_default(glyph: Int32) -> NH3DModelObjects? {
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

private var nh3dMaterialArray: [NH3DMaterial] = [
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


final class NH3DOpenGLView: NSOpenGLView {
	@IBOutlet weak var mapModel: MapModel!
	
	private var loadModelBlocks = [LoadModelBlock](count: Int(MAX_GLYPH), repeatedValue: loadModelFunc_default)
	private var modelDictionary = [Int32: NH3DModelObjects]()
	private let viewLock = NSRecursiveLock()
	private typealias DrawFloorFunc = () -> ()
	private var drawFloorArray = [DrawFloorFunc]()
	
	private typealias SwitchMethod = (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void
	private var switchMethodArray = [SwitchMethod]()
	
	private var isReady = false
	private(set) var isFloating = false
	private(set) var isRiding = false
	var isShocked: Bool = false {
		willSet {
			viewLock.lock()
			nowUpdating = true
		}
		didSet {
			nowUpdating = false
			viewLock.unlock()
		}
	}
	
	private var floorTex = GLuint(0)
	private var floor2Tex = GLuint(0)
	//GLuint		wallTex;
	private var cellingTex = GLuint(0)
	private var waterTex = GLuint(0)
	private var poolTex = GLuint(0)
	private var lavaTex = GLuint(0)
	private var envelopTex = GLuint(0)
	private var minesTex = GLuint(0)
	private var airTex = GLuint(0)
	private var cloudTex = GLuint(0)
	private var hellTex = GLuint(0)
	private var nullTex = GLuint(0)
	private var rougeTex = GLuint(0)
	private var defaultTex = [GLuint](count: Int(MAX_GLYPH), repeatedValue: 0)
	
	private var floorCurrent = GLuint(0)
	private var cellingCurrent  = GLuint(0)
	
	private var mapItemValue: [[NH3DMapItem?]] = [[NH3DMapItem?]](count: Int(NH3DGL_MAPVIEWSIZE_COLUMN), repeatedValue:[NH3DMapItem?](count: Int(NH3DGL_MAPVIEWSIZE_ROW), repeatedValue: nil))

	private var lastCameraX: GLfloat = 5.0;
	var lastCameraY: GLfloat = 1.8;
	var lastCameraZ: GLfloat = 5.0;
	
	private(set) var lastCameraHead: GLfloat = 0;
	private(set) var lastCameraPitch: GLfloat = 0;
	private(set) var lastCameraRoll: GLfloat = 0;
	
	private(set) var cameraX: GLfloat = 5.0;
	private(set) var cameraY: GLfloat = 1.8;
	private(set) var cameraZ: GLfloat = 5.0;
	private(set) var cameraHead: GLfloat = 0.0;
	private(set) var cameraPitch: GLfloat = 0.0;
	private(set) var cameraRoll: GLfloat = 0.0;
	
	var cameraStep: GLfloat = 0
	
	private var keyLightCol = [GLfloat](count: 4, repeatedValue: 0)
	
	private(set) var centerX: Int32 = 0
	private(set) var centerZ: Int32 = 0
	private(set) var playerdepth: Int32 = 0
	private(set) var drawMargin: Int32 = 0;
	var enemyPosition: Int32 = 0 {
		willSet {
			viewLock.lock()
			nowUpdating = true
		}
		didSet {
			nowUpdating = false
			viewLock.unlock()
		}
	}
	var elementalLevel: Int32 = 0
	private(set) var waitRate: Double = 0
	
	private var dRefreshRate: CGRefreshRate = 0

	private var effectArray = [NH3DModelObjects]()
	
	private var nowUpdating = false
	var running: Bool = false {
		willSet {
			viewLock.lock()
		}
		didSet {
			viewLock.unlock()
		}
	}
	private var threadRunning = false
	private var hasWait = false
	private var firstTime = true
	private var oglParamNowChanging = false
	private var useTile = false

	private var keyArray = [Int32]()
	private var delayDrawing = [(item: NH3DMapItem, x: Int32, z: Int32)]()
	
	override convenience init?(frame frameRect: NSRect, pixelFormat format: NSOpenGLPixelFormat?) {
		self.init(frame: frameRect)
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

		glMatrixMode(GLenum(GL_MODELVIEW))
		glLoadIdentity();
		
		glEnable(GLenum(GL_DEPTH_TEST))
		glEnable(GLenum(GL_POINT_SMOOTH))
		
		glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_FILL))
		//	glPolygonMode( GL_BACK,GL_LINE );
		
		glEnable(GLenum(GL_CULL_FACE))
		glCullFace(GLenum(GL_BACK))
		
		glEnable(GLenum(GL_TEXTURE_2D))
		
		glEnable(GLenum(GL_LIGHTING))
		glEnable(GLenum(GL_FOG))
		
		
		// load texture
		
		floorTex = loadImageToTexture(named: "floor.tif")
		floor2Tex = loadImageToTexture(named: "floor2.tif")
		//wallTex = [ self loadImageToTexture:@"wall.tif" ];
		cellingTex = loadImageToTexture(named: "celling.tif")
		waterTex = loadImageToTexture(named: "water.tif")
		poolTex = loadImageToTexture(named: "poolColor.tif")
		lavaTex = loadImageToTexture(named: "lava.tif")
		minesTex = loadImageToTexture(named: "rockwall.tif")
		airTex = loadImageToTexture(named: "air.tif")
		cloudTex = loadImageToTexture(named: "cloud.tif")
		hellTex = loadImageToTexture(named: "hell.tif")
		nullTex = loadImageToTexture(named: "null.tif")
		rougeTex = loadImageToTexture(named: "rouge.tif")
		
		floorCurrent = floorTex
		cellingCurrent = cellingTex
		
		// multi texture
		
		glActiveTexture(GLenum(GL_TEXTURE1))
		
		envelopTex = loadImageToTexture(named: "envlop.tif")
		
		glActiveTexture(GLenum(GL_TEXTURE0))
		
		// init speed up function
		cacheMethods()
		
		// init Effect models
		enemyPosition = 0;
		effectArray.reserveCapacity(12)

		do {
			let effect = NH3DModelObjects() // hit enemy front left
			effect.setModelShiftX(-1, shiftY: 1.8, shiftZ: -1)
			effect.setParticleGravityX(3, y: -0.5, z: 3)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: -1)
			effect.setParticleGravityX(0, y: -0.5, z: 3)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front right
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: -1)
			effect.setParticleGravityX(-3, y: -0.5, z: 3)
			effectArray.append(effect)
		}
		
		//right direction
		do {
			let effect = NH3DModelObjects() // hit enemy front left
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: -1)
			effect.setParticleGravityX(3, y: -0.5, z: 3)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: 0)
			effect.setParticleGravityX(3, y: -0.5, z: 0)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front right
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: 1)
			effect.setParticleGravityX(3, y: -0.5, z: -3)
			effectArray.append(effect)
		}

		//back direction
		do {
			let effect = NH3DModelObjects() // hit enemy front left
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: 1)
			effect.setParticleGravityX(-3, y: -0.5, z: -3)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: 1)
			effect.setParticleGravityX(-3, y: -0.5, z: -3)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front right
			effect.setModelShiftX(1, shiftY: 1.8, shiftZ: 1)
			effect.setParticleGravityX(0, y: -0.5, z: -3)
			effectArray.append(effect)
		}
		
		//left direction
		do {
			let effect = NH3DModelObjects() // hit enemy front left
			effect.setModelShiftX(-1, shiftY: 1.8, shiftZ: 1)
			effect.setParticleGravityX(-3, y: -0.5, z: -3)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front
			effect.setModelShiftX(-1, shiftY: 1.8, shiftZ: 0)
			effect.setParticleGravityX(-3, y: -0.5, z: 0)
			effectArray.append(effect)
		}
		do {
			let effect = NH3DModelObjects() // hit enemy front right
			effect.setModelShiftX(-1, shiftY: 1.8, shiftZ: -1)
			effect.setParticleGravityX(-3, y: -0.5, z: 3)
			effectArray.append(effect)
		}

		for effect in effectArray {
			effect.setParticleSize(8.5)
			effect.particleType = .Points
			effect.particleColor = CLR_RED
			effect.setParticleSpeedX(1.0, y: -1.0)
			effect.particleSlowdown = 0.8
			effect.particleLife = 1
		}
		
		// load cashed models
		autoreleasepool() {
		loadModels()
		}
	}
	
	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let nCenter = NSNotificationCenter.defaultCenter()
		nCenter.addObserver(self, selector: "defaultsDidChange:", name: "NSUserDefaultsDidChangeNotification", object: nil)
		
		let curCfg = CGDisplayCopyDisplayMode(CGMainDisplayID());
		dRefreshRate = CGDisplayModeGetRefreshRate(curCfg);
		
		running = true;
		threadRunning = false;
		
		// set drawflag for Nh3d Titles
		needsDisplay = true
		
		// setup defaults
		defaultsDidChange(nil)
		
		useTile = NH3DGL_USETILE;
		
		// Create and detach to other thread for OpenGL update and drawing.
		if !TRADITIONAL_MAP {
			detachOpenGLThread()
		}
	}
	
	/// draw title.
    override func drawRect(dirtyRect: NSRect) {
		if ( isReady || !firstTime ) {
			return;
		} else {
			var attributes = [String: AnyObject]()
			attributes[NSFontAttributeName] = NSFont(name: "Copperplate", size: 20)!
			attributes[NSForegroundColorAttributeName] = NSColor(calibratedWhite: 0.5, alpha: 0.6)
			
			lockFocusIfCanDraw()
			
			NSColor.clearColor().set()
			NSBezierPath.fillRect(bounds)
			
			NSImage(named: "nh3d")?.drawAtPoint(NSPoint(x: 156, y: 88), fromRect: .zero, operation: .CompositeSourceOver, fraction: 0.7)
			("NetHack3D" as NSString).drawAtPoint(NSPoint(x: 168.0, y: 70.0), withAttributes: attributes)
			attributes[NSFontAttributeName] = NSFont(name: "Copperplate", size: 14)!
			("by Haruumi Yoshino 2005" as NSString).drawAtPoint(NSPoint(x: 130.0, y: 56.0), withAttributes: attributes)
			("NetHack" as NSString).drawAtPoint(NSPoint(x: 192.0, y: 29.0), withAttributes: attributes)
			attributes[NSFontAttributeName] =  NSFont(name: "Copperplate", size: 11)
			("Copyright © Stichting Mathematisch Centrum  Amsterdam, 1985. \n   NetHack may be freely redistributed. See license for details."
				as NSString).drawAtPoint(NSPoint(x: 38.0, y: 3.0), withAttributes: attributes)
			
			unlockFocus()
			
			firstTime = false;
		}
    }
	
	func drawGLView(x x: Int32, z: Int32) {
		guard let mapItem = mapItemValue[Int(x)][Int(z)] else {
			return
		}
		let type = mapItem.modelDrawingType
		if type != 10 {
			switchMethodArray[Int(type)](x: mapItem.posX, z: mapItem.posY, lx: x, lz: z)
		} else {
			// delay drawing for alphablending.
			delayDrawing.append((item: mapItem, x: x, z: z))
		}
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
	
	private final func checkLoadedModels(at startNum: Int32, to endNum: Int32, offset: Int32 = GLYPH_MON_OFF, modelName: String, textured flag: Bool, without: Int32...) -> NH3DModelObjects? {
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
		
		glEnableClientState(GLenum(GL_VERTEX_ARRAY))
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
	
	private func drawFloorAndCeiling(x x: Float, z: Float, flag: Int32) {
		glPushMatrix();
		
		glTranslatef(x, 0.0, z);
		
		glEnableClientState(GLenum(GL_VERTEX_ARRAY))
		glEnableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
		glEnableClientState(GLenum(GL_NORMAL_ARRAY))
		
		glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_AMBIENT), nh3dMaterialArray[Int(NO_COLOR)].ambient );
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_DIFFUSE), nh3dMaterialArray[Int(NO_COLOR)].diffuse );
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_SPECULAR), nh3dMaterialArray[Int(NO_COLOR)].specular );
		glMaterialf(GLenum(GL_FRONT), GLenum(GL_SHININESS), nh3dMaterialArray[Int(NO_COLOR)].shininess );
		glMaterialfv(GLenum(GL_FRONT), GLenum(GL_EMISSION), nh3dMaterialArray[Int(NO_COLOR)].emission );
		
		// Draw floor
		drawFloorArray[Int(flag)]();
		
		glDisableClientState(GLenum(GL_NORMAL_ARRAY))
		glDisableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
		glDisableClientState(GLenum(GL_VERTEX_ARRAY))
		
		glPopMatrix();
	}
	
	private func createLightAndFog() {
		let gblight = 1.0 - ( Float(u.uhp) / Float(u.uhpmax) );
	
		let AmbLightPos: [ GLfloat ] = [0.0, 4.0, 0.0, 0];
		let keyLightPos: [ GLfloat ] = [0.01, 3.0, 0.0, 1]
		var fogColor: [ GLfloat ] = [gblight/4, 0.0, 0.0, 0.0]
		let lightEmisson: [ GLfloat ] = [0.1, 0.1, 0.1, 1]
	
		keyLightCol[0] = 2.0;
		keyLightCol[3] = 1.0;
		if ( 1.00 - gblight < 0 )  {
			keyLightCol[ 1 ] = 0.0;
			keyLightCol[ 2 ] = 0.0;
		} else {
			keyLightCol[ 1 ] = 2.00 - ( gblight * 2.0 );
			keyLightCol[ 2 ] = 2.00 - ( gblight * 2.0 );
		}
	
		glPushMatrix();
	
		glTranslatef(lastCameraX,
			lastCameraY,
			lastCameraZ);
	
		glFogi(GLenum(GL_FOG_MODE), GL_LINEAR)
		glHint(GLenum(GL_MULTISAMPLE_FILTER_HINT_NV), GLenum(GL_NICEST))
	
		glFogf(GLenum(GL_FOG_START), 0.0)
	
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
	
		if isReady && ( Swift_Blind() || u.uswallow != 0 ) {
			// you're blind
	
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), AmbLightPos)
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_AMBIENT_AND_DIFFUSE), keyLightAltAmb)
			glLightf(GLenum(GL_LIGHT0), GLenum(GL_SHININESS), 0.01)
	
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_POSITION), keyLightPos)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_AMBIENT), keyLightAltAmb)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_DIFFUSE), keyLightAltCol)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_SPECULAR), keyLightAltspec)
	
			glLightf(GLenum(GL_LIGHT1), GLenum(GL_SHININESS), 0.01)
	
	
			glClearColor( 0.0 ,0.0 ,0.0 ,0.0 );
			glFogf( GLenum(GL_FOG_END) ,  6.0 );
			glFogfv(GLenum(GL_FOG_COLOR), defaultBackGroundCol)
	
		} else if isReady && Swift_Underwater() {
	
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), AmbLightPos)
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_AMBIENT_AND_DIFFUSE), keyLightCol)
			glLightf(GLenum(GL_LIGHT0), GLenum(GL_SHININESS), 1.0)
	
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_POSITION), keyLightPos)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_AMBIENT), keyLightAmb)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_DIFFUSE), keyLightCol)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_SPECULAR), keyLightspec)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_EMISSION), lightEmisson)
			glLightf(GLenum(GL_LIGHT1), GLenum(GL_SHININESS), 30.0)
	
			glClearColor(0.0, 0.0, 0.8, 0.0)
			glFogf(GLenum(GL_FOG_END), 6.0)
			glFogfv(GLenum(GL_FOG_COLOR), underWaterColar)
	
		} else if Swift_IsRoom(Swift_RoomAtLocation(u.ux, u.uy).typ) || IS_DOOR(Swift_RoomAtLocation(u.ux, u.uy).typ) {
			// in room
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), AmbLightPos)
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_AMBIENT_AND_DIFFUSE), keyLightCol)
			glLightf(GLenum(GL_LIGHT0), GLenum(GL_SHININESS), 0.01)
	
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_POSITION), keyLightPos)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_AMBIENT), keyLightAmb)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_DIFFUSE), keyLightCol)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_SPECULAR), keyLightspec)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_EMISSION), lightEmisson)
			glLightf(GLenum(GL_LIGHT1), GLenum(GL_SHININESS), 30.0)
	
			// check lit position.
			glFogf(GLenum(GL_FOG_END) , 4.5 + Float(MAP_MARGIN) * NH3DGL_TILE_SIZE);
	
			for i in 1...MAP_MARGIN {
				if ( ( Swift_IsRoom( Swift_RoomAtLocation(u.ux, u.uy + xchar(i)).typ ) || IS_DOOR( Swift_RoomAtLocation(u.ux, u.uy + xchar(i)).typ ) )
				&& Swift_RoomAtLocation(u.ux, u.uy + xchar(i)).glyph == S_stone + GLYPH_CMAP_OFF ) {
					glFogf( GLenum(GL_FOG_END) ,  4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				} else if ( ( Swift_IsRoom( Swift_RoomAtLocation(u.ux, u.uy - xchar(i)).typ ) || IS_DOOR( Swift_RoomAtLocation(u.ux, u.uy - xchar(i)).typ ) )
				&& Swift_RoomAtLocation(u.ux, u.uy - xchar(i)).glyph == S_stone + GLYPH_CMAP_OFF ) {
					glFogf( GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				} else if (Swift_IsRoom(Swift_RoomAtLocation(u.ux + xchar(i), u.uy).typ) || IS_DOOR(Swift_RoomAtLocation(u.ux + xchar(i), u.uy).typ))
				&& Swift_RoomAtLocation(u.ux + xchar(i), u.uy).glyph == S_stone + GLYPH_CMAP_OFF {
					glFogf(GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
				break;
	
				} else if (Swift_IsRoom(Swift_RoomAtLocation(u.ux - xchar(i), u.uy).typ) || IS_DOOR(Swift_RoomAtLocation(u.ux - xchar(i), u.uy).typ))
				&& Swift_RoomAtLocation(u.ux - xchar(i), u.uy).glyph == S_stone + GLYPH_CMAP_OFF {
					glFogf(GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				}
			}
	
			glFogfv(GLenum(GL_FOG_COLOR), fogColor);
	
		} else if Swift_RoomAtLocation(u.ux, u.uy).typ == schar(CORR) {
			// in corr
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), AmbLightPos)
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_AMBIENT_AND_DIFFUSE), keyLightCol)
			glLightf(GLenum(GL_LIGHT0), GLenum(GL_SHININESS), 0.01)
	
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_POSITION), keyLightPos)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_AMBIENT), keyLightAmb)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_DIFFUSE), keyLightCol)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_SPECULAR), keyLightspec)
			glLightfv(GLenum(GL_LIGHT1), GLenum(GL_EMISSION), lightEmisson)
			glLightf(GLenum(GL_LIGHT1), GLenum(GL_SHININESS), 30.0)
	
			for i in 1...MAP_MARGIN {
				if Swift_RoomAtLocation(u.ux, u.uy + xchar(i)).typ == schar(CORR)
				&&   Swift_RoomAtLocation(u.ux, u.uy + xchar(i)).lit == 0 {
					glFogf(GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				} else if Swift_RoomAtLocation(u.ux, u.uy - xchar(i)).typ == schar(CORR)
				&&   Swift_RoomAtLocation(u.ux, u.uy - xchar(i)).lit == 0 {
					glFogf(GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				} else if Swift_RoomAtLocation(u.ux + xchar(i), u.uy).typ == schar(CORR)
				&&   Swift_RoomAtLocation(u.ux + xchar(i), u.uy).lit == 0 {
					glFogf(GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				} else if Swift_RoomAtLocation(u.ux - xchar(i), u.uy).typ == schar(CORR)
					&&   Swift_RoomAtLocation(u.ux - xchar(i), u.uy).lit == 0 {
					glFogf(GLenum(GL_FOG_END) , 4.5 + Float(i) * NH3DGL_TILE_SIZE );
					break;
				}
			
			}
		} else {
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), AmbLightPos)
			glLightfv(GLenum(GL_LIGHT0), GLenum(GL_AMBIENT_AND_DIFFUSE), keyLightCol)
			glLightf(GLenum(GL_LIGHT0), GLenum(GL_SHININESS), 1.0)
	
			glLightfv( GLenum(GL_LIGHT1), GLenum(GL_POSITION), keyLightPos );
			glLightfv( GLenum(GL_LIGHT1), GLenum(GL_AMBIENT), keyLightAmb );
			glLightfv( GLenum(GL_LIGHT1), GLenum(GL_DIFFUSE), keyLightCol );
			glLightfv( GLenum(GL_LIGHT1), GLenum(GL_SPECULAR), keyLightspec );
			glLightfv( GLenum(GL_LIGHT1), GLenum(GL_EMISSION), lightEmisson );
			glLightf( GLenum(GL_LIGHT1), GLenum(GL_SHININESS), 10.0 );
	
			glFogf(GLenum(GL_FOG_END),  4.5 + Float(u.nv_range) * NH3DGL_TILE_SIZE)
			glFogfv(GLenum(GL_FOG_COLOR), fogColor)
	
		}
	
		glEnable(GLenum(GL_LIGHT0))
		glEnable(GLenum(GL_LIGHT1))
	
		glPopMatrix();
	}
	
	
	//---------- draw floor function ----------------
	
	
	private func floorfunc_default() {
		return;
	}
	
	override var opaque: Bool {
		return !firstTime
	}
	
	deinit {
		delayDrawing.removeAll()
		modelDictionary.removeAll()
		
		for i in 0..<Int(MAX_GLYPH) {
			var texid = defaultTex[i];
			glDeleteTextures(1, &texid)
		}
		
		glDeleteTextures(1, &floorTex )
		glDeleteTextures(1, &floor2Tex )
		glDeleteTextures(1, &cellingTex )
		glDeleteTextures(1, &waterTex )
		glDeleteTextures(1, &poolTex )
		glDeleteTextures(1, &lavaTex )
		glDeleteTextures(1, &envelopTex )
		glDeleteTextures(1, &minesTex )
		glDeleteTextures(1, &airTex )
		glDeleteTextures(1, &cloudTex )
		glDeleteTextures(1, &hellTex )
		glDeleteTextures(1, &nullTex )
		glDeleteTextures(1, &rougeTex )
	}
	
	func detachOpenGLThread() {
		threadRunning = true
		
		for _ in 0..<OPENGLVIEW_NUMBER_OF_THREADS {
			NSThread.detachNewThreadSelector("timerFired:", toTarget: self, withObject: self)
		}
	}
	
	/// OpenGL update method.
	@objc(timerFired:) private func timerFired(sender: AnyObject) {
		autoreleasepool {
			
			openGLContext?.makeCurrentContext()
			
			viewLock.lock()
			
			var vsType: GLint
			if ( OPENGLVIEW_WAITSYNC ) {
				vsType = vsincWait
			} else {
				vsType = vsincNoWait
			}
			openGLContext?.setValues(&vsType, forParameter: NSOpenGLContextParameter.GLCPSwapInterval)
			
			viewLock.unlock()
			
			while running && !TRADITIONAL_MAP {
				autoreleasepool {
					
					if ( isReady && !nowUpdating && !self.needsDisplay ) {
						//if ( isReady && !nowUpdating ) {
						self.updateGLView()
					}
					
					
					if ( hasWait ) {
						NSThread.sleepUntilDate(NSDate(timeIntervalSinceNow: 1.0 / Double(waitRate)))
					}
				}
			}
			
		}
		NSThread.exit()
	}
	
	/// Drawing OpenGL function.
	func updateGLView() {
/*
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
*/
	}
	
	override func setFrameSize(newSize: NSSize) {
		super.setFrameSize(newSize)
		
		glViewport(0, 0, GLsizei(newSize.width), GLsizei(newSize.height))
	}

	func clearGLView() {
		glClearColor(0, 0, 0, 0)
		
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
	}

	func drawModelArray(mapItem: NH3DMapItem) {
/*
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
			glActiveTexture(GLenum(GL_TEXTURE0));
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glEnable( GL_ALPHA_TEST );
			glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
			
			glBindTexture( GL_TEXTURE_2D, defaultTex[ glyph ] );
			glTexEnvf( GLenum(GL_TEXTURE_ENV), GL_TEXTURE_ENV_MODE, GL_MODULATE );
			
			glMaterialfv(GLenum(GL_FRONT), GL_AMBIENT , nh3dMaterialArray[ NO_COLOR ].ambient );
			glMaterialfv(GLenum(GL_FRONT), GL_DIFFUSE , nh3dMaterialArray[ NO_COLOR ].diffuse );
			glMaterialfv(GLenum(GL_FRONT), GL_SPECULAR , nh3dMaterialArray[ NO_COLOR ].specular );
			glMaterialf(GLenum(GL_FRONT), GL_SHININESS , nh3dMaterialArray[ NO_COLOR ].shininess );
			glMaterialfv(GLenum(GL_FRONT), GL_EMISSION , nh3dMaterialArray[ NO_COLOR ].emission );
			
			
			glAlphaFunc( GL_GREATER, 0.5 );
			
			glEnableClientState( GL_VERTEX_ARRAY );
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glEnableClientState( GL_NORMAL_ARRAY );
			
			glNormalPointer( GL_FLOAT, 0 ,defaultNorms );
			glTexCoordPointer( 2,GL_FLOAT,0, defaultTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , defaultVerts );
			
			
			glDisable( GL_CULL_FACE );
			angle = 5.0;
			for ( f = 0.0 ; f < 0.02 ; f += 0.002 ) {
				angle *= -1.0;
				glTranslatef( 0.0 ,0.0 ,f );
				glRotatef(angle,	0, 1.0, 0);
				glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			}
			glEnable( GL_CULL_FACE );
			
			glDisableClientState( GL_NORMAL_ARRAY );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glDisableClientState( GL_VERTEX_ARRAY );
			
			glDisable( GL_ALPHA_TEST );
			glDisable(GLenum(GL_TEXTURE_2D));
			
			
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
*/
	}
	
	func updateMap() {
		
	/*
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
*/
	}
	
	func changeWallsTexture(texID: Int32) {
		modelDictionary[(S_vwall + GLYPH_CMAP_OFF)]?.texture = texID
		modelDictionary[(S_hwall + GLYPH_CMAP_OFF)]?.texture = texID
		modelDictionary[(S_tlcorn + GLYPH_CMAP_OFF)]?.texture = texID
	}

	@objc(setCenterAtX:z:depth:) func setCenterAt(x x: Int32, z: Int32, depth: Int32) {
		
/*
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
*/
	}
	
	@objc(setCameraHead:pitching:rolling:) func setCamera(head head: Float, pitching pitch: Float, rolling roll: Float) {
		
/*
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
*/
	}
	
	@objc(setCameraAtX:atY:atZ:) func setCameraAt(x x: Float, y: Float, z: Float) {
/*
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
*/
	}
	
// ---------------------------------
// MARK: effect and visual functions.
// ---------------------------------

/*
- ( void )applyCIFilters
{
	CIContext *myCIContext;
	myCIContext = [CIContext contextWithCGLContext:CGLGetCurrentContext()  
										   options:nil]; 
}
*/




// ---------------------------------
	func doEffect() {
		struct EffectHelper {
			static var effectCount = 0
		}
		let localPos = effectArray[ enemyPosition-1 ].modelShift
		
		effectArray[enemyPosition - 1].setPivotX(cameraX+localPos.x,
			atY: localPos.y,
			atZ: cameraZ + localPos.z)
		if EffectHelper.effectCount < Int(waitRate) / 2 {
			effectArray[ enemyPosition-1 ].drawSelf()
			EffectHelper.effectCount++
		} else {
			EffectHelper.effectCount = 0
			enemyPosition = 0
		}
	}
	
	func floatingCamera() {
		struct FloatHelp {
			static var fltCamera: Float = 0
			static var floatDirection = false
		}
		
		FloatHelp.fltCamera = ( FloatHelp.floatDirection ) ? FloatHelp.fltCamera+0.003 : FloatHelp.fltCamera-0.003;
		if ( FloatHelp.fltCamera > 0.08 ) {
			FloatHelp.floatDirection = false
		}
		if ( FloatHelp.fltCamera < -0.08 ) {
			FloatHelp.floatDirection = true
		}
		
		glTranslatef(0.0, FloatHelp.fltCamera, 0.0)
	}

	func shockedCamera() {
		struct ShockHelp {
			static var cameraShock: Float = 0
			static var shockCount = 0
			static var shockDirection = false
		}
		
		//cameraShock = ( shockDirection ) ? cameraShock+( float )( ( random() %4 )*0.01 ) : cameraShock-( float )( ( random() %4 )*0.01 );
		ShockHelp.cameraShock = ( ShockHelp.shockDirection ) ? ShockHelp.cameraShock+0.04 : ShockHelp.cameraShock-0.04;
		if ( ShockHelp.cameraShock > 0.08 ) {
			ShockHelp.shockDirection = false
		}
		if ( ShockHelp.cameraShock < -0.08 ) {
			ShockHelp.shockDirection = true
		}
		
		ShockHelp.shockCount++;
		
		if Double(ShockHelp.shockCount) > waitRate / 2 {
			isShocked = false;
			ShockHelp.shockCount = 0;
		}
		
		glTranslatef(0.0, ShockHelp.cameraShock, 0.0)
	}
	
	func dorryCamera() {
		if !isReady {
			glTranslatef( -cameraX,-cameraY,-cameraZ );
		} else if ( lastCameraX == cameraX && lastCameraY == cameraY && lastCameraZ == cameraZ ) {
			glTranslatef( -cameraX,-cameraY,-cameraZ );
			if drawMargin != 3 {
				drawMargin = 0
			}
		} else {
			let xstep = ( cameraX - lastCameraX ) / cameraStep;
			let ystep = ( cameraY - lastCameraY ) / cameraStep;
			let zstep = ( cameraZ - lastCameraZ ) / cameraStep;
			
			lastCameraZ += zstep;
			lastCameraY += ystep;
			lastCameraX += xstep;
			
			if xstep < 0.001 && xstep > -0.001 {
				lastCameraX = cameraX
			}
			if ystep < 0.001 && ystep > -0.001 {
				lastCameraY = cameraY
			}
			if zstep < 0.001 && zstep > -0.001 {
				lastCameraZ = cameraZ
			}
			
			glTranslatef( -lastCameraX,-lastCameraY,-lastCameraZ );
		}
	}
	
	func panCamera() {
		if !isReady {
			glRotatef( cameraRoll,		0,0,1 );
			glRotatef( -cameraPitch,	1,0,0 );
			glRotatef( -cameraHead,		0,1,0 );
		} else if lastCameraHead == cameraHead {
			if drawMargin != 1 {
				drawMargin  = 0
			}
			glRotatef( cameraRoll,		0,0,1 );
			glRotatef( -cameraPitch,	1,0,0 );
			glRotatef( -cameraHead,		0,1,0 );
		} else {
			let rollstep = ( cameraRoll - lastCameraRoll ) / cameraStep;
			let pitchstep = ( cameraPitch - lastCameraPitch ) / cameraStep;
			let headstep = ( cameraHead - lastCameraHead ) / cameraStep;
			
			lastCameraRoll += rollstep;
			lastCameraPitch += pitchstep;
			lastCameraHead += headstep;
			
			if (rollstep < 0.01 && rollstep > -0.01) || rollstep > 90.0 {
				lastCameraRoll = cameraRoll
			}
			if (pitchstep < 0.01 && pitchstep > -0.01) || pitchstep > 90.0 {
				lastCameraPitch = cameraPitch
			}
			if (headstep < 0.01 && headstep > -0.01) || headstep > 90.0 {
				lastCameraHead = cameraHead
			}
			
			glRotatef( lastCameraRoll,		0,0,1 );
			glRotatef( -lastCameraPitch,	1,0,0 );
			glRotatef( -lastCameraHead,		0,1,0 );
		}
	}

	// MARK: -

	private func createTextureFromSymbol(symbol: AnyObject, color: NSColor) -> GLuint {
		viewLock.lock()
		var texID: GLuint = 0
		let img = NSImage(size: NSSize(width: TEX_SIZE, height: TEX_SIZE))
		var symbolSize = NSSize.zero
		
		img.backgroundColor = NSColor.clearColor()
		
		if ( !NH3DGL_USETILE ) {
			guard let symbol = symbol as? String else {
				assert(false)
				return 0
			}
			var attributes = [String: AnyObject]()
			let fontName = NSUserDefaults.standardUserDefaults().stringForKey(NH3DWindowFontKey)!
			
			
			attributes[NSFontAttributeName] = NSFont(name: fontName,
				size: CGFloat(TEX_SIZE))

			attributes[NSForegroundColorAttributeName] = color;
			attributes[NSBackgroundColorAttributeName] = NSColor.clearColor()
			
			symbolSize = (symbol as NSString).sizeWithAttributes(attributes)
			
			// Draw texture
			img.lockFocus()
			
			(symbol as NSString).drawAtPoint(NSPoint(x: CGFloat( TEX_SIZE/2 ) - ( symbolSize.width/2 ), y: CGFloat( TEX_SIZE/2 ) - ( symbolSize.height/2 ) ), withAttributes: attributes)
			
			img.unlockFocus()
		} else {
			guard let symbol = symbol as? NSImage else {
				assert(false)
				return 0
			}
			symbolSize = symbol.size
			
			// Draw Tiled texture
			img.lockFocus()
			symbol.drawInRect(NSMakeRect( CGFloat(TEX_SIZE)/4 ,0 ,(CGFloat(TEX_SIZE)/4)*3 ,(CGFloat(TEX_SIZE)/4)*3),
				fromRect: NSRect(origin: .zero, size: symbolSize),
				operation: .CompositeSourceOver,
				fraction:1.0)
			img.unlockFocus()
		}
		
		//var imgrep: NSBitmapImageRep?
		guard let imgData = img.TIFFRepresentation, imgrep = NSBitmapImageRep(data: imgData) else {
			return 0
		}
		
		glPixelStorei( GLenum(GL_UNPACK_ALIGNMENT), 1)
		
		glGenTextures( 1, &texID );
		glBindTexture( GLenum(GL_TEXTURE_2D), texID)
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_GENERATE_MIPMAP), GL_TRUE)
		glHint(GLenum(GL_PERSPECTIVE_CORRECTION_HINT), GLenum(GL_NICEST))
		
		// create automipmap texture

		if imgrep.alpha {
			glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
				GLsizei(imgrep.pixelsWide), GLsizei(imgrep.pixelsHigh),
				0, GLenum(GL_RGBA),
				GLenum(GL_UNSIGNED_BYTE), imgrep.bitmapData);
		} else {
			glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB,
				GLsizei(imgrep.pixelsWide), GLsizei(imgrep.pixelsHigh),
				0, GLenum(GL_RGB),
				GLenum(GL_UNSIGNED_BYTE), imgrep.bitmapData);

		}
		// setup texture status
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
		
		glAlphaFunc(GLenum(GL_GREATER), 0.5 );

		
		viewLock.unlock()
		
		return texID
	}
	
	private func loadModels() {
	/*
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
*/
	}

	private func setParamsForMagicEffect(magicItem: NH3DModelObjects, color: Int32) {
		magicItem.setPivotX(0, atY: 1.2, atZ: 0)
		magicItem.setModelScaleX(0.4, scaleY: 1.0, scaleZ: 0.4)
		magicItem.particleType = .Aura
		magicItem.particleColor = color
		magicItem.setParticleGravityX(0, y: 6.5, z: 0)
		magicItem.setParticleSpeedX(1, y: 1)
		magicItem.particleSlowdown = 3.8
		magicItem.particleLife = 0.4
		magicItem.setParticleSize(20)
	}
	
	private func setParamsForMagicExplosion(magicItem: NH3DModelObjects, color: Int32) {
		magicItem.particleType = .Aura
		magicItem.particleColor = color
		magicItem.setParticleGravityX(0, y: 15.5, z: 0)
		magicItem.setParticleSpeedX(1, y: 15)
		magicItem.particleSlowdown = 8.8
		magicItem.particleLife = 0.4
		magicItem.setParticleSize(35)
	}
	
	//MARK: - Load model methods. Used as closures
	
	/// insect class
	private func loadModelFunc_insect(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GIANT_ANT, to: PM_QUEEN_BEE, modelName: "lowerA", textured: false)
	}

	/// blob class
	private func loadModelFunc_blob(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_ACID_BLOB, to: PM_GELATINOUS_CUBE, modelName: "lowerB", textured: false)
	}
	
	/// cockatrice class
	private func loadModelFunc_cockatrice(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_CHICKATRICE, to: PM_PYROLISK, modelName: "lowerC", textured: false)
	}
	
	/// dog or canine class
	private func loadModelFunc_dog(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_JACKAL, to: PM_HELL_HOUND, modelName: "lowerD", textured: false)
	}

	/// eye or sphere class
	private func loadModelFunc_sphere(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GAS_SPORE, to: PM_SHOCKING_SPHERE, modelName: "lowerE", textured: false)
	}
	
	/// cat or feline class
	private func loadModelFunc_cat(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_KITTEN, to: PM_TIGER, modelName: "lowerF", textured: false)
	}
	
	/// gremlins and gagoyles class
	private func loadModelFunc_gremlins(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GREMLIN, to: PM_WINGED_GARGOYLE, modelName: "lowerG", textured: false)
	}

	/// humanoids class
	private func loadModelFunc_humanoids(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		if glyph == PM_DWARF_KING+GLYPH_MON_OFF {
			ret = NH3DModelObjects(with3DSFile:"lowerH", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0, atY: 0.2, atZ: -0.21)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
		} else {
			ret = checkLoadedModels(at: PM_GREMLIN, to: PM_WINGED_GARGOYLE, modelName: "lowerH", textured: false, without: PM_DWARF_KING)
		}
		return ret
	}

	/// imp and minor demons
	private func loadModelFunc_imp(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_MANES, to: PM_TENGU, modelName: "lowerI", textured: false)
	}


	/// jellys
	private func loadModelFunc_jellys(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_BLUE_JELLY, to: PM_OCHRE_JELLY, modelName: "lowerJ", textured: false)
	}

	// kobolds
	private func loadModelFunc_kobolds(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		
		switch glyph {
		case PM_KOBOLD+GLYPH_MON_OFF, PM_LARGE_KOBOLD+GLYPH_MON_OFF :
			ret = checkLoadedModels(at: PM_KOBOLD, to: PM_LARGE_KOBOLD, modelName: "lowerK", textured: false)
			
		case PM_KOBOLD_LORD+GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"lowerK", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0, atY: 0.1, atZ: -0.25)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		case PM_KOBOLD_SHAMAN + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"lowerK", withTexture: false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0, atY: -0.01, atZ: -0.15)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		default:
			break;
		}
		
		return ret;
	}
	
	/// leprechaun
	//private func loadModelFunc_leprechaun(glyph: Int32) -> NH3DModelObjects? {
	//	return NH3DModelObjects(with3DSFile: "lowerL", withTexture: false)
	//}
	
	// mimics
	private func loadModelFunc_mimics(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_SMALL_MIMIC, to: PM_GIANT_MIMIC, modelName: "lowerM", textured: false)
	}
	
	/// nymphs
	private func loadModelFunc_nymphs(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_WOOD_NYMPH, to: PM_MOUNTAIN_NYMPH, modelName: "lowerN", textured: false)
	}
	
	/// orc class
	private func loadModelFunc_orc(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		
		if glyph == PM_ORC_SHAMAN + GLYPH_MON_OFF {
			ret = NH3DModelObjects(with3DSFile: "lowerO", withTexture: false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.15, atZ: -0.15)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		} else {
			ret = checkLoadedModels(at: PM_GOBLIN, to: PM_ORC_CAPTAIN, modelName: "lowerO", textured: false, without: PM_ORC_SHAMAN)
		}
		
		return nil
	}
	
	/// piercers
	private final func loadModelFunc_piercers(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_ROCK_PIERCER, to: PM_GLASS_PIERCER, modelName: "lowerP", textured: false)
	}
	
	/// quadrupeds
	private final func loadModelFunc_quadrupeds(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_ROTHE, to: PM_MASTODON, modelName: "lowerQ", textured: false)
	}
	
	/// rodents
	private final func loadModelFunc_rodents(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_SEWER_RAT, to: PM_WOODCHUCK, modelName: "lowerR", textured: false)
	}
	
	/// spiders
	private final func loadModelFunc_spiders(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_CAVE_SPIDER, to: PM_SCORPION, modelName: "lowerS", textured: false)
	}
	
	/// trapper
	private final func loadModelFunc_trapper(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_LURKER_ABOVE, to: PM_TRAPPER, modelName: "lowerT", textured: false)
	}
	
	/// unicorns and horses
	private final func loadModelFunc_unicorns(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_WHITE_UNICORN, to: PM_WARHORSE, modelName: "lowerU", textured: false)
	}
	
	/// vortices
	private final func loadModelFunc_vortices(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_FOG_CLOUD, to: PM_FIRE_VORTEX, modelName: "lowerV", textured: false)
	}
	
	/// worms
	private final func loadModelFunc_worms(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_BABY_LONG_WORM, to: PM_PURPLE_WORM, modelName: "lowerW", textured: false)
	}
	
	/// xan
	private final func loadModelFunc_xan(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GRID_BUG, to: PM_XAN, modelName: "lowerX", textured: false)
	}
	
	/// lights
	private final func loadModelFunc_lights(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_YELLOW_LIGHT, to: PM_BLACK_LIGHT, modelName: "lowerY", textured: false)
	}
	
	/// Angels
	private final func loadModelFunc_Angels(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_COUATL, to: PM_ARCHON, modelName: "upperA", textured: false)
	}
	
	/// Bats
	private final func loadModelFunc_Bats(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_BAT, to: PM_VAMPIRE_BAT, modelName: "upperB", textured: false)
	}
	
	/// Centaurs
	private final func loadModelFunc_Centaurs(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_PLAINS_CENTAUR, to: PM_MOUNTAIN_CENTAUR, modelName: "upperC", textured: false)
	}
	
	/// Dragons
	private final func loadModelFunc_Dragons(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_BABY_GRAY_DRAGON, to: PM_YELLOW_DRAGON, modelName: "upperD", textured: false)
	}
	
	/// Elementals
	private final func loadModelFunc_Elementals(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_STALKER, to: PM_WATER_ELEMENTAL, modelName: "upperE", textured: false)
	}
	
	/// Fungi
	private final func loadModelFunc_Fungi(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_LICHEN, to: PM_VIOLET_FUNGUS, modelName: "upperF", textured: false)
	}

	/// gnomes
	private final func loadModelFunc_Gnomes(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		switch glyph {
		case PM_GNOME+GLYPH_MON_OFF, PM_GNOME_LORD+GLYPH_MON_OFF :
			ret = checkLoadedModels(at:PM_GNOME,
				to:PM_GNOME_LORD,
				modelName:"upperG",
				textured:false);
			
		case PM_GNOMISH_WIZARD + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"upperG", withTexture:false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY:-0.01, atZ:-0.15)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		case PM_GNOME_KING + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"upperG", withTexture:false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.05, atZ: -0.25)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		default:
			break;
		}
		
		return ret;
	}
	
	/// Giant Humanoids
	private final func loadModelFunc_giantHumanoids(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GIANT, to: PM_MINOTAUR, modelName: "upperH", textured: false)
	}
	
	/// Kops
	private final func loadModelFunc_Kops(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_KEYSTONE_KOP, to: PM_KOP_KAPTAIN, modelName: "upperK", textured: false)
	}
	
	/// Liches
	private final func loadModelFunc_Liches(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_LICH, to: PM_ARCH_LICH, modelName: "upperL", textured: false)
	}
	
	/// Mummies
	private final func loadModelFunc_Mummies(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_KOBOLD_MUMMY, to: PM_GIANT_MUMMY, modelName: "upperM", textured: false)
	}
	
	/// Nagas
	private final func loadModelFunc_Nagas(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_RED_NAGA_HATCHLING, to: PM_GUARDIAN_NAGA, modelName: "upperN", textured: false)
	}

	/// Ogres
	private final func loadModelFunc_Ogres(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		switch glyph {
		case PM_OGRE + GLYPH_MON_OFF, PM_OGRE_LORD + GLYPH_MON_OFF:
			ret = checkLoadedModels(at: PM_OGRE, to: PM_OGRE_LORD, modelName: "upperO", textured: false)
			
		case PM_OGRE_KING + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "upperO", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: 0.15, atZ: -0.18)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]

		default:
			break
		}
		return ret
	}

	/// Puddings
	private final func loadModelFunc_Puddings(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GRAY_OOZE, to: PM_GREEN_SLIME, modelName: "upperP", textured: false)
	}
	
	/// Quantum mechanics
	//private final func loadModelFunc_QuantumMechanics(glyph: Int32) -> NH3DModelObjects? {
	//	return NH3DModelObjects(with3DSFile: "upperQ", withTexture: false)
	//}
	
	/// Rust monster or disenchanter
	private final func loadModelFunc_Rustmonster(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_RUST_MONSTER, to: PM_DISENCHANTER, modelName: "upperR", textured: false)
	}

	/// Snakes
	private final func loadModelFunc_Snakes(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GARTER_SNAKE, to: PM_COBRA, modelName: "upperS", textured: false)
	}

	/// Trolls
	private final func loadModelFunc_Trolls(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_TROLL, to: PM_OLOG_HAI, modelName: "upperT", textured: false)
	}

	/// Umber hulk
	//private final func loadModelFunc_Umberhulk(glyph: Int32) -> NH3DModelObjects? {
	//	return NH3DModelObjects(with3DSFile: "upperU", withTexture: false)
	//}

	/// Vampires
	private final func loadModelFunc_Vampires(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		switch glyph {
		case PM_VAMPIRE + GLYPH_MON_OFF, PM_VAMPIRE_LORD + GLYPH_MON_OFF :
			ret = checkLoadedModels(at: PM_VAMPIRE, to: PM_VAMPIRE_LORD, modelName: "upperV", textured: false)
			
		case PM_VLAD_THE_IMPALER + GLYPH_MON_OFF :
			ret =  NH3DModelObjects(with3DSFile: "upperV", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0, atY: 0.15, atZ: -0.18)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		default:
			break
		}
		
		return ret;
	}
	
	/// Wraiths
	private final func loadModelFunc_Wraiths(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_BARROW_WIGHT, to: PM_NAZGUL, modelName: "upperW", textured: false)
	}
	
	/// Xorn
	//private final func loadModelFunc_Xorn(glyph: Int32) -> NH3DModelObjects? {
	//	return NH3DModelObjects(with3DSFile: "upperX", withTexture: false)
	//}

	/// Yeti and other large beasts
	private final func loadModelFunc_Yeti(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_MONKEY, to: PM_SASQUATCH, modelName: "upperY", textured: false)
	}

	/// Zombie
	private final func loadModelFunc_Zombie(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_KOBOLD_ZOMBIE, to: PM_SKELETON, modelName: "upperZ", textured: false)
	}
	
	/// Golems
	private final func loadModelFunc_Golems(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_STRAW_GOLEM, to: PM_IRON_GOLEM, modelName: "backslash", textured: false)
	}
	
	/// Human or Elves
	private final func loadModelFunc_HumanOrElves(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		
		switch glyph {
		case PM_ELVENKING + GLYPH_MON_OFF:
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0, atY: -0.18, atZ: 0)
			ret?.childObjectAtLast?.setModelRotateX(0, rotateY: 11.7, rotateZ: 0)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		case PM_NURSE + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"atmark", withTexture:false)
			ret?.addChildObject("nurse", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0, atY: -0.28, atZ: 1)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			
		case PM_HIGH_PRIEST + GLYPH_MON_OFF, PM_MEDUSA + GLYPH_MON_OFF, PM_CROESUS + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"atmark", withTexture:false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0, y: 2.5, z: 0)
			ret?.childObjectAtLast?.setParticleSpeedX(1, y: 1)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile:"atmark", withTexture:false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY:-0.28, atZ:-0.15)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			ret?.childObjectAtLast?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.childObjectAtLast?.setPivotX(-0.827, atY:1.968, atZ:1.793)
			ret?.childObjectAtLast?.childObjectAtLast?.particleType = .Both
			ret?.childObjectAtLast?.childObjectAtLast?.particleColor = CLR_BRIGHT_MAGENTA
			ret?.childObjectAtLast?.childObjectAtLast?.setParticleGravityX(-3.5, y:1.5, z:0.8)
			ret?.childObjectAtLast?.childObjectAtLast?.setParticleSpeedX(1.5, y:2.00)
			ret?.childObjectAtLast?.childObjectAtLast?.particleSlowdown = 1.8
			ret?.childObjectAtLast?.childObjectAtLast?.particleLife = 0.5
			ret?.childObjectAtLast?.childObjectAtLast?.setParticleSize(6.0)
			
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.setPivotX(0.827, atY:-1.800, atZ:-1.793)
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y:2.5, z:0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y:1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		default:
			ret = checkLoadedModels(at: PM_HUMAN,
				to: PM_WIZARD_OF_YENDOR,
				modelName: "atmark",
				textured: false,
				without: PM_ELVENKING, PM_NURSE, PM_HIGH_PRIEST, PM_MEDUSA,
				PM_CROESUS, PM_WIZARD_OF_YENDOR)
		}
		
		return ret
	}
	
	/// Ghosts
	private final func loadModelFunc_Ghosts(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_GHOST, to: PM_SHADE, offset: GLYPH_INVIS_OFF, modelName: "invisible", textured: false)
	}

	/// Major Daemons
	private final func loadModelFunc_MajorDamons(glyph: Int32) -> NH3DModelObjects? {
		if ( glyph != PM_DJINNI+GLYPH_MON_OFF || glyph != PM_SANDESTIN+GLYPH_MON_OFF ) {
			return checkLoadedModels(at: PM_WATER_DEMON, to: PM_BALROG, modelName: "and", textured: false)
		} else {
			return checkLoadedModels(at: PM_DJINNI, to: PM_SANDESTIN, modelName: "and", textured: false)
		}
	}

	/// Greater Daemons
	private final func loadModelFunc_GraterDamons(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		if glyph == PM_JUIBLEX + GLYPH_MON_OFF {
			ret = NH3DModelObjects(with3DSFile: "and", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura;
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
		} else {
			ret = checkLoadedModels(at: PM_YEENOGHU, to: PM_DEMOGORGON, modelName: "and", textured: false)
			if let ret = ret where !ret.hasChildObject {
				ret.addChildObject("emitter", type: .Emitter)
				ret.childObjectAtLast?.particleType = .Aura
				ret.childObjectAtLast?.particleColor = CLR_RED
				ret.childObjectAtLast?.setParticleGravityX(0.0, y:2.5, z:0.0)
				ret.childObjectAtLast?.setParticleSpeedX(1.0, y:1.00)
				ret.childObjectAtLast?.particleSlowdown = 8.8
				ret.childObjectAtLast?.particleLife = 0.24
				ret.childObjectAtLast?.setParticleSize(8.0)
				ret.addChildObject("kingset", type: .TexturedObject)
				ret.childObjectAtLast?.setPivotX(0.0, atY:0.52, atZ:0.0)
				ret.childObjectAtLast?.setModelRotateX(0.0, rotateY:0.7, rotateZ:0.0)
				ret.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			}
		}
		return ret;
	}
	
	/// daemon "The Riders"
	private final func loadModelFunc_Riders(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		ret = checkLoadedModels(at: PM_DEATH, to: PM_FAMINE, modelName: "and", textured: false)
		
		if let ret = ret where !ret.hasChildObject {
			ret.addChildObject("emitter", type: .Emitter)
			ret.childObjectAtLast?.particleType = .Aura
			ret.childObjectAtLast?.particleColor = CLR_RED
			ret.childObjectAtLast?.setParticleGravityX(0.0, y:2.5, z:0.0)
			ret.childObjectAtLast?.setParticleSpeedX(1.0, y:1.00)
			ret.childObjectAtLast?.particleSlowdown = 8.8
			ret.childObjectAtLast?.particleLife = 0.24
			ret.childObjectAtLast?.setParticleSize(15.0)
			ret.addChildObject("emitter", type: .Emitter)
			ret.childObjectAtLast?.particleType = .Aura
			ret.childObjectAtLast?.particleColor = CLR_BRIGHT_MAGENTA
			ret.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret.childObjectAtLast?.particleSlowdown = 8.8
			ret.childObjectAtLast?.particleLife = 0.24
			ret.childObjectAtLast?.setParticleSize(8.0)
		}
		
		return ret;
	}
	
	/// sea monsters
	private final func loadModelFunc_seamonsters(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_JELLYFISH, to: PM_KRAKEN, modelName: "semicoron", textured: false)
	}
	
	/// lizards
	private final func loadModelFunc_lizards(glyph: Int32) -> NH3DModelObjects? {
		return checkLoadedModels(at: PM_NEWT, to: PM_SALAMANDER, modelName: "coron", textured: false)
	}
	
	/// Adventurers
	private final func loadModelFunc_Adventures(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		if ( glyph == PM_WIZARD + GLYPH_MON_OFF ) {
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.28, atZ: -0.15)
		} else {
			ret = checkLoadedModels(at: PM_ARCHEOLOGIST, to: PM_VALKYRIE, modelName: "atmark", textured: false)
		}
		return ret
	}

	// Unique person
	private final func loadModelFunc_Uniqueperson(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil
		
		switch glyph {
		case PM_KING_ARTHUR + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.18, atZ: 0.0)
			ret?.childObjectAtLast?.setModelRotateX(0.0, rotateY: 11.7, rotateZ: 0.0)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura ;
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_CYAN
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_NEFERET_THE_GREEN + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.28, atZ: -0.15)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_CYAN
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_MINION_OF_HUHETOTL + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "and", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_THOTH_AMON + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_CHROMATIC_DRAGON + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "upperD", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_CYCLOPS + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "upperH", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_IXOTH + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "upperD", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_MASTER_KAEN + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_NALZOK + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "and", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_SCORPIUS + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "lowerS", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_MASTER_ASSASSIN + GLYPH_MON_OFF, PM_ASHIKAGA_TAKAUJI + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y:1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_LORD_SURTUR + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "upperH", withTexture: false)
			ret?.addChildObject("kingset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.18, atZ: 0.0)
			ret?.childObjectAtLast?.setModelRotateX(0.0, rotateY: 11.7, rotateZ: 0.0)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case PM_DARK_ONE + GLYPH_MON_OFF :
			ret = NH3DModelObjects(with3DSFile: "atmark", withTexture: false)
			ret?.addChildObject("wizardset", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: -0.28, atZ: -0.15)
			ret?.childObjectAtLast?.currentMaterial = nh3dMaterialArray[Int(NO_COLOR)]
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_RED
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.24
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		default:
			
			if glyph >= PM_LORD_CARNARVON + GLYPH_MON_OFF && glyph <= PM_NORN + GLYPH_MON_OFF {
				ret = checkLoadedModels(at: PM_LORD_CARNARVON,
					to: PM_NORN,
					modelName:"atmark",
					textured:false,
					without:PM_KING_ARTHUR)
				
				if let ret = ret where !ret.hasChildObject {
					ret.addChildObject("emitter", type: .Emitter)
					ret.childObjectAtLast?.particleType = .Aura
					ret.childObjectAtLast?.particleColor = CLR_BRIGHT_CYAN
					ret.childObjectAtLast?.setParticleGravityX(0.0, y: 2.5, z: 0.0)
					ret.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
					ret.childObjectAtLast?.particleSlowdown = 8.8
					ret.childObjectAtLast?.particleLife = 0.24
					ret.childObjectAtLast?.setParticleSize(8.0)
				}
			} else {
				
				ret = checkLoadedModels(at:PM_STUDENT,
					to:PM_APPRENTICE,
					modelName:"atmark",
					textured:false)
			}
		}
		
		return ret;
		
	}

	// MARK: - Map Symbol Section

	///  Map Symbols
	private final func loadModelFunc_MapSymbols(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case S_bars + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "ironbar", withTexture: true)
			
		case S_tree + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "tree", withTexture: true)
			ret?.setModelScaleX(2.5, scaleY: 1.7, scaleZ: 2.5)
			
		case S_upstair + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "upStair", withTexture: true)
			
		case S_dnstair + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "downStair", withTexture: true)
			
		case S_upladder + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "upladder", withTexture: true)
			
		case S_dnladder + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "downladder", withTexture: true)
			
		case S_altar + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "alter", withTexture: true)
			
		case S_grave + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "grave", withTexture: true)
			ret?.setModelScaleX(0.6, scaleY:0.6, scaleZ:0.6)
			
		case S_throne + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "opulent_throne", withTexture: true)
			
		case S_sink + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "sink", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: 1.277, atZ: -0.812)
			ret?.childObjectAtLast?.particleType = .Points
			ret?.childObjectAtLast?.particleColor = CLR_CYAN
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y:-8.8, z:1.0)
			ret?.childObjectAtLast?.particleLife = 0.21
			ret?.childObjectAtLast?.setParticleSize(8.0)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(0.0, atY:-0.687, atZ:0.512)
			ret?.childObjectAtLast?.particleType = .Points
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_CYAN
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y:-5.8, z:1.0)
			ret?.childObjectAtLast?.particleLife = 0.3
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case S_fountain + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "fountain", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(-0.34, atY:2.68, atZ:0.65)
			ret?.childObjectAtLast?.setParticleGravityX(0, y: 0.1, z: 0.08)
			ret?.childObjectAtLast?.particleType = .Both ;
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_BLUE
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: -130.0)
			ret?.childObjectAtLast?.particleSlowdown = 4.2
			ret?.childObjectAtLast?.particleLife = 0.8
			ret?.childObjectAtLast?.setParticleSize(8.0)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(0.34, atY: -1.70, atZ: -0.65)
			ret?.childObjectAtLast?.setModelScaleX(0.98, scaleY:0.7, scaleZ:0.98)
			ret?.childObjectAtLast?.setParticleGravityX(0, y: 0.1, z: 0.00)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_BLUE
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: -130.0)
			ret?.childObjectAtLast?.particleSlowdown = 4.2
			ret?.childObjectAtLast?.particleLife = 0.28
			ret?.childObjectAtLast?.setParticleSize(8.0)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setModelScaleX(0.5, scaleY: 0.7, scaleZ: 0.5)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: 1.35, atZ: -0.0)
			ret?.childObjectAtLast?.setParticleGravityX(0, y: 0.4, z: 0.00)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_BLUE
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: -190.0)
			ret?.childObjectAtLast?.particleSlowdown = 4.2
			ret?.childObjectAtLast?.particleLife = 1.2
			ret?.childObjectAtLast?.setParticleSize(8.0)
			
		case S_vodbridge + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "bridgeUP", withTexture: true)
			ret?.setModelRotateX(0, rotateY: -90, rotateZ: 0)
			ret?.addChildObject("bridge_opt", type: .TexturedObject)
			
		case S_hodbridge + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "bridge", withTexture: true)
			ret?.addChildObject("bridge_opt", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(4.0, atY:0.0, atZ:0.0)
			
		case S_vcdbridge + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "bridgeUP", withTexture: true)
			ret?.addChildObject("bridge_opt", type: .TexturedObject)
			
		case S_hcdbridge + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects(with3DSFile: "bridge", withTexture: true)
			ret?.setModelRotateX(0, rotateY: -90, rotateZ: 0)
			ret?.addChildObject("bridge_opt", type: .TexturedObject)
			ret?.childObjectAtLast?.setPivotX(4.0, atY:0.0, atZ:0.0)
			
		default:
			break;
		}
		
		return ret
	}

	/// Trap Symbols
	private final func loadModelFunc_TrapSymbol(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case S_arrow_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "arrowtrap", withTexture: true)
			
		case S_dart_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "dartstrap", withTexture: true)
			
		case S_falling_rock_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "rockfalltrap", withTexture: true)
			
			//case S_squeaky_board + GLYPH_CMAP_OFF :
		case S_land_mine + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "landmine", withTexture: true)
			
			//case S_rolling_boulder_trap + GLYPH_CMAP_OFF :
		case S_sleeping_gas_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "gastrap", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: 0.5, atZ:0.0)
			ret?.childObjectAtLast?.particleType = .Both
			ret?.childObjectAtLast?.setParticleGravityX(0, y: -4.0, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_MAGENTA
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: 300)
			ret?.childObjectAtLast?.particleSlowdown = 5.2
			ret?.childObjectAtLast?.particleLife = 0.56
			ret?.childObjectAtLast?.setParticleSize(5.0)
			
		case S_rust_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "gastrap", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: 0.5, atZ: 0.0)
			ret?.childObjectAtLast?.particleType = .Both
			ret?.childObjectAtLast?.setParticleGravityX(0, y: -4.0, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_GREEN
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: 300.0)
			ret?.childObjectAtLast?.particleSlowdown = 5.2
			ret?.childObjectAtLast?.particleLife = 0.56
			ret?.childObjectAtLast?.setParticleSize(5.0)
			
		case S_fire_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "gastrap", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(0.0, atY: 0.5, atZ: 0.0)
			ret?.childObjectAtLast?.particleType = .Both
			ret?.childObjectAtLast?.setParticleSize(4.0)
			ret?.childObjectAtLast?.setParticleGravityX(0, y: -1.0, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_ORANGE
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: 200)
			ret?.childObjectAtLast?.particleSlowdown = 2.0
			ret?.childObjectAtLast?.particleLife = 0.5
			
		case S_bear_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "beartrap", withTexture: true)
			
		case S_pit + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "pit", withTexture: true)
			
		case S_spiked_pit + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "spikepit", withTexture: true)
			
		case S_hole + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "pit", withTexture: true)
			
		case S_trap_door + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "pit", withTexture: true)
			
		case S_teleportation_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "telporter", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(-0.38, atY: 3.82, atZ: 0.75917)
			ret?.childObjectAtLast?.setModelScaleX(0.55, scaleY: 0.8, scaleZ: 0.55)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.setParticleGravityX(0, y: -4.8, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_CYAN
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y:0.1)
			ret?.childObjectAtLast?.particleSlowdown = 1.8
			ret?.childObjectAtLast?.particleLife = 0.23
			ret?.childObjectAtLast?.isChild = false
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(-0.38, atY: 0.42, atZ: 0.75917)
			ret?.childObjectAtLast?.setModelScaleX(0.55, scaleY: 0.8, scaleZ: 0.55)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.setParticleGravityX(0, y: 4.8, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_CYAN
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: 0.1)
			ret?.childObjectAtLast?.particleSlowdown = 1.8
			ret?.childObjectAtLast?.particleLife = 0.25
			
		case S_level_teleporter + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "leveltelporter", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(-0.38, atY: 3.82, atZ: 0.75917)
			ret?.childObjectAtLast?.setModelScaleX(0.55, scaleY:0.8, scaleZ:0.55)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.setParticleGravityX(0, y: -4.8, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_MAGENTA
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y:0.1)
			ret?.childObjectAtLast?.particleSlowdown = 1.8
			ret?.childObjectAtLast?.particleLife = 0.23
			ret?.childObjectAtLast?.isChild = false
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setPivotX(-0.38, atY: 0.42, atZ: 0.75917)
			ret?.childObjectAtLast?.setModelScaleX(0.55, scaleY: 0.8, scaleZ: 0.55)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.setParticleGravityX(0, y: 4.8, z: 0)
			ret?.childObjectAtLast?.particleColor = CLR_MAGENTA
			ret?.childObjectAtLast?.setParticleSpeedX(0.0, y: 0.1)
			ret?.childObjectAtLast?.particleSlowdown = 1.8
			ret?.childObjectAtLast?.particleLife = 0.25
			
		case S_magic_portal + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects(with3DSFile: "magicportal", withTexture: true)
			ret?.addChildObject("emitter", type: .Emitter)
			ret?.childObjectAtLast?.setModelScaleX(0.8, scaleY:0.7, scaleZ:0.8)
			ret?.childObjectAtLast?.particleType = .Aura
			ret?.childObjectAtLast?.particleColor = CLR_BRIGHT_BLUE
			ret?.childObjectAtLast?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.childObjectAtLast?.setParticleSpeedX(1.0, y: 1.00)
			ret?.childObjectAtLast?.particleSlowdown = 8.8
			ret?.childObjectAtLast?.particleLife = 0.4
			ret?.childObjectAtLast?.setParticleSize(2.0)
			
			//case S_web + GLYPH_CMAP_OFF :
			//case S_statue_trap + GLYPH_CMAP_OFF :
			
		case S_magic_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects()
			ret?.setModelScaleX(0.7, scaleY: 0.4, scaleZ: 0.7)
			ret?.particleType = .Aura
			ret?.particleColor = CLR_MAGENTA
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 8.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(10.0)
			
		case S_anti_magic_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects()
			ret?.setModelScaleX(0.7, scaleY: 0.4, scaleZ: 0.7)
			ret?.particleType = .Aura
			ret?.particleColor = CLR_CYAN
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 8.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(10.0)
			
		case S_polymorph_trap + GLYPH_CMAP_OFF :
			ret = NH3DModelObjects()
			ret?.setModelScaleX(0.7, scaleY: 0.4, scaleZ: 0.7)
			ret?.particleType = .Aura
			ret?.particleColor = CLR_BROWN
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 8.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(10.0)
			
		default:
			break;
		}
		
		return ret
	}
	

// MARK: - Effect Symbols Section.

// ZAP symbols ( NUM_ZAP * four directions )


	/// type Magic Missile
	private final func loadModelFunc_MagicMissile(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 0.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_WHITE)
				//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(0.0, rotateY: 0.0, rotateZ: -90.0)
				setParamsForMagicEffect(ret, color: CLR_WHITE)
				//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: -45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_WHITE)
				//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_WHITE)
				//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		default:
			break
		}
		
		return ret;
	}


	// type Magic FIRE
	private final func loadModelFunc_MagicFIRE(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 0.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_ORANGE)
			}
			
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(0.0, rotateY: 0.0, rotateZ: -90.0)
				setParamsForMagicEffect(ret, color: CLR_ORANGE)
			}
			
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: -45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_ORANGE)
			}
			
		case NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_ORANGE)
			}
			
		default:
			break
		}
		
		return ret;
	}

	/// type Magic COLD
	private final func loadModelFunc_MagicCOLD(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 0.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_CYAN)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(0.0, rotateY: 0.0, rotateZ: -90.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_CYAN)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: -45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_CYAN)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_CYAN)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		default:
			break
		}
		
		return ret;
	}

	/// type Magic SLEEP
	private final func loadModelFunc_MagicSLEEP(glyph: Int32) -> NH3DModelObjects? {
		let ret = NH3DModelObjects()
		ret.setPivotX(0.0, atY:1.2, atZ:0.0)
		ret.setModelScaleX(1.0, scaleY:1.0, scaleZ:1.0)
		ret.particleType = .Aura
		ret.particleColor = CLR_MAGENTA
		//[ ret setParticleColor:CLR_BRIGHT_BLUE ]; // if you want sync to 'zapcolors' from decl.c
		ret.setParticleGravityX(0.0, y: 2.5, z: 0.0)
		ret.setParticleSpeedX(1.0, y: 1.00)
		ret.particleSlowdown = 3.8
		ret.particleLife = 0.4
		ret.setParticleSize(20.0)
		
		return ret;
	}

	/// type Magic DEATH
	private final func loadModelFunc_MagicDEATH(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 0.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_GRAY)
				// :CLR_BLACK ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(0.0, rotateY: 0.0, rotateZ: -90.0)
				setParamsForMagicEffect(ret, color: CLR_GRAY)
				// :CLR_BLACK ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: -45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_GRAY)
				// :CLR_BLACK ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_GRAY)
				// :CLR_BLACK ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		default:
			break
		}
		
		return ret;
	}

	// type Magic LIGHTNING
	private final func loadModelFunc_MagicLIGHTNING(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 0.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_YELLOW)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(0.0, rotateY: 0.0, rotateZ: -90.0)
				setParamsForMagicEffect(ret, color: CLR_YELLOW)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: -45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_YELLOW)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_YELLOW)
				// :CLR_WHITE ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		default:
			break
		}
		ret?.setModelScaleX(0.2, scaleY: 1.0, scaleZ: 0.2)
		
		return ret;
	}

	/// type Magic POISONGAS
	private final func loadModelFunc_MagicPOISONGAS(glyph: Int32) -> NH3DModelObjects? {
		let ret = NH3DModelObjects()
		ret.setPivotX(0.0, atY: 1.2, atZ: 0.0)
		ret.setModelScaleX(1.0, scaleY: 1.0, scaleZ:1.0)
		ret.particleType = .Aura
		ret.particleColor = CLR_GREEN
		//[ ret setParticleColor:CLR_YELLOW ]; // if you want sync to 'zapcolors' from decl.c
		ret.setParticleGravityX(0.0, y: 2.5, z: 0.0)
		ret.setParticleSpeedX(1.0, y: 1.00)
		ret.particleSlowdown = 3.8
		ret.particleLife = 0.4
		ret.setParticleSize(20.0)
		
		return ret;
	}


	/// type Magic ACID
	private final func loadModelFunc_MagicACID(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 0.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_GREEN)
				// :CLR_GREEN ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(0.0, rotateY: 0.0, rotateZ: -90.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_GREEN)
				// :CLR_GREEN ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: -45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_GREEN)
				// :CLR_GREEN ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		case NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT:
			ret = NH3DModelObjects()
			if let ret = ret {
				ret.setModelRotateX(-90.0, rotateY: 45.0, rotateZ: 0.0)
				setParamsForMagicEffect(ret, color: CLR_BRIGHT_GREEN)
				// :CLR_GREEN ]; // if you want sync to 'zapcolors' from decl.c
			}
			
		default:
			break
		}
		
		return ret;
	}

	private final func loadModelFunc_MagicETC(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
			// dig beam
		case S_digbeam + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects()
			ret?.setModelScaleX(0.7, scaleY:1.0, scaleZ:0.7)
			ret?.particleType = .Aura
			ret?.particleColor = CLR_BROWN
			ret?.setParticleGravityX(0.0, y:6.5, z:0.0)
			ret?.setParticleSpeedX(1.0, y:1.00)
			ret?.particleSlowdown = 3.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(20.0)
			
			// camera flash
		case S_flashbeam + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects()
			ret?.particleType = .Aura
			ret?.particleColor = CLR_WHITE
			ret?.setParticleGravityX(0.0, y:6.5, z:0.0)
			ret?.setParticleSpeedX(1.0, y:1.00)
			ret?.particleSlowdown = 3.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(20.0)
			
			// boomerang
			//case S_boomleft + GLYPH_CMAP_OFF :
			//case S_boomright + GLYPH_CMAP_OFF :
		default:
			break
		}
		
		return ret;
	}

	// magic shild
	private final func loadModelFunc_MagicSHILD(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		
		switch glyph {
		case S_ss1 + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects()
			ret?.particleType = .Aura
			ret?.particleColor = CLR_BRIGHT_BLUE
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 3.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(20.0)
			break;
			
		case S_ss2 + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects()
			ret?.particleType = .Aura
			ret?.particleColor = CLR_BRIGHT_CYAN
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 8.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(10.0)
			break;
			
		case S_ss3 + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects()
			ret?.particleType = .Aura
			ret?.particleColor = CLR_WHITE
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 3.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(20.0)
			break;
			
		case S_ss4 + GLYPH_CMAP_OFF:
			ret = NH3DModelObjects()
			ret?.particleType = .Aura
			ret?.particleColor = CLR_BLUE
			ret?.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret?.setParticleSpeedX(1.0, y: 1.00)
			ret?.particleSlowdown = 8.8
			ret?.particleLife = 0.4
			ret?.setParticleSize(10.0)
			break
			
		default:
			break
		}
		
		return ret;
	}
	
	// MARK: explotion symbols ( 9 postion * 7 types )
	
	/// type DARK
	private final func loadModelFunc_explotionDARK(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_DARK,
			to: NH3D_EXPLODE_DARK + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_GRAY)
		}
		
		return ret;
	}
	
	/// type NOXIOUS
	private final func loadModelFunc_explotionNOXIOUS(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_NOXIOUS,
			to: NH3D_EXPLODE_NOXIOUS + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_GREEN)
		}
		
		return ret;
	}
	
	/// type MUDDY
	private final func loadModelFunc_explotionMUDDY(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_MUDDY,
			to: NH3D_EXPLODE_MUDDY + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_BROWN)
		}
		
		return ret;
	}
	
	/// type WET
	private final func loadModelFunc_explotionWET(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_WET,
			to: NH3D_EXPLODE_WET + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_BLUE)
		}
			
		return ret;
	}
	
	/// type MAGICAL
	private final func loadModelFunc_explotionMAGICAL(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_MAGICAL,
			to: NH3D_EXPLODE_MAGICAL + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_BRIGHT_MAGENTA)
		}
		
		return ret;
	}
	
	/// type FIERY
	private final func loadModelFunc_explotionFIERY(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_FIERY,
			to: NH3D_EXPLODE_FIERY + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_ORANGE)
		}
		
		return ret;
	}
	
	//  type FROSTY
	private final func loadModelFunc_explotionFROSTY(glyph: Int32) -> NH3DModelObjects? {
		var ret: NH3DModelObjects? = nil;
		ret = checkLoadedModels(at: NH3D_EXPLODE_FROSTY,
			to: NH3D_EXPLODE_FROSTY + MAXEXPCHARS,
			offset: 0,
			modelName: "emitter",
			textured: false)
		if let ret = ret {
			setParamsForMagicExplosion(ret, color: CLR_BRIGHT_CYAN)
		}
		
		return ret;
	}

/*
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
*/
	
	/// wait for vSync...
	@IBAction func drawAllFrameFunction(sender: AnyObject) {
		viewLock.lock()
		nowUpdating = true
		
		do {
			let hi: Int = sender.state
			NSUserDefaults.standardUserDefaults().setBool(hi != NSOnState, forKey: NH3DOpenGLWaitSyncKey)
			NSUserDefaultsController.sharedUserDefaultsController().values.setValue(hi != NSOnState, forKey:NH3DOpenGLWaitSyncKey)
		}
		
		nowUpdating = false
		viewLock.unlock()
		
		var vsType: GLint
		if OPENGLVIEW_WAITSYNC {
			vsType = vsincWait
		} else {
			vsType = vsincNoWait
		}
		openGLContext?.setValues(&vsType, forParameter: NSOpenGLContextParameter.GLCPSwapInterval)
	}
	
	@IBAction func useAntiAlias(sender: NSMenuItem) {
		viewLock.lock()
		nowUpdating = true
		if sender.state == NSOffState {
			turnOnSmooth()
			sender.state = NSOnState
		} else {
			turnOffSmooth()
			sender.state = NSOffState
		}
		nowUpdating = false
		viewLock.unlock()
	}
	
	@IBAction func changeWaitRate(sender: NSMenuItem) {
		let curCfg = CGDisplayCopyDisplayMode(CGMainDisplayID())
		dRefreshRate = CGDisplayModeGetRefreshRate(curCfg)
		
		viewLock.lock()
		nowUpdating = true
		oglParamNowChanging = true
		switch sender.tag {
		case 1003 : // no wait
			waitRate = dRefreshRate;
			sender.state = NSOnState
			NSUserDefaults.standardUserDefaults().setBool(false, forKey:NH3DOpenGLUseWaitRateKey)
			NSUserDefaultsController.sharedUserDefaultsController().values.setValue( (false as NSNumber),
				forKey: NH3DOpenGLUseWaitRateKey)
			
			sender.menu?.itemWithTag(1004)?.state = NSOffState
			sender.menu?.itemWithTag(1005)?.state = NSOffState
			sender.menu?.itemWithTag(1006)?.state = NSOffState
			
		case 1004 :
			waitRate = WAIT_FAST;
			sender.state = NSOnState
			NSUserDefaults.standardUserDefaults().setBool(false, forKey:NH3DOpenGLUseWaitRateKey)
			NSUserDefaultsController.sharedUserDefaultsController().values.setValue( (true as NSNumber),
				forKey: NH3DOpenGLUseWaitRateKey)
			
			sender.menu?.itemWithTag(1003)?.state = NSOffState
			sender.menu?.itemWithTag(1005)?.state = NSOffState
			sender.menu?.itemWithTag(1006)?.state = NSOffState
			
		case 1005 :
			waitRate = WAIT_NORMAL;
			sender.state = NSOnState
			NSUserDefaults.standardUserDefaults().setBool(false, forKey:NH3DOpenGLUseWaitRateKey)
			NSUserDefaultsController.sharedUserDefaultsController().values.setValue( (true as NSNumber),
				forKey: NH3DOpenGLUseWaitRateKey)
			
			sender.menu?.itemWithTag(1003)?.state = NSOffState
			sender.menu?.itemWithTag(1004)?.state = NSOffState
			sender.menu?.itemWithTag(1006)?.state = NSOffState
			
		case 1006 :
			waitRate = WAIT_SLOW;
			sender.state = NSOnState
			NSUserDefaults.standardUserDefaults().setBool(false, forKey:NH3DOpenGLUseWaitRateKey)
			NSUserDefaultsController.sharedUserDefaultsController().values.setValue( (true as NSNumber),
				forKey: NH3DOpenGLUseWaitRateKey)
			
			sender.menu?.itemWithTag(1003)?.state = NSOffState
			sender.menu?.itemWithTag(1004)?.state = NSOffState
			sender.menu?.itemWithTag(1005)?.state = NSOffState
			
		default:
			break
		}
		
		cameraStep = Float(waitRate / 8.5)
		
		nowUpdating = false;
		oglParamNowChanging = false;
		viewLock.unlock()
		
		NSUserDefaults.standardUserDefaults().setDouble(waitRate, forKey:NH3DOpenGLWaitRateKey)
		NSUserDefaultsController.sharedUserDefaultsController().values.setValue((waitRate as NSNumber),
			forKey: NH3DOpenGLWaitRateKey)
	}
	
	@objc private func defaultsDidChange(notification: NSNotification?) {
		guard !oglParamNowChanging else {
			return
		}
		
		if TRADITIONAL_MAP && !firstTime {
			mapModel.playerDirection = PL_DIRECTION_FORWARD
			//[ self clearGLContext ];
			openGLContext?.clearDrawable()
			hidden = true
			//[ [self openGLContext] setView:nil ];
			threadRunning = false
			//[ self update ];
		}
		if !TRADITIONAL_MAP && !firstTime {
			hidden = false
			openGLContext?.view = self
			if !threadRunning {
				detachOpenGLThread()
			}
		}
		
		viewLock.lock()
		
		let oglFrameRateMenu = self.menu?.itemWithTag(1000)?.submenu?.itemWithTag(1002)?.submenu
		
		nowUpdating = true
		hasWait = OPENGLVIEW_USEWAIT
		
		if !hasWait {
			let curCfg = CGDisplayCopyDisplayMode(CGMainDisplayID())
			dRefreshRate = CGDisplayModeGetRefreshRate(curCfg)
			waitRate = dRefreshRate;
			oglFrameRateMenu?.itemWithTag(1004)?.state = NSOffState
			oglFrameRateMenu?.itemWithTag(1005)?.state = NSOffState
			oglFrameRateMenu?.itemWithTag(1006)?.state = NSOffState
		} else if OPENGLVIEW_WAITRATE == WAIT_FAST {
			waitRate = WAIT_FAST
			oglFrameRateMenu?.itemWithTag(1004)?.state = NSOnState
			oglFrameRateMenu?.itemWithTag(1005)?.state = NSOffState
			oglFrameRateMenu?.itemWithTag(1006)?.state = NSOffState
		} else if OPENGLVIEW_WAITRATE == WAIT_NORMAL {
			waitRate = WAIT_NORMAL
			oglFrameRateMenu?.itemWithTag(1004)?.state = NSOffState
			oglFrameRateMenu?.itemWithTag(1005)?.state = NSOnState
			oglFrameRateMenu?.itemWithTag(1006)?.state = NSOffState
		} else {
			waitRate = WAIT_SLOW
			oglFrameRateMenu?.itemWithTag(1004)?.state = NSOffState
			oglFrameRateMenu?.itemWithTag(1005)?.state = NSOffState
			oglFrameRateMenu?.itemWithTag(1006)?.state = NSOnState
		}
		
		cameraStep = Float(waitRate / 8.5)
		
		do {
			var vsType: GLint
			if OPENGLVIEW_WAITSYNC {
				vsType = vsincWait
			} else {
				vsType = vsincNoWait
			}
			openGLContext?.setValues(&vsType, forParameter: NSOpenGLContextParameter.GLCPSwapInterval)
		}
		
		if useTile != NH3DGL_USETILE {
			for i in 0..<Int(MAX_GLYPH) {
				var texid = defaultTex[i]
				glDeleteTextures(1, &texid)
				defaultTex[i] = 0
			}
			useTile = NH3DGL_USETILE;
		}
		
		nowUpdating = false
		viewLock.unlock()
	}
	
	/// cache func address
	private func cacheMethods() {
		do {
			func blankSwitchMethod(x: Int32, z: Int32, lx: Int32, lz: Int32) {}
			func blankFloorMethod() {}
			
			switchMethodArray = [SwitchMethod](count: 11, repeatedValue: blankSwitchMethod)
			drawFloorArray = [DrawFloorFunc](count: 11, repeatedValue: blankFloorMethod)
		}
		
		switchMethodArray[0] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawNullObject(x: Float(x)*NH3DGL_TILE_SIZE, z: Float(z)*NH3DGL_TILE_SIZE, tex: self.nullTex)
		}
		switchMethodArray[1] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 2);
		}
		switchMethodArray[2] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling( x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 1);
			
			self.drawModelArray(self.mapItemValue[Int(lx)][Int(lz)]!)
		}
		switchMethodArray[3] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 2);
			self.drawModelArray(self.mapItemValue[Int(lx)][Int(lz)]!)
		}
		switchMethodArray[4] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 3);
		}
		switchMethodArray[5] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 4);
		}
		switchMethodArray[6] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 5);
		}
		switchMethodArray[7] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 6);
		}
		switchMethodArray[8] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 7);
		}
		switchMethodArray[9] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 8);
		}
		switchMethodArray[10] = {[unowned self] (x: Int32, z: Int32, lx: Int32, lz: Int32) -> Void in
			self.drawFloorAndCeiling(x: Float(x)*NH3DGL_TILE_SIZE,
				z: Float(z)*NH3DGL_TILE_SIZE,
				flag: 2);
			self.drawModelArray(self.mapItemValue[Int(lx)][Int(lz)]!)
		}
		
		drawFloorArray[0] = { [unowned self] in
			glActiveTexture( GLenum(GL_TEXTURE0) );
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.floorCurrent );
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer(GLenum(GL_FLOAT), 0 ,FloorVertNorms );
			glTexCoordPointer( 2, GLenum(GL_FLOAT),0, FloorTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , FloorVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		drawFloorArray[1] = {[unowned self] in
			glActiveTexture( GLenum(GL_TEXTURE0) );
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.cellingCurrent );
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE);
			
			glNormalPointer(GLenum(GL_FLOAT), 0 , CeilingVertNorms );
			glTexCoordPointer(2, GLenum(GL_FLOAT),0, CeilingTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , CeilingVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		drawFloorArray[2] = { [unowned self] in
			glActiveTexture( GLenum(GL_TEXTURE0) );
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.floorCurrent);
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE);
			
			glNormalPointer(GLenum(GL_FLOAT), 0 ,FloorVertNorms );
			glTexCoordPointer( 2, GLenum(GL_FLOAT),0, FloorTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , FloorVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.cellingCurrent);
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE);
			
			glNormalPointer(GLenum(GL_FLOAT), 0 , CeilingVertNorms );
			glTexCoordPointer( 2, GLenum(GL_FLOAT),0, CeilingTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , CeilingVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		//Draw pool
		drawFloorArray[3] = { [unowned self] in
			glActiveTexture( GLenum(GL_TEXTURE0) );
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glAlphaFunc( GLenum(GL_GREATER), 0.5 );
			glBindTexture( GLenum(GL_TEXTURE_2D), self.poolTex);
			glTexEnvf(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GLfloat(GL_MODULATE))
			
			glActiveTexture(GLenum(GL_TEXTURE1));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.envelopTex );
			
			glEnable(GLenum(GL_TEXTURE_2D));
			glEnable(GLenum(GL_TEXTURE_GEN_S));
			glEnable(GLenum(GL_TEXTURE_GEN_T));
			
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_COMBINE)
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_COMBINE_RGB), GL_INTERPOLATE)
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_SOURCE2_RGB), GL_PREVIOUS)
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_OPERAND2_RGB), GL_ONE_MINUS_SRC_ALPHA)
			
			
			glTexGeni(GLenum(GL_S), GLenum(GL_TEXTURE_GEN_MODE), GL_SPHERE_MAP)
			glTexGeni(GLenum(GL_T), GLenum(GL_TEXTURE_GEN_MODE), GL_SPHERE_MAP)
			
			glNormalPointer(GLenum(GL_FLOAT), 0 ,FloorVertNorms)
			glTexCoordPointer( 2, GLenum(GL_FLOAT), 0, FloorTexVerts)
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , FloorVerts)
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_GEN_S));
			glDisable(GLenum(GL_TEXTURE_GEN_T));
			glDisable(GLenum(GL_TEXTURE_2D));
			
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_SOURCE2_RGB), GL_CONSTANT)
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_OPERAND2_RGB), GL_SRC_ALPHA)
			
			glActiveTexture(GLenum(GL_TEXTURE0))
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.cellingCurrent );
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer(GLenum(GL_FLOAT), 0, CeilingVertNorms)
			glTexCoordPointer(2, GLenum(GL_FLOAT), 0, CeilingTexVerts)
			glVertexPointer(3, GLenum(GL_FLOAT), 0, CeilingVerts)
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_2D))
		}
		//Draw ice
		drawFloorArray[4] = { [unowned self] in
			glActiveTexture(GLenum(GL_TEXTURE0))
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.floorCurrent );
			
			glMaterialf(GLenum(GL_FRONT), GLenum(GL_EMISSION), 10.0)
			
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glActiveTexture(GLenum(GL_TEXTURE1));
			
			glBindTexture(GLenum(GL_TEXTURE_2D), self.envelopTex)
			
			glEnable(GLenum(GL_TEXTURE_2D))
			glEnable(GLenum(GL_TEXTURE_GEN_S))
			glEnable(GLenum(GL_TEXTURE_GEN_T))
			
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_ADD)
			
			glTexGeni(GLenum(GL_S), GLenum(GL_TEXTURE_GEN_MODE), GL_SPHERE_MAP)
			glTexGeni(GLenum(GL_T), GLenum(GL_TEXTURE_GEN_MODE), GL_SPHERE_MAP)
			
			
			glNormalPointer(GLenum(GL_FLOAT), 0, FloorVertNorms)
			glTexCoordPointer(2, GLenum(GL_FLOAT),0, FloorTexVerts)
			glVertexPointer(3, GLenum(GL_FLOAT), 0, FloorVerts)
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_GEN_S));
			glDisable(GLenum(GL_TEXTURE_GEN_T));
			glDisable(GLenum(GL_TEXTURE_2D));
			
			glActiveTexture(GLenum(GL_TEXTURE0))
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.cellingCurrent );
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer(GLenum(GL_FLOAT), 0, CeilingVertNorms)
			glTexCoordPointer(2, GLenum(GL_FLOAT), 0, CeilingTexVerts)
			glVertexPointer(3, GLenum(GL_FLOAT), 0, CeilingVerts)
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_2D))
		}
		//Draw lava
		drawFloorArray[5] = { [unowned self] in
			glActiveTexture(GLenum(GL_TEXTURE0))
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture(GLenum(GL_TEXTURE_2D), self.lavaTex)
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			let emisson:[ GLfloat ] = [ 1.0, 1.0, 1.0, 1.0 ];
			glMaterialfv( GLenum(GL_FRONT), GLenum(GL_EMISSION), emisson)
			
			glNormalPointer(GLenum(GL_FLOAT), 0, FloorVertNorms);
			glTexCoordPointer( 2, GLenum(GL_FLOAT),0, FloorTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , FloorVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.cellingCurrent );
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer(GLenum(GL_FLOAT), 0, CeilingVertNorms)
			glTexCoordPointer(2, GLenum(GL_FLOAT), 0, CeilingTexVerts)
			glVertexPointer(3, GLenum(GL_FLOAT), 0, CeilingVerts)
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		//draw air
		drawFloorArray[6] = { [unowned self] in
			glActiveTexture(GLenum(GL_TEXTURE0));
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.airTex );
			glTexEnvi( GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer( GLenum(GL_FLOAT), 0 ,FloorVertNorms );
			glTexCoordPointer(2, GLenum(GL_FLOAT),0, FloorTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , FloorVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		//draw cloud
		drawFloorArray[7] = { [unowned self] in
			glActiveTexture(GLenum(GL_TEXTURE0));
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture(GLenum(GL_TEXTURE_2D), self.cloudTex)
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer(GLenum(GL_FLOAT), 0 ,FloorVertNorms );
			glTexCoordPointer( 2, GLenum(GL_FLOAT),0, FloorTexVerts );
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0 , FloorVerts );
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0 , 4 );
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		//draw water
		drawFloorArray[8] = { [unowned self] in
			glActiveTexture(GLenum(GL_TEXTURE0));
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.waterTex );
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glActiveTexture(GLenum(GL_TEXTURE1));
			glEnable(GLenum(GL_TEXTURE_2D));
			
			glBindTexture(GLenum(GL_TEXTURE_2D), self.envelopTex)
			
			glEnable(GLenum(GL_TEXTURE_GEN_S));
			glEnable(GLenum(GL_TEXTURE_GEN_T));
			
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_COMBINE)
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_COMBINE_RGB), GL_INTERPOLATE)
			
			let blend: [GLfloat] = [ 1.0, 1.0, 1.0, 0.18 ]
			glTexEnvfv(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_COLOR), blend)
			
			glTexGeni(GLenum(GL_S), GLenum(GL_TEXTURE_GEN_MODE), GL_SPHERE_MAP)
			glTexGeni(GLenum(GL_T), GLenum(GL_TEXTURE_GEN_MODE), GL_SPHERE_MAP)
			
			
			glNormalPointer(GLenum(GL_FLOAT), 0, FloorVertNorms);
			glTexCoordPointer(2, GLenum(GL_FLOAT), 0, FloorTexVerts);
			glVertexPointer( 3 , GLenum(GL_FLOAT), 0, FloorVerts);
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_GEN_S));
			glDisable(GLenum(GL_TEXTURE_GEN_T));
			glDisable(GLenum(GL_TEXTURE_2D));
			
			glActiveTexture(GLenum(GL_TEXTURE0));
			
			glBindTexture( GLenum(GL_TEXTURE_2D), self.cellingCurrent );
			glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_MODULATE)
			
			glNormalPointer(GLenum(GL_FLOAT), 0 , CeilingVertNorms)
			glTexCoordPointer(2, GLenum(GL_FLOAT), 0, CeilingTexVerts)
			glVertexPointer(3, GLenum(GL_FLOAT), 0 , CeilingVerts)
			glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
			
			glDisable(GLenum(GL_TEXTURE_2D));
		}
		
		// insect class
		loadModelBlocks[Int(PM_GIANT_ANT+GLYPH_MON_OFF)] =		loadModelFunc_insect;
		loadModelBlocks[Int(PM_KILLER_BEE+GLYPH_MON_OFF)] =		loadModelFunc_insect;
		loadModelBlocks[Int(PM_SOLDIER_ANT+GLYPH_MON_OFF)] =	loadModelFunc_insect;
		loadModelBlocks[Int(PM_FIRE_ANT+GLYPH_MON_OFF)] =		loadModelFunc_insect;
		loadModelBlocks[Int(PM_GIANT_BEETLE+GLYPH_MON_OFF)] =	loadModelFunc_insect;
		loadModelBlocks[Int(PM_QUEEN_BEE+GLYPH_MON_OFF)] =		loadModelFunc_insect;
		
		// blob class
		loadModelBlocks[Int(PM_ACID_BLOB+GLYPH_MON_OFF)] =			loadModelFunc_blob
		loadModelBlocks[Int(PM_QUIVERING_BLOB+GLYPH_MON_OFF)] =		loadModelFunc_blob
		loadModelBlocks[Int(PM_GELATINOUS_CUBE+GLYPH_MON_OFF)] =	loadModelFunc_blob
		
		// cockatrice class
		loadModelBlocks[Int(PM_CHICKATRICE+GLYPH_MON_OFF)] =	loadModelFunc_cockatrice
		loadModelBlocks[Int(PM_COCKATRICE+GLYPH_MON_OFF)] =		loadModelFunc_cockatrice
		loadModelBlocks[Int(PM_PYROLISK+GLYPH_MON_OFF)] =		loadModelFunc_cockatrice
		
		// dog or canine class
		loadModelBlocks[Int(PM_JACKAL+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_FOX+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_COYOTE+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_WEREJACKAL+GLYPH_MON_OFF)] =			loadModelFunc_dog;
		loadModelBlocks[Int(PM_LITTLE_DOG+GLYPH_MON_OFF)] =			loadModelFunc_dog;
		loadModelBlocks[Int(PM_DOG+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_LARGE_DOG+GLYPH_MON_OFF)] =			loadModelFunc_dog;
		loadModelBlocks[Int(PM_DINGO+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_WOLF+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_WEREWOLF+GLYPH_MON_OFF)] =			loadModelFunc_dog;
		loadModelBlocks[Int(PM_WARG+GLYPH_MON_OFF)] =				loadModelFunc_dog;
		loadModelBlocks[Int(PM_WINTER_WOLF_CUB+GLYPH_MON_OFF)] =	loadModelFunc_dog;
		loadModelBlocks[Int(PM_WINTER_WOLF+GLYPH_MON_OFF)] =		loadModelFunc_dog;
		loadModelBlocks[Int(PM_HELL_HOUND_PUP+GLYPH_MON_OFF)] =		loadModelFunc_dog;
		loadModelBlocks[Int(PM_HELL_HOUND+GLYPH_MON_OFF)] =			loadModelFunc_dog;
		
		// eye or sphere class
		loadModelBlocks[Int(PM_GAS_SPORE+GLYPH_MON_OFF)] =			loadModelFunc_sphere;
		loadModelBlocks[Int(PM_FLOATING_EYE+GLYPH_MON_OFF)] =		loadModelFunc_sphere;
		loadModelBlocks[Int(PM_FREEZING_SPHERE+GLYPH_MON_OFF)] =	loadModelFunc_sphere;
		loadModelBlocks[Int(PM_FLAMING_SPHERE+GLYPH_MON_OFF)] =		loadModelFunc_sphere;
		loadModelBlocks[Int(PM_SHOCKING_SPHERE+GLYPH_MON_OFF)] =	loadModelFunc_sphere;
		
		// cat or feline class
		loadModelBlocks[Int(PM_KITTEN+GLYPH_MON_OFF)] =		loadModelFunc_cat
		loadModelBlocks[Int(PM_HOUSECAT+GLYPH_MON_OFF)] =	loadModelFunc_cat
		loadModelBlocks[Int(PM_JAGUAR+GLYPH_MON_OFF)] =		loadModelFunc_cat
		loadModelBlocks[Int(PM_LYNX+GLYPH_MON_OFF)] =		loadModelFunc_cat
		loadModelBlocks[Int(PM_PANTHER+GLYPH_MON_OFF)] =	loadModelFunc_cat
		loadModelBlocks[Int(PM_LARGE_CAT+GLYPH_MON_OFF)] =	loadModelFunc_cat
		loadModelBlocks[Int(PM_TIGER+GLYPH_MON_OFF)] =		loadModelFunc_cat
		
		// gremlins and gagoyles class
		loadModelBlocks[Int(PM_GREMLIN+GLYPH_MON_OFF)] =			loadModelFunc_gremlins;
		loadModelBlocks[Int(PM_GARGOYLE+GLYPH_MON_OFF)] =			loadModelFunc_gremlins;
		loadModelBlocks[Int(PM_WINGED_GARGOYLE+GLYPH_MON_OFF)] =	loadModelFunc_gremlins;
		
		// humanoids class
		loadModelBlocks[Int(PM_DWARF_KING+GLYPH_MON_OFF)] =			loadModelFunc_humanoids;
		loadModelBlocks[Int(PM_HOBBIT+GLYPH_MON_OFF)] =				loadModelFunc_humanoids;
		loadModelBlocks[Int(PM_DWARF+GLYPH_MON_OFF)] =				loadModelFunc_humanoids;
		loadModelBlocks[Int(PM_BUGBEAR+GLYPH_MON_OFF)] =			loadModelFunc_humanoids;
		loadModelBlocks[Int(PM_DWARF_LORD+GLYPH_MON_OFF)] =			loadModelFunc_humanoids;
		loadModelBlocks[Int(PM_MIND_FLAYER+GLYPH_MON_OFF)] =		loadModelFunc_humanoids;
		loadModelBlocks[Int(PM_MASTER_MIND_FLAYER+GLYPH_MON_OFF)] =	loadModelFunc_humanoids
		
		// imp and minor demons
		loadModelBlocks[Int(PM_MANES+GLYPH_MON_OFF)] =		loadModelFunc_imp;
		loadModelBlocks[Int(PM_HOMUNCULUS+GLYPH_MON_OFF)] =	loadModelFunc_imp;
		loadModelBlocks[Int(PM_IMP+GLYPH_MON_OFF)] =		loadModelFunc_imp;
		loadModelBlocks[Int(PM_LEMURE+GLYPH_MON_OFF)] =		loadModelFunc_imp;
		loadModelBlocks[Int(PM_QUASIT+GLYPH_MON_OFF)] =		loadModelFunc_imp;
		loadModelBlocks[Int(PM_TENGU+GLYPH_MON_OFF)] =		loadModelFunc_imp;
		
		// jellys
		loadModelBlocks[Int(PM_BLUE_JELLY+GLYPH_MON_OFF)] =		loadModelFunc_jellys;
		loadModelBlocks[Int(PM_SPOTTED_JELLY+GLYPH_MON_OFF)] =	loadModelFunc_jellys;
		loadModelBlocks[Int(PM_OCHRE_JELLY+GLYPH_MON_OFF)] =	loadModelFunc_jellys;
		
		// kobolds
		loadModelBlocks[Int(PM_KOBOLD+GLYPH_MON_OFF)] =			loadModelFunc_kobolds;
		loadModelBlocks[Int(PM_LARGE_KOBOLD+GLYPH_MON_OFF)] =	loadModelFunc_kobolds;
		loadModelBlocks[Int(PM_KOBOLD_LORD+GLYPH_MON_OFF)] =	loadModelFunc_kobolds;
		loadModelBlocks[Int(PM_KOBOLD_SHAMAN+GLYPH_MON_OFF)] =	loadModelFunc_kobolds
		
		// leprechaun
		loadModelBlocks[Int(PM_LEPRECHAUN+GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile: "lowerL", withTexture: false)
		}
		
		// mimics
		loadModelBlocks[Int(PM_SMALL_MIMIC+GLYPH_MON_OFF)] = loadModelFunc_mimics
		loadModelBlocks[Int(PM_LARGE_MIMIC+GLYPH_MON_OFF)] = loadModelFunc_mimics
		loadModelBlocks[Int(PM_GIANT_MIMIC+GLYPH_MON_OFF)] = loadModelFunc_mimics
		
		// nymphs
		loadModelBlocks[Int(PM_WOOD_NYMPH+GLYPH_MON_OFF)] =		loadModelFunc_nymphs;
		loadModelBlocks[Int(PM_WATER_NYMPH+GLYPH_MON_OFF)] =	loadModelFunc_nymphs;
		loadModelBlocks[Int(PM_MOUNTAIN_NYMPH+GLYPH_MON_OFF)] =	loadModelFunc_nymphs;
		
		// orc class
		loadModelBlocks[Int(PM_ORC_SHAMAN + GLYPH_MON_OFF)] =	loadModelFunc_orc;
		loadModelBlocks[Int(PM_GOBLIN+GLYPH_MON_OFF)] =			loadModelFunc_orc;
		loadModelBlocks[Int(PM_HOBGOBLIN+GLYPH_MON_OFF)] =		loadModelFunc_orc;
		loadModelBlocks[Int(PM_ORC+GLYPH_MON_OFF)] =			loadModelFunc_orc;
		loadModelBlocks[Int(PM_HILL_ORC+GLYPH_MON_OFF)] =		loadModelFunc_orc;
		loadModelBlocks[Int(PM_MORDOR_ORC+GLYPH_MON_OFF)] =		loadModelFunc_orc;
		loadModelBlocks[Int(PM_URUK_HAI+GLYPH_MON_OFF)] =		loadModelFunc_orc;
		loadModelBlocks[Int(PM_ORC_CAPTAIN+GLYPH_MON_OFF)] =	loadModelFunc_orc;
		
		// piercers
		loadModelBlocks[Int(PM_ROCK_PIERCER+GLYPH_MON_OFF)] = loadModelFunc_piercers
		loadModelBlocks[Int(PM_IRON_PIERCER+GLYPH_MON_OFF)] = loadModelFunc_piercers
		loadModelBlocks[Int(PM_GLASS_PIERCER+GLYPH_MON_OFF)] = loadModelFunc_piercers
		
		// quadrupeds
		loadModelBlocks[Int(PM_ROTHE+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		loadModelBlocks[Int(PM_MUMAK+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		loadModelBlocks[Int(PM_LEOCROTTA+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		loadModelBlocks[Int(PM_WUMPUS+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		loadModelBlocks[Int(PM_TITANOTHERE+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		loadModelBlocks[Int(PM_BALUCHITHERIUM+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		loadModelBlocks[Int(PM_MASTODON+GLYPH_MON_OFF)] = loadModelFunc_quadrupeds
		
		// rodents
		loadModelBlocks[Int(PM_SEWER_RAT+GLYPH_MON_OFF)] = loadModelFunc_rodents
		loadModelBlocks[Int(PM_GIANT_RAT+GLYPH_MON_OFF)] = loadModelFunc_rodents
		loadModelBlocks[Int(PM_RABID_RAT+GLYPH_MON_OFF)] = loadModelFunc_rodents
		loadModelBlocks[Int(PM_WERERAT+GLYPH_MON_OFF)] = loadModelFunc_rodents
		loadModelBlocks[Int(PM_ROCK_MOLE+GLYPH_MON_OFF)] = loadModelFunc_rodents
		loadModelBlocks[Int(PM_WOODCHUCK+GLYPH_MON_OFF)] = loadModelFunc_rodents
		
		// spiders
		loadModelBlocks[Int(PM_CAVE_SPIDER+GLYPH_MON_OFF)] = loadModelFunc_spiders
		loadModelBlocks[Int(PM_CENTIPEDE+GLYPH_MON_OFF)] = loadModelFunc_spiders
		loadModelBlocks[Int(PM_GIANT_SPIDER+GLYPH_MON_OFF)] = loadModelFunc_spiders
		loadModelBlocks[Int(PM_SCORPION+GLYPH_MON_OFF)] = loadModelFunc_spiders
		
		// trapper
		loadModelBlocks[Int(PM_LURKER_ABOVE+GLYPH_MON_OFF)] = loadModelFunc_trapper
		loadModelBlocks[Int(PM_TRAPPER+GLYPH_MON_OFF)] = loadModelFunc_trapper
		
		// unicorns and horses
		loadModelBlocks[Int(PM_WHITE_UNICORN+GLYPH_MON_OFF)] = loadModelFunc_unicorns
		loadModelBlocks[Int(PM_GRAY_UNICORN+GLYPH_MON_OFF)] = loadModelFunc_unicorns
		loadModelBlocks[Int(PM_BLACK_UNICORN+GLYPH_MON_OFF)] = loadModelFunc_unicorns
		loadModelBlocks[Int(PM_PONY+GLYPH_MON_OFF)] = loadModelFunc_unicorns
		loadModelBlocks[Int(PM_HORSE+GLYPH_MON_OFF)] = loadModelFunc_unicorns
		loadModelBlocks[Int(PM_WARHORSE+GLYPH_MON_OFF)] = loadModelFunc_unicorns
		
		// vortices
		loadModelBlocks[Int(PM_FOG_CLOUD+GLYPH_MON_OFF)] = loadModelFunc_vortices
		loadModelBlocks[Int(PM_DUST_VORTEX+GLYPH_MON_OFF)] = loadModelFunc_vortices
		loadModelBlocks[Int(PM_ICE_VORTEX+GLYPH_MON_OFF)] = loadModelFunc_vortices
		loadModelBlocks[Int(PM_ENERGY_VORTEX+GLYPH_MON_OFF)] = loadModelFunc_vortices
		loadModelBlocks[Int(PM_STEAM_VORTEX+GLYPH_MON_OFF)] = loadModelFunc_vortices
		loadModelBlocks[Int(PM_FIRE_VORTEX+GLYPH_MON_OFF)] = loadModelFunc_vortices
		
		// worms
		loadModelBlocks[Int(PM_BABY_LONG_WORM+GLYPH_MON_OFF)] = loadModelFunc_worms
		loadModelBlocks[Int(PM_BABY_PURPLE_WORM+GLYPH_MON_OFF)] = loadModelFunc_worms
		loadModelBlocks[Int(PM_LONG_WORM+GLYPH_MON_OFF)] = loadModelFunc_worms
		loadModelBlocks[Int(PM_PURPLE_WORM+GLYPH_MON_OFF)] = loadModelFunc_worms
		
		// xan
		loadModelBlocks[Int(PM_GRID_BUG+GLYPH_MON_OFF)] = loadModelFunc_xan
		loadModelBlocks[Int(PM_XAN+GLYPH_MON_OFF)] = loadModelFunc_xan
		
		// lights
		loadModelBlocks[Int(PM_YELLOW_LIGHT+GLYPH_MON_OFF)] = loadModelFunc_lights
		loadModelBlocks[Int(PM_BLACK_LIGHT+GLYPH_MON_OFF)] = loadModelFunc_lights
		
		// zruty
		loadModelBlocks[Int(PM_ZRUTY+GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile: "lowerZ", withTexture: false)
		}
		
		// Angels
		loadModelBlocks[Int(PM_COUATL+GLYPH_MON_OFF)] = loadModelFunc_Angels
		loadModelBlocks[Int(PM_ALEAX+GLYPH_MON_OFF)] = loadModelFunc_Angels
		loadModelBlocks[Int(PM_ANGEL+GLYPH_MON_OFF)] = loadModelFunc_Angels
		loadModelBlocks[Int(PM_KI_RIN+GLYPH_MON_OFF)] = loadModelFunc_Angels
		loadModelBlocks[Int(PM_ARCHON+GLYPH_MON_OFF)] = loadModelFunc_Angels
		
		// Bats
		loadModelBlocks[Int(PM_BAT+GLYPH_MON_OFF)] = loadModelFunc_Bats
		loadModelBlocks[Int(PM_GIANT_BAT+GLYPH_MON_OFF)] = loadModelFunc_Bats
		loadModelBlocks[Int(PM_RAVEN+GLYPH_MON_OFF)] = loadModelFunc_Bats
		loadModelBlocks[Int(PM_VAMPIRE_BAT+GLYPH_MON_OFF)] = loadModelFunc_Bats
		
		// Centaurs
		loadModelBlocks[Int(PM_PLAINS_CENTAUR+GLYPH_MON_OFF)] = loadModelFunc_Centaurs
		loadModelBlocks[Int(PM_FOREST_CENTAUR+GLYPH_MON_OFF)] = loadModelFunc_Centaurs
		loadModelBlocks[Int(PM_MOUNTAIN_CENTAUR+GLYPH_MON_OFF)] = loadModelFunc_Centaurs
		
		// Dragons
		loadModelBlocks[Int(PM_BABY_GRAY_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_SILVER_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_RED_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_WHITE_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_ORANGE_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_BLACK_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_BLUE_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_GREEN_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BABY_YELLOW_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_GRAY_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_SILVER_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_RED_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_WHITE_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_ORANGE_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BLACK_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_BLUE_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_GREEN_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		loadModelBlocks[Int(PM_YELLOW_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Dragons
		
		// Elementals
		loadModelBlocks[Int(PM_STALKER+GLYPH_MON_OFF)] = loadModelFunc_Elementals
		loadModelBlocks[Int(PM_AIR_ELEMENTAL+GLYPH_MON_OFF)] = loadModelFunc_Elementals
		loadModelBlocks[Int(PM_FIRE_ELEMENTAL+GLYPH_MON_OFF)] = loadModelFunc_Elementals
		loadModelBlocks[Int(PM_EARTH_ELEMENTAL+GLYPH_MON_OFF)] = loadModelFunc_Elementals
		loadModelBlocks[Int(PM_WATER_ELEMENTAL+GLYPH_MON_OFF)] = loadModelFunc_Elementals
		
		// Fungi
		loadModelBlocks[Int(PM_LICHEN+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		loadModelBlocks[Int(PM_BROWN_MOLD+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		loadModelBlocks[Int(PM_YELLOW_MOLD+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		loadModelBlocks[Int(PM_GREEN_MOLD+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		loadModelBlocks[Int(PM_RED_MOLD+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		loadModelBlocks[Int(PM_SHRIEKER+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		loadModelBlocks[Int(PM_VIOLET_FUNGUS+GLYPH_MON_OFF)] = loadModelFunc_Fungi
		
		// Gnomes
		loadModelBlocks[Int(PM_GNOME+GLYPH_MON_OFF)] = loadModelFunc_Gnomes
		loadModelBlocks[Int(PM_GNOME_LORD+GLYPH_MON_OFF)] = loadModelFunc_Gnomes
		loadModelBlocks[Int(PM_GNOMISH_WIZARD + GLYPH_MON_OFF)] = loadModelFunc_Gnomes
		loadModelBlocks[Int(PM_GNOME_KING + GLYPH_MON_OFF)] = loadModelFunc_Gnomes
		
		// Giant Humanoids
		loadModelBlocks[Int(PM_GIANT + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_STONE_GIANT + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_HILL_GIANT + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_FIRE_GIANT + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_FROST_GIANT + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_STORM_GIANT + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_ETTIN + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_TITAN + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		loadModelBlocks[Int(PM_MINOTAUR + GLYPH_MON_OFF)] = loadModelFunc_giantHumanoids
		
		// Jabberwock
		loadModelBlocks[Int(PM_JABBERWOCK + GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile: "upperJ", withTexture: false)
		}
		
		// Kops
		loadModelBlocks[Int(PM_KEYSTONE_KOP + GLYPH_MON_OFF)] = loadModelFunc_Kops
		loadModelBlocks[Int(PM_KOP_SERGEANT + GLYPH_MON_OFF)] = loadModelFunc_Kops
		loadModelBlocks[Int(PM_KOP_LIEUTENANT + GLYPH_MON_OFF)] = loadModelFunc_Kops
		loadModelBlocks[Int(PM_KOP_KAPTAIN + GLYPH_MON_OFF)] = loadModelFunc_Kops
		
		// Liches
		loadModelBlocks[Int(PM_LICH + GLYPH_MON_OFF)] = loadModelFunc_Liches
		loadModelBlocks[Int(PM_DEMILICH + GLYPH_MON_OFF)] = loadModelFunc_Liches
		loadModelBlocks[Int(PM_MASTER_LICH + GLYPH_MON_OFF)] = loadModelFunc_Liches
		loadModelBlocks[Int(PM_ARCH_LICH + GLYPH_MON_OFF)] = loadModelFunc_Liches
		
		// Mummies
		loadModelBlocks[Int(PM_KOBOLD_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_GNOME_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_ORC_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_DWARF_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_ELF_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_HUMAN_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_ETTIN_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		loadModelBlocks[Int(PM_GIANT_MUMMY + GLYPH_MON_OFF)] = loadModelFunc_Mummies
		
		// Nagas
		loadModelBlocks[Int(PM_RED_NAGA_HATCHLING + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_BLACK_NAGA_HATCHLING + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_GOLDEN_NAGA_HATCHLING + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_GUARDIAN_NAGA_HATCHLING + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_RED_NAGA + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_BLACK_NAGA + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_GOLDEN_NAGA + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		loadModelBlocks[Int(PM_GUARDIAN_NAGA + GLYPH_MON_OFF)] = loadModelFunc_Nagas
		
		// Ogres
		loadModelBlocks[Int(PM_OGRE + GLYPH_MON_OFF)] = loadModelFunc_Ogres
		loadModelBlocks[Int(PM_OGRE_LORD + GLYPH_MON_OFF)] = loadModelFunc_Ogres
		loadModelBlocks[Int(PM_OGRE_KING + GLYPH_MON_OFF)] = loadModelFunc_Ogres
		
		// Puddings
		loadModelBlocks[Int(PM_GRAY_OOZE + GLYPH_MON_OFF)] = loadModelFunc_Puddings
		loadModelBlocks[Int(PM_BROWN_PUDDING + GLYPH_MON_OFF)] = loadModelFunc_Puddings
		loadModelBlocks[Int(PM_BLACK_PUDDING + GLYPH_MON_OFF)] = loadModelFunc_Puddings
		loadModelBlocks[Int(PM_GREEN_SLIME + GLYPH_MON_OFF)] = loadModelFunc_Puddings
		
		// Quantum mechanics
		loadModelBlocks[Int(PM_QUANTUM_MECHANIC + GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile: "upperQ", withTexture: false)
		}
		
		// Rust monster or disenchanter
		loadModelBlocks[Int(PM_RUST_MONSTER + GLYPH_MON_OFF)] = loadModelFunc_Rustmonster
		loadModelBlocks[Int(PM_DISENCHANTER + GLYPH_MON_OFF)] = loadModelFunc_Rustmonster
		
		// Snakes
		loadModelBlocks[Int(PM_GARTER_SNAKE + GLYPH_MON_OFF)] = loadModelFunc_Snakes
		loadModelBlocks[Int(PM_SNAKE + GLYPH_MON_OFF)] = loadModelFunc_Snakes
		loadModelBlocks[Int(PM_WATER_MOCCASIN + GLYPH_MON_OFF)] = loadModelFunc_Snakes
		loadModelBlocks[Int(PM_PIT_VIPER + GLYPH_MON_OFF)] = loadModelFunc_Snakes
		loadModelBlocks[Int(PM_PYTHON + GLYPH_MON_OFF)] = loadModelFunc_Snakes
		loadModelBlocks[Int(PM_COBRA + GLYPH_MON_OFF)] = loadModelFunc_Snakes
		
		// Trolls
		loadModelBlocks[Int(PM_TROLL + GLYPH_MON_OFF)] = loadModelFunc_Trolls;
		loadModelBlocks[Int(PM_ICE_TROLL + GLYPH_MON_OFF)] = loadModelFunc_Trolls;
		loadModelBlocks[Int(PM_ROCK_TROLL + GLYPH_MON_OFF)] = loadModelFunc_Trolls;
		loadModelBlocks[Int(PM_WATER_TROLL + GLYPH_MON_OFF)] = loadModelFunc_Trolls;
		loadModelBlocks[Int(PM_OLOG_HAI + GLYPH_MON_OFF)] = loadModelFunc_Trolls;
		
		// Umber hulk
		loadModelBlocks[Int(PM_UMBER_HULK + GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile:"upperU", withTexture:false)
		};
		
		// Vampires
		loadModelBlocks[Int(PM_VAMPIRE + GLYPH_MON_OFF)] = loadModelFunc_Vampires
		loadModelBlocks[Int(PM_VAMPIRE_LORD + GLYPH_MON_OFF)] = loadModelFunc_Vampires
		loadModelBlocks[Int(PM_VLAD_THE_IMPALER + GLYPH_MON_OFF)] = loadModelFunc_Vampires
		
		// Wraiths
		loadModelBlocks[Int(PM_BARROW_WIGHT + GLYPH_MON_OFF)] = loadModelFunc_Wraiths;
		loadModelBlocks[Int(PM_WRAITH + GLYPH_MON_OFF)] = loadModelFunc_Wraiths;
		loadModelBlocks[Int(PM_NAZGUL + GLYPH_MON_OFF)] = loadModelFunc_Wraiths;
		
		// Xorn
		loadModelBlocks[Int(PM_XORN + GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile:"upperX", withTexture:false)
		}
		
		// Yeti and other large beasts
		loadModelBlocks[Int(PM_MONKEY + GLYPH_MON_OFF)] = loadModelFunc_Yeti
		loadModelBlocks[Int(PM_APE + GLYPH_MON_OFF)] = loadModelFunc_Yeti
		loadModelBlocks[Int(PM_OWLBEAR + GLYPH_MON_OFF)] = loadModelFunc_Yeti
		loadModelBlocks[Int(PM_YETI + GLYPH_MON_OFF)] = loadModelFunc_Yeti
		loadModelBlocks[Int(PM_CARNIVOROUS_APE + GLYPH_MON_OFF)] = loadModelFunc_Yeti
		loadModelBlocks[Int(PM_SASQUATCH + GLYPH_MON_OFF)] = loadModelFunc_Yeti
		
		// Zombie
		loadModelBlocks[Int(PM_KOBOLD_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_GNOME_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_ORC_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_DWARF_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_ELF_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_HUMAN_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_ETTIN_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_GIANT_ZOMBIE + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_GHOUL + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		loadModelBlocks[Int(PM_SKELETON + GLYPH_MON_OFF)] = loadModelFunc_Zombie;
		
		// Golems
		loadModelBlocks[Int(PM_STRAW_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_PAPER_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_ROPE_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_GOLD_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_LEATHER_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_WOOD_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_FLESH_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_CLAY_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_STONE_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_GLASS_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		loadModelBlocks[Int(PM_IRON_GOLEM + GLYPH_MON_OFF)] = loadModelFunc_Golems;
		
		// Human or Elves
		loadModelBlocks[Int(PM_ELVENKING + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_NURSE + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_HIGH_PRIEST + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_MEDUSA + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_CROESUS + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_HUMAN + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_HUMAN_WERERAT + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_HUMAN_WEREJACKAL + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_HUMAN_WEREWOLF + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_ELF + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_WOODLAND_ELF + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_GREEN_ELF + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_GREY_ELF + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_ELF_LORD + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_DOPPELGANGER + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_SHOPKEEPER + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_GUARD + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_PRISONER + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_ORACLE + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_ALIGNED_PRIEST + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_SOLDIER + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_SERGEANT + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_LIEUTENANT + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_CAPTAIN + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_WATCHMAN + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_WATCH_CAPTAIN + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves;
		loadModelBlocks[Int(PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF) ] = loadModelFunc_HumanOrElves
		
		// Ghosts
		loadModelBlocks[ Int(PM_GHOST + GLYPH_INVIS_OFF) ] = loadModelFunc_Ghosts
		loadModelBlocks[ Int(PM_SHADE + GLYPH_INVIS_OFF) ] = loadModelFunc_Ghosts
		
		// Major Daemons
		loadModelBlocks[Int(PM_WATER_DEMON + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_HORNED_DEVIL + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_SUCCUBUS + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_INCUBUS + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_ERINYS + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_BARBED_DEVIL + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_MARILITH + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_VROCK + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_HEZROU + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_BONE_DEVIL + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_ICE_DEVIL + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_NALFESHNEE + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_PIT_FIEND + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_BALROG + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_DJINNI + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		loadModelBlocks[Int(PM_SANDESTIN + GLYPH_MON_OFF)] = loadModelFunc_MajorDamons;
		
		// Greater Daemons
		loadModelBlocks[Int(PM_JUIBLEX + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_YEENOGHU + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_ORCUS + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_GERYON + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_DISPATER + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_BAALZEBUB + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_ASMODEUS + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons;
		loadModelBlocks[Int(PM_DEMOGORGON + GLYPH_MON_OFF)] = loadModelFunc_GraterDamons
		
		// daemon "The Riders"
		loadModelBlocks[Int(PM_DEATH + GLYPH_MON_OFF)] = loadModelFunc_Riders;
		loadModelBlocks[Int(PM_PESTILENCE + GLYPH_MON_OFF)] = loadModelFunc_Riders;
		loadModelBlocks[Int(PM_FAMINE + GLYPH_MON_OFF)] = loadModelFunc_Riders;
		
		// sea monsters
		loadModelBlocks[Int(PM_JELLYFISH + GLYPH_MON_OFF)] = loadModelFunc_seamonsters
		loadModelBlocks[Int(PM_PIRANHA + GLYPH_MON_OFF)] = loadModelFunc_seamonsters;
		loadModelBlocks[Int(PM_SHARK + GLYPH_MON_OFF)] = loadModelFunc_seamonsters;
		loadModelBlocks[Int(PM_GIANT_EEL + GLYPH_MON_OFF)] = loadModelFunc_seamonsters;
		loadModelBlocks[Int(PM_ELECTRIC_EEL + GLYPH_MON_OFF)] = loadModelFunc_seamonsters;
		loadModelBlocks[Int(PM_KRAKEN + GLYPH_MON_OFF)] = loadModelFunc_seamonsters;
		
		// lizards
		loadModelBlocks[Int(PM_NEWT + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_GECKO + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_IGUANA + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_BABY_CROCODILE + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_LIZARD + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_CHAMELEON + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_CROCODILE + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		loadModelBlocks[Int(PM_SALAMANDER + GLYPH_MON_OFF)] = loadModelFunc_lizards;
		
		// wormtail
		loadModelBlocks[Int(PM_LONG_WORM_TAIL + GLYPH_MON_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile: "wormtail", withTexture: false)
		}
		
		// Adventures
		loadModelBlocks[Int(PM_ARCHEOLOGIST + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_BARBARIAN + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_CAVEMAN + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_CAVEWOMAN + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_HEALER + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_KNIGHT + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_MONK + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_PRIEST + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_PRIESTESS + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_RANGER + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_ROGUE + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_SAMURAI + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_TOURIST + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_VALKYRIE + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		loadModelBlocks[Int(PM_WIZARD + GLYPH_MON_OFF)] = loadModelFunc_Adventures
		
		// Unique person
		loadModelBlocks[Int(PM_LORD_CARNARVON+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_PELIAS+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_SHAMAN_KARNOV+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_HIPPOCRATES+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_GRAND_MASTER+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ARCH_PRIEST+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ORION+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_MASTER_OF_THIEVES+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_LORD_SATO+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_TWOFLOWER+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_NORN+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_KING_ARTHUR+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_NEFERET_THE_GREEN+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_MINION_OF_HUHETOTL+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_THOTH_AMON+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_CHROMATIC_DRAGON+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_CYCLOPS+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_IXOTH+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_MASTER_KAEN+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_NALZOK+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_SCORPIUS+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_MASTER_ASSASSIN+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ASHIKAGA_TAKAUJI+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_LORD_SURTUR+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_DARK_ONE+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_STUDENT+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_CHIEFTAIN+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_NEANDERTHAL+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ATTENDANT+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_PAGE+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ABBOT+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ACOLYTE+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_HUNTER+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_THUG+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_NINJA+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_ROSHI+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_GUIDE+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_WARRIOR+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		loadModelBlocks[Int(PM_APPRENTICE+GLYPH_MON_OFF)] = loadModelFunc_Uniqueperson
		// -------------------------- Map Symbol Section ----------------------------- //
		
		loadModelBlocks[Int(S_bars + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_tree + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_upstair + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_dnstair + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_upladder + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_dnladder + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_altar + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_grave + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_throne + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_sink + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_fountain + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_vodbridge + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_hodbridge + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_vcdbridge + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		loadModelBlocks[Int(S_hcdbridge + GLYPH_CMAP_OFF)] = loadModelFunc_MapSymbols;
		//  ------------------------------  Boulder ---------------------------------- //
		loadModelBlocks[Int(BOULDER + GLYPH_OBJ_OFF)] = { _ in
			return NH3DModelObjects(with3DSFile: "boulder", withTexture: true)
		}
		// --------------------------  Trap Symbol Section --------------------------- //
		
		loadModelBlocks[Int(S_arrow_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_dart_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_falling_rock_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		//loadModelBlocks[Int(S_squeaky_board + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_land_mine + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		//loadModelBlocks[ S_rolling_boulder_trap + GLYPH_CMAP_OFF ] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_sleeping_gas_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_rust_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_fire_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_bear_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_pit + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_spiked_pit + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_hole + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_trap_door + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_teleportation_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_level_teleporter + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_magic_portal + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		//loadModelBlocks[Int(S_web + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		//loadModelBlocks[Int(S_statue_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_magic_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_anti_magic_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		loadModelBlocks[Int(S_polymorph_trap + GLYPH_CMAP_OFF)] = loadModelFunc_TrapSymbol;
		// ------------------------- Effect Symbols Section. ------------------------- //
		
		// ZAP symbols ( NUM_ZAP * four directions )
		
		// type Magic Missile
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicMissile;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicMissile;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicMissile;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicMissile
		
		// type Magic FIRE
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicFIRE;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicFIRE;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicFIRE;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicFIRE
		
		// type Magic COLD
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicCOLD;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicCOLD;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicCOLD;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicCOLD
		
		// type Magic SLEEP
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicSLEEP;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicSLEEP;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicSLEEP;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicSLEEP
		
		// type Magic DEATH
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicDEATH;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicDEATH;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicDEATH;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicDEATH
		
		// type Magic LIGHTNING
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicLIGHTNING;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicLIGHTNING;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicLIGHTNING;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicLIGHTNING;
		
		// type Magic POISONGAS
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicPOISONGAS;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicPOISONGAS;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicPOISONGAS;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicPOISONGAS
		
		// type Magic ACID
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM)] = loadModelFunc_MagicACID;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM)] = loadModelFunc_MagicACID;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT)] = loadModelFunc_MagicACID;
		loadModelBlocks[Int(NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT)] = loadModelFunc_MagicACID
		
		// dig beam
		loadModelBlocks[Int(S_digbeam + GLYPH_CMAP_OFF)] = { _ in
			let ret = NH3DModelObjects();
			ret.setModelScaleX(0.7, scaleY:1.0, scaleZ:0.7)
			ret.particleType = .Aura
			ret.particleColor = CLR_BROWN;
			ret.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret.setParticleSpeedX(1.0, y:1.00)
			ret.particleSlowdown = 3.8
			ret.particleLife = 0.4
			ret.setParticleSize(20.0)
			
			return ret;
		}
		// camera flash
		loadModelBlocks[Int(S_flashbeam + GLYPH_CMAP_OFF)] = { _ in
			let ret = NH3DModelObjects();
			ret.setModelScaleX(1.4, scaleY:1.5, scaleZ:1.4)
			ret.particleType = .Aura
			ret.particleColor = CLR_WHITE;
			//[ ret setParticleColor:CLR_WHITE ];
			ret.setParticleGravityX(0.0, y: 6.5, z: 0.0)
			ret.setParticleSpeedX(1.0, y:1.00)
			ret.particleSlowdown = 3.8
			ret.particleLife = 0.4
			ret.setParticleSize(20.0)
			
			return ret;
		}
		// boomerang
		//loadModelBlocks[ S_boomleft + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];
		//loadModelBlocks[ S_boomright + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];
		
		// magic shild
		loadModelBlocks[Int(S_ss1 + GLYPH_CMAP_OFF)] = loadModelFunc_MagicSHILD;
		loadModelBlocks[Int(S_ss2 + GLYPH_CMAP_OFF)] = loadModelFunc_MagicSHILD;
		loadModelBlocks[Int(S_ss3 + GLYPH_CMAP_OFF)] = loadModelFunc_MagicSHILD;
		loadModelBlocks[Int(S_ss4 + GLYPH_CMAP_OFF)] = loadModelFunc_MagicSHILD;
		
		// explosion symbols ( 9 postion * 7 types )
		for i in 0..<MAXEXPCHARS {
			// type DARK
			loadModelBlocks[Int(NH3D_EXPLODE_DARK + i)] = loadModelFunc_explotionDARK;
			
			// type NOXIOUS
			loadModelBlocks[Int(NH3D_EXPLODE_NOXIOUS + i)] = loadModelFunc_explotionNOXIOUS;
			
			// type MUDDY
			loadModelBlocks[Int(NH3D_EXPLODE_MUDDY + i)] = loadModelFunc_explotionMUDDY;
			
			// type WET
			loadModelBlocks[Int(NH3D_EXPLODE_WET + i)] = loadModelFunc_explotionWET
			
			// type MAGICAL
			loadModelBlocks[Int(NH3D_EXPLODE_MAGICAL + i)] = loadModelFunc_explotionMAGICAL;
			
			// type FIERY
			loadModelBlocks[Int(NH3D_EXPLODE_FIERY + i)] = loadModelFunc_explotionFIERY;
			
			// type FROSTY
			loadModelBlocks[Int(NH3D_EXPLODE_FROSTY + i)] = loadModelFunc_explotionFROSTY
		}
	}
}
