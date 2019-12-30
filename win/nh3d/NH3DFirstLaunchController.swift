//
//  NH3DFirstLaunchController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/22/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

@objcMembers class NH3DFirstLaunchController: NSWindowController {
	
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	class func runFirstTimeWindow() {
		let defaults = UserDefaults.standard
		
		// If we have a Hearse Token, it means that the user already knows about Hearse.
		// So don't show the first time launch window
		if defaults.object(forKey: kKeyHearseId) != nil {
			defaults.set(false, forKey: NH3DIsFirstLaunch)
		}
		
		if defaults.bool(forKey: NH3DIsFirstLaunch) {
			let controller = NH3DFirstLaunchController(windowNibName: "FirstLaunch")
			let bindController = NSApp.delegate as! NH3DBindController
			
			controller.window?.isOpaque = false
			controller.window?.backgroundColor = NSColor.clear
			
			bindController.launchWindow?.beginSheet(controller.window!, completionHandler: { (response) in
				NSApp.stopModal()
				defaults.set(false, forKey: NH3DIsFirstLaunch)
				controller.window?.orderOut(nil)
			})
			NSApp.runModal(for: controller.window!)
		}
	}
	
	@IBAction func closePopUp(_ sender: AnyObject?) {
		let bindController = NSApp.delegate as! NH3DBindController
		
		bindController.launchWindow?.endSheet(window!)
	}
}
