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


extension TileSet {
	convenience init?(name named: String) {
		let defaults = NSUserDefaults.standardUserDefaults()
		guard let img = NSImage(named: named) else {
			self.init(imageAtLocation: named)
			return
		}
		
		let size = NSSize(width: CGFloat(defaults.doubleForKey(NH3DTileSizeWidthKey)),
		                  height: CGFloat(defaults.doubleForKey(NH3DTileSizeHeightKey)))
		self.init(image: img, tileSize: size)
	}
	
	convenience init?(imageAtLocation loc: String, tileSize size1: NSSize = .zero) {
		var size = size1
		guard let img = NSImage(contentsOfFile: loc) else {
			return nil
		}
		
		if size == .zero {
			if let nameSize = sizeFromFileName((loc as NSString).lastPathComponent) {
				size = NSSize(width: Int(nameSize.width), height: Int(nameSize.height))
			} else {
				size.width = img.size.width / CGFloat(TILES_PER_LINE)
				size.height = img.size.height / CGFloat(NUMBER_OF_TILES_ROW)
			}
		}
		
		self.init(image: img, tileSize: size)
	}
	
	//@available(OSX, introduced=10.9, deprecated=10.11, message="Use -imageForGlyph: instead")
	func tileImageFromGlyph(glyph: Int32) -> NSImage? {
		let tile = glyphToTile(glyph)
		if (Int32(tile) >= total_tiles_used || tile < 0) {
			NSLog("ERROR: Asked for tile \(tile) outside the allowed range.");
			return nil;
		}
		return imageForGlyph(glyph)
	}
}
