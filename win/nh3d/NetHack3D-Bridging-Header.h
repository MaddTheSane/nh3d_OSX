//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "NH3Dcommon.h"

#import "NH3DUserDefaultsExtern.h"
#import "NH3DMapItem.h"
#import "NH3DMapView.h"
#import "NH3DOpenGLView.h"

static inline BOOL Swift_Invis() {
	return ((HInvis || EInvis || \
			 pm_invisible(youmonst.data)) && !BInvis);
}
