//
//  GLHelpers.swift
//  NetHack3D
//
//  Created by C.W. Betts on 12/15/15.
//  Copyright © 2015 Haruumi Yoshino. All rights reserved.
//

import Foundation
import OpenGL.GL

func glMaterialfv(face: GLenum, _ pname: GLenum, _ params: (GLfloat, GLfloat, GLfloat, GLfloat)) {
	let passedArr: [GLfloat] = [params.0, params.1, params.2, params.3]
	glMaterialfv(face, pname, passedArr)
}

extension NH3DMaterial: Equatable {

}

extension nh3d_point3: Equatable {
	
}

extension nh3d_face3: Equatable {
	
}

extension NH3DMapCoordType: Equatable {
	
}

public func ==(lhs: NH3DMapCoordType, rhs: NH3DMapCoordType) -> Bool {
	if lhs.s != rhs.s {
		return false
	} else if lhs.t != rhs.t {
		return false
	}
	
	return true
}

public func ==(lhs: nh3d_point3, rhs: nh3d_point3) -> Bool {
	if lhs.x != rhs.x {
		return false
	} else if lhs.y != rhs.y {
		return false
	} else if lhs.z != lhs.z {
		return false
	}
	return true
}

public func ==(lhs: nh3d_face3, rhs: nh3d_face3) -> Bool {
	if lhs.a != rhs.a {
		return false
	} else if lhs.b != rhs.b {
		return false
	} else if lhs.c != lhs.c {
		return false
	}
	return true
}

private func ==(lhs: NH3DMaterialType, rhs: NH3DMaterialType) -> Bool {
	if lhs.0 != rhs.0 {
		return false
	} else if lhs.1 != rhs.1 {
		return false
	} else if lhs.2 != rhs.2 {
		return false
	} else if lhs.3 != rhs.3 {
		return false
	}
	
	return true
}

private func !=(lhs: NH3DMaterialType, rhs: NH3DMaterialType) -> Bool {
	return !(lhs == rhs)
}

public func ==(lhs: NH3DMaterial, rhs: NH3DMaterial) -> Bool {
	if lhs.ambient != rhs.ambient {
		return false
	} else if lhs.ambient != rhs.ambient {
		return false
	} else if lhs.diffuse != rhs.diffuse {
		return false
	} else if lhs.specular != rhs.specular {
		return false
	} else if lhs.emission != rhs.emission {
		return false
	} else if lhs.shininess != rhs.shininess {
		return false
	}

	return true
}
