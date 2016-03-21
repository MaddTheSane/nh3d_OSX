//
//  NH3DPreferenceController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 1/1/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

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
				NSUserDefaults.standardUserDefaults().setObject(openPanel.URL?.path, forKey: NH3DTileNameKey)
			}
		}
	}

	@IBAction func resetTileSettings(sender: AnyObject?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		//defaults.setObject("nhtiles.tiff", forKey: NH3DTileNameKey)
		//defaults.setInteger(16, forKey: NH3DTileSizeWidthKey)
		//defaults.setInteger(16, forKey: NH3DTileSizeHeightKey)
		//defaults.setInteger(40, forKey: NH3DTilesPerLineKey)
		//defaults.setInteger(30, forKey: NH3DNumberOfTilesRowKey)
		
		defaults.removeObjectForKey(NH3DTileNameKey)
		defaults.removeObjectForKey(NH3DTileSizeWidthKey)
		defaults.removeObjectForKey(NH3DTileSizeHeightKey)
		defaults.removeObjectForKey(NH3DTilesPerLineKey)
		defaults.removeObjectForKey(NH3DNumberOfTilesRowKey)
	}
	
	@IBAction func applyTileSettings(sender: AnyObject?) {
		bindController?.setTile()
	}
	
	@IBAction func restartHearse(sender: AnyObject?) {
		Hearse.stop()
		Hearse.start()
	}
}
