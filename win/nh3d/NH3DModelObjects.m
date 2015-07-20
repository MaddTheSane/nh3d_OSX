//
//  NH3DModelObjects.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/11/02.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

#import "NH3DModelObjects.h"


static GLfloat colors[ 16 ][ 3 ] = {
	{ 0.1 , 0.1 , 0.1  },				// Black
	{ 0.81424, 0.14136 , 0.14136 },		// Red
	{ 0.17568 , 0.81424 , 0.17568 },	// Green
	{ 0.8038 , 0.47048 , 0.0828 },		// Brown
	{ 0.16568 , 0.16568 , 0.81424 },	// Blue
	{ 0.81424 , 0.17568 , 0.81424 },	// Magenta
	{ 0.17568 , 0.81424 , 0.81424 },	// Cyan
	{ 0.4 , 0.4 , 0.4 },				// Gray
	{ 1.0 , 1.0 , 1.0  },				// No Color
	{ 0.91424, 0.51136 , 0.00136 },		// Orange
	{ 0.37568 , 0.85424 , 0.37568 },	// Bright Green
	{ 0.81424, 0.81424 , 0.00136 },		// Yellow
	{ 0.37568 , 0.37568 , 0.81424 },	// Bright Blue
	{ 0.81424 , 0.47568 , 0.81424 },	// Bright Magenta
	{ 0.47568 , 0.81424 , 0.81424 },	// Bright Cyan
	{ 1.0 , 0.929 , 0.929 }				// White
};

static NH3DMaterial defaultMat = {
		{ 0.5, 0.5, 0.5, 1.0 },
		{ 1.0 , 1.0 , 1.0 , 1.0 },
		{ 0.0 , 0.0 , 0.0 , 1.0},
		{ 0.1 , 0.1 , 0.1 , 1.0 },
		1.0 
};


@implementation NH3DModelObjects


- (GLuint)loadImageToTexture:(NSString *)fileName
{
	NSImage	*sourcefile = [ [NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.tif",
																   [[NSBundle mainBundle] resourcePath],
																	fileName]						  ];
	NSBitmapImageRep	*imgrep;
	GLuint				tex_id;			// valiable to return
	
	if (sourcefile == nil) {
		
		sourcefile = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",
															  [[NSBundle mainBundle] resourcePath],
															   fileName]						 ];
		
		if (sourcefile == nil) {
			NSLog(@"texture file %@ is not found.",fileName);
			return 0;
		}
	}
	   
		imgrep = [[NSBitmapImageRep alloc] initWithData:[sourcefile TIFFRepresentation]];
	   
	   glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
	   
	   glGenTextures( 1, &tex_id );
	   glBindTexture( GL_TEXTURE_2D, tex_id );
	   
	   glTexParameterf(GL_TEXTURE_2D,GL_GENERATE_MIPMAP,GL_TRUE);
	   
	   
	  // glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 
	  //			[imgrep pixelsWide], [imgrep pixelsHigh], 
	  //				0,
	//				[imgrep hasAlpha] ? GL_RGBA : GL_RGB, 
	//				GL_UNSIGNED_BYTE, 
	//				[imgrep bitmapData]);
	   
	   // create automipmap texture
	   gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGBA,
						 [imgrep pixelsWide],[imgrep pixelsHigh],
						 [imgrep hasAlpha] ? GL_RGBA : GL_RGB,
						 GL_UNSIGNED_BYTE,[imgrep bitmapData]);
	   
	   glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	   glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	   
	   glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	   glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	   
	   
	   [imgrep release];
	   [sourcefile release];
	   
	   return tex_id;
}

/*
- (BOOL)importOBJfileToNH3DModel:(NSString *)name
{	
	// NOTICE.
	// this method work for TRIANGLE MESH(vertexs,normals) ONLY 
	// not yat impliment other mesh type. do not work well texturecood, and faceinfomation.
	// plz use method '- (BOOL)import3DSfileToNH3DModel:(NSString *)filename ' and 3ds format files.
	// ---- A kind has too abundant an OBJ file and is hard. I am too unpleasant to accept. hal.
	
	
	NSCharacterSet *chSet;
	NSString *sourceObj = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@.OBJ",name]];
	NSString *destText;
	NSScanner *scanner;

	if (sourceObj == nil) {
		NSLog(@"file %@.OBJ is not found.",name);
		return NO;
	} else 
	
	modelName = name;
	
	chSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	
	scanner = [NSScanner scannerWithString:sourceObj];
	
    while(![scanner isAtEnd] && (verts_qty < MAX_VERTICES && face_qty < MAX_POLYGONS)) {
			
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		
			[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
			
			if ([destText isEqualToString:@"v"]) {
				// scan vertexes
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					verts[verts_qty].x = [destText floatValue];
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					verts[verts_qty].y = [destText floatValue];
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					verts[verts_qty].z = [destText floatValue];
					
					verts_qty++;
					
			} else if ([destText isEqualToString:@"vn"]) {
					// scan normals
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					norms[normal_qty].x = [destText floatValue];
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					norms[normal_qty].y = [destText floatValue];
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					norms[normal_qty].z = [destText floatValue];
					
					normal_qty++;
					
			} else if ([destText isEqualToString:@"vt"]) {
					// scan texture coords
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					texcoords[texcords_qty].s = [destText floatValue];
					[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
					texcoords[texcords_qty].t = [destText floatValue];
					//NSLog(@"vt %d:%f,%f",texcords_qty,texcoords[texcords_qty].s,texcoords[texcords_qty].t);
					
					texcords_qty++;
					
			} else if ([destText isEqualToString:@"f"]) {
				// scan faces
				// a format of 'f' section its vertex reference number,
				// optionally include the texture vertex and vertex normal reference numbers.
				// e,g. v1/vt1/vn1 /v2/vt2/vn2 ....
				// but not work well yat.
					
					//NSRange aRange = [destText rangeOfString:@"/"];
					//if ( aRange.length != 0) {
						[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
						NSArray *faceArray_A = [destText componentsSeparatedByString:@"/"];
						faces[face_qty].a = [[faceArray_A objectAtIndex:0] intValue];
						texReference[face_qty].a = [[faceArray_A objectAtIndex:1] intValue];
						normReference[face_qty].a = [[faceArray_A objectAtIndex:2] intValue];
						
					//}	
						[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
						NSArray *faceArray_B = [destText componentsSeparatedByString:@"/"];
						faces[face_qty].b = [[faceArray_B objectAtIndex:0] intValue];
						texReference[face_qty].b = [[faceArray_B objectAtIndex:1] intValue];
						normReference[face_qty].b = [[faceArray_B objectAtIndex:2] intValue];
					
						
						[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
						NSArray *faceArray_C = [destText componentsSeparatedByString:@"/"];
						faces[face_qty].c = [[faceArray_C objectAtIndex:0] intValue];
						texReference[face_qty].c = [[faceArray_C objectAtIndex:1] intValue];
						normReference[face_qty].c = [[faceArray_C objectAtIndex:2] intValue];
						
						face_qty++;
						
			} // end if ([destText ...
			
			[pool release];
    } // end while(![scanner isAtEnd])
	
	return YES;
}
*/

- (BOOL)import3DSfileToNH3DModel:(NSString *)name
{
	int i = 0;
	
	unsigned short l_ChunkIdent = 0;
	unsigned char l_Name = 0;
	unsigned short l_Counts = 0;
	unsigned short l_Face_Flag = 0;
	unsigned long l_ChunkLength = 0;
			
	NSRange fileRange = {0,0};
	
	// Open 3DS file and Create NSData object
	NSData *file_3ds = [[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.3ds",[[NSBundle mainBundle] resourcePath],name]
													  options:NSMappedRead
														error:nil];
	//NSLog(@"Model %@ loading...",name);
	
	char	mName[20];
	
	if (file_3ds == nil) return NO;
	
	fileRange.length = [file_3ds length];
	fileRange.location = 0;
	
	
	while (fileRange.location < fileRange.length && verts_qty < MAX_VERTICES && face_qty < MAX_POLYGONS)
	{		
		float floatBuffer = 0.0;	// float value buffer
		unsigned short shortBuffer = 0; // short value buffer
		unsigned long longBuffer = 0; // long value buffer
		
		//NSLog(@"Read start %d/%d",fileRange.location,fileRange.length);
		
		[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
		fileRange.location = fileRange.location + sizeof(unsigned short);
		
		l_ChunkIdent = NSSwapLittleShortToHost(shortBuffer);
		
		//NSLog(@"ChunkID: %x",l_ChunkIdent);
		
		[file_3ds getBytes:&longBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned long))];
		fileRange.location = fileRange.location + sizeof(unsigned long);
		
		l_ChunkLength = NSSwapLittleLongToHost(longBuffer);
		
		//NSLog(@"Chunk_length: %d",l_ChunkLength);
		
		switch (l_ChunkIdent)
        {
			
			case 0x4d4d:	//MAIN CHUNK
				break;    
				
			case 0x3d3d:	//3D EDITOR CHUNK
				break;
				
			case 0x4000:	// MODELBLOCK ..read model name
				
				i=0;
				do
				{
					[file_3ds getBytes:&l_Name range:NSMakeRange(fileRange.location,1)];
					fileRange.location = fileRange.location + 1;
					mName[i]=l_Name;
					i++;
                }while(l_Name != '\0' && i<20);
					
					modelName = [[NSString alloc] initWithCString:mName encoding:NSUTF8StringEncoding];
				
				break;
				
			case 0x4100:	// TRIANGULAR MESH
				break;
				
			case 0x4110:	// read VERTICES
				
				[file_3ds getBytes:&l_Counts range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
				fileRange.location = fileRange.location + sizeof(unsigned short);
				
				verts_qty =  NSSwapLittleShortToHost(l_Counts);
                
				if (verts_qty > MAX_VERTICES) { 
					verts_qty = MAX_VERTICES;
					NSLog(@"Model %@|%@ reache to MaxVertices. it does not complete.",modelCode,modelName);
				}
				
				normal_qty = verts_qty;
				
				if ( verts_qty ) {
					
					verts = malloc( verts_qty * sizeof(NH3DVertexType) );
					norms = malloc( normal_qty * sizeof(NH3DVertexType) );
					
					//NSLog(@"Number of vertices: %d",verts_qty);						
					
					for (i=0; i < verts_qty; i++)
					{
						
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
						fileRange.location = fileRange.location + sizeof(float);
						
						verts[i].x = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Vertices x: %f",i,verts[i].x);
						
						
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
						fileRange.location = fileRange.location + sizeof(float);
						
						verts[i].y = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Vertices y: %f",i,verts[i].y);
						
						
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
						fileRange.location = fileRange.location + sizeof(float);
						
						verts[i].z = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Vertices list z: %f",i,verts[i].z);
					}
				} else {
					NSLog(@"Model %@|%@ does not have effective data. check modelformat or data.",modelCode,modelName);
					return NO;
				}
				
				break;
				
				
			case 0x4120:	// FACES DESCRIPTION ....read face infomation
				
				[file_3ds getBytes:&l_Counts range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
				fileRange.location = fileRange.location + sizeof(unsigned short);
				
				face_qty = NSSwapLittleShortToHost(l_Counts);
				
				if (face_qty > MAX_POLYGONS) { 
					face_qty = MAX_POLYGONS;
					NSLog(@"Model %@|%@ reache to MaxPolygons. it does not complete.",modelCode,modelName);
				}
				
					if ( face_qty ) {
						faces = malloc( face_qty * sizeof(NH3DFaceType));
						
						//NSLog(@"Number of polygons: %d",face_qty); 
						
						for (i=0; i < face_qty; i++)
						{
							[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
							fileRange.location = fileRange.location + sizeof(unsigned short);
							
							faces[i].a = NSSwapLittleShortToHost(shortBuffer);
							
							//NSLog(@"%d Polygon point a: %d",i,faces[i].a);
							
							
							[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
							fileRange.location = fileRange.location + sizeof(unsigned short);
							
							faces[i].b = NSSwapLittleShortToHost(shortBuffer);
							
							//NSLog(@"%d Polygon point b: %d",i,faces[i].b);
							
							[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
							fileRange.location = fileRange.location + sizeof(unsigned short);
							
							faces[i].c = NSSwapLittleShortToHost(shortBuffer);
							
							//NSLog(@"%d Polygon point c: %d",i,faces[i].c);
							
							
							[file_3ds getBytes:&l_Face_Flag range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
							fileRange.location = fileRange.location + sizeof(unsigned short);
							
							l_Face_Flag = NSSwapLittleShortToHost(l_Face_Flag);
							
							//NSLog(@"%d Face flags: %x",i,l_Face_Flag);
							
						}
					}
				break;
				
			case 0x4130:	// FACE MATERIALS
				break;
				
			case 0x4140:	// MAPPING COORDINATES LIST ...read texture uv infomation
				
				[file_3ds getBytes:&l_Counts range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
				fileRange.location = fileRange.location + sizeof(unsigned short);
				
				texcords_qty = NSSwapLittleShortToHost(l_Counts);
				
				if (texcords_qty > MAX_POLYGONS) { 
					texcords_qty = MAX_POLYGONS;
					NSLog(@"Model %@|%@ TextureCoods reache to MaxPolygons. it does not complete.",modelCode,modelName);
				}
					
					if ( texcords_qty ) {
						
						texcoords = malloc( texcords_qty * sizeof(NH3DMapCoordType) );
						
						//NSLog(@"Number of TexCoords %d",texcords_qty);
						
						for (i=0; i < texcords_qty; i++)
						{
							
							[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
							fileRange.location = fileRange.location + sizeof(float);
							
							texcoords[i].s = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
							
							//NSLog(@"%d Mapping list u: %f",i,texcoords[i].s);
							
							
							[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
							fileRange.location = fileRange.location + sizeof(float);
							
							texcoords[i].t = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
							
							//NSLog(@"%d Mapping list v: %f",i,texcoords[i].t);
						}
					}
					break;
				
			default: // skip other chunk
				
				fileRange.location = fileRange.location + l_ChunkLength-6;
				//NSLog(@"Read done ... %d/%d",fileRange.location,fileRange.length);
				break;
		}
		
	}
		
	[file_3ds release];
	
	return YES;
}


- (float)vectorLength :(NH3DVertexType *)p_vector
{
	return (float)(sqrt(p_vector->x*p_vector->x + p_vector->y*p_vector->y + p_vector->z*p_vector->z));
}


- (void)vectorNormalize:(NH3DVertexType *)p_vector
{
	float l_length;
	
	l_length = [self vectorLength:p_vector];
	if (l_length==0) l_length=1;
	p_vector->x /= l_length;
	p_vector->y /= l_length;
	p_vector->z /= l_length;
}

- (void)createVector :(NH3DVertexType *)p_start :(NH3DVertexType *)p_end :(NH3DVertexType *)p_vector
{
    p_vector->x = p_end->x - p_start->x;
    p_vector->y = p_end->y - p_start->y;
    p_vector->z = p_end->z - p_start->z;
	[self vectorNormalize:p_vector];
}



- (float)vectScalarProduct:(NH3DVertexType *)p_vector1:(NH3DVertexType *)p_vector2
{
    return (p_vector1->x*p_vector2->x + p_vector1->y*p_vector2->y + p_vector1->z*p_vector2->z);
}


- (void)vectDotProduct:(NH3DVertexType *)p_vector1 :(NH3DVertexType *)p_vector2 :(NH3DVertexType *)p_normal
{
    p_normal->x=(p_vector1->y * p_vector2->z) - (p_vector1->z * p_vector2->y);
    p_normal->y=(p_vector1->z * p_vector2->x) - (p_vector1->x * p_vector2->z);
    p_normal->z=(p_vector1->x * p_vector2->y) - (p_vector1->y * p_vector2->x);
}



- (void)calculateNormals
{
	int i;
	NH3DVertexType l_vect1,l_vect2,l_vect3,l_vect_b1,l_vect_b2,l_normal;
	int l_Connect[verts_qty];
	
	for (i=0;  i< verts_qty; i++)
	{
		norms[i].x = 0.0;
		norms[i].y = 0.0;
		norms[i].z = 0.0;
		l_Connect[i]=0;
	}
	
	for (i=0 ; i < face_qty; i++)
	{
        l_vect1.x = verts[ faces[i].a ].x ;
        l_vect1.y = verts[ faces[i].a ].y ;
        l_vect1.z = verts[ faces[i].a ].z ;
        l_vect2.x = verts[ faces[i].b ].x ;
        l_vect2.y = verts[ faces[i].b ].y ;
        l_vect2.z = verts[ faces[i].b ].z ;
        l_vect3.x = verts[ faces[i].c ].x ;
        l_vect3.y = verts[ faces[i].c ].y ;
        l_vect3.z = verts[ faces[i].c ].z ;         
		
        // Polygon normal calculation
		[self createVector :&l_vect1 :&l_vect2 :&l_vect_b1];
        [self createVector :&l_vect1 :&l_vect3 :&l_vect_b2];
        [self vectDotProduct :&l_vect_b1 :&l_vect_b2 :&l_normal];
        [self vectorNormalize :&l_normal];
		
		l_Connect[ faces[i].a ]+=1;
		l_Connect[ faces[i].b ]+=1;
		l_Connect[ faces[i].c ]+=1;
		
		norms[ faces[i].a ].x += l_normal.x;
		norms[ faces[i].a ].y += l_normal.y;
		norms[ faces[i].a ].z += l_normal.z;
		norms[ faces[i].b ].x += l_normal.x;
		norms[ faces[i].b ].y += l_normal.y;
		norms[ faces[i].b ].z += l_normal.z;
		norms[ faces[i].c ].x += l_normal.x;
		norms[ faces[i].c ].y += l_normal.y;
		norms[ faces[i].c ].z += l_normal.z;	
	}	
	
    for (i=0; i < verts_qty; i++)
	{
		if (l_Connect[i]>0)
		{
			norms[i].x /= l_Connect[i];
			norms[i].y /= l_Connect[i];
			norms[i].z /= l_Connect[i];
		}
	}
}



//--------------------------------------------
// initializers
//--------------------------------------------



- ( BOOL )queryExtensionSupported:( char* )szTargetExtension
{
	const unsigned char *pszExtensions = NULL;
    const unsigned char *pszStart;
	unsigned char *pszWhere, *pszTerminator;
	
	// Extension names should not have spaces
	pszWhere = (unsigned char *) strchr( szTargetExtension, ' ' );
	if( pszWhere || *szTargetExtension == '\0' )
		return NO;
	
	// Get Extensions String
	pszExtensions = glGetString( GL_EXTENSIONS );
	
	// Search The Extensions String For An Exact Copy
	pszStart = pszExtensions;
	for(;;)
	{
		pszWhere = (unsigned char *) strstr( (const char *) pszStart, szTargetExtension );
		if( !pszWhere )
			break;
		pszTerminator = pszWhere + strlen( szTargetExtension );
		if( pszWhere == pszStart || *( pszWhere - 1 ) == ' ' )
			if( *pszTerminator == ' ' || *pszTerminator == '\0' )
				return YES;
		pszStart = pszTerminator;
	}
	return NO;
}



- ( void )initParams
{
	verts_qty = 0;							
	face_qty = 0;
	normal_qty = 0;
	texcords_qty = 0;
	texture = 0;
	useEnvironment = NO;
	animate = NO;
	animationValue = 0.0;
	animationRate = 0.1;
	
	currentMaterial = defaultMat;
	
	hasChildObject = NO;
	numberOfChildObjects = 0;
	childObjects = nil;
	
	modelScale.x = 1.0;
	modelScale.y = 1.0;
	modelScale.z = 1.0;
	modelRotate.x = 0;
	modelRotate.y = 0;
	modelRotate.z = 0;
	modelPivot.x = 0;
	modelPivot.y = 0;
	modelPivot.z = 0;
	
	textures[0] = 0;
	numberOfTextures = 0;
}	




- (id) init // emitter init
{
	self = [super init];
	if (self != nil) {
		
		int i;
		
		[ self initParams ];
		
		slowdown = 2.0f;
		xspeed = 0;
		yspeed = 0;
		
		particleGravity.x = 0;
		particleGravity.y = -4.0f;
		particleGravity.z = 0;		
		particleSize = 1.0;
		particleType = PARTICLE_POINTS;
		particleLife = 1.0;
		particles = malloc( MAX_PARTICLES * sizeof(NH3DParticle) );

			
		for( i = 0; i < MAX_PARTICLES; i++ ) {
			particles[ i ].active = YES;
			particles[ i ].life = 0.8f;
			
			particles[ i ].fade = (float) ( rand() % 100 ) / 1000.0f + 0.003;
			particles[ i ].r = colors[ i * ( 12 / MAX_PARTICLES ) ][ 0 ];
			particles[ i ].g = colors[ i * ( 12 / MAX_PARTICLES ) ][ 1 ];
			particles[ i ].b = colors[ i * ( 12 / MAX_PARTICLES ) ][ 2 ];
			particles[ i ].xi = ( (float) ( rand() % 50 ) - 26.0f ) * 10.0f;
			particles[ i ].yi = ( (float) ( rand() % 50 ) - 25.0f ) * 10.0f;
			particles[ i ].zi = ( (float) ( rand() % 50 ) - 25.0f ) * 10.0f;
			particles[ i ].xg = particleGravity.x;
			particles[ i ].yg = particleGravity.y;
			particles[ i ].zg = particleGravity.z;
		}
		
		modelName = [ [[NSDate date] description] retain ];
		modelCode = @"emitter";
		modelType = MODEL_IS_EMITTER;
		active = YES;
		
	}
	
	return self;
}


/*
- (id) initWithOBJFile:(NSString *)name withTexture:(BOOL)flag
{
	self = [super init];
	if (self != nil) {
		NH3DMaterial defaultMat = {{ 0.5, 0.5, 0.5, 1.0 },
		{ 1.0 , 1.0 , 1.0 , 1.0 },
		{ 0.0 , 0.0 , 0.0 , 1.0},
		{ 0.1 , 0.1 , 0.1 , 1.0 },
			1.0 };

		int i;
		[ self initParams ];
		slowdown = 3.0f;
		xspeed = 0;
		yspeed = 0;
		
		particleGravity.x = 0;
		particleGravity.y = -4.0f;
		particleGravity.z = 0;
		
		particleSize = 1.0;
		
		particleType = PARTICLE_POINTS;
		
		for (i=0;i<MAX_TEXTURES;i++)
			textures[i] = 0;
		
		numberOfTextures = 0;
		
		if ([self importOBJfileToNH3DModel:name] == NO) return nil;
		
		modelType = MODEL_IS_OBJECT;
		
		if (flag == YES) {
			textures[texture] = [self loadImageToTexture:name];
			modelType = MODEL_IS_TEXTURED_OBJECT;
			++numberOfTextures;
		}
		
		
		[self calculateNormals];
		
		active = YES;		
	}
	return self;
}
*/

- (id) initWith3DSFile:(NSString *)name withTexture:(BOOL)flag
{
	self = [super init];
	if (self != nil) {
		
		modelCode = [ [NSString alloc] initWithString:name ];
		
		[ self initParams ];
		
		slowdown = 0;
		xspeed = 0;
		yspeed = 0;
		
		particleGravity.x = 0;
		particleGravity.y = 0;
		particleGravity.z = 0;
		particleSize = 0;
		particleType = PARTICLE_POINTS;
		
		if ( ![self import3DSfileToNH3DModel:name] ) return nil;
		
		modelType = MODEL_IS_OBJECT;
		
		if ( flag ) {
			textures[texture] = [self loadImageToTexture:name];
			modelType = MODEL_IS_TEXTURED_OBJECT;
			++numberOfTextures;
		}
		
		[self calculateNormals];		
		active = YES;
	}
	return self;
}

- (void) dealloc {
	
	int i;
	
	//NSLog(@"dealloc %@|%@",modelCode,modelName);
	
	for ( i = 0 ; i < numberOfTextures ; i++ ) {
		GLuint texid = textures[ i ];
		glDeleteTextures( 1 , &texid );
	}
	
	free(verts);
	free(norms);
	free(faces);
	free(texcoords);
	free(particles);

	[ childObjects removeAllObjects ];
	[ childObjects release ];

	[ modelName release ];
	[ modelCode release ];
	
	[super dealloc];
	
}





//--------------------------------------------

- (BOOL)isActive
{
	return active;
}


- (void)setActive:(BOOL)flag
{
	active = flag;
}


- (NSString *)modelName 
{
	return modelName;
}


- (int)verts_qty
{
	return verts_qty;
}


- (int)face_qty
{
	return face_qty;
}


- (int)normal_qty
{
	return normal_qty;
}


- (int)texcords_qty
{
	return texcords_qty;
}


- (NH3DVertexType *)verts
{
	return verts;
}


- (NH3DVertexType *)norms
{
	return norms;
}


- (NH3DFaceType *)faces
{
	return faces;
}

/*
- (NH3DFaceType *)texReference
{
	return texReference;
}


- (NH3DFaceType *)normReference
{
	return normReference;
}
*/

- (NH3DMapCoordType *)texcoords
{
	return texcoords;
}


- (int)texture
{
	return textures[texture];
}


- (void)setTexture:(int)tex_id
{
	texture = tex_id;
}


- (BOOL)addTexture:(NSString *)textureName
{
	if (numberOfTextures+1 < MAX_TEXTURES) {
		textures[numberOfTextures] = [self loadImageToTexture:textureName];
		++numberOfTextures;
		return YES;
	} else {
		NSLog(@"Model %@ :Can't add new Texture %@. reach to limit of texture numbers",modelCode,textureName);
		return NO;
	}
}		


- (BOOL)useEnvironment
{
	return useEnvironment;
}


- (void)setUseEnvironment:(BOOL)flag
{
	useEnvironment = flag;
}


- (BOOL)isAnimate
{
	return animate;
}


- (void)setAnimate:(BOOL)flag
{
	animate = flag;
}


- (float)animationValue
{
	return animationValue;
}


- (void)setAnimationValue:(float)value
{
	animationValue = value;
}


- (float)animationRate
{
	return animationRate;
}


- (void)setAnimationRate:(float)rate
{
	animationRate = rate;
}


- (void)animate
{
	animationValue += animationRate;
}


- (NH3DVertexType)particleGravity
{
	return particleGravity;
}


- (void)setParticleGravityX:(float)x_gravity Y:(float)y_gravity Z:(float)z_gravity
{
	
	int i;
	
	if (modelType != MODEL_IS_EMITTER) return;
	
	particleGravity.x = x_gravity;
	particleGravity.y = y_gravity;
	particleGravity.z = z_gravity;
	
	for( i = 0; i < MAX_PARTICLES; i++ )
	{
		particles[ i ].xg = particleGravity.x;
		particles[ i ].yg = particleGravity.y;
		particles[ i ].zg = particleGravity.z;
	}
	
}


- (void)setParticleType:(int)type
{
	if (modelType != MODEL_IS_EMITTER) return;
	
	particleType = type;
}


- (int)particleColor
{
	if (modelType != MODEL_IS_EMITTER) return 0;
	
	return particleColor;
}


- (void)setParticleColor:(int)col
{
	if (modelType != MODEL_IS_EMITTER) return;
	
	particleColor = col;
}


- (void)setParticleSpeedX:(float)x Y:(float)y
{
	if (modelType != MODEL_IS_EMITTER) return;
	
	xspeed = x;
	yspeed = y;
}


- (void)setParticleSlowdown:(float)value
{
	if (modelType != MODEL_IS_EMITTER) return;
	slowdown = value;
}

- (void)setParticleLife:(float)value
{
	if (modelType != MODEL_IS_EMITTER) return;
	particleLife = value;
}

- (void)setParticleSize:(float)value
{
	if (modelType != MODEL_IS_EMITTER) return;
	particleSize = value;
}

- (NH3DVertexType )modelShift
{
	return modelShift;
}


- (void)setModelShiftX:(float)sx shiftY:(float)sy shiftZ:(float)sz
{
	modelShift.x = sx;
	modelShift.y = sy;
	modelShift.z = sz;
}


- (NH3DVertexType )modelScale
{
	return modelScale;
}


- (void)setModelScaleX:(float)scx scaleY:(float)scy scaleZ:(float)scz
{
	modelScale.x = scx;
	modelScale.y = scy;
	modelScale.z = scz;
}


- (NH3DVertexType )modelRotate
{
	return modelRotate;
}


- (void)setModelRotateX:(float)rx rotateY:(float)ry rotateZ:(float)rz
{
	modelRotate.x = rx;
	modelRotate.y = ry;
	modelRotate.z = rz;
}


- (NH3DVertexType )modelPivot
{
	return modelPivot;
}


- (void)setPivotX:(float)px atY:(float)py atZ:(float)pz
{
	modelPivot.x = px;
	modelPivot.y = py;
	modelPivot.z = pz;
}

- (BOOL)isChild
{
	return isChild;
}

- (void)setIsChild:(BOOL)flag
{
	isChild = flag;
}	


- (BOOL)hasChildObject
{
	return hasChildObject;
}


- (unsigned int)numberOfChildObjects
{
	return numberOfChildObjects;
}


- (NH3DModelObjects *)childObjectAtIndex:(unsigned int)index;
{
	return [childObjects objectAtIndex:index];
}

- (NH3DModelObjects *)childObjectAtLast
{
	return [childObjects lastObject];
}


- (void)addChildObject:(NSString *)childName type:(int)type
{
	NH3DModelObjects *modelobj = nil;
	
	switch (type) {
		
		case MODEL_IS_OBJECT:
			modelobj = [ [[[NH3DModelObjects alloc] initWith3DSFile:childName withTexture:NO] retain] autorelease ];
//			if (modelobj == nil) {
//				modelobj = [[NH3DModelObjects alloc] initWithOBJFile:childName withTexture:NO];
//			}
			
			break;
		case MODEL_IS_TEXTURED_OBJECT:
			modelobj = [ [[[NH3DModelObjects alloc] initWith3DSFile:childName withTexture:YES] retain] autorelease ];
//			if (modelobj == nil) {
//				modelobj = [[NH3DModelObjects alloc] initWithOBJFile:childName withTexture:YES];
//			}
				
			break;
		case MODEL_IS_EMITTER:
			modelobj = [ [[[NH3DModelObjects alloc] init] retain] autorelease ];
			
			break;
		default :
			NSLog(@"NH3DModelObjects:Can't add Child object '%@'. There is not an appointed type '%d'.",childName,type);
			break;
	}
	
	if ( modelobj != nil ) {
		if ( childObjects == nil ) {
			childObjects = [ [NSMutableArray alloc] init ];
		}
		
		[ modelobj setIsChild:YES ];
		[ childObjects addObject:modelobj ];
		hasChildObject = YES;
		numberOfChildObjects = [ childObjects count ];
	} else {
		NSLog(@"NH3DModelObjects:Can't add Child object '%@'. please check filename or location.",childName);
	}
	
	[ modelobj release ];
												
}


- (NH3DMaterial )currentMaterial
{
	return currentMaterial;
}


- (void)setCurrentMaterial:(NH3DMaterial)material
{
	currentMaterial = material;
}


//-------------------------------------------------------------------------------------

- (void)drawSelf
{
	int i;
	float px , py, pz;
	
	if ( active ) {
		
		GLfloat blendcol[4] = { 1.0, 1.0, 1.0, 0.33 };
		
		if ( !isChild ) glPushMatrix();
		
		glTranslatef( modelPivot.x, modelPivot.y, modelPivot.z);
		glRotatef(modelRotate.x , 1, 0, 0);
		glRotatef(modelRotate.y , 0, 1, 0);
		glRotatef(modelRotate.z , 0, 0, 1);
		glScalef( modelScale.x ,modelScale.y ,modelScale.z );
		
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		
		glMaterialfv(GL_FRONT , GL_AMBIENT , currentMaterial.ambient );
		glMaterialfv(GL_FRONT , GL_DIFFUSE , currentMaterial.diffuse );
		glMaterialfv(GL_FRONT , GL_SPECULAR , currentMaterial.specular );
		glMaterialf(GL_FRONT , GL_SHININESS , currentMaterial.shininess );
		glMaterialfv(GL_FRONT , GL_EMISSION , currentMaterial.emission );
				
		
		switch ( modelType ) {
			
			case MODEL_IS_OBJECT:
				
				glActiveTexture(GL_TEXTURE0);
				glDisable(GL_TEXTURE_2D);
				
				if ( useEnvironment ) {
					
					glActiveTexture(GL_TEXTURE1);
					
					glBindTexture( GL_TEXTURE_2D, texture );
					
					glEnable(GL_TEXTURE_2D);
					glEnable(GL_TEXTURE_GEN_S);
					glEnable(GL_TEXTURE_GEN_T);
					
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
					glTexEnvf(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_INTERPOLATE);
					glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, blendcol);
					
					glTexGenf(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
					glTexGenf(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
					glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
				}
				
				glBegin(GL_TRIANGLES);
				
				for ( i= 0 ;i < face_qty ;i++ ) {
					
					glNormal3f( norms[ faces[i].a ].x ,
								norms[ faces[i].a ].y ,
								norms[ faces[i].a ].z );
					
					glVertex3f( verts[ faces[i].a ].x + modelShift.x,
								verts[ faces[i].a ].y + modelShift.y,
								verts[ faces[i].a ].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 1st vertex is over
					glNormal3f( norms[ faces[i].b ].x,
								norms[ faces[i].b ].y,
								norms[ faces[i].b ].z);
					
					glVertex3f( verts[ faces[i].b ].x + modelShift.x,
								verts[ faces[i].b ].y + modelShift.y,
								verts[ faces[i].b ].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 2nd vertex is over
					glNormal3f( norms[ faces[i].c ].x,
								norms[ faces[i].c ].y,
								norms[ faces[i].c ].z);
					
					glVertex3f( verts[ faces[i].c ].x + modelShift.x,
								verts[ faces[i].c ].y + modelShift.y,
								verts[ faces[i].c ].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 3rd vertex is over		
					//--------------------------------------------------------------------------------------------- draw is over
				}
				glEnd();
				
				if ( useEnvironment ) {
					glDisable(GL_TEXTURE_GEN_S);
					glDisable(GL_TEXTURE_GEN_T);
					glDisable(GL_TEXTURE_2D);
				}
				
				glActiveTexture(GL_TEXTURE0);
				glEnable(GL_TEXTURE_2D);
				
				break;
				
			case MODEL_IS_TEXTURED_OBJECT:
				
				glActiveTexture(GL_TEXTURE0);
				glEnable(GL_TEXTURE_2D);
				glBindTexture( GL_TEXTURE_2D, textures[texture] );
				glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
				
				glBegin(GL_TRIANGLES);
				
				for ( i= 0 ;i < face_qty ;i++ ) {
					
					glNormal3f( norms[ faces[i].a ].x ,
								norms[ faces[i].a ].y ,
								norms[ faces[i].a ].z );
					
					glTexCoord2f( texcoords[ faces[i].a ].s,
								  texcoords[ faces[i].a ].t);
					
					glVertex3f( verts[ faces[i].a ].x + modelShift.x,
								verts[ faces[i].a ].y + modelShift.y,
								verts[ faces[i].a ].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 1st vertex is over
					glNormal3f( norms[ faces[i].b ].x,
								norms[ faces[i].b ].y,
								norms[ faces[i].b ].z);
					
					glTexCoord2f( texcoords[ faces[i].b ].s,
								  texcoords[ faces[i].b ].t);
					
					
					glVertex3f( verts[ faces[i].b ].x + modelShift.x,
								verts[ faces[i].b ].y + modelShift.y,
								verts[ faces[i].b ].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 2nd vertex is over
					glNormal3f( norms[ faces[i].c ].x,
								norms[ faces[i].c ].y,
								norms[ faces[i].c ].z);
					
					glTexCoord2f( texcoords[ faces[i].c ].s,
								  texcoords[ faces[i].c ].t);
					
					glVertex3f( verts[ faces[i].c ].x + modelShift.x,
								verts[ faces[i].c ].y + modelShift.y,
								verts[ faces[i].c ].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 3rd vertex is over		
					//--------------------------------------------------------------------------------------------- draw is over
					
				}	
					glEnd();
				
					break;
				
			case MODEL_IS_EMITTER:
				
				glDisable(GL_LIGHTING);
				glDisable(GL_TEXTURE_2D);
				
				glEnable(GL_BLEND);
				glBlendFunc(GL_SRC_ALPHA ,GL_ONE);
				
				for( i = 0; i < MAX_PARTICLES; i++ ) {
					
					float colorArray[4] = { particles[ i ].r, particles[ i ].g, particles[ i ].b, particles[ i ].life };
					
					if( particles[ i ].active ) {
						px = particles[ i ].x;         
						py = particles[ i ].y;
						pz = particles[ i ].z; 
						float pSize;
						
						switch ( particleType ) {
							
							case PARTICLE_POINTS :
								
								glPointSize( ((random() % 500 )*0.01) + particleSize );
								
								glBegin(GL_POINTS);
								glColor4fv(colorArray);
								glVertex3f( px + 0.02f, py + 0.02f, pz +0.02f);
								glVertex3f( px - 0.02f, py + 0.02f, pz -0.02f);
								glVertex3f( px + 0.02f, py - 0.02f, pz +0.02f);
								glVertex3f( px - 0.02f, py - 0.02f, pz -0.02f);
								glEnd();
								
								break;
							case PARTICLE_LINES :
								glLineWidth( ((random() % 400)*0.01) + particleSize );
								
								glBegin(GL_LINE_STRIP);
								glColor4fv(colorArray);
								glVertex3f( px + 0.02f, py , pz ); glVertex3f( px - 0.02f, py + 0.1f, pz + 0.01f );
								glVertex3f( px - 0.02f, py , pz ); glVertex3f( px + 0.02f, py - 0.1f, pz - 0.01f );
								glEnd();
								
								break;
							case PARTICLE_BOTH :								
								glPointSize( ((random() % 500)*0.01) + particleSize);
								
								glBegin(GL_POINTS);
								glColor4fv(colorArray);
								glVertex3f( px + 0.02f, py + 0.02f, pz +0.02f);
								glVertex3f( px - 0.02f, py + 0.02f, pz -0.02f);
								glVertex3f( px + 0.02f, py - 0.02f, pz +0.02f);
								glVertex3f( px - 0.02f, py - 0.02f, pz -0.02f);
								glEnd();
								
								glLineWidth( (random() % 4) + particleSize);
								
								glBegin(GL_LINE_STRIP);
								
								glColor4fv(colorArray);
								glVertex3f( px + 0.02f, py , pz ); glVertex3f( px - 0.02f, py + 0.1f, pz + 0.01f );
								glVertex3f( px , py , pz ); glVertex3f( px - 0.02f, py - 0.1f, pz - 0.01f );
								glEnd();
								
								break;
							case PARTICLE_AURA :
								glLineWidth( ((random() % 200)*0.01) + particleSize);
								
								glBegin(GL_LINE_STRIP);
								
								glColor4fv(colorArray);

								glVertex3f( px + 0.3975f , py + 0.2f , pz + 2.0f   );	glVertex3f( px + 1.11333f, py		 , pz + 1.6963f);
								glVertex3f( px + 1.11333f, py		 , pz + 1.6963f);	glVertex3f( px + 1.6958f , py + 0.1f , pz + 1.1338f);
								glVertex3f( px + 1.6958f , py + 0.1f , pz + 1.1338f);	glVertex3f( px + 2.0f	 , py		 , pz + 0.3984f);
								glVertex3f( px + 2.0f	 , py		 , pz + 0.3984f);	glVertex3f( px + 2.0f	 , py + 0.2f , pz - 0.3984f);
								glVertex3f( px + 2.0f	 , py + 0.2f , pz - 0.3984f);	glVertex3f( px + 1.6958f , py		 , pz - 1.1338f);
								glVertex3f( px + 1.6958f , py		 , pz - 1.1338f);	glVertex3f( px + 1.1333f , py + 0.1f , pz - 1.6953f);
								glVertex3f( px + 1.1333f , py + 0.1f , pz - 1.6953f);	glVertex3f( px + 0.3975f , py		 , pz - 2.0f   );
								glVertex3f( px + 0.3975f , py		 , pz - 2.0f   );	glVertex3f( px - 0.3975f , py + 0.2f , pz - 2.0f   );
								glVertex3f( px - 0.3975f , py + 0.2f , pz - 2.0f   );	glVertex3f( px - 1.1323f , py		 , pz - 1.6953f);
								glVertex3f( px - 1.1323f , py		 , pz - 1.6953f);	glVertex3f( px - 1.6958f , py + 0.1f , pz - 1.1338f);
								glVertex3f( px - 1.6958f , py + 0.1f , pz - 1.1338f);	glVertex3f( px - 2.0f    , py		 , pz - 0.3984f);
								glVertex3f( px - 2.0f    , py		 , pz  -0.3984f);	glVertex3f( px - 2.0f    , py + 0.2f , pz + 0.3984f);
								glVertex3f( px - 2.0f    , py + 0.2f , pz + 0.3984f);	glVertex3f( px - 1.6958f , py		 , pz + 1.1338f);
								glVertex3f( px - 1.6958f , py		 , pz + 1.1338f);	glVertex3f( px - 1.1323f , py + 0.1f , pz + 1.6963f);
								glVertex3f( px - 1.1323f , py + 0.1f , pz + 1.6963f);	glVertex3f( px - 0.3975f , py		 , pz + 2.0f   );
								glVertex3f( px - 0.3975f , py		 , pz + 2.0f   );	glVertex3f( px + 0.3975f , py + 0.2f , pz + 2.0f   );
								glEnd();
								
								break;
							default :
								pSize = ( (random() % 5) + particleSize) * 0.01;
								glBegin(GL_QUADS);
								glColor4fv(colorArray);
								glVertex3f( px + pSize, py + pSize, pz );
								glVertex3f( px - pSize, py + pSize, pz );
								glVertex3f( px + pSize, py - pSize, pz );
								glVertex3f( px - pSize, py - pSize, pz );
								glEnd();
								break;
						}
						
						
						// Move on the axes by appropriate amount
						particles[ i ].x += particles[ i ].xi / ( slowdown * 1000 );
						particles[ i ].y += particles[ i ].yi / ( slowdown * 1000 );
						particles[ i ].z += particles[ i ].zi / ( slowdown * 1000 );
						// Take gravity into account
						particles[ i ].xi += particles[ i ].xg;
						particles[ i ].yi += particles[ i ].yg;
						particles[ i ].zi += particles[ i ].zg;
						// Reduce particle's life by 'fade'
						particles[ i ].life -= particles[ i ].fade;
						
						if( particles[ i ].life < 0.0f ) {
							particles[ i ].life = particleLife; 
							
							particles[ i ].fade = (float) ( rand() % 100 ) / 1000.0f +
								0.003f;
							particles[ i ].x = 0.0f;   // Center on X axis
							particles[ i ].y = 0.0f;   // Center on Y axis
							particles[ i ].z = 0.0f;   // Center on Z axis
													   // X axis speed and direction
							particles[ i ].xi = xspeed + (float) ( random() % 60 ) - 32.0f;
							particles[ i ].yi = yspeed + (float) ( random() % 60 ) - 30.0f;
							particles[ i ].zi = (float) ( random() % 60 ) - 30.0f;
							
							particles[ i ].r = colors[ particleColor ][ 0 ];
							particles[ i ].g = colors[ particleColor ][ 1 ];
							particles[ i ].b = colors[ particleColor ][ 2 ];
						}
						
					}
				}

				glEnable(GL_LIGHTING);
				glEnable(GL_TEXTURE_2D);
				
				break;		
		}
		
		if ( !isChild ) glPopMatrix();
		
		// Draw ChildObject
		if ( hasChildObject ) {
			for ( i=0 ; i < numberOfChildObjects ; i++ ) {
				[ [childObjects objectAtIndex:i] drawSelf ];
			}
		}
		
	}
	
}	


@end
