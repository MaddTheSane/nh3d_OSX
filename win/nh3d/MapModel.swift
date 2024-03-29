//
//  MapModel.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/8/15.
//
//

import Cocoa

@objcMembers class MapModel: NSObject {
	@IBOutlet weak var asciiMapView: NH3DMapView!
	@IBOutlet weak var dungeonNameField: NSTextField!
	@IBOutlet weak var enemyIndicator: NSLevelIndicator!
	@IBOutlet weak var glMapView: NH3DOpenGLView!
	private var kvoo = [NSKeyValueObservation]()
	
	dynamic var playerDirection: NH3DPlayerDirection = .forward {
		willSet {
			if newValue.rawValue >= 0 && newValue.rawValue <= 3 {
				
				switch (playerDirection.rawValue - newValue.rawValue) {
				case -3, 1:
					glMapView.setCamera(head: glMapView.cameraHead + 90, pitch: 0, roll: 0)
					
				case  2, -2:
					glMapView.setCamera(head: glMapView.cameraHead - 180, pitch: 0, roll: 0)
					
				case  3, -1:
					glMapView.setCamera(head: glMapView.cameraHead - 90, pitch: 0, roll: 0)
					
				default:
					break
				}
			}
		}
		
		didSet {
			asciiMapView.needClear = true
			updateAllMaps()
		}
	}
	
	private(set) var dungeonNameString = NSAttributedString()
	private var strAttributes: [NSAttributedString.Key: Any] = {
		var toRet = [NSAttributedString.Key: Any]()
		toRet.reserveCapacity(4)
		return toRet
	}()
	
	private var indicatorIsActive = false
	
	var enemyWarnBase: Int32 {
		get {
			return enemyWarnBaseInternal
		}
		set {
			if indicatorIsActive {
				stopIndicator()
				enemyWarnBaseInternal = (newValue > 90) ? 90 : newValue
				startIndicator()
			} else {
				enemyWarnBaseInternal = (newValue > 90) ? 90 : newValue
			}
		}
	}
	private var enemyWarnBaseInternal: Int32 = 0
	private(set) final var loadingStatus = 0
	private var indicatorTimer: Timer?
	
	private(set) final var cursX: Int32 = 0
	private(set) final var cursY: Int32 = 0
	final var mapArray = [[NH3DMapItem?]](repeating: [NH3DMapItem?](repeating: nil, count: Int(MAPSIZE_ROW)), count: Int(MAPSIZE_COLUMN))
	
	private var lock = NSRecursiveLock()
	
	override init() {
		for x in 0 ..< MAPSIZE_COLUMN {
			for y in 0 ..< MAPSIZE_ROW {
				mapArray[Int(x)][Int(y)] = NH3DMapItem(parameter: 0x20, glyph: Int32(S_stone.rawValue) + NetHackGlyphCMapOffset, color: 0, posX: x, posY: y, special: 0, bgGlyph: NetHackGlyphNoGlyph)
			}
		}
		
		super.init()
		enemyWarnBase = 10
	}
	
	final override func awakeFromNib() {
		super.awakeFromNib()
		prepareAttributes()
		let updateDungeon = {
			self.prepareAttributes()
			let dns = NSAttributedString(string: self.dungeonNameString.string, attributes: self.strAttributes)
			self.dungeonNameString = dns
			self.dungeonNameField.attributedStringValue = dns
		}
		var toOb = UserDefaults.standard.observe(\.windowFontName) { (defaults, cng) in
			updateDungeon()
		}
		kvoo.append(toOb)
		toOb = UserDefaults.standard.observe(\.windowFontSize) { (defaults, cng) in
			updateDungeon()
		}
		kvoo.append(toOb)
	}
	
	@IBAction func toggleIndicator(_ sender: AnyObject?) {
		if indicatorIsActive {
			stopIndicator()
			enemyIndicator.integerValue = 0
		} else {
			startIndicator()
		}
	}
	
	private func prepareAttributes() {
		let shadow = NSShadow()
		shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.7)
		shadow.shadowOffset = NSSize(width: 2, height: -2)
		shadow.shadowBlurRadius = 1.0
		
		let style = NSMutableParagraphStyle()
		style.alignment = .center
		
		strAttributes.removeAll(keepingCapacity: true)
		strAttributes[.font] = NSFont(name: NH3DWINDOWFONT, size: NH3DWINDOWFONTSIZE + 4.0)
		strAttributes[.shadow] = shadow.copy()
		strAttributes[.paragraphStyle] = style.copy()
	}
	
	final func stopIndicator() {
		indicatorTimer?.invalidate()
		indicatorTimer = nil
		indicatorIsActive = false
	}
	
	final func startIndicator() {
		indicatorIsActive = true
		indicatorTimer = Timer.scheduledTimer(timeInterval: 1.0 / 20, target: self, selector: #selector(MapModel.updateEnemyIndicator(_:)), userInfo: nil, repeats: true)
		RunLoop.current.add(indicatorTimer!, forMode: RunLoop.Mode.default)
	}
	
	@objc private func updateEnemyIndicator(_ timer: Timer) {
		var value = enemyWarnBase + (1...3).randomElement()!
		let alert = NSSound(named: "Hero")!
		
		if enemyIndicator.intValue == value {
			value = enemyWarnBase - (1...3).randomElement()!
		}
		enemyIndicator.intValue = value
		
		if value >= 60 && !alert.isPlaying && !SOUND_MUTE {
			alert.play()
		}
	}
	
	@objc(setMapModelGlyph:xPos:yPos:bgGlyph:)
	final func setMapModel(glyph glf: Int32, x: Int32, y: Int32, bgGlyph: Int32) {
		if mapArray[Int(x+MAP_MARGIN)][Int(y+MAP_MARGIN)]?.glyph == glf && mapArray[Int(x+MAP_MARGIN)][Int(y+MAP_MARGIN)]?.bgGlyph == bgGlyph {
			return
		} else if x+MAP_MARGIN > MAPSIZE_COLUMN || y+MAP_MARGIN > MAPSIZE_ROW {
			panic("Illegal map size!")
		} else {
			var ch: Int32 = 0
			var color: Int32 = 0
			var special: UInt32 = 0
			
			// map glyph to character and color
			
			mapglyph(glf, &ch, &color, &special, x, y, 0)
			// add view Margin
			let x2 = x + MAP_MARGIN
			let y2 = y + MAP_MARGIN
			
			lock.withLock {
				//  make map
				mapArray[Int(x2)][Int(y2)] = NH3DMapItem(parameter: Int8(truncatingIfNeeded: ch), glyph: glf, color: color, posX: x2, posY: y2, special: Int32(bitPattern: special), bgGlyph: bgGlyph)
			}
			
			if (x2-MAP_MARGIN) == Int32(u.ux) && (y2-MAP_MARGIN) == Int32(u.uy) {
				mapArray[Int(x2)][Int(y2)]?.isPlayer = true
				
				//set player pos for asciiview, openGLView
				asciiMapView.setCenter(x: x2, y: y2, depth: Int32(depth(&u.uz)))
				glMapView.setCenter(x: x2, z: y2, depth: Int32(depth(&u.uz)))
			}
			
			if TRADITIONAL_MAP {
				asciiMapView.drawTraditionalMapAt(x: x2, y: y2)
			}
		}
	}
	
	@objc(setPosCursorAtX:atY:)
	final func setPosCursor(x: Int32, y: Int32) {
		if (cursX == x && cursY == y) {
			mapArray[Int(x+MAP_MARGIN)][Int(y+MAP_MARGIN)]?.hasCursor = true
			return
		} else {
			mapArray[Int(cursX+MAP_MARGIN)][Int(cursY+MAP_MARGIN)]?.hasCursor = false
			
			cursX = x
			cursY = y
			
			// center the map on the cursor, not the player.
			asciiMapView.setCenter(x: x + MAP_MARGIN, y: y + MAP_MARGIN, depth: Int32(depth(&u.uz)))
			
			mapArray[Int(x + MAP_MARGIN)][Int(y + MAP_MARGIN)]?.hasCursor = true
			asciiMapView.needClear = true
			updateAllMaps()
		}
	}
	
	@objc(mapArrayAtX:atY:)
	final func mapArray(x: Int32, y: Int32) -> NH3DMapItem? {
		if (x < MAPSIZE_COLUMN) && (y < MAPSIZE_ROW) && (x >= 0) && (y >= 0) && (mapArray[Int(x)][Int(y)] != nil) {
			return mapArray[Int(x)][Int(y)]
		} else {
			//NSLog(@"MapLoadError atX:%d,Y:%d",x,y);
			return nil
		}
	}
	
	@IBAction final func turnPlayerRight(_ sender: AnyObject?) {
		if playerDirection != .left {
			// don't this instance value direct Increment/decrement
			// playerDirection binded by Cocoa binding.
			self.playerDirection = NH3DPlayerDirection(rawValue: playerDirection.rawValue + 1)!
		} else {
			self.playerDirection = .forward
		}
	}
	
	@IBAction final func turnPlayerLeft(_ sender: AnyObject?) {
		if playerDirection != .forward {
			// don't this instance value direct Increment/decrement
			// playerDirection binded by Cocoa binding.
			self.playerDirection = NH3DPlayerDirection(rawValue: playerDirection.rawValue - 1)!
		} else {
			self.playerDirection = .left
		}
	}
	
	final func clearMapModel() {
		lock.withLock {
			for x in 0 ..< MAPSIZE_COLUMN {
				for y in 0 ..< MAPSIZE_ROW {
					mapArray[Int(x)][Int(y)] = NH3DMapItem(parameter: 0x20, glyph: Int32(S_stone.rawValue) + NetHackGlyphCMapOffset, color: 0, posX: x, posY: y, special: 0, bgGlyph: NetHackGlyphNoGlyph)
				}
			}
		}
	}
	
	final func updateAllMaps() {
		asciiMapView.updateMap()
		glMapView.updateMap()
	}
	
	final func reloadAllMaps() {
		asciiMapView.reloadMap()
		glMapView.updateMap()
	}
	
	final func setDungeonName(_ str: String) {
		dungeonNameString = NSAttributedString(string: str, attributes: strAttributes)
		dungeonNameField.attributedStringValue = dungeonNameString
	}
	
	final func clearTileCaches() {
		lock.withLock {
			for x in 0 ..< Int(MAPSIZE_COLUMN) {
				for y in 0 ..< Int(MAPSIZE_ROW) {
					mapArray[x][y]?.clearTileCache()
				}
			}
		}
	}
}
