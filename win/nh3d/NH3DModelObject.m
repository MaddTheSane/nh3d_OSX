//
//  NH3DModelObject.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/11/02.
//  Copyright 2005 Haruumi Yoshino. All rights reserved.
//

#include "C99Bool.h"
#include <math.h>
#include <tgmath.h>
#import "NH3DModelObject.h"
#include <OpenGL/gl.h>
#import "NetHack3D-Swift.h"
#import "NSBitmapImageRep+NH3DAdditions.h"


static const GLfloat colors[16][3] = {
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

static const NH3DMaterial defaultMat = {
		{0.5, 0.5, 0.5, 1.0},
		{1.0, 1.0, 1.0, 1.0},
		{0.0, 0.0, 0.0, 1.0},
		{0.1, 0.1, 0.1, 1.0},
		1.0 
};

@implementation NH3DModelObject
@synthesize currentMaterial;
@synthesize isChild;
@synthesize animated = animate;
@synthesize useEnvironment;
@synthesize active;
@synthesize animationRate;
@synthesize animationValue;
@synthesize particleColor;
@synthesize particleType;
@synthesize modelShift;
@synthesize modelScale;
@synthesize modelRotate;
@synthesize modelPivot;
@synthesize particleLife;
@synthesize particleSlowdown = slowdown;
@synthesize particleGravity;
@synthesize particleSize;
@synthesize modelName;
@synthesize modelType;
@synthesize verts;
@synthesize norms;
@synthesize faces;
@synthesize texcoords;
@synthesize numberOfTextures;
@synthesize particleSpeedX = xspeed;
@synthesize particleSpeedY = yspeed;

- (BOOL)hasChildren
{
	return childObjects ? childObjects.count > 0 : NO;
}

- (NSInteger)countOfChildObjects
{
	return childObjects.count;
}

+ (instancetype)modelNamed:(NSString*)name withTexture:(BOOL)flag
{
	return [self modelNamed:name textureNamed:flag ? name : nil];
}

+ (instancetype)modelNamed:(NSString*)name textureNamed:(NSString*)texName
{
	NH3DModelObject *modObj = [[NH3DModelObject alloc] initWith3DSFile:name textureNamed:texName];
	if (!modObj) {
		modObj = [[NH3DModelObject alloc] initWithOBJFile:name textureNamed:texName];
	}
	return modObj;
}

- (GLuint)loadImageToTexture:(NSString *)fileName
{
	NSImage	*sourcefile = [NSImage imageNamed:fileName];
	NSBitmapImageRep	*imgrep;
	GLuint				tex_id = 0;			// variable to return
	
	if (sourcefile == nil) {
		sourcefile = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",
															  [NSBundle mainBundle].resourcePath,
															  fileName]];
		
		if (sourcefile == nil) {
			NSLog(@"texture file %@ was not found.",fileName);
			return 0;
		}
	}
	
	imgrep = [[[NSBitmapImageRep alloc] initWithData:sourcefile.TIFFRepresentation] forceRGBColorSpace];
	
	if (!imgrep) {
		return tex_id;
	}
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	
	glGenTextures(1, &tex_id);
	glBindTexture(GL_TEXTURE_2D, tex_id);
	
	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// create automipmap texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
				 imgrep.pixelsWide, imgrep.pixelsHigh,
				 0, imgrep.alpha ? GL_RGBA : GL_RGB,
				 GL_UNSIGNED_BYTE, imgrep.bitmapData);

	return tex_id;
}

- (BOOL)importOBJfileToNH3DModel:(NSString *)name
{
	// NOTICE.
	// this method work for TRIANGLE MESH(vertexs,normals) ONLY
	// not yat impliment other mesh type. do not work well texturecood, and faceinfomation.
	// plz use method '- (BOOL)import3DSfileToNH3DModel:(NSString *)filename ' and 3ds format files.
	// ---- A kind has too abundant an OBJ file and is hard. I am too unpleasant to accept. hal.
	
	NSCharacterSet *chSet;
	NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"obj"];
	if (!sourceURL) {
		if (name.absolutePath) {
			sourceURL = [NSURL fileURLWithPath:name];
			name = name.lastPathComponent.stringByDeletingPathExtension;
		} else {
			return NO;
		}
	}
	
	NSString *sourceObj = [[NSString alloc] initWithContentsOfURL:sourceURL usedEncoding:NULL error:NULL];
	NSString *destText;

	if (sourceObj == nil) {
		NSLog(@"file %@.obj was not found.", name);
		return NO;
	} else {
		modelName = [name copy];
	}
	
	chSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSArray <NSString*>* lines = [sourceObj componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	// initial count of vert/norms/faces/coords
	{
		NSInteger vtxCnt = 0;
		NSInteger nmlCnt = 0;
		NSInteger facCnt = 0;
		NSInteger cooCnt = 0;
		for (NSString *line in lines) {
			if ([line hasPrefix:@"#"]) {
				continue;
			} else if ([line hasPrefix:@"v "]) {
				vtxCnt++;
			} else if ([line hasPrefix:@"vn "]) {
				nmlCnt++;
			} else if ([line hasPrefix:@"vt "]) {
				facCnt++;
			} else if ([line hasPrefix:@"f "]) {
				cooCnt++;
			}
		}
		// Basic sanity check:
		if (vtxCnt == 0 || nmlCnt == 0 || facCnt == 0 || cooCnt == 0) {
			NSLog(@"Invalid OBJ file \"%@\"? Vertexes: %li, Normals: %li, Faces: %li, Texture Coordinates: %li", name, (long)vtxCnt, (long)nmlCnt, (long)facCnt, (long)cooCnt);
			return NO;
		}
		verts = calloc(sizeof(vector_float3), vtxCnt);
		norms = calloc(sizeof(vector_float3), nmlCnt);
		faces = calloc(sizeof(NH3DFaceType), facCnt);
		texcoords = calloc(sizeof(NH3DMapCoordType), cooCnt);
	}
	
	for (NSString *line in lines) {
		if (!(verts_qty < MAX_VERTICES && face_qty < MAX_POLYGONS)) {
			break;
		}
		@autoreleasepool {
			NSScanner *scanner = [[NSScanner alloc] initWithString:line];
			[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
			
			if ([destText isEqualToString:@"v"]) {
				// scan vertexes
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				verts[verts_qty].x = destText.floatValue;
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				verts[verts_qty].y = destText.floatValue;
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				verts[verts_qty].z = destText.floatValue;
				
				verts_qty++;
			} else if ([destText isEqualToString:@"vn"]) {
				// scan normals
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				norms[normal_qty].x = destText.floatValue;
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				norms[normal_qty].y = destText.floatValue;
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				norms[normal_qty].z = destText.floatValue;
				
				normal_qty++;
			} else if ([destText isEqualToString:@"vt"]) {
				// scan texture coords
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				texcoords[texcords_qty].s = destText.floatValue;
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				texcoords[texcords_qty].t = destText.floatValue;
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
				// The bases start at 1. Remove 1 to prevent off-by-one failures.
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				NSArray *faceArray_A = [destText componentsSeparatedByString:@"/"];
				faces[face_qty].a = [faceArray_A[0] intValue] - 1;
				texReference[face_qty].a = [faceArray_A[1] intValue] - 1;
				normReference[face_qty].a = [faceArray_A[2] intValue] - 1;
				//}
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				NSArray *faceArray_B = [destText componentsSeparatedByString:@"/"];
				faces[face_qty].b = [faceArray_B[0] intValue] - 1;
				texReference[face_qty].b = [faceArray_B[1] intValue] - 1;
				normReference[face_qty].b = [faceArray_B[2] intValue] - 1;
				
				[scanner scanUpToCharactersFromSet:chSet intoString:&destText];
				NSArray *faceArray_C = [destText componentsSeparatedByString:@"/"];
				faces[face_qty].c = [faceArray_C[0] intValue] - 1;
				texReference[face_qty].c = [faceArray_C[1] intValue] - 1;
				normReference[face_qty].c = [faceArray_C[2] intValue] - 1;
				
				face_qty++;
			} else if ([destText isEqualToString:@"mtllib"]) {
				NSString *mtlName;
				[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&mtlName];
				sourceURL = [[NSBundle mainBundle] URLForResource:mtlName withExtension:nil];
				if (!sourceURL) {
					if (mtlName.absolutePath) {
						sourceURL = [NSURL fileURLWithPath:mtlName];
					} else {
						NSLog(@"Unable to locate mtl file named '%@', skipping.", mtlName);
						continue;
					}
				}
				NSError *err;
				NSString *sourceMtl = [NSString stringWithContentsOfURL:sourceURL usedEncoding:NULL error:&err];
				if (!sourceMtl) {
					NSLog(@"Unable to open mtl file: %@", err);
					continue;
				}
				NSScanner *mtlScan = [NSScanner scannerWithString:sourceMtl];
				BOOL mtlDefined = NO;
				while(!mtlScan.atEnd && (verts_qty < MAX_VERTICES && face_qty < MAX_POLYGONS)) {
					@autoreleasepool {
						[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
						if ([[destText substringToIndex:1] isEqualToString:@"#"]) {
							// Skip past comments
							[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
						} else if([destText isEqualToString:@"Ns"]) {
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.shininess = [destText floatValue];
						} else if([destText isEqualToString:@"newmtl"]) {
							if (mtlDefined) {
								break;
							}
							[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil]; // TODO: use this, but how?
							mtlDefined = YES;
						} else if([destText isEqualToString:@"Ka"]) {
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							// Unsupported formats
							if ([destText isEqualToString:@"spectral"] || [destText isEqualToString:@"xyz"]) {
								NSString *format = destText;
								[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&destText];
								NSLog(@"Unsupported ambient reflectivity (Ka) type %@ with parameters %@", format, destText);
								continue;
							}
							currentMaterial.ambient[0] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.ambient[1] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.ambient[2] = [destText floatValue];
							currentMaterial.ambient[3] = 1;
						} else if([destText isEqualToString:@"Kd"]) {
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							// Unsupported formats
							if ([destText isEqualToString:@"spectral"] || [destText isEqualToString:@"xyz"]) {
								NSString *format = destText;
								[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&destText];
								NSLog(@"Unsupported diffuse reflectivity (Kd) type %@ with parameters %@", format, destText);
								continue;
							}
							currentMaterial.diffuse[0] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.diffuse[1] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.diffuse[2] = [destText floatValue];
							currentMaterial.diffuse[3] = 1;
						} else if([destText isEqualToString:@"Ks"]) {
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							// Unsupported formats
							if ([destText isEqualToString:@"spectral"] || [destText isEqualToString:@"xyz"]) {
								NSString *format = destText;
								[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&destText];
								NSLog(@"Unsupported specular reflectivity (Ks) type %@ with parameters %@", format, destText);
								continue;
							}
							currentMaterial.specular[0] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.specular[1] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.specular[2] = [destText floatValue];
							currentMaterial.specular[3] = 1;
						} else if([destText isEqualToString:@"Ke"]) {
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							// Unsupported formats
							if ([destText isEqualToString:@"spectral"] || [destText isEqualToString:@"xyz"]) {
								NSString *format = destText;
								[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&destText];
								NSLog(@"Unsupported specular emissions (Ke) type %@ with parameters %@", format, destText);
								continue;
							}
							currentMaterial.emission[0] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.emission[1] = [destText floatValue];
							[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
							currentMaterial.emission[2] = [destText floatValue];
							currentMaterial.emission[3] = 1;
						//} else if([destText isEqualToString:@"d"]) {
						//	[mtlScan scanUpToCharactersFromSet:chSet intoString:&destText];
						} else {
							NSString *str1 = destText;
							[mtlScan scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&destText];
							NSLog(@"Unsupported .mtl option: %@ with parameters %@", str1, destText);
						}
					}
				}
			} else if ([[destText substringToIndex:1] isEqualToString:@"#"]) {
				//comment line. skip
				[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
			} else if ([destText isEqualToString:@"o"]) {
				[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&destText];
				modelName = [destText copy];
			} // end if ([destText ...
		}
	} // end while(![scanner isAtEnd])
	
	return YES;
}

- (BOOL)import3DSfileToNH3DModel:(NSString *)name
{
	int i = 0;
	
	unsigned short l_ChunkIdent = 0;
	unsigned char l_Name = 0;
	unsigned short l_Counts = 0;
	unsigned short l_Face_Flag = 0;
	unsigned int l_ChunkLength = 0;
	
	/// location is used for current location, length is the total size of the data file.
	NSRange fileRange = NSMakeRange(0, 0);
	
	// Open 3DS file and Create NSData object
	NSData *file_3ds;
	NSURL *dataURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"3ds"];
	if (dataURL) {
		file_3ds = [[NSData alloc] initWithContentsOfURL:dataURL
												 options:NSDataReadingMappedIfSafe
												   error:nil];
	}
	//NSLog(@"Model %@ loading...",name);
	
	if (!file_3ds) {
		NSString *locName = [NSString stringWithFormat:@"Models/%@", name];
		file_3ds = [[NSDataAsset alloc] initWithName:locName].data;
	}
	
	char mName[21];
	
	if (file_3ds == nil)
		return NO;
	
	// Magic number check
	[file_3ds getBytes:mName range:NSMakeRange(0, 2)];
	if (memcmp("MM", mName, 2) != 0) {
		return NO;
	}
	
	memset(mName, 0, sizeof(mName));
	
	fileRange.length = file_3ds.length;
	fileRange.location = 0;
	
	while (fileRange.location < fileRange.length && verts_qty < MAX_VERTICES && face_qty < MAX_POLYGONS) {
		float floatBuffer = 0.0;	// float value buffer
		unsigned short shortBuffer = 0; // short value buffer
		unsigned int longBuffer = 0; // long value buffer
		
		//NSLog(@"Read start %d/%d",fileRange.location,fileRange.length);
		
		[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
		fileRange.location += sizeof(unsigned short);
		
		l_ChunkIdent = NSSwapLittleShortToHost(shortBuffer);
		
		//NSLog(@"ChunkID: %x",l_ChunkIdent);
		
		[file_3ds getBytes:&longBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned int))];
		fileRange.location += sizeof(unsigned int);
		
		l_ChunkLength = NSSwapLittleIntToHost(longBuffer);
		
		//NSLog(@"Chunk_length: %d",l_ChunkLength);
		
		switch (l_ChunkIdent) {
			case 0x4d4d:	//MAIN CHUNK
				break;
				
			case 0x3d3d:	//3D EDITOR CHUNK
				break;
				
			case 0x4000:	// MODELBLOCK ..read model name
				i = 0;
				do {
					[file_3ds getBytes:&l_Name range:NSMakeRange(fileRange.location, 1)];
					fileRange.location++;
					mName[i]=l_Name;
					i++;
				} while (l_Name != '\0' && i<20);
				
				modelName = @(mName);
				break;
				
			case 0x4100:	// TRIANGULAR MESH
				break;
				
			case 0x4110:	// read VERTICES
				[file_3ds getBytes:&l_Counts range:NSMakeRange(fileRange.location, sizeof(unsigned short))];
				fileRange.location += sizeof(unsigned short);
				
				verts_qty =  NSSwapLittleShortToHost(l_Counts);
				
				if (verts_qty > MAX_VERTICES) {
					verts_qty = MAX_VERTICES;
					NSLog(@"Model %@|%@ reached MaxVertices. It does not complete.", modelCode, modelName);
				}
				
				normal_qty = verts_qty;
				
				if (verts_qty) {
					verts = malloc(verts_qty * sizeof(vector_float3));
					norms = malloc(normal_qty * sizeof(vector_float3));
					
					//NSLog(@"Number of vertices: %d",verts_qty);
					
					for (i = 0; i < verts_qty; i++) {
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
						fileRange.location += sizeof(float);
						
						verts[i].x = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Vertices x: %f",i,verts[i].x);
						
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
						fileRange.location += sizeof(float);
						
						verts[i].y = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Vertices y: %f",i,verts[i].y);
						
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location , sizeof(float))];
						fileRange.location += sizeof(float);
						
						verts[i].z = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Vertices list z: %f",i,verts[i].z);
					}
				} else {
					NSLog(@"Model %@|%@ does not have effective data. Check model format or data.", modelCode, modelName);
					return NO;
				}
				break;
				
			case 0x4120:	// FACES DESCRIPTION ....read face infomation
				[file_3ds getBytes:&l_Counts range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
				fileRange.location += sizeof(unsigned short);
				
				face_qty = NSSwapLittleShortToHost(l_Counts);
				
				if (face_qty > MAX_POLYGONS) {
					face_qty = MAX_POLYGONS;
					NSLog(@"Model %@|%@ reached MaxPolygons. It does not complete.", modelCode, modelName);
				}
				
				if (face_qty) {
					faces = malloc(face_qty * sizeof(NH3DFaceType));
					
					//NSLog(@"Number of polygons: %d",face_qty);
					
					for (i = 0; i < face_qty; i++) {
						[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
						fileRange.location += sizeof(unsigned short);
						
						faces[i].a = NSSwapLittleShortToHost(shortBuffer);
						
						//NSLog(@"%d Polygon point a: %d",i,faces[i].a);
						
						[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
						fileRange.location += sizeof(unsigned short);
						
						faces[i].b = NSSwapLittleShortToHost(shortBuffer);
						
						//NSLog(@"%d Polygon point b: %d",i,faces[i].b);
						
						[file_3ds getBytes:&shortBuffer range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
						fileRange.location += sizeof(unsigned short);
						
						faces[i].c = NSSwapLittleShortToHost(shortBuffer);
						
						//NSLog(@"%d Polygon point c: %d",i,faces[i].c);
						
						[file_3ds getBytes:&l_Face_Flag range:NSMakeRange(fileRange.location , sizeof(unsigned short))];
						fileRange.location += sizeof(unsigned short);
						
						l_Face_Flag = NSSwapLittleShortToHost(l_Face_Flag);
						
						//NSLog(@"%d Face flags: %x",i,l_Face_Flag);
					}
				}
				break;
				
			case 0x4130:	// FACE MATERIALS
				break;
				
			case 0x4140:	// MAPPING COORDINATES LIST ...read texture uv infomation
				[file_3ds getBytes:&l_Counts range:NSMakeRange(fileRange.location, sizeof(unsigned short))];
				fileRange.location += sizeof(unsigned short);
				
				texcords_qty = NSSwapLittleShortToHost(l_Counts);
				
				if (texcords_qty > MAX_POLYGONS) {
					texcords_qty = MAX_POLYGONS;
					NSLog(@"Model %@|%@ TextureCoods reached MaxPolygons. It does not complete.", modelCode, modelName);
				}
				
				if (texcords_qty) {
					texcoords = malloc(texcords_qty * sizeof(NH3DMapCoordType));
					
					//NSLog(@"Number of TexCoords %d",texcords_qty);
					
					for (i = 0; i < texcords_qty; i++) {
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location, sizeof(float))];
						fileRange.location += sizeof(float);
						
						texcoords[i].s = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Mapping list u: %f",i,texcoords[i].s);
						
						[file_3ds getBytes:&floatBuffer range:NSMakeRange(fileRange.location, sizeof(float))];
						fileRange.location += sizeof(float);
						
						texcoords[i].t = NSSwapLittleFloatToHost(NSConvertHostFloatToSwapped(floatBuffer));
						
						//NSLog(@"%d Mapping list v: %f",i,texcoords[i].t);
					}
				}
				break;
				
			default: // skip other chunk
				fileRange.location += l_ChunkLength-6;
				//NSLog(@"Read done ... %d/%d",fileRange.location,fileRange.length);
				break;
		}
		
	}
	
	return YES;
}

//--------------------------------------------
// initializers
//--------------------------------------------
- (BOOL)queryExtensionSupported:(char*)szTargetExtension
{
	const unsigned char *pszExtensions = NULL;
    const unsigned char *pszStart;
	unsigned char *pszWhere, *pszTerminator;
	
	// Extension names should not have spaces
	pszWhere = (unsigned char *)strchr(szTargetExtension, ' ');
	if(pszWhere || *szTargetExtension == '\0')
		return NO;
	
	// Get Extensions String
	pszExtensions = glGetString(GL_EXTENSIONS);
	
	// Search The Extensions String For An Exact Copy
	pszStart = pszExtensions;
	for (;;) {
		pszWhere = (unsigned char *)strstr((const char *)pszStart, szTargetExtension);
		if(!pszWhere)
			break;
		pszTerminator = pszWhere + strlen(szTargetExtension);
		if (pszWhere == pszStart || *( pszWhere - 1 ) == ' ')
			if (*pszTerminator == ' ' || *pszTerminator == '\0')
				return YES;
		pszStart = pszTerminator;
	}
	return NO;
}

- (void)initParams
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

- (instancetype)init
{
	if (self = [super init]) {
		[self initParams];
		
		slowdown = 2.0f;
		xspeed = 0;
		yspeed = 0;
		
		particleGravity.x = 0;
		particleGravity.y = -4.0f;
		particleGravity.z = 0;
		particleSize = 1.0;
		particleType = NH3DParticleTypePoints;
		particleLife = 1.0;
		particles = malloc(MAX_PARTICLES * sizeof(NH3DParticle));
		
		for (int i = 0; i < MAX_PARTICLES; i++) {
			particles[i].active = YES;
			particles[i].life = 0.8f;
			
			particles[i].fade = (float) ( rand() % 100 ) / 1000.0f + 0.003;
			particles[i].r = colors[i * (12 / MAX_PARTICLES)][0];
			particles[i].g = colors[i * (12 / MAX_PARTICLES)][1];
			particles[i].b = colors[i * (12 / MAX_PARTICLES)][2];
			particles[i].xi = ((float) (rand() % 50) - 26.0f) * 10.0f;
			particles[i].yi = ((float) (rand() % 50) - 25.0f) * 10.0f;
			particles[i].zi = ((float) (rand() % 50) - 25.0f) * 10.0f;
			particles[i].xg = particleGravity.x;
			particles[i].yg = particleGravity.y;
			particles[i].zg = particleGravity.z;
		}
		
		modelName = [NSDate date].description;
		modelCode = @"emitter";
		modelType = NH3DModelTypeEmitter;
		active = YES;
	}
	
	return self;
}

- (instancetype) initWithOBJFile:(NSString *)name withTexture:(BOOL)flag
{
	return [self initWithOBJFile:name textureNamed:flag ? name : nil];
}

- (instancetype) initWithOBJFile:(NSString *)name textureNamed:(NSString *)texName
{
	self = [super init];
	if (self != nil) {
		modelCode = [name copy];

		int i;
		[self initParams];
		slowdown = 3.0f;
		xspeed = 0;
		yspeed = 0;
		
		particleGravity.x = 0;
		particleGravity.y = -4.0f;
		particleGravity.z = 0;
		
		particleSize = 1.0;
		
		particleType = NH3DParticleTypePoints;
		
		memset(textures, 0, sizeof(textures));
		
		numberOfTextures = 0;
		
		if ([self importOBJfileToNH3DModel:name] == NO)
			return nil;
		
		modelType = NH3DModelTypeObject;
		
		if (texName) {
			textures[texture] = [self loadImageToTexture:texName];
			modelType = NH3DModelTypeTexturedObject;
			++numberOfTextures;
		}
		
		[self calculateNormals];
		
		active = YES;
	}
	return self;
}

- (instancetype)initWith3DSFile:(NSString *)name withTexture:(BOOL)flag
{
	return [self initWith3DSFile:name textureNamed:flag ? name : nil];
}

- (instancetype)initWith3DSFile:(NSString *)name textureNamed:(NSString*)texName
{
	if (self = [super init]) {
		modelCode = [[NSString alloc] initWithString:name];
		
		[self initParams];
		
		slowdown = 0;
		xspeed = 0;
		yspeed = 0;
		
		particleGravity.x = 0;
		particleGravity.y = 0;
		particleGravity.z = 0;
		particleSize = 0;
		particleType = NH3DParticleTypePoints;
		
		if (![self import3DSfileToNH3DModel:name]) {
			return nil;
		}
		
		modelType = NH3DModelTypeObject;
		
		if (texName) {
			textures[texture] = [self loadImageToTexture:texName];
			modelType = NH3DModelTypeTexturedObject;
			++numberOfTextures;
		}
		
		[self calculateNormals];
		active = YES;
	}
	return self;
}

- (void) dealloc {
	for (int i = 0; i < numberOfTextures; i++) {
		GLuint texid = textures[i];
		glDeleteTextures(1, &texid);
	}
	
	free(verts);
	free(norms);
	free(faces);
	free(texcoords);
	free(particles);
}

//--------------------------------------------

- (NSInteger)verts_qty
{
	return verts_qty;
}

- (NSInteger)face_qty
{
	return face_qty;
}

- (NSInteger)normal_qty
{
	return normal_qty;
}

- (NSInteger)texcords_qty
{
	return texcords_qty;
}

- (NH3DFaceType *)texReference
{
	return texReference;
}

- (NH3DFaceType *)normReference
{
	return normReference;
}

- (GLuint)texture
{
	if (texture > numberOfTextures) {
		return texture;
	}
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
		NSLog(@"Model %@: Can't add new texture \"%@\": Limit of textures reached.", modelCode, textureName);
		return NO;
	}
}

- (void)animate
{
	animationValue += animationRate;
}

- (void)setParticleGravity:(NH3DVertexType)aParticleGravity
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	
	particleGravity = aParticleGravity;
	
	for (int i = 0; i < MAX_PARTICLES; i++) {
		particles[i].xg = particleGravity.x;
		particles[i].yg = particleGravity.y;
		particles[i].zg = particleGravity.z;
	}
}

- (void)setParticleGravityX:(GLfloat)x_gravity Y:(GLfloat)y_gravity Z:(GLfloat)z_gravity
{
	NH3DVertexType toSet;
	toSet.x = x_gravity;
	toSet.y = y_gravity;
	toSet.z = z_gravity;
	self.particleGravity = toSet;
}

- (void)setParticleType:(NH3DParticleType)type
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	
	particleType = type;
}

- (int)particleColor
{
	if (modelType != NH3DModelTypeEmitter)
		return 0;
	
	return particleColor;
}

- (void)setParticleColor:(int)col
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	
	particleColor = col;
}

- (void)setParticleSpeedX:(GLfloat)x Y:(GLfloat)y
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	
	xspeed = x;
	yspeed = y;
}

- (void)setParticleSlowdown:(GLfloat)value
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	slowdown = value;
}

- (void)setParticleLife:(GLfloat)value
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	particleLife = value;
}

- (void)setParticleSize:(GLfloat)value
{
	if (modelType != NH3DModelTypeEmitter)
		return;
	particleSize = value;
}

- (void)setModelShiftX:(GLfloat)sx shiftY:(GLfloat)sy shiftZ:(GLfloat)sz
{
	NH3DVertexType toSet;
	toSet.x = sx;
	toSet.y = sy;
	toSet.z = sz;
	self.modelShift = toSet;
}

- (void)setModelScaleX:(GLfloat)scx scaleY:(GLfloat)scy scaleZ:(GLfloat)scz
{
	NH3DVertexType toSet;
	toSet.x = scx;
	toSet.y = scy;
	toSet.z = scz;
	self.modelScale = toSet;
}

- (void)setModelRotateX:(GLfloat)rx rotateY:(GLfloat)ry rotateZ:(GLfloat)rz
{
	NH3DVertexType toSet;
	toSet.x = rx;
	toSet.y = ry;
	toSet.z = rz;
	self.modelRotate = toSet;
}

- (void)setPivotX:(GLfloat)px atY:(GLfloat)py atZ:(GLfloat)pz
{
	NH3DVertexType toSet;
	toSet.x = px;
	toSet.y = py;
	toSet.z = pz;
	self.modelPivot = toSet;
}

- (NH3DModelObject *)childObjectAtIndex:(NSInteger)index;
{
	return childObjects[index];
}

- (NH3DModelObject *)lastChildObject
{
	return childObjects.lastObject;
}

- (void)addChildObject:(NSString *)childName type:(NH3DModelType)type
{
	NH3DModelObject *modelobj = nil;
	
	switch (type) {
		case NH3DModelTypeObject:
			modelobj = [[NH3DModelObject alloc] initWith3DSFile:childName withTexture:NO];
			//if (modelobj == nil) {
			//	modelobj = [[NH3DModelObject alloc] initWithOBJFile:childName withTexture:NO];
			//}
			
			break;
		case NH3DModelTypeTexturedObject:
			modelobj = [[NH3DModelObject alloc] initWith3DSFile:childName withTexture:YES];
			//if (modelobj == nil) {
			//	modelobj = [[NH3DModelObject alloc] initWithOBJFile:childName withTexture:YES];
			//}
				
			break;
		case NH3DModelTypeEmitter:
			modelobj = [[NH3DModelObject alloc] init];
			break;
			
		default:
			NSLog(@"NH3DModelObject: Can't add Child object '%@'. There is not an appointed type '%ld'.",childName, (long)type);
			break;
	}
	
	if (modelobj != nil) {
		if (childObjects == nil) {
			childObjects = [[NSMutableArray alloc] init];
		}
		
		[modelobj setIsChild:YES];
		[childObjects addObject:modelobj];
	} else {
		NSLog(@"NH3DModelObject: Can't add Child object '%@'. Please check filename or location.", childName);
	}
}

- (void)addChildObject:(NSString *)childName textureName:(NSString*)type
{
	NH3DModelObject *modelobj = nil;

	modelobj = [[NH3DModelObject alloc] initWith3DSFile:childName textureNamed:type];
	if (modelobj == nil) {
		modelobj = [[NH3DModelObject alloc] initWithOBJFile:childName textureNamed:type];
	}

	
	if (modelobj != nil) {
		if (childObjects == nil) {
			childObjects = [[NSMutableArray alloc] init];
		}
		
		[modelobj setIsChild:YES];
		[childObjects addObject:modelobj];
	} else {
		NSLog(@"NH3DModelObject: Can't add Child object '%@'. Please check filename or location.", childName);
	}
}

//-------------------------------------------------------------------------------------

- (void)drawSelf
{
	int i;
	GLfloat px, py, pz;
	
	if (active) {
		static const GLfloat blendcol[4] = {1.0, 1.0, 1.0, 0.33};
		
		if (!isChild) {
			glPushMatrix();
		}
		
		glTranslatef(modelPivot.x, modelPivot.y, modelPivot.z);
		glRotatef(modelRotate.x, 1, 0, 0);
		glRotatef(modelRotate.y, 0, 1, 0);
		glRotatef(modelRotate.z, 0, 0, 1);
		glScalef(modelScale.x, modelScale.y, modelScale.z);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		
		glMaterialfv(GL_FRONT, GL_AMBIENT, currentMaterial.ambient);
		glMaterialfv(GL_FRONT, GL_DIFFUSE, currentMaterial.diffuse);
		glMaterialfv(GL_FRONT, GL_SPECULAR, currentMaterial.specular);
		glMaterialf(GL_FRONT, GL_SHININESS, currentMaterial.shininess);
		glMaterialfv(GL_FRONT, GL_EMISSION, currentMaterial.emission);
		
		switch (modelType) {
			case NH3DModelTypeObject:
				
				glActiveTexture(GL_TEXTURE0);
				glDisable(GL_TEXTURE_2D);
				
				if (useEnvironment) {
					glActiveTexture(GL_TEXTURE1);
					
					glBindTexture(GL_TEXTURE_2D, texture);
					
					glEnable(GL_TEXTURE_2D);
					glEnable(GL_TEXTURE_GEN_S);
					glEnable(GL_TEXTURE_GEN_T);
					
					glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
					glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_INTERPOLATE);
					glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, blendcol);
					
					glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
					glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
					glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				}
				
				glBegin(GL_TRIANGLES);
				
				for (i = 0; i < face_qty; i++) {
					glNormal3f(norms[faces[i].a].x,
							   norms[faces[i].a].y,
							   norms[faces[i].a].z);
					
					glVertex3f(verts[faces[i].a].x + modelShift.x,
							   verts[faces[i].a].y + modelShift.y,
							   verts[faces[i].a].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 1st vertex is over
					glNormal3f(norms[faces[i].b].x,
							   norms[faces[i].b].y,
							   norms[faces[i].b].z);
					
					glVertex3f(verts[faces[i].b].x + modelShift.x,
							   verts[faces[i].b].y + modelShift.y,
							   verts[faces[i].b].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 2nd vertex is over
					glNormal3f(norms[faces[i].c].x,
							   norms[faces[i].c].y,
							   norms[faces[i].c].z);
					
					glVertex3f(verts[faces[i].c].x + modelShift.x,
							   verts[faces[i].c].y + modelShift.y,
							   verts[faces[i].c].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 3rd vertex is over
					//--------------------------------------------------------------------------------------------- draw is over
				}
				glEnd();
				
				if (useEnvironment) {
					glDisable(GL_TEXTURE_GEN_S);
					glDisable(GL_TEXTURE_GEN_T);
					glDisable(GL_TEXTURE_2D);
				}
				
				glActiveTexture(GL_TEXTURE0);
				glEnable(GL_TEXTURE_2D);
				break;
				
			case NH3DModelTypeTexturedObject:
				glActiveTexture(GL_TEXTURE0);
				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D, [self texture]);
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				
				glBegin(GL_TRIANGLES);
				
				for (i = 0; i < face_qty; i++) {
					glNormal3f(norms[faces[i].a].x,
							   norms[faces[i].a].y,
							   norms[faces[i].a].z);
					
					glTexCoord2f(texcoords[faces[i].a].s,
								 texcoords[faces[i].a].t);
					
					glVertex3f(verts[faces[i].a].x + modelShift.x,
							   verts[faces[i].a].y + modelShift.y,
							   verts[faces[i].a].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 1st vertex is over
					glNormal3f(norms[faces[i].b].x,
							   norms[faces[i].b].y,
							   norms[faces[i].b].z);
					
					glTexCoord2f(texcoords[faces[i].b].s,
								 texcoords[faces[i].b].t);
					
					
					glVertex3f(verts[faces[i].b].x + modelShift.x,
							   verts[faces[i].b].y + modelShift.y,
							   verts[faces[i].b].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 2nd vertex is over
					glNormal3f(norms[faces[i].c].x,
							   norms[faces[i].c].y,
							   norms[faces[i].c].z);
					
					glTexCoord2f(texcoords[faces[i].c].s,
								 texcoords[faces[i].c].t);
					
					glVertex3f(verts[faces[i].c].x + modelShift.x,
							   verts[faces[i].c].y + modelShift.y,
							   verts[faces[i].c].z + modelShift.z);
					//--------------------------------------------------------------------------------------------- 3rd vertex is over
					//--------------------------------------------------------------------------------------------- draw is over
				}
				
				glEnd();
				break;
				
			case NH3DModelTypeEmitter:
				glDisable(GL_LIGHTING);
				glDisable(GL_TEXTURE_2D);
				
				glEnable(GL_BLEND);
				glBlendFunc(GL_SRC_ALPHA, GL_ONE);
				
				for (i = 0; i < MAX_PARTICLES; i++) {
					GLfloat colorArray[4] = {particles[i].r, particles[i].g, particles[i].b, particles[i].life};
					
					if (particles[i].active) {
						px = particles[i].x;
						py = particles[i].y;
						pz = particles[i].z;
						float pSize;
						
						switch (particleType) {
							case NH3DParticleTypePoints:
								glPointSize(((random() % 500 )*0.01) + particleSize);
								
								glBegin(GL_POINTS);
								glColor4fv(colorArray);
								glVertex3f(px + 0.02f, py + 0.02f, pz +0.02f);
								glVertex3f(px - 0.02f, py + 0.02f, pz -0.02f);
								glVertex3f(px + 0.02f, py - 0.02f, pz +0.02f);
								glVertex3f(px - 0.02f, py - 0.02f, pz -0.02f);
								glEnd();
								break;
								
							case NH3DParticleTypeLines:
								glLineWidth(((random() % 400)*0.01) + particleSize);
								
								glBegin(GL_LINE_STRIP);
								glColor4fv(colorArray);
								glVertex3f(px + 0.02f, py, pz); glVertex3f(px - 0.02f, py + 0.1f, pz + 0.01f);
								glVertex3f(px - 0.02f, py, pz); glVertex3f(px + 0.02f, py - 0.1f, pz - 0.01f);
								glEnd();
								break;
								
							case NH3DParticleTypeBoth:
								glPointSize(((random() % 500)*0.01) + particleSize);
								
								glBegin(GL_POINTS);
								glColor4fv(colorArray);
								glVertex3f(px + 0.02f, py + 0.02f, pz +0.02f);
								glVertex3f(px - 0.02f, py + 0.02f, pz -0.02f);
								glVertex3f(px + 0.02f, py - 0.02f, pz +0.02f);
								glVertex3f(px - 0.02f, py - 0.02f, pz -0.02f);
								glEnd();
								
								glLineWidth((random() % 4) + particleSize);
								
								glBegin(GL_LINE_STRIP);
								
								glColor4fv(colorArray);
								glVertex3f(px + 0.02f, py, pz); glVertex3f(px - 0.02f, py + 0.1f, pz + 0.01f);
								glVertex3f(px , py , pz); glVertex3f(px - 0.02f, py - 0.1f, pz - 0.01f);
								glEnd();
								break;
								
							case NH3DParticleTypeAura:
								glLineWidth(((random() % 200)*0.01) + particleSize);
								
								glBegin(GL_LINE_STRIP);
								
								glColor4fv(colorArray);
								
								glVertex3f(px + 0.3975f , py + 0.2f , pz + 2.0f   );	glVertex3f(px + 1.11333f, py		 , pz + 1.6963f);
								glVertex3f(px + 1.11333f, py		 , pz + 1.6963f);	glVertex3f(px + 1.6958f , py + 0.1f , pz + 1.1338f);
								glVertex3f(px + 1.6958f , py + 0.1f , pz + 1.1338f);	glVertex3f(px + 2.0f	 , py		 , pz + 0.3984f);
								glVertex3f(px + 2.0f	 , py		 , pz + 0.3984f);	glVertex3f(px + 2.0f	 , py + 0.2f , pz - 0.3984f);
								glVertex3f(px + 2.0f	 , py + 0.2f , pz - 0.3984f);	glVertex3f(px + 1.6958f , py		 , pz - 1.1338f);
								glVertex3f(px + 1.6958f , py		 , pz - 1.1338f);	glVertex3f(px + 1.1333f , py + 0.1f , pz - 1.6953f);
								glVertex3f(px + 1.1333f , py + 0.1f , pz - 1.6953f);	glVertex3f(px + 0.3975f , py		 , pz - 2.0f);
								glVertex3f(px + 0.3975f , py		 , pz - 2.0f   );	glVertex3f(px - 0.3975f , py + 0.2f , pz - 2.0f);
								glVertex3f(px - 0.3975f , py + 0.2f , pz - 2.0f   );	glVertex3f(px - 1.1323f , py		 , pz - 1.6953f);
								glVertex3f(px - 1.1323f , py		 , pz - 1.6953f);	glVertex3f(px - 1.6958f , py + 0.1f , pz - 1.1338f);
								glVertex3f(px - 1.6958f , py + 0.1f , pz - 1.1338f);	glVertex3f(px - 2.0f    , py		 , pz - 0.3984f);
								glVertex3f(px - 2.0f    , py		 , pz  -0.3984f);	glVertex3f(px - 2.0f    , py + 0.2f , pz + 0.3984f);
								glVertex3f(px - 2.0f    , py + 0.2f , pz + 0.3984f);	glVertex3f(px - 1.6958f , py		 , pz + 1.1338f);
								glVertex3f(px - 1.6958f , py		 , pz + 1.1338f);	glVertex3f(px - 1.1323f , py + 0.1f , pz + 1.6963f);
								glVertex3f(px - 1.1323f , py + 0.1f , pz + 1.6963f);	glVertex3f(px - 0.3975f , py		 , pz + 2.0f);
								glVertex3f(px - 0.3975f , py		 , pz + 2.0f   );	glVertex3f(px + 0.3975f , py + 0.2f , pz + 2.0f);
								glEnd();
								break;
								
							default:
								pSize = ((random() % 5) + particleSize) * 0.01;
								glBegin(GL_QUADS);
								glColor4fv(colorArray);
								glVertex3f(px + pSize, py + pSize, pz);
								glVertex3f(px - pSize, py + pSize, pz);
								glVertex3f(px + pSize, py - pSize, pz);
								glVertex3f(px - pSize, py - pSize, pz);
								glEnd();
								break;
						}
						
						
						// Move on the axes by appropriate amount
						particles[i].x += particles[i].xi / (slowdown * 1000);
						particles[i].y += particles[i].yi / (slowdown * 1000);
						particles[i].z += particles[i].zi / (slowdown * 1000);
						// Take gravity into account
						particles[i].xi += particles[i].xg;
						particles[i].yi += particles[i].yg;
						particles[i].zi += particles[i].zg;
						// Reduce particle's life by 'fade'
						particles[i].life -= particles[i].fade;
						
						if (particles[i].life < 0.0f) {
							particles[i].life = particleLife;
							
							particles[i].fade = (float) (rand() % 100) / 1000.0f +
							0.003f;
							particles[i].x = 0.0f;   // Center on X axis
							particles[i].y = 0.0f;   // Center on Y axis
							particles[i].z = 0.0f;   // Center on Z axis
							// X axis speed and direction
							particles[i].xi = xspeed + (float) (random() % 60) - 32.0f;
							particles[i].yi = yspeed + (float) (random() % 60) - 30.0f;
							particles[i].zi = (float) (random() % 60) - 30.0f;
							
							particles[i].r = colors[particleColor][0];
							particles[i].g = colors[particleColor][1];
							particles[i].b = colors[particleColor][2];
						}
						
					}
				}
				
				glEnable(GL_LIGHTING);
				glEnable(GL_TEXTURE_2D);
				
				break;
		}
		
		if (!isChild) {
			glPopMatrix();
		}
		
		// Draw children
		if (self.hasChildren) {
			for (NH3DModelObject *childObject in childObjects) {
				[childObject drawSelf];
			}
		}
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Model \"%@\" (\"%@\"), vertices %i, model type %li, children: %@", modelName, modelCode, verts_qty, (long)modelType, self.hasChildren ? @([self countOfChildObjects]) : @"NO"];
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@"Model \"%@\" (File name \"%@\"), vertices %i, model type %li, children: {\n%@\n}", modelName, modelCode, verts_qty, (long)modelType, childObjects];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return [childObjects countByEnumeratingWithState:state objects:buffer count:len];
}

@end
