//
//  TileSet.swift
//  NetHackCocoa
//
//  Created by C.W. Betts on 8/9/15.
//
//

//  This file is part of NetHackCocoa.
//
//  iNetHack is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 2 of the License only.
//
//  iNetHack is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with iNetHack.  If not, see <http://www.gnu.org/licenses/>.

import Cocoa
import CoreGraphics

final class TileSet: NSObject {
	@objc static var instance: TileSet?
	let image: NSImage
	@objc let tileSize: NSSize
	private let rows: Int
	private let columns: Int
	private var cache: [Int16: NSImage] = [:]
	
	@objc init(image img: NSImage, tileSize ts: NSSize) {
		image = img.copy() as! NSImage
		
		tileSize = ts
		rows = Int(image.size.height / tileSize.height)
		columns = Int(image.size.width / tileSize.width)
		
		super.init()
	}
	
	@objc convenience init?(name named: String) {
		guard let img = NSImage(named: named) else {
			self.init(imageAtLocation: named)
			return
		}
		
		let defaults = UserDefaults.standard
		
		let size = NSSize(width: defaults.double(forKey: NH3DTileSizeWidthKey),
		                  height: defaults.double(forKey: NH3DTileSizeHeightKey))
		self.init(image: img, tileSize: size)
	}
	
	@objc(initWithImageAtURL:tileSize:)
	convenience init?(imageAt loc: URL, tileSize size1: NSSize = .zero) {
		var size = size1
		guard let img = NSImage(contentsOf: loc) else {
			return nil
		}
		
		do {
			//Attempt to find (and use) Retina @2x images
			//TODO: check if hi-res, multi-page images work.
			let x2Loc: URL = {
				let ext = loc.pathExtension
				let parentPath = loc.deletingLastPathComponent()
				var lastPath = loc.deletingPathExtension().lastPathComponent
				lastPath += "@2x"
				lastPath = (lastPath as NSString).appendingPathExtension(ext) ?? "\(lastPath).\(ext)"
				var toRet = parentPath
				toRet.appendPathComponent(lastPath)
				
				return toRet
			}()
			if img.representations.count == 1,
				!(img.representations[0] is NSPDFImageRep),
				let img2 = NSImage(contentsOf: x2Loc),
				let rep = img2.representations[0].copy() as? NSImageRep {
				rep.size = img.size
				img.addRepresentation(rep)
			}
		}
		
		if size == .zero {
			if let nameSize = sizeFrom(fileName: loc.lastPathComponent) {
				size = NSSize(width: Int(nameSize.width), height: Int(nameSize.height))
			} else {
				size.width = img.size.width / CGFloat(TILES_PER_LINE)
				size.height = img.size.height / CGFloat(NUMBER_OF_TILES_ROW)
			}
		}
		
		self.init(image: img, tileSize: size)
	}
	
	@objc convenience init?(imageAtLocation loc: String, tileSize size: NSSize = .zero) {
		self.init(imageAt: URL(fileURLWithPath: loc), tileSize: size)
	}
	
	private func sourceRect(for glyph: Int32) -> NSRect {
		let tile = glyphToTile(glyph)
		return sourceRect(for: tile)
	}
	
	private func sourceRect(for tile: Int16) -> NSRect {
		let row = rows - 1 - Int(tile) / columns
		let col = Int(tile) % columns
		
		let r = NSRect(origin: CGPoint(x: CGFloat(col) * tileSize.width, y: CGFloat(row) * tileSize.height), size: tileSize)
		return r
	}
	
	@objc private(set) lazy var imageSize: NSSize = {
		var size = tileSize
		if size.width > 16 || size.height > 16 {
			// since these images are used in menus we want to scale them down
			var m = max(size.width, size.height)
			m = 16 / m
			size.width  *= m
			size.height *= m
		}
		
		return size
	}()
	
	@objc(imageForGlyph:)
	func image(forGlyph glyph: Int32) -> NSImage {
		let tile = glyphToTile(glyph)
		// Check for cached image:
		if let img = cache[tile] {
			return img
		}
		// get image
		let srcRect = sourceRect(for: tile)
		let newImage = NSImage(size: tileSize)
		let dstRect = NSRect(origin: .zero, size: tileSize)
		if !(image.representations.first is NSPDFImageRep) {
			at1x: do { //@1x
				guard let imgBir1x = image.representations.first(where: { (imgRep) -> Bool in
					let bmpSize = NSSize(width: imgRep.pixelsWide, height: imgRep.pixelsHigh)
					return bmpSize == image.size
				}) else {
					break at1x
				}
				let clrSpace: CGColorSpace = {
					if let nsClrSpace: NSColorSpace = (imgBir1x as AnyObject).colorSpace,
						nsClrSpace.colorSpaceModel == .rgb,
						let cgClrSpace = nsClrSpace.cgColorSpace {
						return cgClrSpace
					}
					
					return CGColorSpace(name: CGColorSpace.sRGB)!
				}()
				guard let ctx1x = CGContext(data: nil, width: Int(tileSize.width), height: Int(tileSize.height), bitsPerComponent: 8, bytesPerRow: Int(tileSize.width) * 4, space: clrSpace, bitmapInfo: CGBitmapInfo.byteOrder32Host.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) else {
					break at1x
				}
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx1x, flipped: false)
				imgBir1x.draw(in: dstRect, from: srcRect, operation: .copy, fraction: 1, respectFlipped: true, hints: nil)
				NSGraphicsContext.restoreGraphicsState()
				guard let cgImage1x = ctx1x.makeImage() else {
					break at1x
				}
				let bir1x = NSBitmapImageRep(cgImage: cgImage1x)
				newImage.addRepresentation(bir1x)
			}
			at2x: do { //@2x
				guard let imgBir2x = image.representations.first(where: { (imgRep) -> Bool in
					let bmpSize = NSSize(width: imgRep.pixelsWide, height: imgRep.pixelsHigh)
					let at2xSize = NSSize(width: image.size.width * 2, height: image.size.height * 2)
					return bmpSize == at2xSize
				}) else {
					break at2x
				}
				let clrSpace: CGColorSpace = {
					if let nsClrSpace: NSColorSpace = (imgBir2x as AnyObject).colorSpace,
						nsClrSpace.colorSpaceModel == .rgb,
						let cgClrSpace = nsClrSpace.cgColorSpace {
						return cgClrSpace
					}
					
					return CGColorSpace(name: CGColorSpace.sRGB)!
				}()
				let dstRect2x: NSRect = {
					var toRet = dstRect
					toRet.size.width *= 2
					toRet.size.height *= 2
					return toRet
				}()

				guard let ctx2x = CGContext(data: nil, width: Int(dstRect2x.width), height: Int(dstRect2x.height), bitsPerComponent: 8, bytesPerRow: Int(dstRect2x.width) * 4, space: clrSpace, bitmapInfo: CGBitmapInfo.byteOrder32Host.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) else {
					break at2x
				}
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx2x, flipped: false)
				imgBir2x.draw(in: dstRect2x, from: srcRect, operation: .copy, fraction: 1, respectFlipped: true, hints: nil)
				NSGraphicsContext.restoreGraphicsState()
				guard let cgImage2x = ctx2x.makeImage() else {
					break at2x
				}
				let bir2x = NSBitmapImageRep(cgImage: cgImage2x)
				bir2x.size = tileSize
				newImage.addRepresentation(bir2x)
			}
		}
		// last resort
		if newImage.representations.count == 0 {
			newImage.lockFocus()
			// to prevent strange artifacts caused by pixel doubling
			NSGraphicsContext.current?.imageInterpolation = .none
			self.image.draw(in: dstRect, from: srcRect, operation: .copy, fraction: 1)
			newImage.unlockFocus()
		}
		// cache image
		cache[tile] = newImage
		return newImage
	}
}
