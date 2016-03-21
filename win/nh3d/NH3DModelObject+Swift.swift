//
//  NH3dModelObject+Swift.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/7/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Foundation
import simd

extension NH3DModelObject {
	func calculateNormals() {
		var l_Connect = [Int32](count: Int(verts_qty), repeatedValue: 0)
		
		let zeroVert = vector_float3(x: 0, y: 0, z: 0)
		
		for i in 0..<Int(verts_qty) {
			norms[i] = zeroVert
		}
		
		//faces
		let theFaces = UnsafeMutableBufferPointer(start: faces, count: Int(face_qty))
		
		for face in theFaces {
			let l_vect1 = verts[Int(face.a)]
			let l_vect2 = verts[Int(face.b)]
			let l_vect3 = verts[Int(face.c)]
			
			// Polygon normal calculation
			let l_vect_b1 = vector_float3(start: l_vect1, endingAt: l_vect2)
			let l_vect_b2 = vector_float3(start: l_vect1, endingAt: l_vect3)
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
				norms[i] /= float3(connFloat)
			}
		}
	}
}

extension vector_float3 : Equatable {
	mutating func normalizeInPlace() {
		var l_length: Float
		
		l_length = length(self)
		if l_length == 0 {
			l_length = 1
		}
		self /= float3(l_length)
	}
	
	var normalize: vector_float3 {
		var ourself = self
		ourself.normalizeInPlace()
		return ourself
	}
	
	init(start p_start: vector_float3, endingAt p_end : vector_float3) {
		self = p_end - p_start
		normalizeInPlace()
	}
}

private func dotProduct(p_vector1: vector_float3, _ p_vector2: vector_float3) -> vector_float3 {
	let x = (p_vector1.y * p_vector2.z) - (p_vector1.z * p_vector2.y)
	let y = (p_vector1.z * p_vector2.x) - (p_vector1.x * p_vector2.z)
	let z = (p_vector1.x * p_vector2.y) - (p_vector1.y * p_vector2.x)
	let p_normal = vector_float3(x: x, y: y, z: z)

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

public func ==(lhs: vector_float3, rhs: vector_float3) -> Bool {
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
