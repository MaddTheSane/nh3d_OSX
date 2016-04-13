//
//  NH3DMenuWindowController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 4/13/16.
//  Copyright © 2016 Haruumi Yoshino. All rights reserved.
//

import Cocoa

func getMainWindow() -> NSWindow! {
	let appDel = NSApp.delegate as? NH3DBindController
	return appDel?.mainWindow
}

class NH3DMenuWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
	private(set) var menuParams: NhMenuWindow!
	private var nh3dMenu = [NH3DMenuItem]()

	@IBOutlet weak var menuTableView: NSTableView!
	@IBOutlet weak var menuPanelString: NSTextField!
	@IBOutlet weak var menuPanelStringShadow: NSTextField!
	@IBOutlet weak var menuScrollView: NSScrollView!

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
		window?.backgroundColor = NSColor.clearColor()
		window?.opaque = false
		menuTableView.backgroundColor = NSColor.clearColor()
		menuScrollView.drawsBackground = false

		// set DubleClicked action
		menuTableView.target = self;
		menuTableView.doubleAction = #selector(NH3DMenuWindowController.closeModalDialog(_:))
		
		// set DataCell
		let cell = NSButtonCell();
		let tableColumn = menuTableView.tableColumnWithIdentifier("name")
		
		cell.bezelStyle = .RecessedBezelStyle;
		cell.setButtonType(.MomentaryLightButton)
		cell.bordered = true;
		cell.gradientType = .None;
		cell.highlightsBy = .NoCellMask;
		cell.wraps = true;
		cell.lineBreakMode = .ByCharWrapping;
		cell.controlView = menuTableView;
		
		tableColumn?.dataCell = cell;
	}

	convenience init(menu: NhMenuWindow) {
		self.init(windowNibName: "MenuWindow")
		menuParams = menu
	}
	
	@IBAction func closeModalDialog(sender: NSView) {
		let sendWind = sender.window!
		if (sender.tag == 1) {
			getMainWindow().endSheet(sendWind)
			NSApp.stopModalWithCode(DIALOG_CANCEL)
		} else {
			getMainWindow().endSheet(sendWind)
			NSApp.stopModalWithCode(DIALOG_OK)
		}
		sendWind.orderOut(self)
	}

	// MARK: - Table View Delegate/data source
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return nh3dMenu.count
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row rowIndex: Int) -> AnyObject? {
		let identifier = aTableColumn!.identifier
		let aMenuItem = nh3dMenu[rowIndex];
		
		return aMenuItem.valueForKey(identifier)
	}
	
	func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
		let aMenuItem = nh3dMenu[row];
		let identifier = tableColumn!.identifier;
		let aCell = cell as! NSButtonCell
		
		if identifier == "name" {
			aCell.attributedTitle = aMenuItem.name()
			
			aCell.imagePosition = .ImageLeft
			aCell.image = aMenuItem.smallGlyph;
			
			if (!aMenuItem.selectable) {
				aCell.bordered = false
				aCell.selectable = false
			} else {
				aCell.bordered = true
				
				if let attrStr = aMenuItem.accelerator() {
					aCell.keyEquivalent = String(attrStr.string.characters.first!)
				}
			}
		}
		
		if (aMenuItem.preselected) {
			tableView.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: true)
			aMenuItem.setPreselect( false /*MENU_UNSELECTED*/)
		}
	}
	
	func tableView(tableView: NSTableView, shouldSelectRow rowIndex: Int) -> Bool {
		let aMenuItem = nh3dMenu[rowIndex];
		return aMenuItem.selectable;
	}
	
	dynamic var multipleSelection: Bool {
		return menuParams.how == PICK_ANY
	}
	
	class func menuWindowWithMenu(menu: NhMenuWindow) {
		let win = NH3DMenuWindowController(menu: menu)
		if let prompt = menu.prompt {
			
		}
		
		getMainWindow().beginSheet(win.window!) { (resp) in
			
		}
		
		NSApp.runModalForWindow(win.window!)
	}
}
