//
//  NH3dModelObject+Swift.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/7/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Foundation

extension NH3DModelObject {
	func calculateNormals() {
		var l_vect1 = NH3DVertexType(), l_vect2 = NH3DVertexType(), l_vect3 = NH3DVertexType(), l_vect_b1 = NH3DVertexType(), l_vect_b2 = NH3DVertexType(), l_normal = NH3DVertexType();
		var l_Connect = [Int32](count: Int(verts_qty), repeatedValue: 0)
		
		for i in 0..<Int(verts_qty) {
			norms[i].x = 0.0
			norms[i].y = 0.0
			norms[i].z = 0.0
		}
		
		//faces
		let theFaces = UnsafeMutableBufferPointer(start: faces, count: Int(face_qty))
		
		for face in theFaces {
			l_vect1.x = verts[Int(face.a)].x
			l_vect1.y = verts[Int(face.a)].y
			l_vect1.z = verts[Int(face.a)].z
			l_vect2.x = verts[Int(face.b)].x
			l_vect2.y = verts[Int(face.b)].y
			l_vect2.z = verts[Int(face.b)].z
			l_vect3.x = verts[Int(face.c)].x
			l_vect3.y = verts[Int(face.c)].y
			l_vect3.z = verts[Int(face.c)].z
			
			// Polygon normal calculation
			
			l_vect_b1 = NH3DVertexType(start: l_vect1, endingAt: l_vect2)
			l_vect_b2 = NH3DVertexType(start: l_vect1, endingAt: l_vect3)
			l_normal = dotProduct(l_vect_b1, l_vect_b2).normalize
			
			l_Connect[Int(face.a)] += 1
			l_Connect[Int(face.b)] += 1
			l_Connect[Int(face.c)] += 1
			
			norms[Int(face.a)].x += l_normal.x
			norms[Int(face.a)].y += l_normal.y
			norms[Int(face.a)].z += l_normal.z
			norms[Int(face.b)].x += l_normal.x
			norms[Int(face.b)].y += l_normal.y
			norms[Int(face.b)].z += l_normal.z
			norms[Int(face.c)].x += l_normal.x
			norms[Int(face.c)].y += l_normal.y
			norms[Int(face.c)].z += l_normal.z
		}
		
		for (i, connect) in l_Connect.enumerate() {
			if connect > 0 {
				let connFloat = Float(connect)
				norms[i].x /= connFloat
				norms[i].y /= connFloat
				norms[i].z /= connFloat
			}
		}
	}
}

extension NH3DVertexType {
	var vectorLength: Float {
		return sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
	}
	
	mutating func normalizeInPlace() {
		var l_length: Float
		
		l_length = self.vectorLength
		if (l_length==0) {
			l_length=1
		}
		self.x /= l_length
		self.y /= l_length
		self.z /= l_length
	}
	
	var normalize: NH3DVertexType {
		var ourself = self
		ourself.normalizeInPlace()
		return ourself
	}
	
	var vectScalar: Float {
		return (self.x*self.x + self.y*self.y + self.z*self.z)
	}
	
	init(start p_start: NH3DVertexType, endingAt p_end : NH3DVertexType) {
		x = p_end.x - p_start.x
		y = p_end.y - p_start.y
		z = p_end.z - p_start.z
		normalizeInPlace()
	}
}

func dotProduct(p_vector1: NH3DVertexType, _ p_vector2: NH3DVertexType) -> NH3DVertexType {
	var p_normal = NH3DVertexType()
	p_normal.x = (p_vector1.y * p_vector2.z) - (p_vector1.z * p_vector2.y)
	p_normal.y = (p_vector1.z * p_vector2.x) - (p_vector1.x * p_vector2.z)
	p_normal.z = (p_vector1.x * p_vector2.y) - (p_vector1.y * p_vector2.x)

	return p_normal
}
