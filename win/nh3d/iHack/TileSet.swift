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

	init(image img: NSImage, tileSize ts: NSSize) {
		let rect = NSRect(origin: .zero, size: img.size)
		image = NSImage(size: rect.size)
		image.lockFocus()
		img.drawInRect(rect, fromRect: rect, operation: .CompositeCopy, fraction: 1.0)
		image.unlockFocus()
		
		tileSize = ts
		rows = Int(image.size.height / tileSize.height)
		columns = Int(image.size.width / tileSize.width)

		super.init()
	}
	
	func sourceRectForGlyph(glyph: Int32) -> NSRect {
		let tile = glyphToTile(glyph)
		return sourceRectForTile(tile)
	}
	
	private func sourceRectForTile(tile: Int32) -> NSRect {
		let row = rows - 1 - Int(tile)/columns;
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
	
	func imageForGlyph(glyph: Int32, enabled: Bool = true) -> NSImage {
		// get image
		let srcRect = sourceRectForGlyph(glyph)
		let size = imageSize
		let newImage = NSImage(size: size)
		let dstRect = NSRect(origin: .zero, size: size)
		newImage.lockFocus()
		image.drawInRect(dstRect, fromRect: srcRect, operation: .CompositeCopy, fraction: enabled ? 1.0 : 0.5)
		newImage.unlockFocus()
		return newImage
	}
}
