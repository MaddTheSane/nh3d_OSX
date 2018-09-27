//
//  SoundController.swift
//  NetHack3D
//
//  Created by C.W. Betts on 1/12/17.
//  Copyright © 2017 Haruumi Yoshino. All rights reserved.
//

import Foundation
import FDAudio

private func URLsPointingToTheSameFile(_ urlA: URL, _ urlB: URL) -> Bool {
	if urlA == urlB {
		return true
	}
	var dat1: (NSCopying & NSSecureCoding & NSObjectProtocol)? = nil
	var dat2: (NSCopying & NSSecureCoding & NSObjectProtocol)? = nil
	var bothAreValid = true
	var theSame = false
	do {
		let vals = try urlA.resourceValues(forKeys: [.fileResourceIdentifierKey])
		dat1 = vals.fileResourceIdentifier
		
		let vals2 = try urlB.resourceValues(forKeys: [.fileResourceIdentifierKey])
		dat2 = vals2.fileResourceIdentifier
	} catch _ {
		bothAreValid = false
	}
	if bothAreValid, let dat1 = dat1, let dat2 = dat2 {
		theSame = dat1.isEqual(dat2)
	}
	return theSame
}

final class SoundController: NSObject {
	private final class SoundObject {
		let audioFile = FDAudioFile(mixer: FDAudioMixer.shared)!
		var currentPriority = Priority.medium
		
		var isPlaying: Bool {
			return audioFile.isPlaying
		}
		
		var isFinished: Bool {
			return audioFile.isFinished || audioFile.file == nil
		}
		
		var volume: Float {
			get {
				return audioFile.volume * 100
			}
			set {
				audioFile.volume = newValue / 100
			}
		}
		
		@discardableResult
		func startFile(at url: URL) -> Bool {
			return audioFile.startFile(url, loop: false)
		}
		
		func pause() {
			audioFile.pause()
		}
		
		@discardableResult
		func restart() -> Bool {
			return audioFile.restart()
		}
		
		func resume() {
			audioFile.resume()
		}
		
		@discardableResult
		func stop() -> Bool {
			return audioFile.stop()
		}
		
		@discardableResult
		func play() -> Bool {
			return audioFile.play()
		}
	}
	
	@objc(NH3DSoundPriority) enum Priority: Int {
		case low = -1
		case medium = 0
		case high = 1
		case immediate = 2
	}
	
	@objc(sharedSoundController) static let shared = SoundController()
	
	private override init() {
		super.init()
		FDAudioMixer.shared?.start()
	}
	
	private var audioObjects: [SoundObject] = {
		var arrs = [SoundObject]()
		for _ in 0 ..< 8 {
			arrs.append(SoundObject())
		}
		
		return arrs
	}()
	
	@objc func stopAll() {
		for obj in audioObjects {
			obj.stop()
		}
	}
	
	private func findDoneObject() -> SoundObject? {
		for obj in audioObjects {
			if obj.isFinished {
				return obj
			}
		}
		
		return nil
	}
	
	private func findObject(withPriorityLowerThan newPrio: Priority) -> SoundObject? {
		for obj in audioObjects {
			if obj.currentPriority.rawValue < newPrio.rawValue {
				return obj
			}
		}
		
		return nil
	}
	
	private func findObject(withPriorityEqualTo newPrio: Priority) -> SoundObject? {
		for obj in audioObjects {
			// Just in case
			if obj.currentPriority.rawValue <= newPrio.rawValue {
				return obj
			}
		}
		
		return nil
	}
	
	private func findObject(pointingTo newPrio: URL) -> SoundObject? {
		for obj in audioObjects {
			if let bURL = obj.audioFile.file, URLsPointingToTheSameFile(newPrio, bURL) {
				return obj
			}
		}
		
		return nil
	}
	
	@objc(playAudioFileAtURL:volume:priority:)
	func playAudioFile(at url: URL, volume: Float = 100, priority: Priority = .medium) {
		var obj2: SoundObject? = nil
		
		//See if there's an audio object that points to the requested URL
		if let obj = findObject(pointingTo: url) {
			if obj.isPlaying {
				obj.pause()
			}
			obj.volume = volume
			obj.currentPriority = priority
			obj.restart()
			obj.play()
			return
		}
		
		if obj2 == nil {
			obj2 = findDoneObject()
		}
		
		if obj2 == nil {
			obj2 = findObject(withPriorityLowerThan: priority)
		}
		
		if obj2 == nil {
			obj2 = findObject(withPriorityEqualTo: priority)
		}
		
		guard let obj = obj2 else {
			return
		}
		
		obj.volume = volume
		obj.currentPriority = priority
		obj.startFile(at: url)
	}
}
