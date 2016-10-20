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
/// to something usable by OpenGL's `glMaterialfv`.
func glMaterialfv(_ face: GLenum, _ pname: GLenum, _ params1: NH3DMaterialType) {
	var params = params1
	withUnsafePointer(to: &params) { (aParam) -> Void in
		aParam.withMemoryRebound(to: GLfloat.self, capacity: 4, { (ptr2) -> Void in
			glMaterialfv(face, pname, ptr2)
		})
	}
}

/// Helper function that puts the data from an `NH3DMaterial` object
/// into the OpenGL stacks via `glMaterialfv`.
///
/// - parameter face: The face to apply the material to. Default is `GL_FRONT`
func glMaterial(face: GLenum = GLenum(GL_FRONT), _ material: NH3DMaterial) {
	glMaterialfv(face, GLenum(GL_AMBIENT), material.ambient)
	glMaterialfv(face, GLenum(GL_DIFFUSE), material.diffuse)
	glMaterialfv(face, GLenum(GL_SPECULAR), material.specular)
	glMaterialf(face, GLenum(GL_SHININESS), material.shininess)
	glMaterialfv(face, GLenum(GL_EMISSION), material.emission)
}
