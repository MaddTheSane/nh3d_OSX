/* NH3DOpenGLView */

#import <Cocoa/Cocoa.h>
//#import <OpenGL/gl.h>
//#import <OpenGL/glext.h>
//#import <OpenGL/glu.h>
//#import <OpenGL/OpenGL.h>
#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"


@class NH3DMapModel;
@class NH3DMapItem;
@class NH3DModelObjects;


@interface NH3DOpenGLView : NSOpenGLView {
	
	IBOutlet NH3DMapModel *_mapModel;
	
	GLfloat		lastCameraX;
	GLfloat		lastCameraY;
	GLfloat		lastCameraZ;
	GLfloat		lastCameraHead;
	GLfloat		lastCameraPitch;
	GLfloat		lastCameraRoll;
	
	GLfloat		cameraX;
	GLfloat		cameraY;
	GLfloat		cameraZ;
	GLfloat		cameraHead;
	GLfloat		cameraPitch;
	GLfloat		cameraRoll;	
	
	GLfloat		cameraStep;
	
	BOOL		isReady;
	BOOL		isFloating;
	BOOL		isRiding;
	BOOL		isShocked;
	
	GLuint		floorCurrent;
	GLuint		cellingCurrent;
	
	GLuint		floorTex;
	GLuint		floor2Tex;
	//GLuint		wallTex;
	GLuint		cellingTex;
	GLuint		waterTex;
	GLuint		poolTex;
	GLuint		lavaTex;
	GLuint		envelopTex;
	GLuint		minesTex;
	GLuint		airTex;
	GLuint		cloudTex;
	GLuint		hellTex;
	GLuint		nullTex;
	GLuint		rougeTex;
	GLuint		defaultTex[MAX_GLYPH];
	
	GLfloat		keyLightCol[4];
	
	int			centerX;
	int			centerZ;
	int			playerdepth;
	int			drawMargin;
	int			enemyPosition;
	int			elementalLevel;
	float		waitRate;
	
	NSRecursiveLock		*viewLock;
	
	CGRefreshRate   dRefreshRate;
	
	NH3DMapItem *mapItemValue[NH3DGL_MAPVIEWSIZE_COLUMN][NH3DGL_MAPVIEWSIZE_ROW];
	
	//NH3DModelObjects *modelArray[MAX_GLYPH];
	NH3DModelObjects *effectArray[NH3D_MAX_EFFECTS];
	
	NSMutableDictionary *modelDictionary;
	NSMutableArray		*keyArray;
	
	NSMutableArray *delayDrawing;
	
	BOOL		nowUpdating;
	BOOL		runnning;
	BOOL		threadRunning;
	BOOL		hasWait;
	BOOL		firstTime;
	BOOL		oglParamNowChanging;
	BOOL		useTile;
	
	//-------------------
	// for speed funcion
	//-------------------
	
	void	(*switchMethodArray[11])( );
	void	(*drawFloorArray[11])( );
	IMP		loadModelAddreses[MAX_GLYPH];
	SEL		loadModelSelectors[MAX_GLYPH];
	IMP		playerDirectionImp;
	IMP		drawModelArrayImp;
	IMP		panCameraImp;
	IMP		dorryCameraImp;
	IMP		floatingCameraImp;
	IMP		shockedCameraImp;
	IMP		drawGlViewAddress;
	IMP		flushBufferImp;
	
}

- (instancetype)initWithFrame:(NSRect)theFrame;

- (void)updateGlView;
- (void)loadModels;
- (id)checkLoadedModelsAt:(int)startNum
						 to:(int)endNum
					 offset:(int)offset
				  modelName:(NSString *)mName
				   textured:(BOOL)flag
					withOut:(int)without, ... NS_RETURNS_RETAINED /*NS_FORMAT_FUNCTION(4,7)*/;
//- ( id )loadModelToArray:(int)glyph;

@property (readonly) float cameraHead;

- (void)drawModelArray:(NH3DMapItem *)mapItem;

- (GLuint)loadImageToTexture:(NSString *)filename;
- (GLuint)createTextureFromSymbol:(id)symbol withColor:(NSColor*)color;

- (void)setCenterAtX:(int)x z:(int)z depth:(int)depth;
- (void)setCameraAtX:(float)x atY:(float)y atZ:(float)z;
- (void)setCameraHead:(float)head pitching:(float)pitch rolling:(float)roll;

- (void)setIsShocked:(BOOL)flag;
- (void)setEnemyPosition:(int)direction;

- (void)updateMap;

- (void)doEffect;
- (void)floatingCamera;
- (void)shockedCamera;
- (void)dorryCamera;
- (void)panCamera;

- (void)setNowUpdating:(BOOL)flag;
- (void)setRunnning:(BOOL)flag;

- (IBAction)drawAllFrameFunction:(id)sender;
//- (IBAction)useAntiAlias:(id)sender;
- (IBAction)setWaitRate:(id)sender;

// Notifications
- (void)defaultDidChange:(NSNotification *)notification;

//-----------------------
// speed function
//-----------------------

- (void)cashMethod;

@end
