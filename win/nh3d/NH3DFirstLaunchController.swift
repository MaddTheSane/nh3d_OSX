//
//  NH3DFirstLaunchController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/22/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa
import QuartzCore.CAAnimation

class NH3DFirstLaunchController: NSWindowController {
	private var transition: CATransition?
	@IBOutlet weak var currentView: MSZLinkedView? {
		willSet(newView) {
			guard let currentView = currentView else {
				return
			}
			contentView?.animator().replaceSubview(currentView, with: newView!)
		}
	}
	@IBOutlet weak var contentView: NSView!
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		contentView.wantsLayer = true
		//contentView.addSubview(currentView!)
		contentView.replaceSubview(currentView!, with: currentView!.nextView!)

		transition = CATransition()
		transition!.type = kCATransitionPush
		transition!.subtype = kCATransitionFromLeft
		
		contentView.animations = ["subviews": transition!]
    }

	class func runFirstTimeWindow() {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		if defaults.boolForKey(NH3DIsFirstLaunch) {
			let controller = NH3DFirstLaunchController(windowNibName: "FirstLaunch")
			let bindController = NSApp.delegate as! NH3DBindController
			
			controller.window?.opaque = false
			controller.window?.backgroundColor = NSColor.clearColor()
			
			bindController.launchWindow?.beginSheet(controller.window!, completionHandler: { (response) in
				NSApp.stopModal()
				defaults.setBool(true, forKey: NH3DIsFirstLaunch)
				controller.window?.orderOut(nil)
				bindController.setTile()
			})
			NSApp.runModalForWindow(controller.window!)
		}
	}
	
	@IBAction func closePopUp(sender: AnyObject?) {
		let bindController = NSApp.delegate as! NH3DBindController
		
		bindController.launchWindow?.endSheet(window!)
	}
	
	@IBAction func nextView(sender: AnyObject) {
		guard let nextViewa = currentView?.nextView else {
			return
		}
		transition!.subtype = kCATransitionFromRight
		currentView = nextViewa
	}
	
	@IBAction func previousView(sender: AnyObject) {
		guard let prevView = currentView?.previousView else {
			return
		}
		transition!.subtype = kCATransitionFromLeft
		currentView = prevView
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
		
		defaults.removeObjectForKey(NH3DTileNameKey)
		defaults.removeObjectForKey(NH3DTileSizeWidthKey)
		defaults.removeObjectForKey(NH3DTileSizeHeightKey)
		defaults.removeObjectForKey(NH3DTilesPerLineKey)
		defaults.removeObjectForKey(NH3DNumberOfTilesRowKey)
	}
}
