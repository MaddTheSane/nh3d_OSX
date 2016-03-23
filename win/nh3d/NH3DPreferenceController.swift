//
//  NH3DPreferenceController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 1/1/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

/// Returns the amount of tiles per row and column.
///
/// Needed because NH3D uses a different way of handling tiles:
/// NH3D wants the number of rows and columns; other front-ends
/// specify the width and height of one tile.<br>
/// This assumes that there are no extra pixels, such as signatures.
func tilesInfoFromFileAtLocation(fileName: String) -> (width: Int, height: Int)? {
	/// Scans the file name to identify the width and height.
	/// - returns: `nil` if the tile size could not be identified
	func sizeFromFileName(fileName: String) -> (width: Int32, height: Int32)? {
		// FIXME: this is ugly!  Transition to Regex/NSScanner.
		var width: Int32 = 0
		var height: Int32 = 0
		
		let unsfePtr1 = withUnsafeMutablePointer(&width) {
			return $0
		}
		let unsfePtr2 = withUnsafeMutablePointer(&height) {
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
	
	guard let fileDimensions = sizeFromFileName((fileName as NSString).lastPathComponent) else {
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
	let imgDimensions: (Int32, Int32)
	// On bitmap formats, get the actual pixel size.
	// This makes, for example, the Absurd tile sets load
	if let firstRep = image1.representations.first as? NSBitmapImageRep {
		imgDimensions = (Int32(firstRep.pixelsWide), Int32(firstRep.pixelsHigh))
	} else {
		imgDimensions = (Int32(image1.size.width), Int32(image1.size.height))
	}
	
	// divide the numbers, getting the remainder remainder
	let divWidth: (divided: Int32, remainder: Int32) = {
		let width1 = fileDimensions.width
		let width2 = imgDimensions.0
		
		return (width2 / width1, width2 % width1)
	}()
	let divHeight: (divided: Int32, remainder: Int32) = {
		let height1 = fileDimensions.height
		let height2 = imgDimensions.1
		
		return (height2 / height1, height2 % height1)
	}()
	
	// If there's any remainder, it means the passed-in string size
	// doesn't match
	if divHeight.remainder != 0 || divWidth.remainder != 0 {
		// We failed
		return nil
	}
	
	return (Int(divWidth.divided), Int(divHeight.divided))
}

class NH3DPreferenceController : NSWindowController, NSWindowDelegate {
	private var bindController: NH3DBindController?
	private var fontButtonTag = 0

	convenience init() {
		self.init(windowNibName: "PreferencePanel")
	}
	
	func windowShouldClose(sender: AnyObject) -> Bool {
		bindController?.endPreferencePanel()
		
		return true
	}
	
	func showPreferencePanel(sender: NH3DBindController) {
		bindController = sender
		window?.makeKeyAndOrderFront(self)
	}
	
	@IBAction override func changeFont(sender: AnyObject?) {
		guard let sender = sender as? NSFontManager else {
			return
		}
		
		let font = NSFont.systemFontOfSize(NSFont.systemFontSize())
		let convertedFont = sender.convertFont(font)
		
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
		
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setObject(convertedFont.fontName, forKey: key)
		defaults.setFloat(Float(convertedFont.pointSize), forKey: sizeKey)
	}
	
	@IBAction func showFontPanelAction(sender: NSMatrix?) {
		guard let sender = sender else {
			return
		}
		let key: String
		fontButtonTag = sender.selectedCell()?.tag ?? 0
		
		switch (fontButtonTag) {
		case 1:
			key = NH3DMsgFontKey
			
		case 2:
			key = NH3DWindowFontKey
			
		case 3:
			key = NH3DMapFontKey
			
		case 4:
			key = NH3DBoldFontKey
			
		case 5:
			key = NH3DInventryFontKey
			
		default:
			return
		}
		
		guard let familyName = NSUserDefaults.standardUserDefaults().stringForKey(key), selFont = NSFont(name: familyName, size: NSFont.systemFontSize()) else {
			return
		}
		
		//NSLog(familyName);
		
		// Set font font manager
		let fontMgr = NSFontManager.sharedFontManager()
		fontMgr.setSelectedFont(selFont, isMultiple: false)
		//fontMgr.delegate = self;
		
		// Show font panel
		let fontPanel = NSFontPanel.sharedFontPanel()
		if !fontPanel.visible {
			fontPanel.orderFront(self)
		}
		window?.makeFirstResponder(nil)
	}
	
	@IBAction func resetFontFamily(sender: AnyObject?) {
		let initialValues = NSUserDefaultsController.sharedUserDefaultsController().initialValues ?? [:]
		let defaults = NSUserDefaults.standardUserDefaults()
		
		defaults.setObject(initialValues[NH3DMsgFontKey],
			forKey: NH3DMsgFontKey)
		defaults.setObject(initialValues[NH3DMapFontKey],
			forKey: NH3DMapFontKey)
		defaults.setObject(initialValues[NH3DBoldFontKey],
			forKey: NH3DBoldFontKey)
		defaults.setObject(initialValues[NH3DWindowFontKey],
			forKey: NH3DWindowFontKey)
		defaults.setObject(initialValues[NH3DInventryFontKey],
			forKey: NH3DInventryFontKey)
		
		defaults.setObject(initialValues[NH3DMsgFontSizeKey],
			forKey: NH3DMsgFontSizeKey)
		defaults.setObject(initialValues[NH3DMapFontSizeKey],
			forKey: NH3DMapFontSizeKey)
		defaults.setObject(initialValues[NH3DBoldFontSizeKey],
			forKey: NH3DBoldFontSizeKey)
		defaults.setObject(initialValues[NH3DWindowFontSizeKey],
			forKey: NH3DWindowFontSizeKey)
		defaults.setObject(initialValues[NH3DInventryFontSizeKey],
			forKey: NH3DInventryFontSizeKey)
	}

	@IBAction func chooseTileFile(sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		openPanel.allowedFileTypes = NSImage.imageTypes()
		//openPanel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
		openPanel.beginSheetModalForWindow(window!) { (result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				let filePath = openPanel.URL!.path!
				let defaults = NSUserDefaults.standardUserDefaults()
				if let tileSize = tilesInfoFromFileAtLocation(filePath) {
					defaults.setInteger(tileSize.width, forKey: NH3DTilesPerLineKey)
					defaults.setInteger(tileSize.height, forKey: NH3DNumberOfTilesRowKey)
				}
				
				defaults.setObject(filePath, forKey: NH3DTileNameKey)
			}
		}
	}

	@IBAction func resetTileSettings(sender: AnyObject?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		defaults.removeObjectForKey(NH3DTileNameKey)
		defaults.removeObjectForKey(NH3DTileSizeWidthKey)
		defaults.removeObjectForKey(NH3DTileSizeHeightKey)
		defaults.removeObjectForKey(NH3DTilesPerLineKey)
		defaults.removeObjectForKey(NH3DNumberOfTilesRowKey)
	}
	
	@IBAction func clearID(sender: AnyObject?) {
		NSUserDefaults.standardUserDefaults().removeObjectForKey(kKeyHearseId)
		restartHearse(nil)
	}
	
	@IBAction func applyTileSettings(sender: AnyObject?) {
		bindController?.setTile()
	}
	
	@IBAction func restartHearse(sender: AnyObject?) {
		Hearse.stop()
		Hearse.start()
	}
}
