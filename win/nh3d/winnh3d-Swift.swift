//
//  winnh3d.swift
//  NetHack3D
//
//  Created by C.W. Betts on 4/13/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Foundation

// 6 is above the window types used by NetHack
private var currentWid: winid = 6
private var windowDict = [winid: NhWindow]()

extension NH3DBindController {
	@objc class func windowForWindowID(wid: winid) -> NhWindow? {
		return windowDict[wid]
	}
	
	@objc(setWindow:forID:) class func setWindow(window: NhWindow, id wid: winid) {
		windowDict[wid] = window
	}
	
	@objc class func addWindow(window: NhWindow) -> winid {
		currentWid += 1
		let newID = currentWid
		windowDict[newID] = window
		return newID
	}
	
	@objc(removeWindowWithID:) class func removeWindow(id wid: winid) {
		windowDict.removeValueForKey(wid)
	}
}
