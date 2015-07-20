/* NH3DMapModel */
//
//  NH3DMapModel.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/08/21.
//  Copyright 2005 Haruumi Yoshino.
//



#import "NH3DMapModel.h"

@implementation NH3DMapModel

- (id)init
{

	self = [super init];
	if (self != nil) {
		int x,y;
		
		lock = [ [NSRecursiveLock alloc] init ];
		shadow = [ [NSShadow alloc] init ];
		style = [ [NSMutableParagraphStyle alloc] init ];
		strAttributes = [ [NSMutableDictionary alloc] init ];
		
		[ self setEnemyWarnBase:10 ];
		indicatorIsActive = NO;
//		
		for (x=0;x<MAPSIZE_COLUMN;x++) {
			for (y=0;y<MAPSIZE_ROW;y++) {
				mapArray[x][y] = [ [NH3DMapItem alloc]initWithParameter:' '
																  glyph:S_stone + GLYPH_CMAP_OFF
																  color:0
																   posX:x
																   posY:y
																special:0 ];
			}
		}
	}
		return self;

}


- (void)dealloc
{
	int x,y;
	[ strAttributes release ];
	[ dungeonNameString release ];
	[ indicatorTimer release ];
	for (x=0;x<MAPSIZE_COLUMN;x++) {
		for (y=0;y<MAPSIZE_ROW;y++) {
			[ mapArray[x][y] release ];
		}
	}

	[ lock release ];
	[ shadow release ];
	
	[ super dealloc ];
}


- (void)awakeFromNib 
{
	[ self prepareAttributes ];
	
}


- (IBAction)toggleIndicator:(id)sender
{ 
	if (indicatorIsActive)
	{
		[ self stopIndicator ];
		[ _enemyIndicator setIntValue:0 ];
	} else {
		[ self startIndicator ];
	}
}

- (void)startIndicator
{
	indicatorIsActive = YES;
	indicatorTimer =
    [ [ NSTimer scheduledTimerWithTimeInterval:(1.0 / 20)
                                      target:self
                                    selector:@selector( updateEnemyIndicator)
                                    userInfo:nil
                                     repeats:YES ] retain ];
	 [ [NSRunLoop currentRunLoop] addTimer:indicatorTimer forMode:NSEventTrackingRunLoopMode ];

}


- (void)stopIndicator
{
	[ indicatorTimer invalidate ];
	[ indicatorTimer release ];
	indicatorTimer = nil;	 
	indicatorIsActive = NO;
}


- (int)playerDirection
{
	return playerDirection;
}

- (void)setPlayerDirection:(int)direction
{
	if (direction >= 0 && direction <= 3) {

		switch (playerDirection - direction) {
			case -3:
			case  1:
				[ _glMapView setCameraHead:[_glMapView cameraHead]+90.0 pitching:0.0 rolling:0.0 ];
				break;
			case  2:
			case -2:
				[ _glMapView setCameraHead:[_glMapView cameraHead]-180.0 pitching:0.0 rolling:0.0 ];
				break;
			case  3:
			case -1:
				[ _glMapView setCameraHead:[_glMapView cameraHead]-90.0 pitching:0.0 rolling:0.0 ];
				break;
		}

		playerDirection = direction;
	}

	[ _asciiMapView setNeedClear:YES ];
	[ self updateAllMaps ];
}




- (void)prepareAttributes
{

            [ shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] ];
            [ shadow setShadowOffset:NSMakeSize(2, -2) ];
            [ shadow setShadowBlurRadius:1.0 ];
			
			[ style setAlignment:NSCenterTextAlignment ];
	
			[ strAttributes setObject:
						[NSFont fontWithName:NH3DWINDOWFONT
										size: NH3DWINDOWFONTSIZE + 4.0]
							   forKey:NSFontAttributeName ];
			[ strAttributes setObject:shadow
							   forKey:NSShadowAttributeName ];
			[ strAttributes setObject:style
							   forKey:NSParagraphStyleAttributeName] ;

}


- (NSAttributedString *)dungeonNameString
{
	return dungeonNameString;
}


- (NSMutableDictionary *)strAttributes
{
	return strAttributes;
}


- (void)setDungeonNameString:(NSString *)aStr
{	
	[ aStr retain ];
	[ dungeonNameString release ];
	dungeonNameString = [ [NSAttributedString alloc] initWithString:aStr attributes:strAttributes ];
	[ aStr release ];
	[ _dungeonName setAttributedStringValue:dungeonNameString ];
}


- (int)enemyWarnBase
{
	return enemyWarnBase;
}

- (void)setEnemyWarnBase:(int)aValue
{
	if (indicatorIsActive) {
		[ self stopIndicator ];
		enemyWarnBase = (aValue > 90) ? 90 : aValue;
		[ self startIndicator ];
	} else 
		enemyWarnBase = (aValue > 90) ? 90 : aValue;		
}


- (void)updateEnemyIndicator
{
		int value = enemyWarnBase +(random() %3 + 1);
		NSSound *alert = [ NSSound soundNamed:@"Hero" ];

		if ([ _enemyIndicator intValue ] == value ) {
				value = enemyWarnBase -(random() %3 + 1);
		}

		[ _enemyIndicator setIntValue:value ];

		if (value >= 60 && ![ alert isPlaying ]) {
			[ alert play ];
		}
}


- (void)setMapModelGlyph:(int)glf xPos:(int)x yPos:(int)y
{
	int ch = 0;
    int	    color = 0;
    unsigned special = 0;
	
	//[_progressIndicator animate:nil];
	
	if ([ mapArray[x+MAP_MARGIN][y+MAP_MARGIN] glyph ] == glf) {
		return;
	} else if ( x+MAP_MARGIN > MAPSIZE_COLUMN || y+MAP_MARGIN > MAPSIZE_ROW) {
		panic("Illegal map size!!");
	} else {
    // map glyph to character and color
		mapglyph(glf, &ch, &color, &special, x, y);
	
	// add view Margin
		x = x+MAP_MARGIN;
		y = y+MAP_MARGIN;
	
		
		[ lock lock ];
	//  make map
		
		[ mapArray[x][y] release ];
		
		mapArray[x][y] = [ [NH3DMapItem alloc] initWithParameter:ch 
														   glyph:glf 
														   color:color 
															posX:x 
															posY:y 
														 special:special ];

		[ lock unlock ];
		
		if ( x-MAP_MARGIN == u.ux && y-MAP_MARGIN == u.uy ) {
			[ mapArray[x][y] setPlayer:YES ];
		
		//set player pos for asciiview,openGlview
			[ _asciiMapView setCenter:x:y:depth(&u.uz) ];
			[ _glMapView setCenter:x:y:depth(&u.uz) ];
		}
		
		if ( TRADITIONAL_MAP ) [ _asciiMapView drawTraditionalMapAtX:x atY:y ];
	}
}


- (int)cursX
{
	return cursX;
}

- (int)cursY
{
	return cursY;
}

- (void)setCursX:(int)x
{
	cursX = x;
}

- (void)setCursY:(int)y
{
	cursY = y;
}


- (void)setPosCursorAtX:(int)x atY:(int)y
{
	if (cursX == x && cursY == y) {
		[ mapArray[x+MAP_MARGIN][y+MAP_MARGIN] setHasCursor:YES ];
		return;
	} else {
		[ mapArray[cursX+MAP_MARGIN][cursY+MAP_MARGIN] setHasCursor:NO ];
		
		cursX = x;
		cursY = y;
		
		if (Invisible) {

			[ mapArray[x+MAP_MARGIN][y+MAP_MARGIN] setPlayer:YES ];

			//set player pos for asciiview,openGlview
			[ _asciiMapView setCenter:x+MAP_MARGIN :y+MAP_MARGIN:depth(&u.uz) ];
			[ _glMapView setCenter:x+MAP_MARGIN :y+MAP_MARGIN :depth(&u.uz) ];
		}
				
		[ mapArray[x+MAP_MARGIN][y+MAP_MARGIN] setHasCursor:YES ];

		[ _asciiMapView setNeedClear:YES ];
		[ self updateAllMaps ];
	}
}





- (NH3DMapItem *)mapArrayAtX:(int)x atY:(int)y
{

#ifdef DEBUG
	NSLog(@"want %d,%d",x,y);
#endif
	if ( x<MAPSIZE_COLUMN && y<MAPSIZE_ROW && x>=0 && y>=0 && mapArray[x][y] != nil ) {
		return  mapArray[x][y];
	} else {
		//NSLog(@"MapLoadError atX:%d,Y:%d",x,y);
		return nil;
	}
}

- (IBAction)turnPlayerRight:(id)sender
{
	if (playerDirection != 3) {
		// don't this instance value direct Increment/decrement
		// playerDirection binded by Cocoa binding.
		[ self setPlayerDirection:playerDirection+1 ];
	} else { 
		[ self setPlayerDirection:0 ];
	}
}


- (IBAction)turnPlayerLeft:(id)sender
{
	if (playerDirection) {
		// don't this instance value direct Increment/decrement
		// playerDirection binded by Cocoa binding.
		[ self setPlayerDirection:playerDirection-1 ];
	} else {
		[ self setPlayerDirection:3 ];
	}
}

- (void)updateAllMaps
{
	[ _asciiMapView updateMap ];
	[ _glMapView updateMap ];
}

- (void)reloadAllMaps
{
	[ _asciiMapView reloadMap ];
	[ _glMapView updateMap ];
}

- (void)clearMapModel
{ 
	int x,y;
	[ lock lock ];
	for ( x=0 ; x<MAPSIZE_COLUMN ; x++ ) {
		for ( y=0 ; y<MAPSIZE_ROW ; y++ ) {
	
			[ mapArray[x][y] release ];
		
			mapArray[x][y] = [ [NH3DMapItem alloc]initWithParameter:' '
															  glyph:S_stone + GLYPH_CMAP_OFF
															  color:0
															   posX:x
															   posY:y
															special:0 ];

		}
	}
	[ lock unlock ];
}

@end
