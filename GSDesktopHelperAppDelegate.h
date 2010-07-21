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
	IBOutlet NSWindow *mi_preferenceWindow;
	BOOL hotKeyRegistered;
	BOOL mediaKeyRegistered;
	BOOL loadAtLogin;
	BOOL firstLaunch;
	NSString *bundlePath;
	CFMachPortRef eventTap;
}

- (IBAction)showGrooveshark:(id)sender;
- (IBAction)openPreferencesWindow:(id)sender;
- (IBAction)startAtLogin:(id)sender;
- (IBAction)mediaKeys:(id)sender;
- (IBAction)globalKeys:(id)sender;
- (IBAction)openLink:(id)sender;
- (void)registerHotKeys:(BOOL)registerKeys;
- (void)printToAPIFile:(NSString *)withAction;
- (CGEventRef) processEvent:(CGEventRef)event withType:(CGEventType)type;
- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent;

@end
