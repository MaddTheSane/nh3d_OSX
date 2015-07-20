// NH3Dcommon.h

#import "config.h"


#ifdef GNUSTEP
# import "compat/Cocoa-compat.h"
# import <GL/gl.h>
# import <GL/glext.h>
# import <GL/glu.h>
#else
# import <Cocoa/Cocoa.h>
# import <OpenGL/gl.h>
# import <OpenGL/glext.h>
# import <OpenGL/glu.h>
# import <OpenGL/OpenGL.h>
#endif
