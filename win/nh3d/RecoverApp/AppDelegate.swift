//
//  AppDelegate.swift
//  Recover
//
//  Created by C.W. Betts on 10/21/15.
//  Copyright © 2015 Dirk Zimmermann. All rights reserved.
//

import Cocoa

extension NHRecoveryErrors: ErrorType {
	public var _domain: String {
		return NHRecoveryErrorDomain
	}
	
	public var _code: Int {
		return rawValue
	}
}

/// NSTableViewDataSource url table column key
private let locURLKey = "NHRecoverURL"

/// NSTableViewDataSource error table column key
private let recoverErrorKey = "NHRecoverError"

@NSApplicationMain
class AppDelegate: NSObject {
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var progress: NSProgressIndicator!
	@IBOutlet weak var errorPanel: NSWindow!
	@IBOutlet weak var errorTable: NSTableView!
	
	private var failedNums = 0
	private var succeededNums = 0
	dynamic private(set) var countNums = 0
	
	private var recoveryErrors = [NSURL: NSError]()
	private var errorOrder = [NSURL]()
	
	private var errorToReport: NHRecoveryErrors?
	private let opQueue: NSOperationQueue = {
		let aQueue = NSOperationQueue()
		
		aQueue.name = "NetHack Recovery"
		
		//if #available(OSX 10.10, *) {
		    aQueue.qualityOfService = .UserInitiated
		//}
		
		return aQueue
	}()

	override func awakeFromNib() {
		super.awakeFromNib()
		
		let selfBundleURL = NSBundle.mainBundle().bundleURL
		guard let parentBundleURL = selfBundleURL.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent,
			parentBundle = NSBundle(URL: parentBundleURL), parentBundleResources = parentBundle.resourcePath
			where parentBundle.bundleURL.pathExtension == "app" else {
				errorToReport = .HostBundleNotFound
				return
		}
		
		//Change to the NetHack resource directory.
		NSFileManager.defaultManager().changeCurrentDirectoryPath(parentBundleResources)
	}
	
	private func launchNetHack() throws {
		let workspace = NSWorkspace.sharedWorkspace()
		let parentBundleURL: NSURL = {
			let selfBundleURL = NSBundle.mainBundle().bundleURL
			return selfBundleURL.URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!
		}()
		try workspace.launchApplicationAtURL(parentBundleURL, options: .Default, configuration: [:])
		NSApp.terminate(nil)
	}
	
	func addURL(url: NSURL) {
		let saveRecover = SaveRecoveryOperation(saveFileURL: url)
		
		saveRecover.completionBlock = {
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				if saveRecover.success {
					self.succeededNums += 1
				} else {
					self.failedNums += 1
					self.recoveryErrors[url] = saveRecover.error!
				}
				if self.countNums == self.succeededNums + self.failedNums {
					// we're done
					
					let alert = NSAlert()
					alert.addButtonWithTitle("Relaunch NetHack")
					
					if self.failedNums != 0 {
						alert.alertStyle = .WarningAlertStyle
						alert.messageText = "Recovery unsuccessful!"
						alert.informativeText = "\(self.failedNums) file\(self.failedNums > 1 ? "s were" : " was") not successfully recovered."
						alert.addButtonWithTitle("Quit")
						alert.addButtonWithTitle("Show Errors")
					} else {
						alert.alertStyle = .InformationalAlertStyle
						alert.messageText = "Recovery successful"
						alert.informativeText = "\(self.succeededNums) file\(self.succeededNums > 1 ? "s were" : " was") successfully recovered."
					}
					
					alert.beginSheetModalForWindow(self.window, completionHandler: { (response) -> Void in
						switch response {
						case NSAlertFirstButtonReturn:
							do {
								try self.launchNetHack()
							} catch let error as NSError {
								NSBeep()
								NSAlert(error: error).runModal()
								exit(EXIT_FAILURE)
							}
							
						case NSAlertSecondButtonReturn:
							NSApp.terminate(nil)
							
						case NSAlertThirdButtonReturn:
							self.showErrorList()
							
						default:
							NSBeep()
							sleep(1)
							exit(EXIT_FAILURE)
						}
					})
				}
			})
		}
		
		opQueue.addOperation(saveRecover)
		countNums += 1
	}

	func showErrorList() {
		//Created to make sure we have data in constant order.
		errorOrder = Array(recoveryErrors.keys)
		errorTable.reloadData()
		self.window.beginSheet(errorPanel) { (resp) in
			if resp == -1 {
				// Just quit
				NSApp.terminate(nil)
			} else if resp == 0 {
				do {
					try self.launchNetHack()
				} catch let error as NSError {
					NSBeep()
					NSAlert(error: error).runModal()
					exit(EXIT_FAILURE)
				}
			} else {
				//Don't quit
				NSBeep()
			}
		}
	}
	
	@IBAction func tableButton(sender: NSButton) {
		self.window.endSheet(errorPanel, returnCode: sender.tag)
	}
}

//MARK: - NSApplicationDelegate

extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		
		if let errorToReport = errorToReport {
			do {
				throw errorToReport
			} catch let error as NSError {
				// force loading of SaveRecoveryOperation class
				SaveRecoveryOperation.load()

				let anAlert = NSAlert(error: error)
				anAlert.alertStyle = .CriticalAlertStyle
				
				anAlert.informativeText += "\n\nRecovery will now close."
				
				anAlert.runModal()
				NSApp.terminate(nil)
			}
		}
		
		progress.startAnimation(nil)
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func application(sender: NSApplication, openFile filename: String) -> Bool {
		let fileURL = NSURL(fileURLWithPath: filename)
		addURL(fileURL)
		return true
	}
}

// MARK: - NSTableViewDataSource

extension AppDelegate: NSTableViewDataSource {
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return recoveryErrors.count
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
		guard let columnID = tableColumn?.identifier else {
			return nil
		}
		switch columnID {
		case locURLKey:
			return errorOrder[row].lastPathComponent
			
		case recoverErrorKey:
			return recoveryErrors[errorOrder[row]]?.localizedDescription
			
		default:
			return nil
		}
	}
}
