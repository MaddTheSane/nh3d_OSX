//
//  MSZLinkedView.swift
//  NetHack3D
//
//  Created by C.W. Betts on 3/23/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//
//  Based off of the code from CoreAnimationWizard, which
//  was created by Marcus S. Zarra on 3/1/08.
//  Copyright 2008 Zarra Studios LLC. All rights reserved.
//

import Cocoa
import QuartzCore.CAAnimation

class MSZLinkedView : NSView {
	@IBOutlet weak var previousView: MSZLinkedView?
	@IBOutlet weak var nextView: MSZLinkedView?
	
	@IBOutlet weak var nextButton: NSButton?
	@IBOutlet weak var previousButton: NSButton?

	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.wantsLayer = true
		previousButton?.enabled = previousView != nil
		nextButton?.enabled = nextView != nil
	}
}
