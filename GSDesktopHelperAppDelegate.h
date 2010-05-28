//
//  GSDesktopHelperAppDelegate.h
//  GSDesktopHelper
//
//  Created by Terin Stock on 5/22/10.
//  Copyright 2010 Three Strange Days Development. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//@interface GSDesktopHelperAppDelegate : NSObject <NSApplicationDelegate> {
@interface GSDesktopHelperAppDelegate : NSObject {
	NSStatusItem *statusItem;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *mi_showGrooveshark;
	IBOutlet NSMenuItem *mi_startAtLogin;
	IBOutlet NSMenuItem *mi_mediaKeys;
	IBOutlet NSMenuItem *mi_globalKeys;
	IBOutlet NSWindow *mi_firstLaunch;
	BOOL hotKeyRegistered;
	BOOL loadAtLogin;
	BOOL firstLaunch;
	NSString *bundlePath;
}

- (IBAction)showGrooveshark:(id)sender;
- (IBAction)startAtLogin:(id)sender;
- (IBAction)mediaKeys:(id)sender;
- (IBAction)globalKeys:(id)sender;
- (void)registerHotKeys:(BOOL)registerKeys;

@end
