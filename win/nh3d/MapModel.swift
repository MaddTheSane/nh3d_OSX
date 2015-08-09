//
//  MapModel.swift
//  NetHack3D
//
//  Created by C.W. Betts on 8/8/15.
//
//

import Cocoa

class MapModel: NSObject {
	@IBOutlet weak var asciiMapView: NH3DMapView!
	@IBOutlet weak var dungeonNameField: NSTextField!
	@IBOutlet weak var enemyIndicator: NSLevelIndicator!
	@IBOutlet weak var glMapView: NH3DOpenGLView!
	
	dynamic var playerDirection: Int32 = 0 {
		willSet {
			if (newValue >= 0 && newValue <= 3) {
				
				switch (playerDirection - newValue) {
				case -3, 1:
					glMapView.setCameraHead(glMapView.cameraHead + 90, pitching: 0, rolling: 0)
					
				case  2, -2:
					glMapView.setCameraHead(glMapView.cameraHead - 180, pitching: 0, rolling: 0)
					
				case  3, -1:
					glMapView.setCameraHead(glMapView.cameraHead - 90, pitching: 0, rolling: 0)
					
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
	var strAttributes = [String: AnyObject]()
	var shadow = NSShadow()
	var style = NSMutableParagraphStyle()
	
	private var indicatorIsActive = false
	
	var enemyWarnBase: Int32 {
		get {
			return enemyWarnBaseInternal
		}
		set {
			if (indicatorIsActive) {
				stopIndicator()
				enemyWarnBaseInternal = (newValue > 90) ? 90 : newValue;
				startIndicator()
			} else {
				enemyWarnBaseInternal = (newValue > 90) ? 90 : newValue;
			}
		}
	}
	private var enemyWarnBaseInternal: Int32 = 0
	var loadingStatus = 0
	private var indicatorTimer: NSTimer?
	
	var cursX: Int32 = 0
	var cursY: Int32 = 0
	var mapArray = [[NH3DMapItem!]](count: Int(MAPSIZE_COLUMN), repeatedValue: [NH3DMapItem!](count: Int(MAPSIZE_ROW), repeatedValue: nil))

	private var lock = NSRecursiveLock()
	
	override init() {
		for x in 0 ..< MAPSIZE_COLUMN {
			for y in 0 ..< MAPSIZE_ROW {
				mapArray[Int(x)][Int(y)] = NH3DMapItem(parameter: 0x20, glyph: S_stone + GLYPH_CMAP_OFF, color: 0, posX: x, posY: y, special: 0)
			}
		}
		
		super.init()
		enemyWarnBase = 10
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		prepareAttributes()
	}
	
	@IBAction func toggleIndicator(sender: AnyObject?) {
		if indicatorIsActive {
			stopIndicator()
			enemyIndicator.intValue = 0
		} else {
			startIndicator()
		}
	}

	private func prepareAttributes() {
		shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.7)
		shadow.shadowOffset = NSMakeSize(2, -2) ;
		shadow.shadowBlurRadius = 1.0 ;
		
		style.alignment = NSCenterTextAlignment;
		
		strAttributes[NSFontAttributeName] = NSFont(name: NH3DWINDOWFONT, size: NH3DWINDOWFONTSIZE + 4.0)  
		strAttributes[NSShadowAttributeName] = shadow;
		strAttributes[NSParagraphStyleAttributeName] = style;
	}
	
	func stopIndicator() {
		indicatorTimer?.invalidate()
		indicatorTimer = nil;
		indicatorIsActive = false;
	}
	
	func startIndicator() {
		indicatorIsActive = true;
		indicatorTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 20, target: self, selector: "updateEnemyIndicator:", userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(indicatorTimer!, forMode: NSEventTrackingRunLoopMode)
	}
	
	@objc private func updateEnemyIndicator(timer: NSTimer) {
		var value = enemyWarnBase + (random() % 3 + 1);
		let alert = NSSound(named: "Hero")!
		
		if enemyIndicator.intValue == value {
			value = enemyWarnBase - (random() % 3 + 1);
			
		}
		enemyIndicator.intValue = value
		
		if (value >= 60 && !alert.playing ) {
			alert.play()
		}
	}
	
	func setMapModelGlyph(glf: Int32, xPos x: Int32, yPos y: Int32) {
		var ch: Int32 = 0
		var color: Int32 = 0
		var special: UInt32 = 0
		
		if ( mapArray[Int(x+MAP_MARGIN)][Int(y+MAP_MARGIN)].glyph == glf) {
			return
		} else if x+MAP_MARGIN > MAPSIZE_COLUMN || y+MAP_MARGIN > MAPSIZE_ROW {
			panic("Illegal map size!!");
		} else {
			// map glyph to character and color

			mapglyph(glf, &ch, &color, &special, x, y)
			// add view Margin
			let x2 = x + MAP_MARGIN
			let y2 = y + MAP_MARGIN
			
			lock.lock()
			
			//  make map
			mapArray[Int(x2)][Int(y2)] = NH3DMapItem(parameter: Int8(ch), glyph: glf, color: color, posX: x2, posY: y2, special: Int32(special))
			
			lock.unlock()
			
			if (x2-MAP_MARGIN) == Int32(u.ux) && (y2-MAP_MARGIN) == Int32(u.uy) {
				mapArray[Int(x2)][Int(y2)].player = true
				
				//set player pos for asciiview,openGlview
				asciiMapView.setCenterAtX(x2, y: y2, depth: Int32(depth(&u.uz)))
				glMapView.setCenterAtX(x2, z: y2, depth: Int32(depth(&u.uz)))
			}
			
			if TRADITIONAL_MAP {
				asciiMapView.drawTraditionalMapAtX(x2, atY: y2)
			}
		}
	}
	
	func setPosCursorAtX(x: Int32, atY y: Int32) {
		if (cursX == x && cursY == y) {
			mapArray[Int(x+MAP_MARGIN)][Int(y+MAP_MARGIN)].hasCursor = true
			return;
		} else {
			mapArray[Int(cursX+MAP_MARGIN)][Int(cursY+MAP_MARGIN)].hasCursor = false

			cursX = x
			cursY = y
			
			if Invisible {
				mapArray[Int(x + MAP_MARGIN)][Int(y + MAP_MARGIN)].player = true
				
				//set player pos for asciiview,openGlview
				asciiMapView.setCenterAtX(x + MAP_MARGIN, y: y + MAP_MARGIN, depth: Int32(depth(&u.uz)))
				glMapView.setCenterAtX(x + MAP_MARGIN, z: y + MAP_MARGIN, depth: Int32(depth(&u.uz)))
			}
			
			mapArray[Int(x + MAP_MARGIN)][Int(y + MAP_MARGIN)].hasCursor = true
			asciiMapView.needClear = true
			updateAllMaps()
		}
	}
	
	@objc(mapArrayAtX:atY:) func mapArray(x x: Int32, y: Int32) -> NH3DMapItem? {
		
		if (x < MAPSIZE_COLUMN) && (y < MAPSIZE_ROW) && (x >= 0) && (y >= 0) && (mapArray[Int(x)][Int(y)] != nil) {
			return  mapArray[Int(x)][Int(y)];
		} else {
			//NSLog(@"MapLoadError atX:%d,Y:%d",x,y);
			return nil;
		}
	}
	
	@IBAction func turnPlayerRight(sender: AnyObject?) {
		if playerDirection != 3 {
			// don't this instance value direct Increment/decrement
			// playerDirection binded by Cocoa binding.
			self.playerDirection = playerDirection + 1;
		} else {
			self.playerDirection = 0
		}
	}
	
	@IBAction func turnPlayerLeft(sender: AnyObject?) {
		if playerDirection != 0 {
			// don't this instance value direct Increment/decrement
			// playerDirection binded by Cocoa binding.
			self.playerDirection = playerDirection - 1;
		} else {
			self.playerDirection = 3;
		}
	}
	
	func clearMapModel() {
		lock.lock()
		for x in 0 ..< MAPSIZE_COLUMN {
			for y in 0 ..< MAPSIZE_ROW {
				mapArray[Int(x)][Int(y)] = NH3DMapItem(parameter: 0x20, glyph: S_stone + GLYPH_CMAP_OFF, color: 0, posX: x, posY: y, special: 0)
			}
		}
		lock.unlock()
	}

	func updateAllMaps() {
		asciiMapView.updateMap()
		glMapView.updateMap()
	}

	func reloadAllMaps() {
		asciiMapView.reloadMap()
		glMapView.updateMap()
	}

	func setDungeonName(str: String) {
		dungeonNameString = NSAttributedString(string: str, attributes: strAttributes)
		dungeonNameField.attributedStringValue = dungeonNameString
	}
}
