//
//  NH3DMessaging.swift
//  NetHack3D
//
//  Created by C.W. Betts on 12/31/15.
//  Copyright © 2015 Haruumi Yoshino. All rights reserved.
//

import Cocoa

let DIALOG_OK		= 128
let DIALOG_CANCEL	= 129

class NH3DMessaging: NSObject {
	private final class ScreenEffect: CustomStringConvertible {
		private var regex = regex_init()
		let effect: Int32
		/// The regex string used to match against.<br>
		/// Useful for debugging
		let str: String
		
		init?(message text: String, effect: Int32) {
			str = text
			self.effect = effect
			guard regex_compile(text, regex) else {
				raw_print(regex_error_desc(regex))
				
				return nil
			}
		}
		
		deinit {
			regex_free(regex)
		}
		
		func matches(_ str: String) -> Bool {
			return regex_match(str, regex)
		}
		
		var description: String {
			return "Screen Effect #\(effect): `\(str)`"
		}
	}
	
	var messageWindow: NSTextView! {
		return messageScrollView.contentView.documentView as? NSTextView
	}
	@IBOutlet weak var messageScrollView: NSScrollView!
	@IBOutlet weak var rawPrintScrollView: NSScrollView!
	var rawPrintWindow: NSTextView! {
		return rawPrintScrollView.contentView.documentView as? NSTextView
	}
	@IBOutlet weak var panelCloseButton: NSButton!
	@IBOutlet weak var rawPrintPanel: NSPanel!
	@IBOutlet weak var glView: NH3DOpenGLView!
	
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var ripPanel: NSPanel!
	
	@IBOutlet weak var inputPanel: NSPanel!
	
	@IBOutlet weak var deathDescription: NSTextField!
	@IBOutlet weak var inputTextField: NSTextField!
	@IBOutlet weak var questionTextField: NSTextField!
	
	private var msgArray = [Int]()
	
	private var darkShadowStrAttributes = [NSAttributedStringKey: Any]()
	private var lightShadowStrAttributes = [NSAttributedStringKey: Any]()
	private let darkShadow: NSShadow = {
		//for view or backgrounded text field.
		let adarkShadow = NSShadow()
		adarkShadow.shadowColor = NSColor(calibratedWhite: 0.2, alpha: 0.5)
		adarkShadow.shadowOffset = NSSize(width: 2, height: -2)
		adarkShadow.shadowBlurRadius = 0.5
		return adarkShadow
	}()
	private let lightShadow: NSShadow = {
		//for panel or window.
		let alightShadow = NSShadow()
		alightShadow.shadowColor = NSColor(calibratedWhite:1.0, alpha:1.0)
		alightShadow.shadowOffset = NSSize(width: -1.5, height: 1.5)
		alightShadow.shadowBlurRadius = 1.6
		return alightShadow
	}()
	private var style = NSMutableParagraphStyle()
	
	private var ripFlag = false
	@objc var lastAttackDirection: Int32 = 0
	
	private var effectArray = [ScreenEffect]()
	
	private func prepareAttributes() {
		style = NSMutableParagraphStyle()
		style.lineSpacing = -2
		
		darkShadowStrAttributes.removeAll(keepingCapacity: true)
		lightShadowStrAttributes.removeAll(keepingCapacity: true)
		
		//Text attributes in View or backgrounded text field.
		
		style.alignment = .left
		darkShadowStrAttributes[.font] = NSFont(name: NH3DMSGFONT, size: NH3DMSGFONTSIZE)
		darkShadowStrAttributes[.shadow] = darkShadow
		darkShadowStrAttributes[.paragraphStyle] = style.copy()
		darkShadowStrAttributes[.foregroundColor] = NSColor(calibratedWhite: 0.0, alpha: 0.8)
		
		//Text attributes on Panel or Window.
		
		style.alignment = .center
		lightShadowStrAttributes[.font] = NSFont(name: NH3DWINDOWFONT, size: NH3DWINDOWFONTSIZE)
		lightShadowStrAttributes[.shadow] = lightShadow
		lightShadowStrAttributes[.paragraphStyle] = style.copy()
		lightShadowStrAttributes[.foregroundColor] = NSColor(calibratedWhite: 0.0, alpha: 0.8)
	}
	
	override init() {
		super.init()
		msgArray.reserveCapacity(Int(iflags.msg_history))
		darkShadowStrAttributes.reserveCapacity(8)
		lightShadowStrAttributes.reserveCapacity(8)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		prepareAttributes()
		messageWindow.drawsBackground = false
		messageScrollView.drawsBackground = false
	}
	
	@objc(addEffectMessage:effectType:)
	func addEffect(message newMsg: String, effectType: Int32) -> Bool {
		guard effectType == 1 || effectType == 2 else {
			return false
		}
		guard let newObj = ScreenEffect(message: newMsg, effect: effectType) else {
			return false
		}
		effectArray.append(newObj)
		return true
	}
	
	@objc(putMainMessage:text:)
	func putMainMessage(attribute attr: Int32, text: UnsafePointer<CChar>?) {
		prepareAttributes()
		
		guard let text = text else {
			return
		}
		
		guard let textStr = String(cString: text, encoding: NH3DTextEncoding) else {
			NSSound.beep()
			return
		}
		
		if !SOUND_MUTE {
			for msgEffect in effectArray {
				if msgEffect.matches(textStr) {
					switch msgEffect.effect {
					case 1: // hit enemy attack to player
						glView.isShocked = true
						
					case 2: // hit player attack to enemy
						glView.enemyPosition = lastAttackDirection
						
					default:
						break
					}
				}
			}
		}
		
		switch attr {
		case ATR_NONE:
			break
			
		case ATR_ULINE:
			darkShadowStrAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			
		case ATR_BOLD:
			darkShadowStrAttributes[.font] = NSFont(name: NH3DBOLDFONT, size: NH3DBOLDFONTSIZE)
			
		case ATR_BLINK, ATR_INVERSE:
			darkShadowStrAttributes[.foregroundColor] = NSColor.alternateSelectedControlTextColor
			darkShadowStrAttributes[.backgroundColor] = NSColor.alternateSelectedControlColor
			
		default:
			break
		}
		
		let putString = NSMutableAttributedString(string: textStr + "\n", attributes: darkShadowStrAttributes)
		
		if msgArray.count < Int(iflags.msg_history) {
			msgArray.append(putString.length)
		} else {
			let txtRange = NSRange(location: 0, length: msgArray.removeFirst())
			messageWindow.textStorage?.deleteCharacters(in: txtRange)
			msgArray.append(putString.length)
		}
		
		messageWindow.textStorage?.append(putString)
		messageWindow.scrollToEndOfDocument(self)
	}
	
	/// This is a bit of a misnomer, as it doesn't wipe the text, just greys it out.
	@objc func clearMainMessage() {
		messageWindow.textStorage?.addAttribute(.foregroundColor,
		                                        value: NSColor(calibratedWhite: 0.4, alpha: 0.7),
		                                        range: NSRange(location: 0, length: messageWindow.textStorage!.length))
	}
	
	@objc func showInputPanel(_ messageStr: UnsafePointer<CChar>, line: UnsafeMutablePointer<CChar>) -> Int32 {
		guard let questionStr = String(cString: messageStr, encoding: NH3DTextEncoding) else {
			return -1
		}
		var result = 0
		
		prepareAttributes()
		
		let putString = NSAttributedString(string: questionStr,
		                                   attributes: lightShadowStrAttributes)
		
		questionTextField.attributedStringValue = putString
		
		window.beginSheet(inputPanel) { (returnCode) -> Void in
			//do nothing?
		}
		
		result = NSApp.runModal(for: inputPanel).rawValue
		
		window.endSheet(inputPanel)
		inputPanel.orderOut(self)
		
		if result == DIALOG_CANCEL {
			questionTextField.stringValue = ""
			inputTextField.stringValue = ""
			return -1
		}
		if inputTextField.stringValue.characters.count == 0 {
			questionTextField.stringValue = ""
			return -1
		}
		
		if inputTextField.stringValue.lengthOfBytes(using: NH3DTextEncoding) > Int(BUFSZ) {
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("There is too much number of the letters.", comment: "")
			alert.informativeText = " "
			alert.runModal()
			
			questionTextField.stringValue = ""
			inputTextField.stringValue = ""
			return -1
		}
		
		guard let inputData = inputTextField.stringValue.data(using: NH3DTextEncoding, allowLossyConversion: true),
			let str = String(data: inputData, encoding: NH3DTextEncoding),
			let cStr = str.cString(using: NH3DTextEncoding) else {
				questionTextField.stringValue = ""
				inputTextField.stringValue = ""
				return -1
		}
		
		strcpy(line, cStr)
		
		questionTextField.stringValue = ""
		inputTextField.stringValue = ""
		
		return 0
	}
	
	@IBAction func closeInputPanel(_ sender: NSButton?) {
		if sender?.tag != 0 {
			NSApp.stopModal(withCode: NSApplication.ModalResponse(rawValue: DIALOG_CANCEL))
		} else {
			NSApp.stopModal(withCode: NSApplication.ModalResponse(rawValue: DIALOG_OK))
		}
	}
	
	func showOutRip(_ ripString: UnsafePointer<CChar>) {
		let conv = String(cString: ripString, encoding: NH3DTextEncoding) ?? "You died.\n\nNothing eventful happened, though."
		showOutRip(conv)
	}
	
	@objc(showOutRipString:)
	func showOutRip(_ ripString: String) {
		ripFlag = true
		
		prepareAttributes()
		style.alignment = .center
		
		lightShadowStrAttributes[.paragraphStyle] = style.copy()
		lightShadowStrAttributes[.font] = NSFont(name: "Optima Bold", size: 11)
		
		deathDescription.attributedStringValue = NSAttributedString(string: ripString,
		                                                            attributes: lightShadowStrAttributes)
		
		ripPanel.alphaValue = 0
		ripPanel.orderFront(self)
		// window fade out/in
		NSAnimationContext.runAnimationGroup({ (ctx) -> Void in
			self.window.animator().alphaValue = 0
			self.ripPanel.animator().alphaValue = 1
		}, completionHandler: {
			self.ripPanel.flush()
		})
	}
	
	@objc(putLogMessage:bold:)
	func putLog(message rawText: String, bold: Bool) {
		#if DEBUG
			NSLog(" %@", rawText)
		#endif
		prepareAttributes()
		style.alignment = .left
		
		lightShadowStrAttributes[.paragraphStyle] = style.copy()
		lightShadowStrAttributes[.font] = NSFont(name: bold ? "Courier Bold" : "Courier", size: 12)
		
		let putStr = NSAttributedString(string: rawText + "\n", attributes: lightShadowStrAttributes)
		DispatchQueue.main.async {
			self.rawPrintWindow.textStorage?.append(putStr)
		}
	}
	
	@objc func showLogPanel() -> NSApplication.TerminateReply {
		var ripOrMainWindow: NSWindow
		
		panelCloseButton.action = #selector(NH3DMessaging.closeInputPanel(_:))
		panelCloseButton.title = NSLocalizedString("OK", comment: "OK")
		let rppWasVisible = rawPrintPanel.isVisible && !ripFlag
		
		if !rppWasVisible {
			rawPrintPanel.alphaValue = 0
			rawPrintPanel.center()
		}
		rawPrintPanel.makeKeyAndOrderFront(self)
		// window fade out/in
		
		if ripFlag {
			ripOrMainWindow = ripPanel
			NSApp.runModal(for: ripPanel)
		} else {
			ripOrMainWindow = window
		}
		
		NSAnimationContext.runAnimationGroup({ (ctx) -> Void in
			ripOrMainWindow.animator().alphaValue = 0
			if rppWasVisible {
				let newRect = self.rawPrintPanel.frame.centered(in: self.rawPrintPanel.screen!.visibleFrame)
				//TODO: make this smoother.
				self.rawPrintPanel.animator().setFrame(newRect, display: true)
				//self.rawPrintPanel.setFrame(newRect, display: true, animate: true)
				//self.rawPrintPanel.animator().center()
			} else {
				self.rawPrintPanel.animator().alphaValue = 1
			}
		}, completionHandler: {
			ripOrMainWindow.orderOut(self)
			NSApp.runModal(for: self.rawPrintPanel)
			self.rawPrintPanel.orderOut(self)
			clearlocks()
			NSApp.reply(toApplicationShouldTerminate: true)
		})
		
		return .terminateLater
	}
	
	@IBAction func showLogPanel(_ sender: Any?) {
		rawPrintPanel.makeKeyAndOrderFront(self)
	}
	
	@IBAction func closeLogPanel(_ sender: Any?) {
		rawPrintPanel.orderOut(self)
	}
}

extension NSRect {
	func centered(in outerRect: NSRect) -> NSRect {
		var innerRect = self
		innerRect.origin.x = outerRect.origin.x
			+ floor((outerRect.size.width - innerRect.size.width) / 2.0)
		innerRect.origin.y = outerRect.origin.y
			+ floor((outerRect.size.height - innerRect.size.height) / 2.0)

		return innerRect
	}
}
