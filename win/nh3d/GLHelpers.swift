//
//  GLHelpers.swift
//  NetHack3D
//
//  Created by C.W. Betts on 12/15/15.
//  Copyright © 2015 Haruumi Yoshino. All rights reserved.
//

import Foundation
import OpenGL

func glMaterialfv(face: GLenum, _ pname: GLenum, _ params: (GLfloat, GLfloat, GLfloat, GLfloat)) {
	let passedArr: [GLfloat] = [params.0, params.1, params.2, params.3]
	glMaterialfv(face, pname, passedArr)
}
