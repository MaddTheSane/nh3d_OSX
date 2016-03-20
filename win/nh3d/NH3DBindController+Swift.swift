//
//  NH3DBindController_Swift.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/20/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

// 6 is above the window types used by NetHack
private var currentWid: winid = 6
private var windowDict = [winid: AnyObject]()


extension NH3DBindController {
	@objc class func windowForWindowID(wid: winid) -> AnyObject? {
		return windowDict[wid]
	}
	
	@objc(setWindow:forID:) class func setWindow(window: AnyObject, id wid: winid) {
		windowDict[wid] = window
	}
	
	@objc class func addWindow(window: AnyObject) -> winid {
		let newID = ++currentWid
		windowDict[newID] = window
		return newID
	}
	
	@objc(removeWindowWithID:) class func removeWindow(id wid: winid) {
		windowDict.removeValueForKey(wid)
	}
}
