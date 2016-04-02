//
//  GLHelpers.swift
//  NetHack3D
//
//  Created by C.W. Betts on 12/15/15.
//  Copyright © 2015 Haruumi Yoshino. All rights reserved.
//

import Foundation
import OpenGL.GL

/// Helper function that takes `NH3DMaterialType` and converts it
/// to something usable by for `glMaterialfv`.
func glMaterialfv(face: GLenum, _ pname: GLenum, _ params1: NH3DMaterialType) {
	var params = params1
	let passedArr = withUnsafePointer(&params) { (aParam) -> UnsafePointer<GLfloat> in
		return UnsafePointer<GLfloat>(aParam)
	}
	glMaterialfv(face, pname, passedArr)
}
