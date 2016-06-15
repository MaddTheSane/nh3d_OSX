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


final class TileSet: NSObject {
	static var instance: TileSet?
	let image: NSImage
	let tileSize: NSSize
	private let rows: Int
	private let columns: Int
	private var cache: [Int16: NSImage] = [:]

	init(image img: NSImage, tileSize ts: NSSize) {
		let rect = NSRect(origin: .zero, size: img.size)
		image = NSImage(size: rect.size)
		image.lockFocus()
		img.draw(in: rect, from: rect, operation: .copy, fraction: 1.0)
		image.unlockFocus()
		
		tileSize = ts
		rows = Int(image.size.height / tileSize.height)
		columns = Int(image.size.width / tileSize.width)

		super.init()
	}
	
	convenience init?(name named: String) {
		let defaults = UserDefaults.standard()
		guard let img = NSImage(named: named) else {
			self.init(imageAtLocation: named)
			return
		}
		
		let size = NSSize(width: CGFloat(defaults.double(forKey: NH3DTileSizeWidthKey)),
		                  height: CGFloat(defaults.double(forKey: NH3DTileSizeHeightKey)))
		self.init(image: img, tileSize: size)
	}
	
	convenience init?(imageAtLocation loc: String, tileSize size1: NSSize = .zero) {
		var size = size1
		guard let img = NSImage(contentsOfFile: loc) else {
			return nil
		}
		
		if size == .zero {
			if let nameSize = sizeFrom(fileName: (loc as NSString).lastPathComponent) {
				size = NSSize(width: Int(nameSize.width), height: Int(nameSize.height))
			} else {
				size.width = img.size.width / CGFloat(TILES_PER_LINE)
				size.height = img.size.height / CGFloat(NUMBER_OF_TILES_ROW)
			}
		}
		
		self.init(image: img, tileSize: size)
	}
	
	func sourceRect(for glyph: Int32) -> NSRect {
		let tile = glyphToTile(glyph)
		return sourceRect(for: tile)
	}
	
	private func sourceRect(for tile: Int16) -> NSRect {
		let row = rows - 1 - Int(tile) / columns;
		let col = Int(tile) % columns;

		var r = NSRect()
		r.origin = CGPoint(x: CGFloat(col) * tileSize.width, y: CGFloat(row) * tileSize.height)
		r.size = tileSize
		return r
	}
	
	var imageSize: NSSize {
		var size = tileSize
		if size.width > 32.0 || size.height > 32.0 {
			// since these images are used in menus we want to scale them down
			var m = size.width > size.height ? size.width : size.height;
			m = 32.0 / m;
			size.width  *= m;
			size.height *= m;
		}
		
		return size
	}
	
	@objc(imageForGlyph:) func imageFor(_ glyph: Int32) -> NSImage {
		let tile = glyphToTile(glyph)
		// Check for cached image:
		if let img = cache[tile] {
			return img
		}
		// get image
		let srcRect = sourceRect(for: glyph)
		let newImage = NSImage(size: tileSize)
		let dstRect = NSRect(origin: .zero, size: tileSize)
		newImage.lockFocus()
		self.image.draw(in: dstRect, from: srcRect, operation: .copy, fraction: 1)
		newImage.unlockFocus()
		// cache image
		cache[tile] = newImage
		return newImage
	}
	
	//@available(OSX, introduced=10.9, deprecated=10.11, message="Use -imageForGlyph: instead")
	func tileImageFromGlyph(_ glyph: Int32) -> NSImage? {
		let tile = glyphToTile(glyph)
		if (Int32(tile) >= total_tiles_used || tile < 0) {
			NSLog("ERROR: Asked for tile \(tile) outside the allowed range.");
			return nil;
		}
		return imageFor(glyph)
	}
}
