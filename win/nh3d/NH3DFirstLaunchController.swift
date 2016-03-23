//
//  NH3DFirstLaunchController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/22/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

class NH3DFirstLaunchController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
			})
			NSApp.runModalForWindow(controller.window!)
		}
	}
	
	@IBAction func closePopUp(sender: AnyObject?) {
		let bindController = NSApp.delegate as! NH3DBindController
		
		bindController.launchWindow?.endSheet(window!)
	}
}
