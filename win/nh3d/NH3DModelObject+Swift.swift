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
		var l_Connect = [Int32](count: Int(verts_qty), repeatedValue: 0)
		
		for i in 0..<Int(verts_qty) {
			norms[i].x = 0.0
			norms[i].y = 0.0
			norms[i].z = 0.0
		}
		
		//faces
		let theFaces = UnsafeMutableBufferPointer(start: faces, count: Int(face_qty))
		
		for face in theFaces {
			let l_vect1 = verts[Int(face.a)]
			let l_vect2 = verts[Int(face.b)]
			let l_vect3 = verts[Int(face.c)]
			
			// Polygon normal calculation
			
			let l_vect_b1 = NH3DVertexType(start: l_vect1, endingAt: l_vect2)
			let l_vect_b2 = NH3DVertexType(start: l_vect1, endingAt: l_vect3)
			let l_normal = dotProduct(l_vect_b1, l_vect_b2).normalize
			
			l_Connect[Int(face.a)] += 1
			l_Connect[Int(face.b)] += 1
			l_Connect[Int(face.c)] += 1
			
			norms[Int(face.a)] += l_normal
			norms[Int(face.b)] += l_normal
			norms[Int(face.c)] += l_normal
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

extension NH3DVertexType : Equatable {
	var vectorLength: Float {
		return sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
	}
	
	mutating func normalizeInPlace() {
		var l_length: Float
		
		l_length = self.vectorLength
		if l_length == 0 {
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

func +(lhs: NH3DVertexType, rhs: NH3DVertexType) -> NH3DVertexType {
	var toRet = NH3DVertexType()
	toRet.x = lhs.x + rhs.x
	toRet.y = lhs.y + rhs.y
	toRet.z = lhs.z + rhs.z
	return toRet
}

func +=(inout lhs: NH3DVertexType, rhs: NH3DVertexType) {
	lhs.x += rhs.x
	lhs.y += rhs.y
	lhs.z += rhs.z
}

private func dotProduct(p_vector1: NH3DVertexType, _ p_vector2: NH3DVertexType) -> NH3DVertexType {
	var p_normal = NH3DVertexType()
	p_normal.x = (p_vector1.y * p_vector2.z) - (p_vector1.z * p_vector2.y)
	p_normal.y = (p_vector1.z * p_vector2.x) - (p_vector1.x * p_vector2.z)
	p_normal.z = (p_vector1.x * p_vector2.y) - (p_vector1.y * p_vector2.x)

	return p_normal
}

extension NH3DMaterial: Equatable {
	
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
