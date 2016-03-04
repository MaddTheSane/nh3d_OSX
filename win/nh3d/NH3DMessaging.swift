//
//  NH3DMessaging.swift
//  NetHack3D
//
//  Created by C.W. Betts on 12/31/15.
//  Copyright © 2015 Haruumi Yoshino. All rights reserved.
//

import Cocoa
import AVFoundation

private let DIALOG_OK		= 128
private let DIALOG_CANCEL	= 129

class NH3DMessaging: NSObject {
	var messageWindow: NSTextView! {
		return messageScrollView.contentView.documentView as? NSTextView
	}
	@IBOutlet weak var messageScrollView: NSScrollView!
	@IBOutlet weak var rawPrintScrollView: NSScrollView!
	var rawPrintWindow: NSTextView! {
		return rawPrintScrollView.contentView.documentView as? NSTextView
	}
	@IBOutlet weak var rawPrintPanel: NSPanel!
	@IBOutlet weak var glView: NH3DOpenGLView!
	
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var ripPanel: NSPanel!
	
	@IBOutlet weak var inputPanel: NSPanel!
	
	@IBOutlet weak var deathDescription: NSTextField!
	@IBOutlet weak var inputTextField: NSTextField!
	@IBOutlet weak var questionTextField: NSTextField!
	
	private var audioDict = [String: AVAudioPlayer]()
	
	private var msgArray = [Int]()
	
	private var darkShadowStrAttributes = [String: AnyObject]()
	private var lightShadowStrAttributes = [String: AnyObject]()
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
	
	var lastAttackDirection: Int32 = 0
	
	private var effectArray = [Effect]()
	
	private struct Effect {
		var message: String
		var type: Int32
	}
	
	func prepareAttributes() {
		style = NSMutableParagraphStyle()
		style.lineSpacing = -2
		
		darkShadowStrAttributes = [:]
		lightShadowStrAttributes = [:]
		
		//Text attributes in View or backgrounded text field.
		
		darkShadowStrAttributes[NSFontAttributeName] = NSFont(name: NH3DMSGFONT, size: NH3DMSGFONTSIZE)
		darkShadowStrAttributes[NSShadowAttributeName] = darkShadow;
		darkShadowStrAttributes[NSParagraphStyleAttributeName] = style;
		darkShadowStrAttributes[NSForegroundColorAttributeName] = NSColor(calibratedWhite: 0.0, alpha: 0.8)
		
		//Text attributes on Panel or Window.
		
		lightShadowStrAttributes[NSFontAttributeName] = NSFont(name: NH3DWINDOWFONT, size: NH3DWINDOWFONTSIZE)
		lightShadowStrAttributes[NSShadowAttributeName] = lightShadow;
		lightShadowStrAttributes[NSParagraphStyleAttributeName] = style;
		lightShadowStrAttributes[NSForegroundColorAttributeName] = NSColor(calibratedWhite: 0.0, alpha: 0.8)
	}

	override init() {
		super.init()
		msgArray.reserveCapacity(Int(iflags.msg_history))
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		prepareAttributes()
		messageWindow.drawsBackground = false
		messageScrollView.drawsBackground = false
	}

	func addEffectMessage(newMsg: String, effectType: Int32) -> Bool {
		guard effectType != 1 || effectType != 2 else {
			return false
		}
		effectArray.append(NH3DMessaging.Effect(message: newMsg, type: effectType))
		return true
	}

	@objc(playSoundAtURL:volume:) func playSound(URL URL: NSURL, volume: Float) -> Bool {
		guard !SOUND_MUTE else {
			return false
		}
		
		func playAud(playSound: AVAudioPlayer) {
			if playSound.playing {
				playSound.pause()
				playSound.currentTime = 0
			}
			playSound.volume = volume * 0.01
			playSound.play()
		}
		
		if let playSound1 = audioDict[URL.path!] {
			playAud(playSound1)
			return true
		}
		guard URL.checkResourceIsReachableAndReturnError(nil) else {
			return false
		}
		
		guard let playSound = try? AVAudioPlayer(contentsOfURL: URL) else {
			return false
		}
		audioDict[URL.path!] = playSound
		playAud(playSound)
		return true
	}
	
	@objc(putMainMessage:text:) func putMainMessage(attribute attr: Int32, text: UnsafePointer<CChar>) {
		prepareAttributes()
		style.alignment = .Left
		
		if text == nil {
			return
		}
		
		guard let textStr = String(CString: text, encoding: NH3DTEXTENCODING) else {
			NSBeep()
			return
		}
		
		let textNSStr = textStr as NSString
		
		if !SOUND_MUTE {
			for msgEffect in effectArray {
				if textNSStr.isLike(msgEffect.message) {
					switch msgEffect.type {
					case 1: // hit enemy attack to player
						glView.isShocked = true
						
					case 2: // hit player attack to enemy
						glView.enemyPosition = lastAttackDirection
						
					default:
						break;
					}
				}
			}
		}
		
		switch attr {
		case ATR_NONE:
			break;
			
		case ATR_ULINE:
			darkShadowStrAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
			
		case ATR_BOLD:
			darkShadowStrAttributes[NSFontAttributeName] = NSFont(name:NH3DBOLDFONT, size: NH3DBOLDFONTSIZE)

		case ATR_BLINK, ATR_INVERSE:
			darkShadowStrAttributes[NSForegroundColorAttributeName] = NSColor.alternateSelectedControlTextColor()
			darkShadowStrAttributes[NSBackgroundColorAttributeName] = NSColor.alternateSelectedControlColor()

		default:
			break
		}
		
		let putString = NSMutableAttributedString(string: textStr + "\n", attributes: darkShadowStrAttributes)
		
		if msgArray.count < Int(iflags.msg_history) {
			msgArray.append(putString.length)
		} else {
			let txtRange = NSRange(location: 0, length: msgArray.removeFirst())
			messageWindow.textStorage?.deleteCharactersInRange(txtRange)
			msgArray.append(putString.length)
		}
		
		messageWindow.textStorage?.appendAttributedString(putString)
		messageWindow.scrollToEndOfDocument(self)
	}
	
	/// This is a bit of a misnomer, as it doesn't wipe the text, just greys it out.
	func clearMainMessage() {
		messageWindow.textStorage?.addAttribute(NSForegroundColorAttributeName,
			value: NSColor(calibratedWhite: 0.4, alpha: 0.7),
			range: NSRange(location: 0, length: messageWindow.textStorage!.length))
	}

	func showInputPanel(messageStr: UnsafePointer<CChar>, line: UnsafeMutablePointer<CChar>) -> Int32 {
		guard let questionStr = String(CString: messageStr, encoding: NH3DTEXTENCODING) else {
			return -1
		}
		var result = 0;

		prepareAttributes()
		style.alignment = .Center

		let putString = NSAttributedString(string: questionStr,
			attributes: lightShadowStrAttributes)
		
		questionTextField.attributedStringValue = putString
		
		window.beginSheet(inputPanel) { (returnCode) -> Void in
			//do nothing?
		}
		
		result = NSApp.runModalForWindow(inputPanel)
		
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
		
		if inputTextField.stringValue.lengthOfBytesUsingEncoding(NH3DTEXTENCODING) > Int(BUFSZ) {
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("There is too much number of the letters.", comment: "")
			alert.informativeText = " "
			alert.runModal()
			
			questionTextField.stringValue = ""
			inputTextField.stringValue = ""
			return -1
		}
		
		guard let inputData = inputTextField.stringValue.dataUsingEncoding(NH3DTEXTENCODING, allowLossyConversion:true),
			str = String(data: inputData, encoding: NH3DTEXTENCODING),
			cStr = str.cStringUsingEncoding(NH3DTEXTENCODING) else {
				questionTextField.stringValue = ""
				inputTextField.stringValue = ""
				return -1
		}
		
		strcpy(line, cStr)
		
		questionTextField.stringValue = ""
		inputTextField.stringValue = ""
		
		return 0
	}
	
	@IBAction func closeInputPanel(sender: NSButton?) {
		if sender?.tag != 0 {
			NSApp.stopModalWithCode(DIALOG_CANCEL)
		} else {
			NSApp.stopModalWithCode(DIALOG_OK)
		}
	}
	
	func showOutRip(ripString: UnsafePointer<CChar>) {
		let conv = String(CString: ripString, encoding: NH3DTEXTENCODING) ?? "You died.\n\nNothing eventful happened, though."
		showOutRip(conv)
	}
	
	@objc(showOutRipString:) func showOutRip(ripString: String) {
		ripFlag = true;
		
		prepareAttributes()
		style.alignment = .Center
		
		lightShadowStrAttributes[NSParagraphStyleAttributeName] = style
		lightShadowStrAttributes[NSFontAttributeName] = NSFont(name: "Optima Bold", size: 11)
		
		deathDescription.attributedStringValue = NSAttributedString(string: ripString,
			attributes: lightShadowStrAttributes)
		
		ripPanel.alphaValue = 0
		ripPanel.orderFront(self)
		// window fade out/in
		NSAnimationContext.runAnimationGroup({ (ctx) -> Void in
			ctx.duration = 0.6
			self.window.animator().alphaValue = 0
			self.ripPanel.animator().alphaValue = 1
			}, completionHandler: {
				self.ripPanel.flushWindow()
			}
		)
	}
	
	func putLogMessage(rawText: String, bold: Bool) {
		#if DEBUG
			NSLog(" %@", rawText)
		#endif
		prepareAttributes()
		style.alignment = .Left
		
		lightShadowStrAttributes[NSFontAttributeName] = NSFont(name: bold ? "Courier Bold" : "Courier", size: 12)
		
		let putStr = NSAttributedString(string: rawText + "\n", attributes: lightShadowStrAttributes)
		
		rawPrintWindow.textStorage?.appendAttributedString(putStr)
		#if DEBUG
			NSLog("%@", rawText);
		#endif
	}
	
	func showLogPanel() -> NSApplicationTerminateReply {
		var ripOrMainWindow: NSWindow
		
		rawPrintPanel.alphaValue = 0
		rawPrintPanel.makeKeyAndOrderFront(self)
		// window fade out/in
		
		if ripFlag {
			ripOrMainWindow = ripPanel
			NSApp.runModalForWindow(ripPanel)
		} else {
			ripOrMainWindow = window
		}
		
		NSAnimationContext.runAnimationGroup({ (ctx) -> Void in
			ctx.duration = 0.55
			ripOrMainWindow.animator().alphaValue = 0
			self.rawPrintPanel.animator().alphaValue = 1
			}, completionHandler: {
				NSApp.runModalForWindow(self.rawPrintPanel)
				self.rawPrintPanel.orderOut(self)
				clearlocks();
				NSApp.replyToApplicationShouldTerminate(true)
		})
		
		return .TerminateLater
	}
}
