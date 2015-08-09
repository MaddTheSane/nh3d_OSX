//
//  TileCache.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/8/15.
//
//

import Cocoa

class TileCache: NSObject {
	private let bitMap: NSBitmapImageRep!
	
	let tileSize_X: Int
	let tileSize_Y: Int

	override init() {
		
	}
	
	init?(named imageName: String) {
		var tileSource1 = NSImage(contentsOfFile: (NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent(imageName))
		
		if tileSource1 == nil {
			tileSource1 = NSImage(contentsOfFile: imageName)
		}
		
		guard let tileSource = tileSource1 else {
			let alert = NSAlert()
			alert.messageText = "Tile Load Error!"
			alert.informativeText = "Can't find Tilefile: \(imageName)!!"
			
			alert.runModal()
			
			tileSize_X = 0
			tileSize_Y = 0
			bitMap = nil
			super.init()
			return nil
		}
		
		guard let tiffData = tileSource.TIFFRepresentation else {
			
			tileSize_X = 0
			tileSize_Y = 0
			bitMap = nil
			super.init()
			return nil
		}
		guard let bitmap = NSBitmapImageRep(data: tiffData) else {
			tileSize_X = 0
			tileSize_Y = 0
			bitMap = nil
			super.init()
			return nil
		}
		
		if  (bitmap.pixelsWide % TILES_PER_LINE) != 0 && (bitmap.pixelsHigh % NUMBER_OF_TILES_ROW) != 0 {
			let alert = NSAlert()
			alert.messageText = "Tile Format Error!"
			alert.informativeText = "\(imageName): Does not support this TILE Pattern."
			
			alert.runModal()

			
			tileSize_X = 0
			tileSize_Y = 0
			bitMap = nil
			super.init()
			return nil
		} else {
			bitMap = bitmap
			tileSize_X = bitmap.pixelsWide / TILES_PER_LINE;
			tileSize_Y = bitmap.pixelsHigh / NUMBER_OF_TILES_ROW;

		}
		
		/*
{

NSImage	*tileSource = [ [NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent: imageName]];
NSData  *tiffData;

if ( tileSource == nil ) {
tileSource = [ [NSImage alloc] initWithContentsOfFile:imageName ];
if ( tileSource == nil ) {
NSRunCriticalAlertPanel(@"Tile Load Error!",
@"Can't find Tilefile: %@!!",
@"OK",nil,nil, imageName);
NSLog(@"Can't find Tilefile: %@!!",imageName);
return nil;
}

}

tiffData = tileSource.TIFFRepresentation ;
bitMap = [[NSBitmapImageRep alloc] initWithData: tiffData];

//[ tiffData release ];

if ( ( bitMap.pixelsWide % TILES_PER_LINE) && ( bitMap.pixelsHigh % NUMBER_OF_TILES_ROW) ) {
NSRunCriticalAlertPanel(@"Tile Format Error!",
@"%@: Does not support this TILE Pattern.",
@"OK",nil,nil, imageName);
NSLog( @"%@: Does not support this TILE Pattern.",imageName );
return nil;
} else {
tileSize_X = bitMap.pixelsWide / TILES_PER_LINE;
tileSize_Y = bitMap.pixelsHigh / NUMBER_OF_TILES_ROW;
}

}*/

		super.init()

	}
}
