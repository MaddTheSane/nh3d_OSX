//
//  NH3DPreferenceController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 1/1/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

/// Scans the file name to identify the width and height.
/// - returns: `nil` if the tile size could not be identified
func sizeFrom(fileName: String) -> (width: Int32, height: Int32)? {
	// FIXME: this is ugly!  Transition to Regex/NSScanner.
	var width: Int32 = 0
	var height: Int32 = 0
	
	let unsfePtr1 = withUnsafeMutablePointer(to: &width) {
		return $0
	}
	let unsfePtr2 = withUnsafeMutablePointer(to: &height) {
		return $0
	}
	
	var valist = getVaList([unsfePtr1, unsfePtr2])
	
	// First, try finding both width and height
	if vsscanf(fileName, "%*[^0-9]%dx%d.%*s", valist) == 2 {
		return (width, height)
	}
	
	// Regenerate the VaList
	valist = getVaList([unsfePtr1])
	// Next, try for a square size
	if vsscanf(fileName, "%*[^0-9]%d.%*s", valist) == 1 {
		return (width, width)
	}
	
	// We didn't get either
	return nil
}

/// Returns the amount of tiles per row and column.
///
/// Needed because NH3D uses a different way of handling tiles:
/// NH3D wants the number of rows and columns; other front-ends
/// specify the width and height of one tile.<br>
/// This assumes that there are no extra pixels, such as signatures.
private func tilesInfo(fromFile fileName: String) -> (tileSize: NSSize, rows: Int, columns: Int)? {
	guard let fileDimensions = sizeFrom(fileName: (fileName as NSString).lastPathComponent) else {
		return nil
	}
	
	// Get the image, to calculate the needed rows and columns
	var image = NSImage(named: fileName)
	
	if image == nil {
		image = NSImage(byReferencingFile: fileName)
	}
	guard let image1 = image else {
		// We didn't get the image :(
		return nil
	}
	let imgDimensions: NSSize
	if let firstRep = image1.representations.first as? NSBitmapImageRep {
		imgDimensions = NSSize(width: firstRep.pixelsWide, height: firstRep.pixelsHigh)
	} else {
		imgDimensions = image1.size
	}
	// divide the numbers, getting the remainder remainder
	let divWidth = imgDimensions.width / CGFloat(fileDimensions.width)
	let divHeight = imgDimensions.height / CGFloat(fileDimensions.height)
	
	// If there's any decimal points, it means the passed-in string size
	// doesn't match
	if round(divHeight) != divHeight || round(divWidth) != divWidth {
		// We failed
		return nil
	}
	
	let actualSize: NSSize = {
		var imgSize = image1.size
		imgSize.width /= divWidth
		imgSize.height /= divHeight
		return imgSize
	}()
	
	return (actualSize, Int(divWidth), Int(divHeight))
}

class NH3DPreferenceController : NSWindowController, NSWindowDelegate {
	private var bindController: NH3DBindController?
	private var fontButtonTag = 0

	convenience init() {
		self.init(windowNibName: "PreferencePanel")
	}
	
	func windowShouldClose(_ sender: Any) -> Bool {
		bindController?.endPreferencePanel()
		
		return true
	}
	
	func showPreferencePanel(_ sender: NH3DBindController) {
		bindController = sender
		window?.makeKeyAndOrderFront(self)
	}
	
	@IBAction override func changeFont(_ sender: Any?) {
		guard let sender = sender as? NSFontManager else {
			return
		}
		
		let font = NSFont.systemFont(ofSize: NSFont.systemFontSize())
		let convertedFont = sender.convert(font)
		
		let key: String
		let sizeKey: String
		
		// Get preferences keys
		switch fontButtonTag {
		case 1:
			key = NH3DMsgFontKey
			sizeKey = NH3DMsgFontSizeKey
			
		case 2:
			key = NH3DWindowFontKey
			sizeKey = NH3DWindowFontSizeKey
			
		case 3:
			key = NH3DMapFontKey
			sizeKey = NH3DMapFontSizeKey
			
		case 4:
			key = NH3DBoldFontKey
			sizeKey = NH3DBoldFontSizeKey
			
		case 5:
			key = NH3DInventryFontKey
			sizeKey = NH3DInventryFontSizeKey
			
		default:
			return
		}
		
		let defaults = UserDefaults.standard
		defaults.set(convertedFont.fontName, forKey: key)
		defaults.set(Float(convertedFont.pointSize), forKey: sizeKey)
	}
	
	@IBAction func showFontPanelAction(_ sender: NSMatrix?) {
		guard let sender = sender else {
			return
		}
		let defaults = UserDefaults.standard
		let key: String
		let sizeKey: String
		fontButtonTag = sender.selectedCell()?.tag ?? 0
		
		switch fontButtonTag {
		case 1:
			key = NH3DMsgFontKey
			sizeKey = NH3DMsgFontSizeKey
			
		case 2:
			key = NH3DWindowFontKey
			sizeKey = NH3DWindowFontSizeKey
			
		case 3:
			key = NH3DMapFontKey
			sizeKey = NH3DMapFontSizeKey
			
		case 4:
			key = NH3DBoldFontKey
			sizeKey = NH3DBoldFontSizeKey
			
		case 5:
			key = NH3DInventryFontKey
			sizeKey = NH3DInventryFontSizeKey
			
		default:
			return
		}
		
		guard let familyName = defaults.string(forKey: key),
			let selFont = NSFont(name: familyName, size: CGFloat(defaults.float(forKey: sizeKey))) else {
			return
		}
		
		//NSLog(familyName);
		
		// Set font font manager
		let fontMgr = NSFontManager.shared()
		fontMgr.setSelectedFont(selFont, isMultiple: false)
		//fontMgr.delegate = self;
		
		// Show font panel
		let fontPanel = NSFontPanel.shared()
		if !fontPanel.isVisible {
			fontPanel.orderFront(self)
		}
		window?.makeFirstResponder(nil)
	}
	
	@IBAction func resetFontFamily(_ sender: AnyObject?) {
		let initialValues = NSUserDefaultsController.shared().initialValues ?? [:]
		let defaults = UserDefaults.standard
		
		defaults.set(initialValues[NH3DMsgFontKey],
			forKey: NH3DMsgFontKey)
		defaults.set(initialValues[NH3DMapFontKey],
			forKey: NH3DMapFontKey)
		defaults.set(initialValues[NH3DBoldFontKey],
			forKey: NH3DBoldFontKey)
		defaults.set(initialValues[NH3DWindowFontKey],
			forKey: NH3DWindowFontKey)
		defaults.set(initialValues[NH3DInventryFontKey],
			forKey: NH3DInventryFontKey)
		
		defaults.set(initialValues[NH3DMsgFontSizeKey],
			forKey: NH3DMsgFontSizeKey)
		defaults.set(initialValues[NH3DMapFontSizeKey],
			forKey: NH3DMapFontSizeKey)
		defaults.set(initialValues[NH3DBoldFontSizeKey],
			forKey: NH3DBoldFontSizeKey)
		defaults.set(initialValues[NH3DWindowFontSizeKey],
			forKey: NH3DWindowFontSizeKey)
		defaults.set(initialValues[NH3DInventryFontSizeKey],
			forKey: NH3DInventryFontSizeKey)
	}

	@IBAction func chooseTileFile(_ sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		openPanel.allowedFileTypes = NSImage.imageTypes()
		//openPanel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
		openPanel.beginSheetModal(for: window!) { (result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				let filePath = openPanel.url!.path
				let defaults = UserDefaults.standard
				if let tileSize = tilesInfo(fromFile: filePath) {
					defaults.set(tileSize.rows, forKey: NH3DTilesPerLineKey)
					defaults.set(tileSize.columns, forKey: NH3DNumberOfTilesRowKey)
					defaults.set(Double(tileSize.tileSize.width), forKey: NH3DTileSizeWidthKey)
					defaults.set(Double(tileSize.tileSize.height), forKey: NH3DTileSizeHeightKey)
				}
				
				defaults.set(filePath, forKey: NH3DTileNameKey)
			}
		}
	}

	@IBAction func resetTileSettings(_ sender: AnyObject?) {
		let defaults = UserDefaults.standard
		
		defaults.removeObject(forKey: NH3DTileNameKey)
		defaults.removeObject(forKey: NH3DTileSizeWidthKey)
		defaults.removeObject(forKey: NH3DTileSizeHeightKey)
		defaults.removeObject(forKey: NH3DTilesPerLineKey)
		defaults.removeObject(forKey: NH3DNumberOfTilesRowKey)
	}
	
	@IBAction func clearID(_ sender: AnyObject?) {
		UserDefaults.standard.removeObject(forKey: kKeyHearseId)
		restartHearse(nil)
	}
	
	@IBAction func applyTileSettings(_ sender: AnyObject?) {
		bindController?.setTile()
	}
	
	@IBAction func restartHearse(_ sender: AnyObject?) {
		#if !HEARSE_DISABLE
		Hearse.stop()
		Hearse.start()
		#endif
	}
}
