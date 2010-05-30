//
//  GSApplication.m
//  GSDesktopHelper
//
//  Created by Terin Stock on 5/29/10.
//  Copyright 2010 Three Strange Days Development. All rights reserved.
//

#import "GSApplication.h"


@implementation GSApplication

- (void)mediaKeyEvent:(int)key state:(BOOL)state {
	switch (key) {
		//Play pressed
		case NX_KEYTYPE_PLAY:
			if (state == NO) {
				[[self delegate] printToAPIFile:@"playpause\n"];
			}
			break;
		case NX_KEYTYPE_FAST:
			if (state == NO) {
				[[self delegate] printToAPIFile:@"next\n"];
			}
			break;
		case NX_KEYTYPE_REWIND:
			if (state == NO) {
				[[self delegate] printToAPIFile:@"previous\n"];
			}
			break;
	}
}

- (void)sendEvent:(NSEvent *)theEvent {
	if ([theEvent type] == NSSystemDefined && [theEvent subtype] == NX_SUBTYPE_AUX_CONTROL_BUTTONS
		&& [[NSUserDefaults standardUserDefaults] boolForKey:@"EnableMediaKeys"]) {
		int keyCode = (([theEvent data1] & 0xFFFF0000) >> 16);
		int keyFlags = ([theEvent data1] & 0x0000FFFF);
		int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
		
		[self mediaKeyEvent:keyCode state:keyState];
		return;
	}
	
	[super sendEvent:theEvent];
}

@end
