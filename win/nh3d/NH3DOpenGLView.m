#import "NH3DOpenGLView.h"

#import "NH3DMapModel.h"
#import "NH3DModelObjects.h"
#import "NH3DMapItem.h"



#define TEX_SIZE 128

/* from tile.c */
extern short glyph2tile[];
extern int total_tiles_used;


// memo.   << MAP_ITEM_SIZE >>					
//		y			   +2.0,+6.0			y
//		|			  ( RIGHT,TOP )			|
//		|									|
//		|	  0,0,2.0						|
//		| ( CENTER of Item )					|  -	-2.0 ( BACK )
//		|									|/ z
//		---------------- x					---------------- x
//	-2.0,0.0( LEFT,BOTTOM )				  / +	+2.0 ( FRONT )



static const GLfloat keyLightAmb[] = {0.1 ,0.1 ,0.1 ,1} ;
static const GLfloat keyLightspec[] = {1 ,1 ,1 ,1} ;

static const GLfloat keyLightAltCol[] = {0.04 ,0.01 ,0.00 ,1} ;
static const GLfloat keyLightAltAmb[] = {0.08 ,0.08 ,0.08 ,1} ;
static const GLfloat keyLightAltspec[] = {0.04 ,0.09 ,0.18 ,1} ;

static const GLfloat defaultBackGroundCol[] = {0.00 ,0.00 ,0.00 ,0} ;
static const GLfloat underWaterColar[] = {0.00 ,0.00 ,0.80 ,1.0} ;

static const GLint vsincWait = 1;
static const GLint vsincNoWait = 0;
////////////////////////////////
// floor model
////////////////////////////////

static NH3DVertexType FloorVerts[] = {
{ -2.0, 0.0, -2.0 },
{ -2.0, 0.0, 2.0 },	
{ 2.0, 0.0, -2.0 },
{ 2.0, 0.0, 2.0 }	
};

static NH3DMapCoordType FloorTexVerts[] = {
	{0.0,0.0},
	{1.0,0.0},
	{0.0,1.0},
	{1.0,1.0}
};

static NH3DVertexType FloorVertNorms[] = {
	{ -0.25, 0.50, 0.25},
	{ -0.25, 0.50, 0.25},
	{ 0.25, 0.50, -0.25},
	{ 0.25, 0.50, -0.25}
};

//////////////////////////////
// ceiling model
//////////////////////////////

static NH3DVertexType CeilingVerts[] = {
	{ 2.0, 6.0, -2.0 },
	{ 2.0, 6.0, 2.0 },
	{ -2.0, 6.0, -2.0 },
	{ -2.0, 6.0, 2.0 }
};

static NH3DMapCoordType CeilingTexVerts[] = {
	{1.0,1.0},
	{0.0,1.0},
	{1.0,0.0},
	{0.0,0.0}	
};


static NH3DVertexType CeilingVertNorms[] = {
	{ 0.0, -1.0, 0.0},
	{ 0.0, -1.0, 0.0},
	{ 0.0, -1.0, 0.0},
	{ 0.0, -1.0, 0.0}
};

////////////////////////////////
// default model
////////////////////////////////


static NH3DVertexType defaultVerts[] = {
	{ -1.5, 0.5,  0 }, 
	{  1.5, 0.5,  0 }, 
	{ -1.5,  3.5,  0 }, 
	{  1.5,  3.5,  0 }
};

static NH3DMapCoordType defaultTexVerts[] = {
	{0.0,1.0},
	{1.0,1.0},
	{0.0,0.0},
	{1.0,0.0}
};

static NH3DVertexType defaultNorms[] = {
	{ 0.5, 0.0, 0.5},
	{ 0.5, 0.0, 0.5}
};



////////////////////////////////
// null object
////////////////////////////////

static NH3DVertexType nullObjectVerts[] = {
	{  2, 0, -2 }, { -2, 0, -2 }, {  2,  6, -2 }, { -2,  6, -2 }, // rear
    {  2, 0,  2 }, {  2, 0, -2 }, {  2,  6,  2 }, {  2,  6, -2 }, // right
    { -2, 0,  2 }, {  2, 0,  2 }, { -2,  6,  2 }, {  2,  6,  2 }, // front
    { -2, 0, -2 }, { -2, 0,  2 }, { -2,  6, -2 }, { -2,  6,  2 }  // left
};

static NH3DMapCoordType nullObjectTexVerts[] = {
	{ 0.0, 0.0 }, { 1.0,  0.0 }, { 0.0, 1.0 }, { 1.0,  1.0 },
    { 0.0,  0.0 }, { 1.0, 0.0 }, { 0.0,  1.0 }, { 1.0, 1.0 },
    { 0.0, 0.0 }, { 1.0,   0.0 }, { 0.0, 1.0 }, { 1.0,   1.0 },
    { 0.0,   0.0 }, { 1.0, 0.0 }, { 0.0,   1.0 }, { 1.0, 1.0 }
};


static NH3DVertexType nullObjectNorms[] = {
    { 0.20,  0.50, -0.30 },{ 0.20, 0.50, -0.30 },
    { -0.30,  -0.50, 0.20 },{ -0.30, -0.50, 0.20 },
    { 0.20,  0.50, 0.30 },{ 0.20, 0.50, 0.30 },
    { 0.30,  -0.50, -0.20 },{ 0.30, -0.50, -0.20 }
};


// Material

static NH3DMaterial		nh3dMaterialArray[] = {
	// Black
	{	{ 0.05, 0.05, 0.05, 1.0 },					//	ambient color
		{ 0.1 , 0.1 , 0.1 , 1.0 },					//	diffuse color
		{ 0.474597 , 0.474597 , 0.474597 , 1.0},	//	specular color
		{ 0.1 , 0.1 , 0.1 , 1.0 },					//  emission
		0.01		},								//	shininess 
	// Red
	{	{ 0.1745 , 0.01175 , 0.01175 , 1.0 },
		{ 0.81424, 0.04136 , 0.04136 , 1.0 },
		{ 0.427811 , 0.126959 , 0.126959 , 1.0},
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// Green
	{	{ 0.0215 , 0.1745 , 0.0215 , 1.0 },
		{ 0.07568 , 0.81424 , 0.07568 , 1.0 },
		{ 0.133 , 0.427811 , 0.133 , 1.0 },
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// Brown
	{	{ 0.19125 , 0.0735 , 0.0225 , 1.0 },
		{ 0.8038 , 0.37048 , 0.0828 , 1.0 },
		{ 0.25677 , 0.137622 , 0.086014 , 1.0 },
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// Blue
	{	{ 0.0215 , 0.0215 , 0.1745 , 1.0 },
		{ 0.08568 , 0.08568 , 0.81424 , 1.0 },
		{ 0.133 , 0.133 , 0.427811 , 1.0 },
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// Magenta
	{	{ 0.1745 , 0.0215 , 0.1745 , 1.0 },
		{ 0.81424 , 0.07568 , 0.81424 , 1.0 },
		{ 0.127811 , 0.133 , 0.427811 , 1.0 },
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// Cyan
	{	{ 0.0215 , 0.1745 , 0.1745 , 1.0 },
		{ 0.08568 , 0.81424 , 0.81424 , 1.0 },
		{ 0.133 , 0.427811 , 0.427811 , 1.0 },
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// Gray
	{	{ 0.25, 0.25, 0.25, 1.0 },
		{ 0.6 , 0.6 , 0.6 , 1.0 },
		{ 0.474597 , 0.474597 , 0.474597 , 1.0},
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		0.01		},
	// No Color
	{	{ 0.5, 0.5, 0.5, 1.0 },
		{ 0.5 , 0.5 , 0.5 , 1.0 },
		{ 0.5 , 0.5 , 1.5 , 1.0},
		{ 1.0 , 1.0 , 1.0 , 1.0 },
		1.0		},
	// Orange
	{	{ 0.1745 , 0.05175 , 0.00175 , 1.0 },
		{ 0.91424, 0.41136 , 0.00136 , 1.0 },
		{ 0.527811 , 0.284959 , 0.026959 , 1.0},
		{ 0.3 , 0.3 , 0.3 , 1.0 },
		0.1		},
	// Bright Green
	{	{ 0.0615 , 0.1745 , 0.0615 , 1.0 },
		{ 0.17568 , 0.95424 , 0.17568 , 1.0 },
		{ 0.133 , 0.527811 , 0.133 , 1.0 },
		{ 0.3 , 0.3 , 0.3 , 1.0 },
		0.1		},
	// Yellow
	{	{ 0.1745 , 0.1745 , 0.00175 , 1.0 },
		{ 0.91424, 0.91424 , 0.00136 , 1.0 },
		{ 0.327811 , 0.327811 , 0.026959 , 1.0},
		{ 0.3 , 0.3 , 0.3 , 1.0 },
		0.1		},
	// Bright Blue
	{	{ 0.0715 , 0.0715 , 0.1745 , 1.0 },
		{ 0.17568 , 0.27568 , 0.91424 , 1.0 },
		{ 0.133 , 0.133 , 0.527811 , 1.0 },
		{ 0.3 , 0.3 , 0.3 , 1.0 },
		0.1		},
	// Bright Magenta
	{	{ 0.3745 , 0.1215 , 0.3745 , 1.0 },
		{ 0.91424 , 0.27568 , 0.91424 , 1.0 },
		{ 0.427811 , 0.133 , 0.427811 , 1.0 },
		{ 0.3 , 0.3 , 0.3 , 1.0 },
		0.1		},
	// Bright Cyan
	{	{ 0.0215 , 0.2745 , 0.2745 , 1.0 },
		{ 0.17568 , 0.91424 , 0.91424 , 1.0 },
		{ 0.133 , 0.427811 , 0.427811 , 1.0 },
		{ 0.3 , 0.3 , 0.3 , 1.0 },
		0.1		},
	// White
	{	{ 0.25 , 0.20725 , 0.20725 , 1.0 },
		{ 1.0 , 0.929 , 0.929 , 1.0 },
		{ 0.296648 , 0.296648 , 0.296648 , 1.0 },
		{ 0.6 , 0.6 , 0.6 , 1.0 },
		0.088 	}
	
};


@implementation NH3DOpenGLView


//------------------------------------------------------------------
// for speed up functions. (replace 'switch' method)
//------------------------------------------------------------------


//#define NH3DOpenGLViewCast( self )  \
//( ( struct { @defs( NH3DOpenGLView ) } * ) self )
#define NH3DOpenGLViewCast( self ) ((NH3DOpenGLView*)self)


static inline void drawNullObject( float x, float z,int tex )
{
	
	glPushMatrix();
	
	glTranslatef( x,0.0,z );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glEnableClientState( GL_NORMAL_ARRAY );
	
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, tex );		
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glMaterialfv( GL_FRONT , GL_AMBIENT , nh3dMaterialArray[ NO_COLOR ].ambient );
	glMaterialfv( GL_FRONT , GL_DIFFUSE , nh3dMaterialArray[ NO_COLOR ].diffuse );
	glMaterialfv( GL_FRONT , GL_SPECULAR , nh3dMaterialArray[ NO_COLOR ].specular );
	glMaterialf( GL_FRONT , GL_SHININESS , nh3dMaterialArray[ NO_COLOR ].shininess );
	glMaterialfv( GL_FRONT , GL_EMISSION , nh3dMaterialArray[ NO_COLOR ].emission );
	
	
	glNormalPointer( GL_FLOAT, 0 ,nullObjectNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, nullObjectTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , nullObjectVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 16 );
	
	
	glDisableClientState( GL_NORMAL_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
	glDisableClientState( GL_VERTEX_ARRAY );
	
	glDisable( GL_TEXTURE_2D );
	
	glPopMatrix();
	
}


static inline void drawFloorAndCeiling( float x, float z, int flag , id self )
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
	NH3DOpenGLViewCast( self ) -> drawFloorArray[ flag ]( self );
	
	glDisableClientState( GL_NORMAL_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
	glDisableClientState( GL_VERTEX_ARRAY );
	
	glPopMatrix();
	
}


static inline void createLightAndFog( id self )
{
	float gblight = 1.0 - ( ( float )u.uhp / ( float )u.uhpmax );
	
	GLfloat AmbLightPos[ 4 ] = {0.0, 4.0, 0.0 ,0};
	GLfloat keyLightPos[ 4 ] = {0.01, 3.0, 0.0 ,1};
	GLfloat fogColor[ 4 ] = {gblight/4, 0.0, 0.0, 0.0};
	GLfloat lightEmisson[ 4 ] = {0.1, 0.1, 0.1 ,1};
	
	NH3DOpenGLViewCast( self ) -> keyLightCol[ 0 ] = 2.0;
	NH3DOpenGLViewCast( self ) -> keyLightCol[ 3 ] = 1.0;
	if ( 1.00 - gblight < 0 )  {
		NH3DOpenGLViewCast( self ) -> keyLightCol[ 1 ] = 0.0;
		NH3DOpenGLViewCast( self ) -> keyLightCol[ 2 ] = 0.0;
	} else {
		NH3DOpenGLViewCast( self ) -> keyLightCol[ 1 ] = 2.00 - ( gblight * 2.0 );
		NH3DOpenGLViewCast( self ) -> keyLightCol[ 2 ] = 2.00 - ( gblight * 2.0 );
	}
	
	glPushMatrix();
	
	glTranslatef( NH3DOpenGLViewCast( self ) -> lastCameraX,
				 NH3DOpenGLViewCast( self ) -> lastCameraY,
				 NH3DOpenGLViewCast( self ) -> lastCameraZ );
	
	glFogi( GL_FOG_MODE , GL_LINEAR );
	glHint( GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST );
	
	glFogf( GL_FOG_START , 0.0 );
	
	switch ( NH3DOpenGLViewCast( self ) -> elementalLevel ) {
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
	
	if ( NH3DOpenGLViewCast( self ) -> isReady && ( Blind || u.uswallow ) ) {
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
		
	} else if ( NH3DOpenGLViewCast( self ) -> isReady && Underwater ) {
		
		glLightfv( GL_LIGHT0, GL_POSITION, AmbLightPos );
		glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
		glLightf( GL_LIGHT0, GL_SHININESS, 1.0 );
		
		glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
		glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
		glLightfv( GL_LIGHT1, GL_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
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
		glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
		glLightf( GL_LIGHT0, GL_SHININESS, 0.01 );
		
		glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
		glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
		glLightfv( GL_LIGHT1, GL_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
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
		glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
		glLightf( GL_LIGHT0, GL_SHININESS, 0.01 );
		
		glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
		glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
		glLightfv( GL_LIGHT1, GL_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
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
		glLightfv( GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
		glLightf( GL_LIGHT0, GL_SHININESS, 1.0 );
		
		glLightfv( GL_LIGHT1, GL_POSITION, keyLightPos );
		glLightfv( GL_LIGHT1, GL_AMBIENT, keyLightAmb );
		glLightfv( GL_LIGHT1, GL_DIFFUSE, NH3DOpenGLViewCast( self ) -> keyLightCol );
		glLightfv( GL_LIGHT1, GL_SPECULAR, keyLightspec );
		glLightfv( GL_LIGHT1, GL_EMISSION, lightEmisson );
		glLightf( GL_LIGHT1, GL_SHININESS, 10.0 );

		glFogf( GL_FOG_END ,  4.5 + u.nv_range * NH3DGL_TILE_SIZE );
		glFogfv( GL_FOG_COLOR,fogColor );
		
	}
	
	glEnable( GL_LIGHT0 );
	glEnable( GL_LIGHT1 );
	
	glPopMatrix();
	
}


static void drawfunc_0( int x ,int z ,int lx ,int lz ,id self )
{
	drawNullObject( ( float )x*NH3DGL_TILE_SIZE,( float )z*NH3DGL_TILE_SIZE, NH3DOpenGLViewCast( self ) -> nullTex );
}

static void drawfunc_1( int x ,int z ,int lx ,int lz ,id self )
{
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						2,self );
}

static void drawfunc_2( int x ,int z ,int lx ,int lz ,id self )
{					
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						1,self );
	NH3DOpenGLViewCast( self ) ->drawModelArrayImp( self,@selector( drawModelArray: ),NH3DOpenGLViewCast( self ) -> mapItemValue[ lx ][ lz ] );
}

static void drawfunc_3( int x ,int z ,int lx ,int lz ,id self )
{					
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						2,self );
	NH3DOpenGLViewCast( self ) ->drawModelArrayImp( self,@selector( drawModelArray: ),NH3DOpenGLViewCast( self ) -> mapItemValue[ lx ][ lz ] );
}

static void drawfunc_4( int x ,int z ,int lx ,int lz ,id self )
{
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						3,self );
}

static void drawfunc_5( int x ,int z ,int lx ,int lz ,id self )
{					
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						4,self );}

static void drawfunc_6( int x ,int z ,int lx ,int lz ,id self )
{
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						5,self );
}

static void drawfunc_7( int x ,int z ,int lx ,int lz ,id self )
{
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						6,self );
}

static void drawfunc_8( int x ,int z ,int lx ,int lz ,id self )
{
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						7,self );
}

static void drawfunc_9( int x ,int z ,int lx ,int lz ,id self )
{
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						8,self );
}

/*
static void drawfunc_a( int x ,int z ,int lx ,int lz ,id self )
{
	drawNullObject( ( float )x*NH3DGL_TILE_SIZE,( float )z*NH3DGL_TILE_SIZE, NH3DOpenGLViewCast( self ) -> wallTex );
}
*/

static void drawfunc_a( int x ,int z ,int lx ,int lz ,id self )
{					
	drawFloorAndCeiling( x*NH3DGL_TILE_SIZE,
						z*NH3DGL_TILE_SIZE,
						2,self );
	[ self drawModelArray: NH3DOpenGLViewCast( self ) -> mapItemValue[ lx ][ lz ] ];
}


static void drawfunc_default( int x ,int z ,int lx ,int lz ,id self )
{
	
	return;
}

//---------- draw floor function ----------------

static void floorfunc_0( id self )
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> floorCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glDisable( GL_TEXTURE_2D );
}

static void floorfunc_1( id self )
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cellingCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );	
	
	glDisable( GL_TEXTURE_2D );
}

static void floorfunc_2( id self )
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> floorCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cellingCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );	
	
	glDisable( GL_TEXTURE_2D );
}

static void floorfunc_3( id self ) // draw pool
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );

	glAlphaFunc( GL_GREATER, 0.5 );
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> poolTex );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glActiveTexture( GL_TEXTURE1 );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> envelopTex );
	
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
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cellingCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );	
	
	glDisable( GL_TEXTURE_2D );
}	

static void floorfunc_4( id self ) // draw ice
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> floorCurrent );
	
	glMaterialf( GL_FRONT , GL_EMISSION , 10.0 );
	
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glActiveTexture( GL_TEXTURE1 );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> envelopTex );
	
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
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cellingCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 , CeilingVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glDisable( GL_TEXTURE_2D );
	
}


static void floorfunc_5( id self ) // draw lava
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> lavaTex );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	GLfloat emisson[ 4 ] = { 1.0, 1.0, 1.0, 1.0 };
	glMaterialfv( GL_FRONT , GL_EMISSION , emisson );
	
	glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cellingCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT , 0 , CeilingVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glDisable( GL_TEXTURE_2D );
	
}

static void floorfunc_6( id self ) // draw air
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> airTex );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT , 0 ,FloorVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glDisable( GL_TEXTURE_2D );
}

static void floorfunc_7( id self ) // draw cloud
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cloudTex );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT, 0 ,FloorVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, FloorTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , FloorVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glDisable( GL_TEXTURE_2D );
	
}

static void floorfunc_8( id self ) // draw water
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> waterTex );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glActiveTexture( GL_TEXTURE1 );
	glEnable( GL_TEXTURE_2D );
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> envelopTex );
	
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
	
	glBindTexture( GL_TEXTURE_2D, NH3DOpenGLViewCast( self ) -> cellingCurrent );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	glNormalPointer( GL_FLOAT , 0 , CeilingVertNorms );
	glTexCoordPointer( 2,GL_FLOAT,0, CeilingTexVerts );
	glVertexPointer( 3 , GL_FLOAT , 0 , CeilingVerts );
	glDrawArrays( GL_TRIANGLE_STRIP , 0 , 4 );
	
	glDisable( GL_TEXTURE_2D );
	
}

static void floorfunc_default( id self )
{
	return;
}


- ( BOOL )isOpaque
{
	return ( !firstTime ) ? YES : NO ;
}


- ( void )turnOnSmooth
{
	glEnable( GL_POLYGON_SMOOTH );
    glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST );
}

- ( void )turnOffSmooth
{
	glDisable( GL_POLYGON_SMOOTH );
}




- ( id ) initWithFrame: ( NSRect ) theFrame
{
	int i;
	
	NSOpenGLPixelFormatAttribute attribs [] = {
		NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,		/* use double buffer */
		NSOpenGLPFAAccelerated,			/* use HW accelerate */
		//NSOpenGLPFAStencilSize,32,		/* set Stencil buffer size */
		NSOpenGLPFAAlphaSize,8,
		NSOpenGLPFAColorSize,24,		/* set Color buffer size */
		NSOpenGLPFADepthSize,16,		/* set Depth buffer size */
		0								/* null termnator */
	};
	NSOpenGLPixelFormat *pfmt;
	
	/* Create a GL Context to use - i.e. init the superclass */
	pfmt = [ [ NSOpenGLPixelFormat alloc ] initWithAttributes: attribs ];
	self = [ super initWithFrame: theFrame pixelFormat: pfmt ];
	[ [ self openGLContext ] makeCurrentContext ];
	[ pfmt release ];
	
	[ self setFrameSize: theFrame.size ];
	
	glMatrixMode ( GL_PROJECTION );
	glLoadIdentity();
	
	glClearColor( 0,0,0,0 );
	glClearDepth( 1.0 );
	
	gluPerspective( 76.0,			/* View angle */
				    ( double )theFrame.size.width / ( double )theFrame.size.height, /*Aspect rasio */ 
					0.1,			/* Near limit Distance from origin*/
					30.0 );			/* Far limit  */	
	
	
	// alpha blending
	glEnable( GL_BLEND );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	//[ self turnOnSmooth ];
	
	glShadeModel( GL_SMOOTH );
	//glShadeModel( GL_FLAT );
	
	
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
		[ effectArray[ i ] setParticleType:NH3DParticleTypePoints ];
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
}

- ( void ) dealloc
{
	int i,j;
	
	[ delayDrawing removeAllObjects ];
	[ delayDrawing release ];

	[ modelDictionary removeAllObjects ];
	[ modelDictionary release ];
	
	for ( i=0 ; i<NH3D_MAX_EFFECTS ;i++ ) {
		[ effectArray[ i ] release ];
	}
	
	for ( i=0 ; i<NH3DGL_MAPVIEWSIZE_COLUMN ;i++ ) {
		for ( j=0 ; j<NH3DGL_MAPVIEWSIZE_ROW ; j++ ) {
			[ mapItemValue [ i ][ j ] release ];
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
	
	
	[ viewLock release ];
	[ super dealloc ];
}


-(void)detachOpenGLThread
{
	int i;
	threadRunning = YES;
	
	for ( i=0 ; i<OPENGLVIEW_NUMBER_OF_THREADS ;i++ )
	[ NSThread detachNewThreadSelector:@selector( timerFired: ) toTarget:self withObject:self ];
}


-( void )awakeFromNib
{
	
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
	[ self setNeedsDisplay:YES ];

	// setup from defaults
	[ self defaultDidChange:nil ];
	
	useTile = NH3DGL_USETILE;
	
	// Create and detach to other thread for OpenGL update and drawing.  
	if ( !TRADITIONAL_MAP ) [ self detachOpenGLThread ];
	
}


- ( float )cameraHead
{
	return cameraHead;
}


// OpenGL update method.
- ( void )timerFired:( id )sender
{
	NSAutoreleasePool *threadPool = [ [NSAutoreleasePool alloc] init ];
	
	// cash method addresses.
	IMP	needsDisplayAddress = [ self methodForSelector:@selector( needsDisplay ) ];
	IMP updateGlViewAddress = [ self methodForSelector:@selector( updateGlView ) ];
	
	drawGlViewAddress = [ self methodForSelector:@selector( drawGlView:z: ) ];
	playerDirectionImp = [ _mapModel methodForSelector:@selector( playerDirection ) ];
	drawModelArrayImp = [ self methodForSelector:@selector( drawModelArray: ) ];
	panCameraImp = [ self methodForSelector:@selector( panCamera ) ];
	dorryCameraImp = [ self methodForSelector:@selector( dorryCamera ) ];
	floatingCameraImp = [ self methodForSelector:@selector( floatingCamera ) ];
	shockedCameraImp = [ self methodForSelector:@selector( shockedCamera ) ];
	
	
	[ [ self openGLContext ] makeCurrentContext ];
	
	
	flushBufferImp = [ [ self openGLContext ] methodForSelector:@selector( flushBuffer ) ];
	
	[ viewLock lock ];
	
	if ( OPENGLVIEW_WAITSYNC )
		[ [ self openGLContext ] setValues:&vsincWait forParameter:NSOpenGLCPSwapInterval ];
	else 
		[ [ self openGLContext ] setValues:&vsincNoWait forParameter:NSOpenGLCPSwapInterval ];
	[ viewLock unlock ];
	
	while ( runnning && !TRADITIONAL_MAP ) {
		NSAutoreleasePool *pool = [ [NSAutoreleasePool alloc] init ];

		if ( isReady && !nowUpdating && !needsDisplayAddress( self, @selector( needsDisplay )) ) {
		//if ( isReady && !nowUpdating ) {
			updateGlViewAddress( self, @selector( updateGlView ));
		}
		
		
		if ( hasWait ) [ NSThread sleepUntilDate:[ NSDate dateWithTimeIntervalSinceNow:( 1.0 / waitRate ) ] ];
		
		[ pool release ];
	}
	
	[ threadPool release ];
	[ NSThread exit ];
}


// draw title.
- ( void ) drawRect: ( NSRect ) theRect
{
	
	if ( isReady || !firstTime ) {
		return; 
	} else {
		NSMutableDictionary *attributes = [ [ NSMutableDictionary alloc ] init ];
		[ attributes setObject:[ NSFont fontWithName:@"Copperplate"
											  size: 20 ]
					   forKey:NSFontAttributeName				 ];
		[ attributes setObject:[ NSColor colorWithCalibratedWhite:0.5 alpha:0.6 ]
					   forKey:NSForegroundColorAttributeName ];
	
		[ self lockFocusIfCanDraw ];
	
		[ [ NSColor clearColor ] set ];
		[ NSBezierPath fillRect:[ self bounds ] ];
	
		[[NSImage imageNamed:@"nh3d"] drawAtPoint:NSMakePoint( 156.0 ,88.0 ) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.7];
		//[ [ NSImage imageNamed:@"nh3d" ] dissolveToPoint:NSMakePoint( 156.0 ,88.0 ) fraction:0.7 ];
		[ @"NetHack3D" drawAtPoint:NSMakePoint( 168.0 ,70.0 ) withAttributes:attributes ];
		[ attributes setObject:[ NSFont fontWithName:@"Copperplate"
												size: 14 ]
						forKey:NSFontAttributeName	 ];
		[ @"by Haruumi Yoshino 2005" drawAtPoint:NSMakePoint( 130.0 ,56.0 ) withAttributes:attributes ];
		[ @"NetHack" drawAtPoint:NSMakePoint( 192.0 ,29.0 ) withAttributes:attributes ];
		[ attributes setObject:[ NSFont fontWithName:@"Copperplate"
												size: 11 ]
						forKey:NSFontAttributeName ];
		[ @"Copyright ( c ) Stichting Mathematisch Centrum  Amsterdam, 1985. \n   NetHack may be freely redistributed. See license for details."
						drawAtPoint:NSMakePoint( 38.0 ,3.0 ) withAttributes:attributes ];
	
		[ self unlockFocus ];
	
		[ attributes release ];
	
		firstTime = NO;
	
	}

}

- ( void )drawGlView:( int )x z:( int )z
{
	NH3DMapItem *mapItem = [ mapItemValue[ x ][ z ] retain ];
	int			type = [ mapItem modelDrawingType ];
				
	if ( type != 10 ) {
		switchMethodArray[ type ]( 	[ mapItem posX ],
									[ mapItem posY ],
									x,z,self );
	} else {
		// delay drawing for alphablending.
		NSNumber *numX = [ [ NSNumber alloc ] initWithInt:x ];
		NSNumber *numZ = [ [ NSNumber alloc ] initWithInt:z ];
		
		[ delayDrawing addObject:mapItem ];
		[ delayDrawing addObject:numX ];
		[ delayDrawing addObject:numZ ];
		[ numX release ];
		[ numZ release ]; 
		// if you want use this method from difference thread,
		// you must do some tricky technique for using collectionclass. 
		// e.g;
		// [ NSMutableArrayobject addObject:[ [ [ NSNumber numberWithInt:x ] retain ] autorelease ] ];
		// [ NSDictionaryobject addObject:[ [ mapItem retain ] autorelease ] ];
	}
	[ mapItem release ];
}

// Drawing OpenGL functions.
- ( void )updateGlView
{		
	
	if ( nowUpdating || TRADITIONAL_MAP ) return;
	
	if ( [ viewLock tryLock ] ) {
		
		static int clearCnt;
		int x,z;
		nowUpdating = YES;
		
		if (!Hallucination || clearCnt == 10) { glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT ); clearCnt=0; }
		else clearCnt++;
		
		
		glPushMatrix();
		
		panCameraImp( self,@selector( panCamera ) );
		dorryCameraImp( self,@selector( dorryCamera ) );
		
		if ( isFloating ) floatingCameraImp( self,@selector( floatingCamera) );
		if ( isShocked ) shockedCameraImp( self,@selector( shockedCamera ) );
		
		// draw models
		// at first. normal objects
		switch ( (int)playerDirectionImp(_mapModel, @selector( playerDirection )) ) {
			case PL_DIRECTION_FORWARD:
				for ( x=0 ; x < NH3DGL_MAPVIEWSIZE_COLUMN ; x++ ) {
					for ( z=0 ; z < MAP_MARGIN+drawMargin ; z++ ) {
						drawGlViewAddress( self, @selector( drawGlView:z: ),x,z );
					}
				}
				break;
			case PL_DIRECTION_RIGHT:
				for ( z=0 ; z < NH3DGL_MAPVIEWSIZE_ROW ; z++ ) {
					for ( x=NH3DGL_MAPVIEWSIZE_COLUMN-1 ; x > MAP_MARGIN-drawMargin ; x-- ) {
						drawGlViewAddress( self, @selector( drawGlView:z: ),x,z );
					}
				}
				break;
			case PL_DIRECTION_BACK:
				for ( x=0 ; x < NH3DGL_MAPVIEWSIZE_COLUMN ; x++ ) {
					for ( z=NH3DGL_MAPVIEWSIZE_ROW-1 ; z > MAP_MARGIN-drawMargin ; z-- ) {
						drawGlViewAddress( self, @selector( drawGlView:z: ),x,z );
					}
				}
				break;
			case PL_DIRECTION_LEFT:
				for ( z=0 ; z < NH3DGL_MAPVIEWSIZE_ROW ; z++ ) {
					for ( x=0 ; x < MAP_MARGIN+drawMargin ; x++ ) {
						drawGlViewAddress( self, @selector( drawGlView:z: ),x,z );
					}
				}
				break;
		}
				
		// next. particle objects
		for ( x=0 ; x < [ delayDrawing count ] ; x+=3 ) {
			NH3DMapItem *mapItem = [ delayDrawing objectAtIndex:x ];
			int lx = [ [ delayDrawing objectAtIndex:x+1 ] intValue ];
			int lz = [ [ delayDrawing objectAtIndex:x+2 ] intValue ];
			switchMethodArray[ [ mapItem modelDrawingType ] ]( [ mapItem posX ] ,
															   [ mapItem posY ] ,lx,lz,self );
		} // end for x
		
		
		if ( enemyPosition ) {
			[ self doEffect ];
		}
		
		
		createLightAndFog( self );
		
		glPopMatrix();
		
		//[ [ self openGLContext ] flushBuffer ];
		flushBufferImp( [ self openGLContext ] , @selector( flushBuffer ) );
		
		[ delayDrawing removeAllObjects ];
		
		nowUpdating = NO;
		[ viewLock unlock ];
	}
}


- ( void ) setFrameSize: ( NSSize ) newSize
{
	[ super setFrameSize: newSize ];
	
	glViewport( 0, 0, newSize.width, newSize.height );
}


- ( void )clearGLView
{
	glClearColor( 0, 0, 0, 0 );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
}


- ( void )drawModelArray:( NH3DMapItem * )mapItem
{
	int glyph = [ mapItem glyph ];
	
	if ( glyph != S_room + GLYPH_CMAP_OFF ) {
		[ viewLock lock ];
		static GLfloat rot;
		float posx = [ mapItem posX ] * NH3DGL_TILE_SIZE;
		float posz = [ mapItem posY ] * NH3DGL_TILE_SIZE;
		
		NSNumber *modelNum = @(glyph);
		id model = [ [modelDictionary objectForKey:modelNum] retain ];
		
		if ( model == nil && !defaultTex[ glyph ] ) {
			id newModel = loadModelAddreses[ glyph ]( self, loadModelSelectors[ glyph ], glyph );
			if ( newModel != nil ) {
				if ( glyph >= PM_GIANT_ANT+GLYPH_MON_OFF && glyph <= PM_APPRENTICE + GLYPH_MON_OFF ) {
					[ newModel setAnimated:YES ];
					[ newModel setAnimationRate:( ( float )( random() %5 )*0.1 )+0.5 ];
					[ newModel setPivotX:0.0 atY:0.3 atZ:0.0 ];
					[ newModel setUseEnvironment:YES ];
					[ newModel setTexture:envelopTex ];
				}
				//NSLog(@"bf retaincount %d",[ newModel retainCount ]);
				[ modelDictionary setObject:newModel forKey:modelNum ];
				//NSLog(@"af retaincount %d",[ newModel retainCount ]);
				[ newModel autorelease ];
				[ keyArray addObject:[NSNumber numberWithInt:glyph] ];
				
				model = [ [modelDictionary objectForKey:modelNum] retain ];
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
					defaultTex[glyph] = [self createTextureFromSymbol:[mapItem tile] withColor:nil];
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
			
			[ model release ];
			
		}
		
		glPopMatrix();
		
		rot += 0.05;
		[ viewLock unlock ];
	}
	
}


- ( void )updateMap
{
	
	if ( !isReady || TRADITIONAL_MAP ) {
		return;
	} else {
		
		[ viewLock lock ];
		int x,z;
		int localx = 0;
		int localz = 0;
		
		nowUpdating = YES;
		
		for ( x = centerX-MAP_MARGIN;x < centerX+1+MAP_MARGIN;x++ ) {
			for ( z = centerZ-MAP_MARGIN;z < centerZ+1+MAP_MARGIN;z++ ) {
				NH3DMapItem *mapItem = [ [ _mapModel mapArrayAtX:x atY:z ] retain ];
				[ mapItemValue[ localx ][ localz ] release ];
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
	[ [modelDictionary objectForKey:[ NSNumber numberWithInt:S_vwall + GLYPH_CMAP_OFF ]] setTexture:tex_id ];
	[ [modelDictionary objectForKey:[ NSNumber numberWithInt:S_hwall + GLYPH_CMAP_OFF ]] setTexture:tex_id ];
	[ [modelDictionary objectForKey:[ NSNumber numberWithInt:S_tlcorn + GLYPH_CMAP_OFF ]] setTexture:tex_id ];	
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
		
	[ viewLock unlock ];
	
}


- ( void )setCameraAtX:( float )x atY:( float )y atZ:( float )z
{	
	
	[ viewLock lock ];
		
		nowUpdating = YES;	
		NSSound *footstep = [ NSSound soundNamed:@"footStep.wav" ];
		
		drawMargin = 1;
		
		cameraX = x;
		cameraY = y;
		cameraZ = z;
		
		
		if ( !isReady ) {
			lastCameraX = cameraX;
			lastCameraY = cameraY;
			lastCameraZ = cameraZ;
			isReady = YES;

		} else 	if ( [ footstep isPlaying ] && ( (!isFloating || isRiding) && !IS_SOFT( levl[ u.ux ][ u.uy ].typ )) && !SOUND_MUTE ) {
			[ footstep stop ];
			[ footstep play ];
		} else if ( (!isFloating || isRiding) && !IS_SOFT( levl[ u.ux ][ u.uy ].typ ) && !SOUND_MUTE ) {
			[ footstep play ];
		}
		
		nowUpdating = NO;
				
	[ viewLock unlock ];
	
	if ( TRADITIONAL_MAP ) [ self setHidden:YES ];
	else if ( !TRADITIONAL_MAP && !threadRunning ) { [ [self openGLContext] setView:self ]; [ self detachOpenGLThread ]; }
	
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
	NH3DVertexType localPos = [ effectArray[ enemyPosition-1 ] modelShift ];
	
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
	NSImage				*sourcefile = [ [ NSImage alloc ] initWithContentsOfFile:[ NSString stringWithFormat:@"%@/%@",
																				[ [ NSBundle mainBundle ] resourcePath ],
																				 filename ]							 ];
	NSBitmapImageRep	*imgrep;
	GLuint tex_id;
	
	imgrep = [ [ NSBitmapImageRep alloc ] initWithData:[ sourcefile TIFFRepresentation ] ];
	
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
	gluBuild2DMipmaps( GL_TEXTURE_2D,GL_RGBA,
					  [ imgrep pixelsWide ],[ imgrep pixelsHigh ],
					 [ imgrep hasAlpha ] ? GL_RGBA : GL_RGB,
					  GL_UNSIGNED_BYTE,[ imgrep bitmapData ] );
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );

	[ imgrep release ];
	[ sourcefile release ];

	[ viewLock unlock ];
	
	return tex_id;
}


- ( GLuint )createTextureFromSymbol:( id )symbol withColor:( NSColor* )color
{
	[ viewLock lock ];
	[ symbol retain ];
	
	GLuint tex_id;
	NSImage				*img = [[NSImage alloc] initWithSize:NSMakeSize( TEX_SIZE , TEX_SIZE )];
	NSBitmapImageRep	*imgrep;
	NSSize				symbolsize;
	
	img.backgroundColor = [NSColor clearColor];
	
	if ( !NH3DGL_USETILE ) {
		NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		NSString *fontName = [[[NSUserDefaults standardUserDefaults] stringForKey:NH3DWindowFontKey] retain];
		
		
		attributes[NSFontAttributeName] = [NSFont fontWithName: fontName
														  size: TEX_SIZE];
		[fontName release];
		attributes[NSForegroundColorAttributeName] = color;
		attributes[NSBackgroundColorAttributeName] = [NSColor clearColor];
		
		symbolsize = [symbol sizeWithAttributes:attributes];
	
		// Draw texture
		[img lockFocus];
		
		[symbol drawAtPoint:NSMakePoint( ( TEX_SIZE/2 ) - ( symbolsize.width/2 ) ,( TEX_SIZE/2 ) - ( symbolsize.height/2 ) )
			  withAttributes:attributes];
		
		[img unlockFocus];
		[attributes release];
		
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
	
	[symbol release];
	
	imgrep = [[NSBitmapImageRep alloc] initWithData:[img TIFFRepresentation]];
	
	
	glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
	
	glGenTextures( 1, &tex_id );
	glBindTexture( GL_TEXTURE_2D, tex_id );
	
	glTexParameterf( GL_TEXTURE_2D,GL_GENERATE_MIPMAP,GL_TRUE );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	// create automipmap texture
	
	if ([imgrep hasAlpha]) {
		gluBuild2DMipmaps( GL_TEXTURE_2D,GL_RGBA,
						   [ imgrep pixelsWide ],[ imgrep pixelsHigh ],
						   GL_RGBA,
						   GL_UNSIGNED_BYTE,[ imgrep bitmapData ] );
	} else {
		gluBuild2DMipmaps( GL_TEXTURE_2D,GL_RGB,
						   [ imgrep pixelsWide ],[ imgrep pixelsHigh ],
						   GL_RGB,
						   GL_UNSIGNED_BYTE,[ imgrep bitmapData ] );
	}		
		
	
	// setup texture status
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
	
	glAlphaFunc( GL_GREATER, 0.5 );
	
	[imgrep release];
	[img release];
	
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
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_ORANGE ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleGravityX:0.0 Y:2.0 Z:0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:6.0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleLife:0.30 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSize:10.0 ];
	[modelDictionary setObject:model
						forKey:@(S_vwall + GLYPH_CMAP_OFF)];
	[model release];
			
				
	model = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"hwall" withTexture:YES ];
	[ model addTexture:@"wall_mines" ];
	[ model addTexture:@"wall_hell" ];
	[ model addTexture:@"wall_knox" ];
	[ model addTexture:@"wall_rouge" ];
		[ model addChildObject:@"touch" type:NH3DModelTypeTexturedObject ];
		[ [ model childObjectAtLast ] setPivotX:-0.005 atY:2.834 atZ:0.483 ];
		[ [ model childObjectAtLast ] addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setPivotX:0.593 atY:1.261 atZ:0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_ORANGE ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleGravityX:0.0 Y:2.0 Z:0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:6.0 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleLife:0.30 ];
			[ [ [ model childObjectAtLast ] childObjectAtLast ] setParticleSize:10.0 ];
		[ [ model childObjectAtLast ] setModelRotateX:0.0 rotateY:-90.0 rotateZ:0.0 ];
	[modelDictionary setObject:model
						forKey:@(S_hwall + GLYPH_CMAP_OFF)];
	[model release];
	
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"corner" withTexture:YES];
	[model addTexture:@"corner_mines"];
	[model addTexture:@"corner_hell"];
	[model addTexture:@"corner_knox"];
	[model addTexture:@"corner_rouge"];
	
	[modelDictionary setObject:model
						forKey:@(S_tlcorn + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_trcorn + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_blcorn + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_brcorn + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_crwall + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_tuwall + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_tdwall + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_tlwall + GLYPH_CMAP_OFF)];
	[modelDictionary setObject:model
						forKey:@(S_trwall + GLYPH_CMAP_OFF)];
	
	[model release];
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"vopendoor" withTexture:YES];
	[modelDictionary setObject:model
						forKey:@(S_vodoor + GLYPH_CMAP_OFF)];
	[model release];
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"hopendoor" withTexture:YES];
	[modelDictionary setObject:model
						forKey:@(S_hodoor + GLYPH_CMAP_OFF)];
	[model release];
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"vdoor" withTexture:YES];
	[modelDictionary setObject:model
						forKey:@(S_vcdoor + GLYPH_CMAP_OFF)];
	[model release];
	
	model = [[NH3DModelObjects alloc] initWith3DSFile:@"hdoor" withTexture:YES];
	[modelDictionary setObject:model
						 forKey:@(S_hcdoor + GLYPH_CMAP_OFF)];
	[model release];
			
		
	}
}


- ( id )checkLoadedModelsAt:(int)startNum
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
		if ( [ modelDictionary objectForKey:[ NSNumber numberWithInt:i ] ] != nil ) {
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
					return [[modelDictionary objectForKey:@(i)] retain];
					
			} else																	// Increment retain count
				return [[modelDictionary objectForKey:@(i)] retain];
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
	[ magicItem setParticleType:NH3DParticleTypeAura ];
	[ magicItem setParticleColor:color ];
	[ magicItem setParticleGravityX:0.0 Y:6.5 Z:0.0 ];
	[ magicItem setParticleSpeedX:1.0 Y:1.00 ];
	[ magicItem setParticleSlowdown:3.8 ];
	[ magicItem setParticleLife:0.4 ];
	[ magicItem setParticleSize:20.0 ];	
}


- (void)setParamsForMagicExplotion:(NH3DModelObjects*)magicItem color:(int)color
{
	[magicItem setParticleType:NH3DParticleTypeAura ];
	[magicItem setParticleColor:color ];
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
						   modelName:@"lowerA" textured:NO withOut:nil];
}


- ( id )loadModelFunc_blob:(int)glyph
{
	// blob class
	return [self checkLoadedModelsAt:PM_ACID_BLOB
								  to:PM_GELATINOUS_CUBE
							  offset:GLYPH_MON_OFF
						   modelName:@"lowerB" textured:NO withOut:nil];
}


- ( id )loadModelFunc_cockatrice:(int)glyph
{
		// cockatrice class
	return [ self checkLoadedModelsAt:PM_CHICKATRICE
								   to:PM_PYROLISK
							   offset:GLYPH_MON_OFF
							modelName:@"lowerC" textured:NO withOut:nil];
}


- ( id )loadModelFunc_dog:(int)glyph
{
	// dog or canine class
	return [ self checkLoadedModelsAt:PM_JACKAL
								   to:PM_HELL_HOUND
							   offset:GLYPH_MON_OFF
							modelName:@"lowerD" textured:NO withOut:nil ];
	
}


- ( id )loadModelFunc_sphere:(int)glyph
{
	// eye or sphere class
	return [ self checkLoadedModelsAt:PM_GAS_SPORE
								   to:PM_SHOCKING_SPHERE
							   offset:GLYPH_MON_OFF
							modelName:@"lowerE" textured:NO withOut:nil ];
	
}


- ( id )loadModelFunc_cat:(int)glyph
{	
	// cat or feline class
	return [ self checkLoadedModelsAt:PM_KITTEN
								   to:PM_TIGER
							   offset:GLYPH_MON_OFF
							modelName:@"lowerF" textured:NO withOut:nil ];
	
}


- ( id )loadModelFunc_gremlins:(int)glyph
{
	// gremlins and gagoyles class
	return [ self checkLoadedModelsAt:PM_GREMLIN
								   to:PM_WINGED_GARGOYLE
							   offset:GLYPH_MON_OFF
							modelName:@"lowerG" textured:NO withOut:nil ];
	
}


- ( id )loadModelFunc_humanoids:(int)glyph
{
	// humanoids class
	id ret =nil;
	
	if ( glyph ==  PM_DWARF_KING+GLYPH_MON_OFF ) {
		ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerH" withTexture:NO ];
		[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
		[ [ret childObjectAtLast] setPivotX:0.0 atY:0.2 atZ:-0.21 ];
		[ [ret childObjectAtLast] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
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
							  withOut:nil ];
}


- ( id )loadModelFunc_jellys:(int)glyph
{
	// jellys	
	return [ self checkLoadedModelsAt:PM_BLUE_JELLY
								   to:PM_OCHRE_JELLY
							   offset:GLYPH_MON_OFF
							modelName:@"lowerJ"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_kobolds:(int)glyph
{
	// kobolds
	id ret = nil;
	
	switch ( glyph ) {
		case PM_KOBOLD+GLYPH_MON_OFF :
		case PM_LARGE_KOBOLD+GLYPH_MON_OFF :
			ret = [ self checkLoadedModelsAt:PM_KOBOLD
										  to:PM_LARGE_KOBOLD
									  offset:GLYPH_MON_OFF
								   modelName:@"lowerK"
									textured:NO
									 withOut:nil ];
			break;
			
		case PM_KOBOLD_LORD+GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerK" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.1 atZ:-0.25 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			
			break;
			
		case PM_KOBOLD_SHAMAN + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerK" withTexture:NO ];
			[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.01 atZ:-0.15 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			
			break;
	}
	
	return ret;
	
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
							  withOut:nil ];
	
}


- ( id )loadModelFunc_nymphs:(int)glyph
{
	// nymphs	
	return [ self checkLoadedModelsAt:PM_WOOD_NYMPH
								   to:PM_MOUNTAIN_NYMPH
							   offset:GLYPH_MON_OFF
							modelName:@"lowerN"
							 textured:NO
							  withOut:nil ];	
}


- ( id )loadModelFunc_orc:(int)glyph
{
	// orc class
	id ret = nil;
	
	if ( glyph ==  PM_ORC_SHAMAN + GLYPH_MON_OFF ) {
		ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"lowerO" withTexture:NO ];
		[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
		[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.15 atZ:-0.15 ];
		[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
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
							  withOut:nil ];
	
}


- ( id )loadModelFunc_quadrupeds:(int)glyph
{
	// quadrupeds
	return [ self checkLoadedModelsAt:PM_ROTHE
								   to:PM_MASTODON
							   offset:GLYPH_MON_OFF
							modelName:@"lowerQ"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_rodents:(int)glyph
{
	// rodents
	return [ self checkLoadedModelsAt:PM_SEWER_RAT
								   to:PM_WOODCHUCK
							   offset:GLYPH_MON_OFF
							modelName:@"lowerR"
							 textured:NO
							  withOut:nil ];
		
}


- ( id )loadModelFunc_spiders:(int)glyph
{
	// spiders
	return [ self checkLoadedModelsAt:PM_CAVE_SPIDER
								   to:PM_SCORPION
							   offset:GLYPH_MON_OFF
							modelName:@"lowerS"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_trapper:(int)glyph
{
	// trapper
	return [ self checkLoadedModelsAt:PM_LURKER_ABOVE
								   to:PM_TRAPPER
							   offset:GLYPH_MON_OFF
							modelName:@"lowerT"
							 textured:NO
							  withOut:nil ];
	
	
}


- ( id )loadModelFunc_unicorns:(int)glyph
{
	// unicorns and horses
	return [ self checkLoadedModelsAt:PM_WHITE_UNICORN
								   to:PM_WARHORSE
							   offset:GLYPH_MON_OFF
							modelName:@"lowerU"
							 textured:NO
							  withOut:nil ];
		
}


- ( id )loadModelFunc_vortices:(int)glyph
{
	// vortices
	return [ self checkLoadedModelsAt:PM_FOG_CLOUD
								   to:PM_FIRE_VORTEX
							   offset:GLYPH_MON_OFF
							modelName:@"lowerV"
							 textured:NO
							  withOut:nil ];
}


- ( id )loadModelFunc_worms:(int)glyph
{
	// worms
	return [ self checkLoadedModelsAt:PM_BABY_LONG_WORM
								   to:PM_PURPLE_WORM
							   offset:GLYPH_MON_OFF
							modelName:@"lowerW"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_xan:(int)glyph
{
	// xan
	return [ self checkLoadedModelsAt:PM_GRID_BUG
								   to:PM_XAN
							   offset:GLYPH_MON_OFF
							modelName:@"lowerX"
							 textured:NO
							  withOut:nil ];	
}


- ( id )loadModelFunc_lights:(int)glyph
{
	// lights
	
	return [ self checkLoadedModelsAt:PM_YELLOW_LIGHT
								   to:PM_BLACK_LIGHT
							   offset:GLYPH_MON_OFF
							modelName:@"lowerY"
							 textured:NO
							  withOut:nil ];
	
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
							  withOut:nil ];
}


- ( id )loadModelFunc_Bats:(int)glyph
{
	// Bats
	return [ self checkLoadedModelsAt:PM_BAT
								   to:PM_VAMPIRE_BAT
							   offset:GLYPH_MON_OFF
							modelName:@"upperB"
							 textured:NO
							  withOut:nil ];
}


- ( id )loadModelFunc_Centaurs:(int)glyph
{
	// Centaurs
	return [ self checkLoadedModelsAt:PM_PLAINS_CENTAUR
								   to:PM_MOUNTAIN_CENTAUR
							   offset:GLYPH_MON_OFF
							modelName:@"upperC"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Dragons:(int)glyph
{
	// Dragons
	return [ self checkLoadedModelsAt:PM_BABY_GRAY_DRAGON
								   to:PM_YELLOW_DRAGON
							   offset:GLYPH_MON_OFF
							modelName:@"upperD"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Elementals:(int)glyph
{
	// Elementals
	return [ self checkLoadedModelsAt:PM_STALKER
								   to:PM_WATER_ELEMENTAL
							   offset:GLYPH_MON_OFF
							modelName:@"upperE"
							 textured:NO
							  withOut:nil ];
}


- ( id )loadModelFunc_Fungi:(int)glyph
{
	// Fungi
	return [ self checkLoadedModelsAt:PM_LICHEN
								   to:PM_VIOLET_FUNGUS
							   offset:GLYPH_MON_OFF
							modelName:@"upperF"
							 textured:NO
							  withOut:nil ];
	
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
									 withOut:nil ];
			
			break;
		case PM_GNOMISH_WIZARD + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperG" withTexture:NO ];
			[ ret addChildObject:@"wizardset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.01 atZ:-0.15 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			break;
			
		case PM_GNOME_KING + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperG" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.05 atZ:-0.25 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
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
							  withOut:nil ];
	
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
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Liches:(int)glyph
{
	
	// Liches
	return [ self checkLoadedModelsAt:PM_LICH
								   to:PM_ARCH_LICH
							   offset:GLYPH_MON_OFF
							modelName:@"upperL"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Mummies:(int)glyph
{
	// Mummies
	return [ self checkLoadedModelsAt:PM_KOBOLD_MUMMY
								   to:PM_GIANT_MUMMY
							   offset:GLYPH_MON_OFF
							modelName:@"upperM"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Nagas:(int)glyph
{
	// Nagas
	return [ self checkLoadedModelsAt:PM_RED_NAGA_HATCHLING
								   to:PM_GUARDIAN_NAGA
							   offset:GLYPH_MON_OFF
							modelName:@"upperN"
							 textured:NO
							  withOut:nil ];
	
	
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
									 withOut:nil ];
			break;
			
		case PM_OGRE_KING + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperO" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.15 atZ:-0.18 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
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
							  withOut:nil ];
	
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
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Snakes:(int)glyph
{
	// Snakes
	return [ self checkLoadedModelsAt:PM_GARTER_SNAKE
								   to:PM_COBRA
							   offset:GLYPH_MON_OFF
							modelName:@"upperS"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Trolls:(int)glyph
{
	// Trolls
	return [ self checkLoadedModelsAt:PM_TROLL
								   to:PM_OLOG_HAI
							   offset:GLYPH_MON_OFF
							modelName:@"upperT"
							 textured:NO
							  withOut:nil ];
	
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
									 withOut:nil ];
			
			break;
			
		case PM_VLAD_THE_IMPALER + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"upperV" withTexture:NO ];
			[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.15 atZ:-0.18 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
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
							  withOut:nil ];
	
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
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Zombie:(int)glyph
{
	// Zombie
	return [ self checkLoadedModelsAt:PM_KOBOLD_ZOMBIE
								   to:PM_SKELETON
							   offset:GLYPH_MON_OFF
							modelName:@"upperZ"
							 textured:NO
							  withOut:nil ];
	
}


- ( id )loadModelFunc_Golems:(int)glyph
{
	// Golems
	return [ self checkLoadedModelsAt:PM_STRAW_GOLEM
								   to:PM_IRON_GOLEM
							   offset:GLYPH_MON_OFF
							modelName:@"backslash"
							 textured:NO
							  withOut:nil ];
	
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
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			break;
			
		case PM_NURSE + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"nurse" type:NH3DModelTypeTexturedObject ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.28 atZ:1.00 ];
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			break;
			
		case PM_HIGH_PRIEST + GLYPH_MON_OFF :
		case PM_MEDUSA + GLYPH_MON_OFF :
		case PM_CROESUS + GLYPH_MON_OFF :
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"atmark" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			[ [ ret childObjectAtLast ] addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setPivotX:-0.827 atY:1.968 atZ:1.793 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleGravityX:-3.5 Y:1.5 Z:0.8 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSpeedX:1.5 Y:2.00 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleLife:0.5 ];
			[ [ [ ret childObjectAtLast ] childObjectAtLast ] setParticleSize:6.0 ];
			
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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


- ( id )loadModelFunc_Ghosts:(int)glyph
{
	// Ghosts
	return [ self checkLoadedModelsAt:PM_GHOST
								   to:PM_SHADE
							   offset:GLYPH_INVIS_OFF
							modelName:@"invisible"
							 textured:NO
							  withOut:nil ];
}


- ( id )loadModelFunc_MajorDamons:(int)glyph
{
	// Major Damons
	
	if ( glyph != PM_DJINNI+GLYPH_MON_OFF || glyph != PM_SANDESTIN+GLYPH_MON_OFF ) {
		return [ self checkLoadedModelsAt:PM_WATER_DEMON
									   to:PM_BALROG
								   offset:GLYPH_MON_OFF
								modelName:@"and"
								 textured:NO
								  withOut:nil ];
	} else {
		return [ self checkLoadedModelsAt:PM_DJINNI
									   to:PM_SANDESTIN
								   offset:GLYPH_MON_OFF
								modelName:@"and"
								 textured:NO
								  withOut:nil ];
	}		
}


- ( id )loadModelFunc_GraterDamons:(int)glyph
{
	// Grater Damons 
	id ret = nil;

	if ( glyph == PM_JUIBLEX + GLYPH_MON_OFF ) {
			ret = [ [ NH3DModelObjects alloc ] initWith3DSFile:@"and" withTexture:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
									 withOut:nil ];
			if ( ![ ret hasChildObject ] ) {
				[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
				[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
				[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
				[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
				[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
				[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
				[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
				[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
				[ ret addChildObject:@"kingset" type:NH3DModelTypeTexturedObject ];
				[ [ ret childObjectAtLast ] setPivotX:0.0 atY:0.52 atZ:0.0 ];
				[ [ ret childObjectAtLast ] setModelRotateX:0.0 rotateY:0.7 rotateZ:0.0 ];
				[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
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
								 withOut:nil ];
		
		if ( ![ ret hasChildObject ] ) {
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_RED ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:2.5 Z:0.0 ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:1.0 Y:1.00 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:8.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.24 ];
			[ [ ret childObjectAtLast ] setParticleSize:15.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
							  withOut:nil ];
	
}


- ( id )loadModelFunc_lizards:(int)glyph
{
	// lizards
	return [ self checkLoadedModelsAt:PM_NEWT
								   to:PM_SALAMANDER
							   offset:GLYPH_MON_OFF
							modelName:@"coron"
							 textured:NO
							  withOut:nil ];
	
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
								 withOut:nil ];
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
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setCurrentMaterial:nh3dMaterialArray[ NO_COLOR ] ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
										  withOut:PM_KING_ARTHUR,nil ];
				 
				 if ( ![ ret hasChildObject ] ) {
					 [ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
					 [ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
									 withOut:nil ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypePoints ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0.0 Y:-8.8 Z:1.0 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.21 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:-0.687 atZ:0.512 ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypePoints ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_BLUE ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-130.0 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.8 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:0.34 atY:-1.70 atZ:-0.65 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.98 scaleY:0.7 scaleZ:0.98 ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.1 Z:0.00 ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BLUE ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:-130.0 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:4.2 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.28 ];
			[ [ ret childObjectAtLast ] setParticleSize:8.0 ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.5 scaleY:0.7 scaleZ:0.5 ];
			[ [ ret childObjectAtLast ] setPivotX:0.0 atY:1.35 atZ:-0.0 ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:0.4 Z:0.00 ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeBoth ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.8 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_CYAN ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.23 ];
			[ [ ret childObjectAtLast ] setIsChild:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:0.42 atZ:0.75917 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
			[ [ ret childObjectAtLast ] setParticleGravityX:0 Y:-4.8 Z:0 ];
			[ [ ret childObjectAtLast ] setParticleColor:CLR_BRIGHT_MAGENTA ];
			[ [ ret childObjectAtLast ] setParticleSpeedX:0.0 Y:0.1 ];
			[ [ ret childObjectAtLast ] setParticleSlowdown:1.8 ];
			[ [ ret childObjectAtLast ] setParticleLife:0.23 ];
			[ [ ret childObjectAtLast ] setIsChild:NO ];
			[ ret addChildObject:@"emitter" type:NH3DModelTypeEmitter ];
			[ [ ret childObjectAtLast ] setPivotX:-0.38 atY:0.42 atZ:0.75917 ];
			[ [ ret childObjectAtLast ] setModelScaleX:0.55 scaleY:0.8 scaleZ:0.55 ];
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
			[ [ ret childObjectAtLast ] setParticleType:NH3DParticleTypeAura ];
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
							 withOut:nil ];
	
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
							 withOut:nil ];
	
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
							 withOut:nil ];
	
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
							 withOut:nil ];
	
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
							 withOut:nil ];

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
							 withOut:nil ];

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
							 withOut:nil ];

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
	
		[ [NSUserDefaults standardUserDefaults] setBool:![ (NSCell*)sender state ] forKey:NH3DOpenGLWaitSyncKey ];
		[ [[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[ NSNumber numberWithBool:![ (NSCell*)sender state ]]
																			 forKey:NH3DOpenGLWaitSyncKey ];
		
	nowUpdating = NO;
	[ viewLock unlock ];
		if ( OPENGLVIEW_WAITSYNC )
			[ [ self openGLContext ] setValues:&vsincWait forParameter:NSOpenGLCPSwapInterval ];
		else 
			[ [ self openGLContext ] setValues:&vsincNoWait forParameter:NSOpenGLCPSwapInterval ];

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
			[(NSCell*) sender setState:NSOnState ];
			[ [NSUserDefaults standardUserDefaults] setBool:NO forKey:NH3DOpenGLUseWaitRateKey ];
			[ [[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[ NSNumber numberWithBool:NO]
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[ [[ sender menu ] itemWithTag:1004 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1005 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1006 ] setState:NSOffState ];
			break;
		case 1004 :
			waitRate = WAIT_FAST;
			[ (NSCell*)sender setState:NSOnState ];
			[ [NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DOpenGLUseWaitRateKey ];
			[ [[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[ NSNumber numberWithBool:YES]
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[ [[ sender menu ] itemWithTag:1003 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1005 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1006 ] setState:NSOffState ];			
			break;
		case 1005 :
			waitRate = WAIT_NORMAL;
			[ (NSCell*)sender setState:NSOnState ];
			[ [NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DOpenGLUseWaitRateKey ];
			[ [[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[ NSNumber numberWithBool:YES]
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[ [[ sender menu ] itemWithTag:1003 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1004 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1006 ] setState:NSOffState ];			
			break;
		case 1006 :
			waitRate = WAIT_SLOW;
			[ (NSCell*)sender setState:NSOnState ];
			[ [NSUserDefaults standardUserDefaults] setBool:YES forKey:NH3DOpenGLUseWaitRateKey ];
			[ [[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[ NSNumber numberWithBool:YES]
																				 forKey:NH3DOpenGLUseWaitRateKey ];
			
			[ [[ sender menu ] itemWithTag:1003 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1004 ] setState:NSOffState ];
			[ [[ sender menu ] itemWithTag:1005 ] setState:NSOffState ];			
			break;
	}
	
	cameraStep = waitRate / 8.5;
	
	nowUpdating = NO;
	oglParamNowChanging = NO;
	[ viewLock unlock ];
	
	[ [NSUserDefaults standardUserDefaults] setFloat:waitRate forKey:NH3DOpenGLWaitRateKey ];
	[ [[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[ NSNumber numberWithFloat:waitRate]
																		 forKey:NH3DOpenGLWaitRateKey ];
	
	CGDisplayModeRelease(curCfg);
}


- (void)defaultDidChange:(NSNotification *)notification
{
	
	if ( oglParamNowChanging ) return;
	
	if ( TRADITIONAL_MAP && !firstTime ) {
		[ _mapModel setPlayerDirection:PL_DIRECTION_FORWARD ];
		//[ self clearGLContext ];
		[ [self openGLContext] clearDrawable ];
		[ self setHidden:YES ];
		//[ [self openGLContext] setView:nil ];
		threadRunning = NO;
		//[ self update ];
	}
	if ( !TRADITIONAL_MAP && !firstTime ) {
		[ self setHidden:NO ];
		[ [self openGLContext] setView:self ];
		if ( !threadRunning )
			[ self detachOpenGLThread ];
	}
	
	[ viewLock lock ];
	
	NSMenu *oglFrameRateMenu = [ [[[[ self menu ] itemWithTag:1000] submenu] itemWithTag:1002] submenu ];
	
	nowUpdating = YES;
	hasWait = OPENGLVIEW_USEWAIT;
	
	if ( !hasWait ) {
		CGDisplayModeRef curCfg = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
		dRefreshRate = CGDisplayModeGetRefreshRate(curCfg);
		waitRate = dRefreshRate;
		[ [oglFrameRateMenu itemWithTag:1004 ] setState:NSOffState ];
		[ [oglFrameRateMenu itemWithTag:1005 ] setState:NSOffState ];
		[ [oglFrameRateMenu itemWithTag:1006 ] setState:NSOffState ];
		CGDisplayModeRelease(curCfg);
	} else if ( OPENGLVIEW_WAITRATE == WAIT_FAST ) {
		waitRate = WAIT_FAST;
		[ [oglFrameRateMenu itemWithTag:1004 ] setState:NSOnState ];
		[ [oglFrameRateMenu itemWithTag:1005 ] setState:NSOffState ];
		[ [oglFrameRateMenu itemWithTag:1006 ] setState:NSOffState ];
	} else if ( OPENGLVIEW_WAITRATE == WAIT_NORMAL ) {
		waitRate = WAIT_NORMAL;
		[ [oglFrameRateMenu itemWithTag:1004 ] setState:NSOffState ];
		[ [oglFrameRateMenu itemWithTag:1005 ] setState:NSOnState ];
		[ [oglFrameRateMenu itemWithTag:1006 ] setState:NSOffState ];
		
	} else {
		waitRate = WAIT_SLOW;
		[ [oglFrameRateMenu itemWithTag:1004 ] setState:NSOffState ];
		[ [oglFrameRateMenu itemWithTag:1005 ] setState:NSOffState ];
		[ [oglFrameRateMenu itemWithTag:1006 ] setState:NSOnState ];
	}
	
	cameraStep = waitRate / 8.5;
	
	if ( OPENGLVIEW_WAITSYNC )
		[ [ self openGLContext ] setValues:&vsincWait forParameter:NSOpenGLCPSwapInterval ];
	else 
		[ [ self openGLContext ] setValues:&vsincNoWait forParameter:NSOpenGLCPSwapInterval ];
	
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
		switchMethodArray[ i ] = &drawfunc_default;
		drawFloorArray[ i ] = &floorfunc_default;
	}
	
	switchMethodArray[ 0 ] = &drawfunc_0;
	switchMethodArray[ 1 ] = &drawfunc_1;
	switchMethodArray[ 2 ] = &drawfunc_2;
	switchMethodArray[ 3 ] = &drawfunc_3;
	switchMethodArray[ 4 ] = &drawfunc_4;
	switchMethodArray[ 5 ] = &drawfunc_5;
	switchMethodArray[ 6 ] = &drawfunc_6;
	switchMethodArray[ 7 ] = &drawfunc_7;
	switchMethodArray[ 8 ] = &drawfunc_8;
	switchMethodArray[ 9 ] = &drawfunc_9;
	switchMethodArray[ 10 ] = &drawfunc_a;
	
	drawFloorArray[ 0 ] = &floorfunc_0;
	drawFloorArray[ 1 ] = &floorfunc_1;
	drawFloorArray[ 2 ] = &floorfunc_2;
	drawFloorArray[ 3 ] = &floorfunc_3;
	drawFloorArray[ 4 ] = &floorfunc_4;
	drawFloorArray[ 5 ] = &floorfunc_5;
	drawFloorArray[ 6 ] = &floorfunc_6;
	drawFloorArray[ 7 ] = &floorfunc_7;
	drawFloorArray[ 8 ] = &floorfunc_8;
	
	for ( i = 0; i < MAX_GLYPH ; i++ ) {
		loadModelAddreses[ i ] = [ self methodForSelector:@selector( loadModelFunc_default: ) ];
		loadModelSelectors[ i ] = @selector( loadModelFunc_default: );
	}
	
	// insect class
	loadModelAddreses[ PM_GIANT_ANT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_insect:) ];
	loadModelAddreses[ PM_KILLER_BEE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_insect:) ];
	loadModelAddreses[ PM_SOLDIER_ANT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_insect:) ];
	loadModelAddreses[ PM_FIRE_ANT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_insect:) ];
	loadModelAddreses[ PM_GIANT_BEETLE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_insect:) ];
	loadModelAddreses[ PM_QUEEN_BEE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_insect:) ];
	// blob class
	loadModelAddreses[ PM_ACID_BLOB+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_blob:) ];
	loadModelAddreses[ PM_QUIVERING_BLOB+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_blob:) ];
	loadModelAddreses[ PM_GELATINOUS_CUBE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_blob:) ];
	// cockatrice class
	loadModelAddreses[ PM_CHICKATRICE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cockatrice:) ];
	loadModelAddreses[ PM_COCKATRICE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cockatrice:) ];
	loadModelAddreses[ PM_PYROLISK+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cockatrice:) ];		
	// dog or canine class
	loadModelAddreses[ PM_JACKAL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_FOX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_COYOTE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_WEREJACKAL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_LITTLE_DOG+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_DOG+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_LARGE_DOG+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_DINGO+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_WOLF+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_WEREWOLF+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_WARG+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_WINTER_WOLF_CUB+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_WINTER_WOLF+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_HELL_HOUND_PUP+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	loadModelAddreses[ PM_HELL_HOUND+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_dog:) ];
	// eye or sphere class
	loadModelAddreses[ PM_GAS_SPORE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_sphere:) ];
	loadModelAddreses[ PM_FLOATING_EYE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_sphere:) ];
	loadModelAddreses[ PM_FREEZING_SPHERE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_sphere:) ];
	loadModelAddreses[ PM_FLAMING_SPHERE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_sphere:) ];
	loadModelAddreses[ PM_SHOCKING_SPHERE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_sphere:) ];
	
	// cat or feline class
	loadModelAddreses[ PM_KITTEN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
	loadModelAddreses[ PM_HOUSECAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
	loadModelAddreses[ PM_JAGUAR+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
	loadModelAddreses[ PM_LYNX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
	loadModelAddreses[ PM_PANTHER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
	loadModelAddreses[ PM_LARGE_CAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
	loadModelAddreses[ PM_TIGER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_cat:) ];
		
	// gremlins and gagoyles class
	loadModelAddreses[ PM_GREMLIN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_gremlins:) ];
	loadModelAddreses[ PM_GARGOYLE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_gremlins:) ];
	loadModelAddreses[ PM_WINGED_GARGOYLE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_gremlins:) ];
			
	// humanoids class
	loadModelAddreses[ PM_DWARF_KING+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	loadModelAddreses[ PM_HOBBIT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	loadModelAddreses[ PM_DWARF+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	loadModelAddreses[ PM_BUGBEAR+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	loadModelAddreses[ PM_DWARF_LORD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	loadModelAddreses[ PM_MIND_FLAYER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	loadModelAddreses[ PM_MASTER_MIND_FLAYER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_humanoids:) ];
	// imp and minor demons
	loadModelAddreses[ PM_MANES+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_imp:) ];
	loadModelAddreses[ PM_HOMUNCULUS+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_imp:) ];
	loadModelAddreses[ PM_IMP+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_imp:) ];
	loadModelAddreses[ PM_LEMURE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_imp:) ];
	loadModelAddreses[ PM_QUASIT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_imp:) ];
	loadModelAddreses[ PM_TENGU+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_imp:) ];
		
	// jellys
	loadModelAddreses[ PM_BLUE_JELLY+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_jellys:) ];
	loadModelAddreses[ PM_SPOTTED_JELLY+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_jellys:) ];
	loadModelAddreses[ PM_OCHRE_JELLY+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_jellys:) ];
	// kobolds
	loadModelAddreses[ PM_KOBOLD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_kobolds:) ];
	loadModelAddreses[ PM_LARGE_KOBOLD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_kobolds:) ];
	loadModelAddreses[ PM_KOBOLD_LORD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_kobolds:) ];
	loadModelAddreses[ PM_KOBOLD_SHAMAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_kobolds:) ];
	// leprechaun
	loadModelAddreses[ PM_LEPRECHAUN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_leprechaun:) ];
	// mimics
	loadModelAddreses[ PM_SMALL_MIMIC+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_mimics:) ];
	loadModelAddreses[ PM_LARGE_MIMIC+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_mimics:) ];
	loadModelAddreses[ PM_GIANT_MIMIC+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_mimics:) ];
	// nymphs
	loadModelAddreses[ PM_WOOD_NYMPH+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_nymphs:) ];
	loadModelAddreses[ PM_WATER_NYMPH+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_nymphs:) ];
	loadModelAddreses[ PM_MOUNTAIN_NYMPH+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_nymphs:) ];
	// orc class
	loadModelAddreses[ PM_ORC_SHAMAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_GOBLIN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_HOBGOBLIN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_ORC+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_HILL_ORC+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_MORDOR_ORC+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_URUK_HAI+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	loadModelAddreses[ PM_ORC_CAPTAIN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_orc:) ];
	// piercers
	loadModelAddreses[ PM_ROCK_PIERCER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_piercers:) ];
	loadModelAddreses[ PM_IRON_PIERCER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_piercers:) ];
	loadModelAddreses[ PM_GLASS_PIERCER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_piercers:) ];
	// quadrupeds
	loadModelAddreses[ PM_ROTHE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	loadModelAddreses[ PM_MUMAK+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	loadModelAddreses[ PM_LEOCROTTA+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	loadModelAddreses[ PM_WUMPUS+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	loadModelAddreses[ PM_TITANOTHERE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	loadModelAddreses[ PM_BALUCHITHERIUM+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	loadModelAddreses[ PM_MASTODON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_quadrupeds:) ];
	// rodents
	loadModelAddreses[ PM_SEWER_RAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_rodents:) ];
	loadModelAddreses[ PM_GIANT_RAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_rodents:) ];
	loadModelAddreses[ PM_RABID_RAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_rodents:) ];
	loadModelAddreses[ PM_WERERAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_rodents:) ];
	loadModelAddreses[ PM_ROCK_MOLE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_rodents:) ];
	loadModelAddreses[ PM_WOODCHUCK+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_rodents:) ];
	// spiders
	loadModelAddreses[ PM_CAVE_SPIDER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_spiders:) ];
	loadModelAddreses[ PM_CENTIPEDE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_spiders:) ];
	loadModelAddreses[ PM_GIANT_SPIDER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_spiders:) ];
	loadModelAddreses[ PM_SCORPION+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_spiders:) ];
	// trapper
	loadModelAddreses[ PM_LURKER_ABOVE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_trapper:) ];
	loadModelAddreses[ PM_TRAPPER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_trapper:) ];
	// unicorns and horses
	loadModelAddreses[ PM_WHITE_UNICORN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_unicorns:) ];
	loadModelAddreses[ PM_GRAY_UNICORN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_unicorns:) ];
	loadModelAddreses[ PM_BLACK_UNICORN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_unicorns:) ];
	loadModelAddreses[ PM_PONY+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_unicorns:) ];
	loadModelAddreses[ PM_HORSE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_unicorns:) ];
	loadModelAddreses[ PM_WARHORSE+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_unicorns:) ];
	// vortices
	loadModelAddreses[ PM_FOG_CLOUD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_vortices:) ];
	loadModelAddreses[ PM_DUST_VORTEX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_vortices:) ];
	loadModelAddreses[ PM_ICE_VORTEX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_vortices:) ];
	loadModelAddreses[ PM_ENERGY_VORTEX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_vortices:) ];
	loadModelAddreses[ PM_STEAM_VORTEX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_vortices:) ];
	loadModelAddreses[ PM_FIRE_VORTEX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_vortices:) ];
	// worms
	loadModelAddreses[ PM_BABY_LONG_WORM+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_worms:) ];
	loadModelAddreses[ PM_BABY_PURPLE_WORM+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_worms:) ];
	loadModelAddreses[ PM_LONG_WORM+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_worms:) ];
	loadModelAddreses[ PM_PURPLE_WORM+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_worms:) ];
	// xan
	loadModelAddreses[ PM_GRID_BUG+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_xan:) ];
	loadModelAddreses[ PM_XAN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_xan:) ];
	// lights
	loadModelAddreses[ PM_YELLOW_LIGHT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lights:) ];
	loadModelAddreses[ PM_BLACK_LIGHT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lights:) ];
	// zruty
	loadModelAddreses[ PM_ZRUTY+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_zruty:) ];
	// Angels
	loadModelAddreses[ PM_COUATL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Angels:) ];
	loadModelAddreses[ PM_ALEAX+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Angels:) ];
	loadModelAddreses[ PM_ANGEL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Angels:) ];
	loadModelAddreses[ PM_KI_RIN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Angels:) ];
	loadModelAddreses[ PM_ARCHON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Angels:) ];
	// Bats
	loadModelAddreses[ PM_BAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Bats:) ];
	loadModelAddreses[ PM_GIANT_BAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Bats:) ];
	loadModelAddreses[ PM_RAVEN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Bats:) ];
	loadModelAddreses[ PM_VAMPIRE_BAT+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Bats:) ];
	// Centaurs
	loadModelAddreses[ PM_PLAINS_CENTAUR+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Centaurs:) ];
	loadModelAddreses[ PM_FOREST_CENTAUR+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Centaurs:) ];
	loadModelAddreses[ PM_MOUNTAIN_CENTAUR+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Centaurs:) ];
	// Dragons
	loadModelAddreses[ PM_BABY_GRAY_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_SILVER_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_RED_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_WHITE_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_ORANGE_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_BLACK_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_BLUE_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_GREEN_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BABY_YELLOW_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_GRAY_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_SILVER_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_RED_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_WHITE_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_ORANGE_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BLACK_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_BLUE_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_GREEN_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	loadModelAddreses[ PM_YELLOW_DRAGON+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Dragons:) ];
	// Elementals
	loadModelAddreses[ PM_STALKER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Elementals:) ];
	loadModelAddreses[ PM_AIR_ELEMENTAL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Elementals:) ];
	loadModelAddreses[ PM_FIRE_ELEMENTAL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Elementals:) ];
	loadModelAddreses[ PM_EARTH_ELEMENTAL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Elementals:) ];
	loadModelAddreses[ PM_WATER_ELEMENTAL+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Elementals:) ];
	// Fungi
	loadModelAddreses[ PM_LICHEN+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	loadModelAddreses[ PM_BROWN_MOLD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	loadModelAddreses[ PM_YELLOW_MOLD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	loadModelAddreses[ PM_GREEN_MOLD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	loadModelAddreses[ PM_RED_MOLD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	loadModelAddreses[ PM_SHRIEKER+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	loadModelAddreses[ PM_VIOLET_FUNGUS+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Fungi:) ];
	// Gnomes
	loadModelAddreses[ PM_GNOME+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Gnomes:) ];
	loadModelAddreses[ PM_GNOME_LORD+GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Gnomes:) ];
	loadModelAddreses[ PM_GNOMISH_WIZARD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Gnomes:) ];
	loadModelAddreses[ PM_GNOME_KING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Gnomes:) ];
	// Giant Humanoids
	loadModelAddreses[ PM_GIANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_STONE_GIANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_HILL_GIANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_FIRE_GIANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_FROST_GIANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_STORM_GIANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_ETTIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_TITAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	loadModelAddreses[ PM_MINOTAUR + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_giantHumanoids:) ];
	// Jabberwock
	loadModelAddreses[ PM_JABBERWOCK + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Jabberwock:) ];
	// Kops
	loadModelAddreses[ PM_KEYSTONE_KOP + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Kops:) ];
	loadModelAddreses[ PM_KOP_SERGEANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Kops:) ];
	loadModelAddreses[ PM_KOP_LIEUTENANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Kops:) ];
	loadModelAddreses[ PM_KOP_KAPTAIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Kops:) ];
	// Liches
	loadModelAddreses[ PM_LICH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Liches:) ];
	loadModelAddreses[ PM_DEMILICH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Liches:) ];
	loadModelAddreses[ PM_MASTER_LICH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Liches:) ];
	loadModelAddreses[ PM_ARCH_LICH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Liches:) ];
	// Mummies
	loadModelAddreses[ PM_KOBOLD_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_GNOME_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_ORC_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_DWARF_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_ELF_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_HUMAN_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_ETTIN_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	loadModelAddreses[ PM_GIANT_MUMMY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Mummies:) ];
	// Nagas
	loadModelAddreses[ PM_RED_NAGA_HATCHLING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_BLACK_NAGA_HATCHLING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_GOLDEN_NAGA_HATCHLING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_GUARDIAN_NAGA_HATCHLING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_RED_NAGA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_BLACK_NAGA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_GOLDEN_NAGA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	loadModelAddreses[ PM_GUARDIAN_NAGA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Nagas:) ];
	// Ogres
	loadModelAddreses[ PM_OGRE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Ogres:) ];
	loadModelAddreses[ PM_OGRE_LORD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Ogres:) ];
	loadModelAddreses[ PM_OGRE_KING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Ogres:) ];
	// Puddings
	loadModelAddreses[ PM_GRAY_OOZE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Puddings:) ];
	loadModelAddreses[ PM_BROWN_PUDDING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Puddings:) ];
	loadModelAddreses[ PM_BLACK_PUDDING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Puddings:) ];
	loadModelAddreses[ PM_GREEN_SLIME + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Puddings:) ];
	// Quantum mechanics
	loadModelAddreses[ PM_QUANTUM_MECHANIC + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Quantummechanics:) ];
	// Rust monster or disenchanter
	loadModelAddreses[ PM_RUST_MONSTER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Rustmonster:) ];
	loadModelAddreses[ PM_DISENCHANTER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Rustmonster:) ];
	// Snakes
	loadModelAddreses[ PM_GARTER_SNAKE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Snakes:) ];
	loadModelAddreses[ PM_SNAKE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Snakes:) ];
	loadModelAddreses[ PM_WATER_MOCCASIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Snakes:) ];
	loadModelAddreses[ PM_PIT_VIPER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Snakes:) ];
	loadModelAddreses[ PM_PYTHON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Snakes:) ];
	loadModelAddreses[ PM_COBRA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Snakes:) ];
	// Trolls
	loadModelAddreses[ PM_TROLL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Trolls:) ];
	loadModelAddreses[ PM_ICE_TROLL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Trolls:) ];
	loadModelAddreses[ PM_ROCK_TROLL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Trolls:) ];
	loadModelAddreses[ PM_WATER_TROLL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Trolls:) ];
	loadModelAddreses[ PM_OLOG_HAI + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Trolls:) ];
	// Umber hulk
	loadModelAddreses[ PM_UMBER_HULK + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Umberhulk:) ];
	// Vampires
	loadModelAddreses[ PM_VAMPIRE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Vampires:) ];
	loadModelAddreses[ PM_VAMPIRE_LORD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Vampires:) ];
	loadModelAddreses[ PM_VLAD_THE_IMPALER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Vampires:) ];
	// Wraiths
	loadModelAddreses[ PM_BARROW_WIGHT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Wraiths:) ];
	loadModelAddreses[ PM_WRAITH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Wraiths:) ];
	loadModelAddreses[ PM_NAZGUL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Wraiths:) ];
	// Xorn
	loadModelAddreses[ PM_XORN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Xorn:) ];
	// Yeti and other large beasts
	loadModelAddreses[ PM_MONKEY + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Yeti:) ];
	loadModelAddreses[ PM_APE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Yeti:) ];
	loadModelAddreses[ PM_OWLBEAR + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Yeti:) ];
	loadModelAddreses[ PM_YETI + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Yeti:) ];
	loadModelAddreses[ PM_CARNIVOROUS_APE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Yeti:) ];
	loadModelAddreses[ PM_SASQUATCH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Yeti:) ];
	// Zombie
	loadModelAddreses[ PM_KOBOLD_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_GNOME_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_ORC_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_DWARF_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_ELF_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_HUMAN_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_ETTIN_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_GIANT_ZOMBIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_GHOUL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	loadModelAddreses[ PM_SKELETON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Zombie:) ];
	// Golems
	loadModelAddreses[ PM_STRAW_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_PAPER_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_ROPE_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_GOLD_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_LEATHER_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_WOOD_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_FLESH_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_CLAY_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_STONE_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_GLASS_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	loadModelAddreses[ PM_IRON_GOLEM + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Golems:) ];
	// Human or Elves
	loadModelAddreses[ PM_ELVENKING + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_NURSE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_HIGH_PRIEST + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_MEDUSA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_CROESUS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_HUMAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_HUMAN_WERERAT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_HUMAN_WEREJACKAL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_HUMAN_WEREWOLF + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];	
	loadModelAddreses[ PM_ELF + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_WOODLAND_ELF + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_GREEN_ELF + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_GREY_ELF + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_ELF_LORD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];	
	loadModelAddreses[ PM_DOPPELGANGER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];		
	loadModelAddreses[ PM_SHOPKEEPER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];	
	loadModelAddreses[ PM_GUARD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_PRISONER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_ORACLE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_ALIGNED_PRIEST + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_SOLDIER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_SERGEANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_LIEUTENANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_CAPTAIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_WATCHMAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_WATCH_CAPTAIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];
	loadModelAddreses[ PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_HumanorElves:) ];	
	// Ghosts
	loadModelAddreses[ PM_GHOST + GLYPH_INVIS_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Ghosts:) ];
	loadModelAddreses[ PM_SHADE + GLYPH_INVIS_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Ghosts:) ];
	// Major Damons
	loadModelAddreses[ PM_WATER_DEMON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_HORNED_DEVIL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_SUCCUBUS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_INCUBUS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_ERINYS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_BARBED_DEVIL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_MARILITH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_VROCK + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_HEZROU + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_BONE_DEVIL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_ICE_DEVIL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_NALFESHNEE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_PIT_FIEND + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_BALROG + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_DJINNI + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	loadModelAddreses[ PM_SANDESTIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MajorDamons:) ];
	// Grater Damons 
	loadModelAddreses[ PM_JUIBLEX + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	loadModelAddreses[ PM_YEENOGHU + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];	
	loadModelAddreses[ PM_ORCUS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	loadModelAddreses[ PM_GERYON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	loadModelAddreses[ PM_DISPATER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	loadModelAddreses[ PM_BAALZEBUB + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	loadModelAddreses[ PM_ASMODEUS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	loadModelAddreses[ PM_DEMOGORGON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_GraterDamons:) ];
	// damon "The Riders"
	loadModelAddreses[ PM_DEATH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Riders:) ];
	loadModelAddreses[ PM_PESTILENCE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Riders:) ];
	loadModelAddreses[ PM_FAMINE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Riders:) ];
	// sea monsters
	loadModelAddreses[ PM_JELLYFISH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_seamonsters:) ];
	loadModelAddreses[ PM_PIRANHA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_seamonsters:) ];
	loadModelAddreses[ PM_SHARK + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_seamonsters:) ];
	loadModelAddreses[ PM_GIANT_EEL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_seamonsters:) ];
	loadModelAddreses[ PM_ELECTRIC_EEL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_seamonsters:) ];
	loadModelAddreses[ PM_KRAKEN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_seamonsters:) ];
	// lizards
	loadModelAddreses[ PM_NEWT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_GECKO + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_IGUANA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_BABY_CROCODILE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_LIZARD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_CHAMELEON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_CROCODILE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	loadModelAddreses[ PM_SALAMANDER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_lizards:) ];
	// wormtail
	loadModelAddreses[ PM_LONG_WORM_TAIL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_wormtail:) ];
	// Adventures
	loadModelAddreses[ PM_ARCHEOLOGIST + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_BARBARIAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_CAVEMAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_CAVEWOMAN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_HEALER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_KNIGHT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_MONK + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_PRIEST + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_PRIESTESS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_RANGER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_ROGUE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_SAMURAI + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_TOURIST + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_VALKYRIE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	loadModelAddreses[ PM_WIZARD + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Adventures:) ];
	// Unique person
	loadModelAddreses[ PM_LORD_CARNARVON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_PELIAS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_SHAMAN_KARNOV + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_HIPPOCRATES + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_GRAND_MASTER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ARCH_PRIEST + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ORION + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_MASTER_OF_THIEVES + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_LORD_SATO + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_TWOFLOWER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_NORN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_KING_ARTHUR + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_NEFERET_THE_GREEN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_MINION_OF_HUHETOTL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_THOTH_AMON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_CHROMATIC_DRAGON + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_CYCLOPS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_IXOTH + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_MASTER_KAEN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_NALZOK + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_SCORPIUS + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_MASTER_ASSASSIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ASHIKAGA_TAKAUJI + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_LORD_SURTUR + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_DARK_ONE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_STUDENT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_CHIEFTAIN + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_NEANDERTHAL + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ATTENDANT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_PAGE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ABBOT + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ACOLYTE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_HUNTER + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_THUG + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_NINJA + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_ROSHI + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_GUIDE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_WARRIOR + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];
	loadModelAddreses[ PM_APPRENTICE + GLYPH_MON_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Uniqueperson:) ];

// -------------------------- Map Symbol Section ----------------------------- //
	
	loadModelAddreses[ S_bars + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_tree + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_upstair + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_dnstair + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_upladder + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_dnladder + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_altar + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_grave + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_throne + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_sink + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_fountain + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_vodbridge + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ]; 
	loadModelAddreses[ S_hodbridge + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ]; 
	loadModelAddreses[ S_vcdbridge + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ];
	loadModelAddreses[ S_hcdbridge + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MapSymbols:) ]; 
//  ------------------------------  Boulder ---------------------------------- //
	
	loadModelAddreses[ BOULDER + GLYPH_OBJ_OFF ] = [ self methodForSelector:@selector( loadModelFunc_Boulder:) ];
// --------------------------  Trap Symbol Section --------------------------- // 
	
	loadModelAddreses[ S_arrow_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_dart_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_falling_rock_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	//loadModelAddreses[ S_squeaky_board + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_land_mine + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	//loadModelAddreses[ S_rolling_boulder_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_sleeping_gas_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_rust_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_fire_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_bear_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_pit + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_spiked_pit + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_hole + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_trap_door + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_teleportation_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_level_teleporter + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_magic_portal + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	//loadModelAddreses[ S_web + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	//loadModelAddreses[ S_statue_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];	
	loadModelAddreses[ S_magic_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_anti_magic_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	loadModelAddreses[ S_polymorph_trap + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_TrapSymbol:) ];
	// ------------------------- Effect Symbols Section. ------------------------- //
	
	// ZAP symbols ( NUM_ZAP * four directions )
	
	// type Magic Missile
	loadModelAddreses[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicMissile:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicMissile:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicMissile:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicMissile:) ];
	// type Magic FIRE
	loadModelAddreses[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicFIRE:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicFIRE:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicFIRE:) ];	
	loadModelAddreses[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicFIRE:) ];
	// type Magic COLD
	loadModelAddreses[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicCOLD:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicCOLD:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicCOLD:) ];	
	loadModelAddreses[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicCOLD:) ];
	// type Magic SLEEP
	loadModelAddreses[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicSLEEP:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicSLEEP:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicSLEEP:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicSLEEP:) ];
	// type Magic DEATH
	loadModelAddreses[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicDEATH:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicDEATH:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicDEATH:) ];	
	loadModelAddreses[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicDEATH:) ];
	// type Magic LIGHTNING
	loadModelAddreses[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicLIGHTNING:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicLIGHTNING:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicLIGHTNING:) ];	
	loadModelAddreses[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicLIGHTNING:) ];
	// type Magic POISONGAS
	loadModelAddreses[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicPOISONGAS:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicPOISONGAS:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicPOISONGAS:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicPOISONGAS:) ];
	// type Magic ACID
	loadModelAddreses[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicACID:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM ] = [ self methodForSelector:@selector( loadModelFunc_MagicACID:) ];
	loadModelAddreses[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicACID:) ];	
	loadModelAddreses[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT ] = [ self methodForSelector:@selector( loadModelFunc_MagicACID:) ];
	// dig beam
	loadModelAddreses[ S_digbeam + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];
	// camera flash
	loadModelAddreses[ S_flashbeam + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];
	// boomerang
	//loadModelAddreses[ S_boomleft + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];
	//loadModelAddreses[ S_boomright + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicETC:) ];

	// magic shild
	loadModelAddreses[ S_ss1 + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicSHILD:) ];
	loadModelAddreses[ S_ss2 + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicSHILD:) ];
	loadModelAddreses[ S_ss3 + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicSHILD:) ];
	loadModelAddreses[ S_ss4 + GLYPH_CMAP_OFF ] = [ self methodForSelector:@selector( loadModelFunc_MagicSHILD:) ];
	// explotion symbols ( 9 postion * 7 types )
	// type DARK
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_DARK + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionDARK:) ];
	}
	// type NOXIOUS
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_NOXIOUS + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionNOXIOUS:) ];
	}
	// type MUDDY
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_MUDDY + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionMUDDY:) ];
	}
	// type WET
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_WET + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionWET:) ];
	}
	// type MAGICAL
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_MAGICAL + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionMAGICAL:) ];
	}
	// type FIERY
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_FIERY + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionFIERY:) ];
	}
	// type FROSTY
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelAddreses[ NH3D_EXPLODE_FROSTY + i ] = [ self methodForSelector:@selector( loadModelFunc_explotionFROSTY:) ];
	}
	
	
// ---------------------------------------------------------------------------- //
// cash Selector
// ---------------------------------------------------------------------------- //
	
	// insect class
	loadModelSelectors[ PM_GIANT_ANT+GLYPH_MON_OFF ] = @selector( loadModelFunc_insect: );
	loadModelSelectors[ PM_KILLER_BEE+GLYPH_MON_OFF ] = @selector( loadModelFunc_insect: );
	loadModelSelectors[ PM_SOLDIER_ANT+GLYPH_MON_OFF ] = @selector( loadModelFunc_insect: );
	loadModelSelectors[ PM_FIRE_ANT+GLYPH_MON_OFF ] = @selector( loadModelFunc_insect: );
	loadModelSelectors[ PM_GIANT_BEETLE+GLYPH_MON_OFF ] = @selector( loadModelFunc_insect: );
	loadModelSelectors[ PM_QUEEN_BEE+GLYPH_MON_OFF ] = @selector( loadModelFunc_insect: );
	// blob class
	loadModelSelectors[ PM_ACID_BLOB+GLYPH_MON_OFF ] = @selector( loadModelFunc_blob: );
	loadModelSelectors[ PM_QUIVERING_BLOB+GLYPH_MON_OFF ] = @selector( loadModelFunc_blob: );
	loadModelSelectors[ PM_GELATINOUS_CUBE+GLYPH_MON_OFF ] = @selector( loadModelFunc_blob: );
	// cockatrice class
	loadModelSelectors[ PM_CHICKATRICE+GLYPH_MON_OFF ] = @selector( loadModelFunc_cockatrice: );
	loadModelSelectors[ PM_COCKATRICE+GLYPH_MON_OFF ] = @selector( loadModelFunc_cockatrice: );
	loadModelSelectors[ PM_PYROLISK+GLYPH_MON_OFF ] = @selector( loadModelFunc_cockatrice: );		
	// dog or canine class
	loadModelSelectors[ PM_JACKAL+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_FOX+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_COYOTE+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_WEREJACKAL+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_LITTLE_DOG+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_DOG+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_LARGE_DOG+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_DINGO+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_WOLF+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_WEREWOLF+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_WARG+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_WINTER_WOLF_CUB+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_WINTER_WOLF+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_HELL_HOUND_PUP+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	loadModelSelectors[ PM_HELL_HOUND+GLYPH_MON_OFF ] = @selector( loadModelFunc_dog: );
	// eye or sphere class
	loadModelSelectors[ PM_GAS_SPORE+GLYPH_MON_OFF ] = @selector( loadModelFunc_sphere: );
	loadModelSelectors[ PM_FLOATING_EYE+GLYPH_MON_OFF ] = @selector( loadModelFunc_sphere: );
	loadModelSelectors[ PM_FREEZING_SPHERE+GLYPH_MON_OFF ] = @selector( loadModelFunc_sphere: );
	loadModelSelectors[ PM_FLAMING_SPHERE+GLYPH_MON_OFF ] = @selector( loadModelFunc_sphere: );
	loadModelSelectors[ PM_SHOCKING_SPHERE+GLYPH_MON_OFF ] = @selector( loadModelFunc_sphere: );
	
	// cat or feline class
	loadModelSelectors[ PM_KITTEN+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
	loadModelSelectors[ PM_HOUSECAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
	loadModelSelectors[ PM_JAGUAR+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
	loadModelSelectors[ PM_LYNX+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
	loadModelSelectors[ PM_PANTHER+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
	loadModelSelectors[ PM_LARGE_CAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
	loadModelSelectors[ PM_TIGER+GLYPH_MON_OFF ] = @selector( loadModelFunc_cat: );
		
	// gremlins and gagoyles class
	loadModelSelectors[ PM_GREMLIN+GLYPH_MON_OFF ] = @selector( loadModelFunc_gremlins: );
	loadModelSelectors[ PM_GARGOYLE+GLYPH_MON_OFF ] = @selector( loadModelFunc_gremlins: );
	loadModelSelectors[ PM_WINGED_GARGOYLE+GLYPH_MON_OFF ] = @selector( loadModelFunc_gremlins: );
			
	// humanoids class
	loadModelSelectors[ PM_DWARF_KING+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	loadModelSelectors[ PM_HOBBIT+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	loadModelSelectors[ PM_DWARF+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	loadModelSelectors[ PM_BUGBEAR+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	loadModelSelectors[ PM_DWARF_LORD+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	loadModelSelectors[ PM_MIND_FLAYER+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	loadModelSelectors[ PM_MASTER_MIND_FLAYER+GLYPH_MON_OFF ] = @selector( loadModelFunc_humanoids: );
	// imp and minor demons
	loadModelSelectors[ PM_MANES+GLYPH_MON_OFF ] = @selector( loadModelFunc_imp: );
	loadModelSelectors[ PM_HOMUNCULUS+GLYPH_MON_OFF ] = @selector( loadModelFunc_imp: );
	loadModelSelectors[ PM_IMP+GLYPH_MON_OFF ] = @selector( loadModelFunc_imp: );
	loadModelSelectors[ PM_LEMURE+GLYPH_MON_OFF ] = @selector( loadModelFunc_imp: );
	loadModelSelectors[ PM_QUASIT+GLYPH_MON_OFF ] = @selector( loadModelFunc_imp: );
	loadModelSelectors[ PM_TENGU+GLYPH_MON_OFF ] = @selector( loadModelFunc_imp: );
		
	// jellys
	loadModelSelectors[ PM_BLUE_JELLY+GLYPH_MON_OFF ] = @selector( loadModelFunc_jellys: );
	loadModelSelectors[ PM_SPOTTED_JELLY+GLYPH_MON_OFF ] = @selector( loadModelFunc_jellys: );
	loadModelSelectors[ PM_OCHRE_JELLY+GLYPH_MON_OFF ] = @selector( loadModelFunc_jellys: );
	// kobolds
	loadModelSelectors[ PM_KOBOLD+GLYPH_MON_OFF ] = @selector( loadModelFunc_kobolds: );
	loadModelSelectors[ PM_LARGE_KOBOLD+GLYPH_MON_OFF ] = @selector( loadModelFunc_kobolds: );
	loadModelSelectors[ PM_KOBOLD_LORD+GLYPH_MON_OFF ] = @selector( loadModelFunc_kobolds: );
	loadModelSelectors[ PM_KOBOLD_SHAMAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_kobolds: );
	// leprechaun
	loadModelSelectors[ PM_LEPRECHAUN+GLYPH_MON_OFF ] = @selector( loadModelFunc_leprechaun: );
	// mimics
	loadModelSelectors[ PM_SMALL_MIMIC+GLYPH_MON_OFF ] = @selector( loadModelFunc_mimics: );
	loadModelSelectors[ PM_LARGE_MIMIC+GLYPH_MON_OFF ] = @selector( loadModelFunc_mimics: );
	loadModelSelectors[ PM_GIANT_MIMIC+GLYPH_MON_OFF ] = @selector( loadModelFunc_mimics: );
	// nymphs
	loadModelSelectors[ PM_WOOD_NYMPH+GLYPH_MON_OFF ] = @selector( loadModelFunc_nymphs: );
	loadModelSelectors[ PM_WATER_NYMPH+GLYPH_MON_OFF ] = @selector( loadModelFunc_nymphs: );
	loadModelSelectors[ PM_MOUNTAIN_NYMPH+GLYPH_MON_OFF ] = @selector( loadModelFunc_nymphs: );
	// orc class
	loadModelSelectors[ PM_ORC_SHAMAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_GOBLIN+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_HOBGOBLIN+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_ORC+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_HILL_ORC+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_MORDOR_ORC+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_URUK_HAI+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	loadModelSelectors[ PM_ORC_CAPTAIN+GLYPH_MON_OFF ] = @selector( loadModelFunc_orc: );
	// piercers
	loadModelSelectors[ PM_ROCK_PIERCER+GLYPH_MON_OFF ] = @selector( loadModelFunc_piercers: );
	loadModelSelectors[ PM_IRON_PIERCER+GLYPH_MON_OFF ] = @selector( loadModelFunc_piercers: );
	loadModelSelectors[ PM_GLASS_PIERCER+GLYPH_MON_OFF ] = @selector( loadModelFunc_piercers: );
	// quadrupeds
	loadModelSelectors[ PM_ROTHE+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	loadModelSelectors[ PM_MUMAK+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	loadModelSelectors[ PM_LEOCROTTA+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	loadModelSelectors[ PM_WUMPUS+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	loadModelSelectors[ PM_TITANOTHERE+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	loadModelSelectors[ PM_BALUCHITHERIUM+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	loadModelSelectors[ PM_MASTODON+GLYPH_MON_OFF ] = @selector( loadModelFunc_quadrupeds: );
	// rodents
	loadModelSelectors[ PM_SEWER_RAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_rodents: );
	loadModelSelectors[ PM_GIANT_RAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_rodents: );
	loadModelSelectors[ PM_RABID_RAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_rodents: );
	loadModelSelectors[ PM_WERERAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_rodents: );
	loadModelSelectors[ PM_ROCK_MOLE+GLYPH_MON_OFF ] = @selector( loadModelFunc_rodents: );
	loadModelSelectors[ PM_WOODCHUCK+GLYPH_MON_OFF ] = @selector( loadModelFunc_rodents: );
	// spiders
	loadModelSelectors[ PM_CAVE_SPIDER+GLYPH_MON_OFF ] = @selector( loadModelFunc_spiders: );
	loadModelSelectors[ PM_CENTIPEDE+GLYPH_MON_OFF ] = @selector( loadModelFunc_spiders: );
	loadModelSelectors[ PM_GIANT_SPIDER+GLYPH_MON_OFF ] = @selector( loadModelFunc_spiders: );
	loadModelSelectors[ PM_SCORPION+GLYPH_MON_OFF ] = @selector( loadModelFunc_spiders: );
	// trapper
	loadModelSelectors[ PM_LURKER_ABOVE+GLYPH_MON_OFF ] = @selector( loadModelFunc_trapper: );
	loadModelSelectors[ PM_TRAPPER+GLYPH_MON_OFF ] = @selector( loadModelFunc_trapper: );
	// unicorns and horses
	loadModelSelectors[ PM_WHITE_UNICORN+GLYPH_MON_OFF ] = @selector( loadModelFunc_unicorns: );
	loadModelSelectors[ PM_GRAY_UNICORN+GLYPH_MON_OFF ] = @selector( loadModelFunc_unicorns: );
	loadModelSelectors[ PM_BLACK_UNICORN+GLYPH_MON_OFF ] = @selector( loadModelFunc_unicorns: );
	loadModelSelectors[ PM_PONY+GLYPH_MON_OFF ] = @selector( loadModelFunc_unicorns: );
	loadModelSelectors[ PM_HORSE+GLYPH_MON_OFF ] = @selector( loadModelFunc_unicorns: );
	loadModelSelectors[ PM_WARHORSE+GLYPH_MON_OFF ] = @selector( loadModelFunc_unicorns: );
	// vortices
	loadModelSelectors[ PM_FOG_CLOUD+GLYPH_MON_OFF ] = @selector( loadModelFunc_vortices: );
	loadModelSelectors[ PM_DUST_VORTEX+GLYPH_MON_OFF ] = @selector( loadModelFunc_vortices: );
	loadModelSelectors[ PM_ICE_VORTEX+GLYPH_MON_OFF ] = @selector( loadModelFunc_vortices: );
	loadModelSelectors[ PM_ENERGY_VORTEX+GLYPH_MON_OFF ] = @selector( loadModelFunc_vortices: );
	loadModelSelectors[ PM_STEAM_VORTEX+GLYPH_MON_OFF ] = @selector( loadModelFunc_vortices: );
	loadModelSelectors[ PM_FIRE_VORTEX+GLYPH_MON_OFF ] = @selector( loadModelFunc_vortices: );
	// worms
	loadModelSelectors[ PM_BABY_LONG_WORM+GLYPH_MON_OFF ] = @selector( loadModelFunc_worms: );
	loadModelSelectors[ PM_BABY_PURPLE_WORM+GLYPH_MON_OFF ] = @selector( loadModelFunc_worms: );
	loadModelSelectors[ PM_LONG_WORM+GLYPH_MON_OFF ] = @selector( loadModelFunc_worms: );
	loadModelSelectors[ PM_PURPLE_WORM+GLYPH_MON_OFF ] = @selector( loadModelFunc_worms: );
	// xan
	loadModelSelectors[ PM_GRID_BUG+GLYPH_MON_OFF ] = @selector( loadModelFunc_xan: );
	loadModelSelectors[ PM_XAN+GLYPH_MON_OFF ] = @selector( loadModelFunc_xan: );
	// lights
	loadModelSelectors[ PM_YELLOW_LIGHT+GLYPH_MON_OFF ] = @selector( loadModelFunc_lights: );
	loadModelSelectors[ PM_BLACK_LIGHT+GLYPH_MON_OFF ] = @selector( loadModelFunc_lights: );
	// zruty
	loadModelSelectors[ PM_ZRUTY+GLYPH_MON_OFF ] = @selector( loadModelFunc_zruty: );
	// Angels
	loadModelSelectors[ PM_COUATL+GLYPH_MON_OFF ] = @selector( loadModelFunc_Angels: );
	loadModelSelectors[ PM_ALEAX+GLYPH_MON_OFF ] = @selector( loadModelFunc_Angels: );
	loadModelSelectors[ PM_ANGEL+GLYPH_MON_OFF ] = @selector( loadModelFunc_Angels: );
	loadModelSelectors[ PM_KI_RIN+GLYPH_MON_OFF ] = @selector( loadModelFunc_Angels: );
	loadModelSelectors[ PM_ARCHON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Angels: );
	// Bats
	loadModelSelectors[ PM_BAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_Bats: );
	loadModelSelectors[ PM_GIANT_BAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_Bats: );
	loadModelSelectors[ PM_RAVEN+GLYPH_MON_OFF ] = @selector( loadModelFunc_Bats: );
	loadModelSelectors[ PM_VAMPIRE_BAT+GLYPH_MON_OFF ] = @selector( loadModelFunc_Bats: );
	// Centaurs
	loadModelSelectors[ PM_PLAINS_CENTAUR+GLYPH_MON_OFF ] = @selector( loadModelFunc_Centaurs: );
	loadModelSelectors[ PM_FOREST_CENTAUR+GLYPH_MON_OFF ] = @selector( loadModelFunc_Centaurs: );
	loadModelSelectors[ PM_MOUNTAIN_CENTAUR+GLYPH_MON_OFF ] = @selector( loadModelFunc_Centaurs: );
	// Dragons
	loadModelSelectors[ PM_BABY_GRAY_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_SILVER_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_RED_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_WHITE_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_ORANGE_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_BLACK_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_BLUE_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_GREEN_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BABY_YELLOW_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_GRAY_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_SILVER_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_RED_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_WHITE_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_ORANGE_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BLACK_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_BLUE_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_GREEN_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	loadModelSelectors[ PM_YELLOW_DRAGON+GLYPH_MON_OFF ] = @selector( loadModelFunc_Dragons: );
	// Elementals
	loadModelSelectors[ PM_STALKER+GLYPH_MON_OFF ] = @selector( loadModelFunc_Elementals: );
	loadModelSelectors[ PM_AIR_ELEMENTAL+GLYPH_MON_OFF ] = @selector( loadModelFunc_Elementals: );
	loadModelSelectors[ PM_FIRE_ELEMENTAL+GLYPH_MON_OFF ] = @selector( loadModelFunc_Elementals: );
	loadModelSelectors[ PM_EARTH_ELEMENTAL+GLYPH_MON_OFF ] = @selector( loadModelFunc_Elementals: );
	loadModelSelectors[ PM_WATER_ELEMENTAL+GLYPH_MON_OFF ] = @selector( loadModelFunc_Elementals: );
	// Fungi
	loadModelSelectors[ PM_LICHEN+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	loadModelSelectors[ PM_BROWN_MOLD+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	loadModelSelectors[ PM_YELLOW_MOLD+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	loadModelSelectors[ PM_GREEN_MOLD+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	loadModelSelectors[ PM_RED_MOLD+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	loadModelSelectors[ PM_SHRIEKER+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	loadModelSelectors[ PM_VIOLET_FUNGUS+GLYPH_MON_OFF ] = @selector( loadModelFunc_Fungi: );
	// Gnomes
	loadModelSelectors[ PM_GNOME+GLYPH_MON_OFF ] = @selector( loadModelFunc_Gnomes: );
	loadModelSelectors[ PM_GNOME_LORD+GLYPH_MON_OFF ] = @selector( loadModelFunc_Gnomes: );
	loadModelSelectors[ PM_GNOMISH_WIZARD + GLYPH_MON_OFF ] = @selector( loadModelFunc_Gnomes: );
	loadModelSelectors[ PM_GNOME_KING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Gnomes: );
	// Giant Humanoids
	loadModelSelectors[ PM_GIANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_STONE_GIANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_HILL_GIANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_FIRE_GIANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_FROST_GIANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_STORM_GIANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_ETTIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_TITAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	loadModelSelectors[ PM_MINOTAUR + GLYPH_MON_OFF ] = @selector( loadModelFunc_giantHumanoids: );
	// Jabberwock
	loadModelSelectors[ PM_JABBERWOCK + GLYPH_MON_OFF ] = @selector( loadModelFunc_Jabberwock: );
	// Kops
	loadModelSelectors[ PM_KEYSTONE_KOP + GLYPH_MON_OFF ] = @selector( loadModelFunc_Kops: );
	loadModelSelectors[ PM_KOP_SERGEANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Kops: );
	loadModelSelectors[ PM_KOP_LIEUTENANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Kops: );
	loadModelSelectors[ PM_KOP_KAPTAIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Kops: );
	// Liches
	loadModelSelectors[ PM_LICH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Liches: );
	loadModelSelectors[ PM_DEMILICH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Liches: );
	loadModelSelectors[ PM_MASTER_LICH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Liches: );
	loadModelSelectors[ PM_ARCH_LICH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Liches: );
	// Mummies
	loadModelSelectors[ PM_KOBOLD_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_GNOME_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_ORC_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_DWARF_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_ELF_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_HUMAN_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_ETTIN_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	loadModelSelectors[ PM_GIANT_MUMMY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Mummies: );
	// Nagas
	loadModelSelectors[ PM_RED_NAGA_HATCHLING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_BLACK_NAGA_HATCHLING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_GOLDEN_NAGA_HATCHLING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_GUARDIAN_NAGA_HATCHLING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_RED_NAGA + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_BLACK_NAGA + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_GOLDEN_NAGA + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	loadModelSelectors[ PM_GUARDIAN_NAGA + GLYPH_MON_OFF ] = @selector( loadModelFunc_Nagas: );
	// Ogres
	loadModelSelectors[ PM_OGRE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Ogres: );
	loadModelSelectors[ PM_OGRE_LORD + GLYPH_MON_OFF ] = @selector( loadModelFunc_Ogres: );
	loadModelSelectors[ PM_OGRE_KING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Ogres: );
	// Puddings
	loadModelSelectors[ PM_GRAY_OOZE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Puddings: );
	loadModelSelectors[ PM_BROWN_PUDDING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Puddings: );
	loadModelSelectors[ PM_BLACK_PUDDING + GLYPH_MON_OFF ] = @selector( loadModelFunc_Puddings: );
	loadModelSelectors[ PM_GREEN_SLIME + GLYPH_MON_OFF ] = @selector( loadModelFunc_Puddings: );
	// Quantum mechanics
	loadModelSelectors[ PM_QUANTUM_MECHANIC + GLYPH_MON_OFF ] = @selector( loadModelFunc_Quantummechanics: );
	// Rust monster or disenchanter
	loadModelSelectors[ PM_RUST_MONSTER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Rustmonster: );
	loadModelSelectors[ PM_DISENCHANTER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Rustmonster: );
	// Snakes
	loadModelSelectors[ PM_GARTER_SNAKE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Snakes: );
	loadModelSelectors[ PM_SNAKE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Snakes: );
	loadModelSelectors[ PM_WATER_MOCCASIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Snakes: );
	loadModelSelectors[ PM_PIT_VIPER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Snakes: );
	loadModelSelectors[ PM_PYTHON + GLYPH_MON_OFF ] = @selector( loadModelFunc_Snakes: );
	loadModelSelectors[ PM_COBRA + GLYPH_MON_OFF ] = @selector( loadModelFunc_Snakes: );
	// Trolls
	loadModelSelectors[ PM_TROLL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Trolls: );
	loadModelSelectors[ PM_ICE_TROLL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Trolls: );
	loadModelSelectors[ PM_ROCK_TROLL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Trolls: );
	loadModelSelectors[ PM_WATER_TROLL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Trolls: );
	loadModelSelectors[ PM_OLOG_HAI + GLYPH_MON_OFF ] = @selector( loadModelFunc_Trolls: );
	// Umber hulk
	loadModelSelectors[ PM_UMBER_HULK + GLYPH_MON_OFF ] = @selector( loadModelFunc_Umberhulk: );
	// Vampires
	loadModelSelectors[ PM_VAMPIRE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Vampires: );
	loadModelSelectors[ PM_VAMPIRE_LORD + GLYPH_MON_OFF ] = @selector( loadModelFunc_Vampires: );
	loadModelSelectors[ PM_VLAD_THE_IMPALER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Vampires: );
	// Wraiths
	loadModelSelectors[ PM_BARROW_WIGHT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Wraiths: );
	loadModelSelectors[ PM_WRAITH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Wraiths: );
	loadModelSelectors[ PM_NAZGUL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Wraiths: );
	// Xorn
	loadModelSelectors[ PM_XORN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Xorn: );
	// Yeti and other large beasts
	loadModelSelectors[ PM_MONKEY + GLYPH_MON_OFF ] = @selector( loadModelFunc_Yeti: );
	loadModelSelectors[ PM_APE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Yeti: );
	loadModelSelectors[ PM_OWLBEAR + GLYPH_MON_OFF ] = @selector( loadModelFunc_Yeti: );
	loadModelSelectors[ PM_YETI + GLYPH_MON_OFF ] = @selector( loadModelFunc_Yeti: );
	loadModelSelectors[ PM_CARNIVOROUS_APE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Yeti: );
	loadModelSelectors[ PM_SASQUATCH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Yeti: );
	// Zombie
	loadModelSelectors[ PM_KOBOLD_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_GNOME_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_ORC_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_DWARF_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_ELF_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_HUMAN_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_ETTIN_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_GIANT_ZOMBIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_GHOUL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	loadModelSelectors[ PM_SKELETON + GLYPH_MON_OFF ] = @selector( loadModelFunc_Zombie: );
	// Golems
	loadModelSelectors[ PM_STRAW_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_PAPER_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_ROPE_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_GOLD_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_LEATHER_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_WOOD_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_FLESH_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_CLAY_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_STONE_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_GLASS_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	loadModelSelectors[ PM_IRON_GOLEM + GLYPH_MON_OFF ] = @selector( loadModelFunc_Golems: );
	// Human or Elves
	loadModelSelectors[ PM_ELVENKING + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_NURSE + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_HIGH_PRIEST + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_MEDUSA + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_CROESUS + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_HUMAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_HUMAN_WERERAT + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_HUMAN_WEREJACKAL + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_HUMAN_WEREWOLF + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );	
	loadModelSelectors[ PM_ELF + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_WOODLAND_ELF + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_GREEN_ELF + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_GREY_ELF + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_ELF_LORD + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );	
	loadModelSelectors[ PM_DOPPELGANGER + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );		
	loadModelSelectors[ PM_SHOPKEEPER + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );	
	loadModelSelectors[ PM_GUARD + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_PRISONER + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_ORACLE + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_ALIGNED_PRIEST + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_SOLDIER + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_SERGEANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_LIEUTENANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_CAPTAIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_WATCHMAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_WATCH_CAPTAIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );
	loadModelSelectors[ PM_WIZARD_OF_YENDOR + GLYPH_MON_OFF ] = @selector( loadModelFunc_HumanorElves: );	
	// Ghosts
	loadModelSelectors[ PM_GHOST + GLYPH_INVIS_OFF ] = @selector( loadModelFunc_Ghosts: );
	loadModelSelectors[ PM_SHADE + GLYPH_INVIS_OFF ] = @selector( loadModelFunc_Ghosts: );
	// Major Damons
	loadModelSelectors[ PM_WATER_DEMON + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_HORNED_DEVIL + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_SUCCUBUS + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_INCUBUS + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_ERINYS + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_BARBED_DEVIL + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_MARILITH + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_VROCK + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_HEZROU + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_BONE_DEVIL + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_ICE_DEVIL + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_NALFESHNEE + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_PIT_FIEND + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_BALROG + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_DJINNI + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	loadModelSelectors[ PM_SANDESTIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_MajorDamons: );
	// Grater Damons 
	loadModelSelectors[ PM_JUIBLEX + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	loadModelSelectors[ PM_YEENOGHU + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );	
	loadModelSelectors[ PM_ORCUS + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	loadModelSelectors[ PM_GERYON + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	loadModelSelectors[ PM_DISPATER + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	loadModelSelectors[ PM_BAALZEBUB + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	loadModelSelectors[ PM_ASMODEUS + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	loadModelSelectors[ PM_DEMOGORGON + GLYPH_MON_OFF ] = @selector( loadModelFunc_GraterDamons: );
	// damon "The Riders"
	loadModelSelectors[ PM_DEATH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Riders: );
	loadModelSelectors[ PM_PESTILENCE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Riders: );
	loadModelSelectors[ PM_FAMINE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Riders: );
	// sea monsters
	loadModelSelectors[ PM_JELLYFISH + GLYPH_MON_OFF ] = @selector( loadModelFunc_seamonsters: );
	loadModelSelectors[ PM_PIRANHA + GLYPH_MON_OFF ] = @selector( loadModelFunc_seamonsters: );
	loadModelSelectors[ PM_SHARK + GLYPH_MON_OFF ] = @selector( loadModelFunc_seamonsters: );
	loadModelSelectors[ PM_GIANT_EEL + GLYPH_MON_OFF ] = @selector( loadModelFunc_seamonsters: );
	loadModelSelectors[ PM_ELECTRIC_EEL + GLYPH_MON_OFF ] = @selector( loadModelFunc_seamonsters: );
	loadModelSelectors[ PM_KRAKEN + GLYPH_MON_OFF ] = @selector( loadModelFunc_seamonsters: );
	// lizards
	loadModelSelectors[ PM_NEWT + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_GECKO + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_IGUANA + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_BABY_CROCODILE + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_LIZARD + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_CHAMELEON + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_CROCODILE + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	loadModelSelectors[ PM_SALAMANDER + GLYPH_MON_OFF ] = @selector( loadModelFunc_lizards: );
	// wormtail
	loadModelSelectors[ PM_LONG_WORM_TAIL + GLYPH_MON_OFF ] = @selector( loadModelFunc_wormtail: );
	// Adventures
	loadModelSelectors[ PM_ARCHEOLOGIST + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_BARBARIAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_CAVEMAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_CAVEWOMAN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_HEALER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_KNIGHT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_MONK + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_PRIEST + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_PRIESTESS + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_RANGER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_ROGUE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_SAMURAI + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_TOURIST + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_VALKYRIE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	loadModelSelectors[ PM_WIZARD + GLYPH_MON_OFF ] = @selector( loadModelFunc_Adventures: );
	// Unique person
	loadModelSelectors[ PM_LORD_CARNARVON + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_PELIAS + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_SHAMAN_KARNOV + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_HIPPOCRATES + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_GRAND_MASTER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ARCH_PRIEST + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ORION + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_MASTER_OF_THIEVES + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_LORD_SATO + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_TWOFLOWER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_NORN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_KING_ARTHUR + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_NEFERET_THE_GREEN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_MINION_OF_HUHETOTL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_THOTH_AMON + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_CHROMATIC_DRAGON + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_CYCLOPS + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_IXOTH + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_MASTER_KAEN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_NALZOK + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_SCORPIUS + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_MASTER_ASSASSIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ASHIKAGA_TAKAUJI + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_LORD_SURTUR + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_DARK_ONE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_STUDENT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_CHIEFTAIN + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_NEANDERTHAL + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ATTENDANT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_PAGE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ABBOT + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ACOLYTE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_HUNTER + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_THUG + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_NINJA + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_ROSHI + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_GUIDE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_WARRIOR + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );
	loadModelSelectors[ PM_APPRENTICE + GLYPH_MON_OFF ] = @selector( loadModelFunc_Uniqueperson: );

// -------------------------- Map Symbol Section ----------------------------- //
	
	loadModelSelectors[ S_bars + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_tree + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_upstair + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_dnstair + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_upladder + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols:);
	loadModelSelectors[ S_dnladder + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols:);
	loadModelSelectors[ S_altar + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_grave + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_throne + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_sink + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_fountain + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_vodbridge + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: ); 
	loadModelSelectors[ S_hodbridge + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: ); 
	loadModelSelectors[ S_vcdbridge + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: );
	loadModelSelectors[ S_hcdbridge + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MapSymbols: ); 
//  ------------------------------  Boulder ---------------------------------- //
	
	loadModelSelectors[ BOULDER + GLYPH_OBJ_OFF ] = @selector( loadModelFunc_Boulder: );
// --------------------------  Trap Symbol Section --------------------------- // 
	
	loadModelSelectors[ S_arrow_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_dart_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_falling_rock_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	//loadModelSelectors[ S_squeaky_board + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_land_mine + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	//loadModelSelectors[ S_rolling_boulder_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_sleeping_gas_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_rust_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_bear_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_fire_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_pit + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_spiked_pit + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_hole + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_trap_door + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_teleportation_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_level_teleporter + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_magic_portal + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	//loadModelSelectors[ S_web + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	//loadModelSelectors[ S_statue_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );	
	loadModelSelectors[ S_magic_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_anti_magic_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	loadModelSelectors[ S_polymorph_trap + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_TrapSymbol: );
	// ------------------------- Effect Symbols Section. ------------------------- //
	
	// ZAP symbols ( NUM_ZAP * four directions )
	
	// type Magic Missile
	loadModelSelectors[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicMissile: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicMissile: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicMissile: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_MISSILE + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicMissile: );
	// type Magic FIRE
	loadModelSelectors[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicFIRE: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicFIRE: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicFIRE: );	
	loadModelSelectors[ NH3D_ZAP_MAGIC_FIRE + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicFIRE: );
	// type Magic COLD
	loadModelSelectors[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicCOLD: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicCOLD: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicCOLD: );	
	loadModelSelectors[ NH3D_ZAP_MAGIC_COLD + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicCOLD: );
	// type Magic SLEEP
	loadModelSelectors[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicSLEEP: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicSLEEP: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicSLEEP: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_SLEEP + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicSLEEP: );
	// type Magic DEATH
	loadModelSelectors[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicDEATH: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicDEATH: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicDEATH: );	
	loadModelSelectors[ NH3D_ZAP_MAGIC_DEATH + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicDEATH: );
	// type Magic LIGHTNING
	loadModelSelectors[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicLIGHTNING: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicLIGHTNING: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicLIGHTNING: );	
	loadModelSelectors[ NH3D_ZAP_MAGIC_LIGHTNING + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicLIGHTNING: );
	// type Magic POISONGAS
	loadModelSelectors[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicPOISONGAS: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicPOISONGAS: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicPOISONGAS: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_POISONGAS + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicPOISONGAS: );
	// type Magic ACID
	loadModelSelectors[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_VBEAM ] = @selector( loadModelFunc_MagicACID: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_HBEAM ] = @selector( loadModelFunc_MagicACID: );
	loadModelSelectors[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_LSLANT ] = @selector( loadModelFunc_MagicACID: );	
	loadModelSelectors[ NH3D_ZAP_MAGIC_ACID + NH3D_ZAP_RSLANT ] = @selector( loadModelFunc_MagicACID: );
	// dig beam
	loadModelSelectors[ S_digbeam + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicETC: );
	// camera flash
	loadModelSelectors[ S_flashbeam + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicETC: );
	// boomerang
	//loadModelSelectors[ S_boomleft + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicETC: );
	//loadModelSelectors[ S_boomright + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicETC: );

	// magic shild
	loadModelSelectors[ S_ss1 + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicSHILD: );
	loadModelSelectors[ S_ss2 + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicSHILD: );
	loadModelSelectors[ S_ss3 + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicSHILD: );
	loadModelSelectors[ S_ss4 + GLYPH_CMAP_OFF ] = @selector( loadModelFunc_MagicSHILD: );
	
	// explotion symbols ( 9 postion * 7 types )
	// type DARK
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_DARK + i ] = @selector( loadModelFunc_explotionDARK: );
	}
	// type NOXIOUS
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_NOXIOUS + i ] = @selector( loadModelFunc_explotionNOXIOUS: );
	}
	// type MUDDY
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_MUDDY + i ] = @selector( loadModelFunc_explotionMUDDY: );
	}
	// type WET
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_WET + i ] = @selector( loadModelFunc_explotionWET: );
	}
	// type MAGICAL
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_MAGICAL + i ] = @selector( loadModelFunc_explotionMAGICAL: );
	}
	// type FIERY
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_FIERY + i ] = @selector( loadModelFunc_explotionFIERY: );
	}
	// type FROSTY
	for ( i=0 ; i < MAXEXPCHARS ; i++ ) {
		loadModelSelectors[ NH3D_EXPLODE_FROSTY + i ] = @selector( loadModelFunc_explotionFROSTY: );
	}
	


}



@end
