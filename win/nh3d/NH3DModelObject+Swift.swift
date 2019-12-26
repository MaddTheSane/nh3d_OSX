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
	/// Normals
	var normals: UnsafeMutableBufferPointer<SIMD3<Float>> {
		return UnsafeMutableBufferPointer(start: __norms, count: __normal_qty)
	}
	
	/// Vertex points
	var vertexes: UnsafeMutableBufferPointer<SIMD3<Float>> {
		return UnsafeMutableBufferPointer(start: __verts, count: __verts_qty)
	}
	
	/// Faces
	var faces: UnsafeMutableBufferPointer<NH3DFaceType> {
		return UnsafeMutableBufferPointer(start: __faces, count: __face_qty)
	}
	
	/// Texture coordinates
	var textureCoordinates: UnsafeMutableBufferPointer<NH3DMapCoordType> {
		return UnsafeMutableBufferPointer(start: __texcoords, count: __texcords_qty)
	}
	
	/// Calculate the normals of the 3D model.
	@objc func calculateNormals() {
		let theNorms = normals
		let theVerts = vertexes

		var l_Connect = [Int32](repeating: 0, count: theVerts.count)

		memset(theNorms.baseAddress!, 0, theNorms.count * MemoryLayout<SIMD3<Float>>.stride)
		
		for face in faces {
			let l_vect1 = theVerts[Int(face.a)]
			let l_vect2 = theVerts[Int(face.b)]
			let l_vect3 = theVerts[Int(face.c)]
			
			// Polygon normal calculation
			let l_vect_b1 = SIMD3<Float>(start: l_vect1, end: l_vect2)
			let l_vect_b2 = SIMD3<Float>(start: l_vect1, end: l_vect3)
			let l_normal = normalize(cross(l_vect_b1, l_vect_b2))
			
			l_Connect[Int(face.a)] += 1
			l_Connect[Int(face.b)] += 1
			l_Connect[Int(face.c)] += 1
			
			theNorms[Int(face.a)] += l_normal
			theNorms[Int(face.b)] += l_normal
			theNorms[Int(face.c)] += l_normal
		}
		
		for (i, connect) in l_Connect.enumerated() {
			// Dividing by 1 will result in the same number.
			if connect > 1 {
				let connFloat = Float(connect)
				theNorms[i] /= SIMD3<Float>(repeating: connFloat)
			}
		}
	}
	
	@inlinable
	var particleSpeed: (x: GLfloat, y: GLfloat) {
		get {
			return (__particleSpeedX, __particleSpeedY)
		}
		set(nv) {
			__setParticleSpeedX(nv.x, y: nv.y)
		}
	}
}

extension SIMD3 where Scalar==Float {
	fileprivate init(start p_start: SIMD3<Scalar>, end p_end : SIMD3<Scalar>) {
		let pre = p_end - p_start
		self = normalize(pre)
	}
}

extension NH3DMaterial: Equatable, CustomStringConvertible {
	public var description: String {
		return "ambient: \(ambient), diffuse: \(diffuse), specular: \(specular), emission: \(emission), shininess: \(shininess)"
	}
	
	public static func ==(lhs: NH3DMaterial, rhs: NH3DMaterial) -> Bool {
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
}

extension nh3d_face3: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return "a: \(a), b: \(b), c: \(c)"
	}
	
	public var debugDescription: String {
		return "Face a: \(a), b: \(b), c: \(c)"
	}
	
	public static func ==(lhs: nh3d_face3, rhs: nh3d_face3) -> Bool {
		if lhs.a != rhs.a {
			return false
		} else if lhs.b != rhs.b {
			return false
		} else if lhs.c != lhs.c {
			return false
		}
		return true
	}
}

extension NH3DMapCoordType: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return "s: \(s), t: \(t)"
	}
	
	public var debugDescription: String {
		return "Coord s: \(s), t: \(t)"
	}
	
	public static func ==(lhs: NH3DMapCoordType, rhs: NH3DMapCoordType) -> Bool {
		if lhs.s != rhs.s {
			return false
		} else if lhs.t != rhs.t {
			return false
		}
		
		return true
	}
}

extension NH3DVertexType: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return "x: \(x), y: \(y), z: \(z)"
	}
	
	public var debugDescription: String {
		return "Vertex x: \(x), y: \(y), z: \(z)"
	}
	
	public static func ==(lhs: NH3DVertexType, rhs: NH3DVertexType) -> Bool {
		if lhs.x != rhs.x {
			return false
		} else if lhs.y != rhs.y {
			return false
		} else if lhs.z != lhs.z {
			return false
		}
		return true
	}
}
