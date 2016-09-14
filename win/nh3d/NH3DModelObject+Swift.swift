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
	/// Calculate the normals of the 3D model.
	func calculateNormals() {
		var l_Connect = [Int32](repeating: 0, count: verts_qty)
		
		memset(norms, 0, normal_qty * sizeof(float3))
		
		//faces
		let theFaces = UnsafeBufferPointer(start: faces, count: face_qty)
		let theVerts = UnsafeBufferPointer(start: verts, count: verts_qty)
		let theNorms = UnsafeMutableBufferPointer(start: norms, count: normal_qty)

		for face in theFaces {
			let l_vect1 = theVerts[Int(face.a)]
			let l_vect2 = theVerts[Int(face.b)]
			let l_vect3 = theVerts[Int(face.c)]
			
			// Polygon normal calculation
			let l_vect_b1 = float3(start: l_vect1, end: l_vect2)
			let l_vect_b2 = float3(start: l_vect1, end: l_vect3)
			let l_normal = normalize(cross(l_vect_b1, l_vect_b2))
			
			l_Connect[Int(face.a)] += 1
			l_Connect[Int(face.b)] += 1
			l_Connect[Int(face.c)] += 1
			
			theNorms[Int(face.a)] += l_normal
			theNorms[Int(face.b)] += l_normal
			theNorms[Int(face.c)] += l_normal
		}
		
		for (i, connect) in l_Connect.enumerated() {
			if connect > 0 {
				let connFloat = Float(connect)
				theNorms[i] /= float3(connFloat)
			}
		}
	}
	
	var particleSpeed: (x: GLfloat, y: GLfloat) {
		get {
			return (particleSpeedX, particleSpeedY)
		}
		set(nv) {
			setParticleSpeed(x: nv.x, y: nv.y)
		}
	}
}

extension float3 {
	private init(start p_start: float3, end p_end : float3) {
		let pre = p_end - p_start
		self = normalize(pre)
	}
}

extension NH3DMaterial: Equatable {
	
}

extension nh3d_face3: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return "a: \(a), b: \(b), c: \(c)"
	}
	
	public var debugDescription: String {
		return "Face a: \(a), b: \(b), c: \(c)"
	}
}

extension NH3DMapCoordType: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return "s: \(s), t: \(t)"
	}
	
	public var debugDescription: String {
		return "Coord s: \(s), t: \(t)"
	}
}

extension NH3DVertexType: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return "x: \(x), y: \(y), z: \(z)"
	}
	
	public var debugDescription: String {
		return "Vertex x: \(x), y: \(y), z: \(z)"
	}
}

public func ==(lhs: NH3DMapCoordType, rhs: NH3DMapCoordType) -> Bool {
	if lhs.s != rhs.s {
		return false
	} else if lhs.t != rhs.t {
		return false
	}
	
	return true
}

public func ==(lhs: NH3DVertexType, rhs: NH3DVertexType) -> Bool {
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

public func ==(lhs: NH3DMaterial, rhs: NH3DMaterial) -> Bool {
	if lhs.ambient != rhs.ambient {
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
