//
//  GSDesktopHelperAppDelegate.m
//  GSDesktopHelper
//
//  Created by Terin Stock on 5/22/10.
//  Copyright 2010 Three Strange Days Development. All rights reserved.
//

#import "GSDesktopHelperAppDelegate.h"
#import <Carbon/Carbon.h>

@implementation GSDesktopHelperAppDelegate


void printToAPIFile(NSString *withAction) {
	NSFileManager *fm = [NSFileManager defaultManager];	
	NSString *path = @"~/Library/Preferences/GroovesharkDesktop.7F9BF17D6D9CB2159C78A6A6AB076EA0B1E0497C.1/Local Store/shortcutAction.txt";
	path = [path stringByExpandingTildeInPath];
	NSError *error; 
	if ([fm fileExistsAtPath:[path stringByDeletingLastPathComponent]] == NO) {
		if (![fm createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Could not create directory: %@", [error localizedFailureReason]);
		};
	}
	BOOL fileExists = [fm fileExistsAtPath:path];
	if (!fileExists) {
		if (![withAction writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error]) {
			NSLog(@"Could not write to file: %@", [error localizedFailureReason]);
			return;
		}
	} else if ([fm isWritableFileAtPath:[path stringByDeletingLastPathComponent]]) {
		NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:path];
		[output seekToEndOfFile];
		[output writeData:[withAction dataUsingEncoding:NSUTF8StringEncoding]];
		[output closeFile];
	}
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
	EventHotKeyID hkCom;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
	int eventID = hkCom.id;
	switch (eventID) {
		case 1:
			printToAPIFile(@"previous\n");
			break;
		case 2:
			printToAPIFile(@"next\n");
			break;
		case 3:
			printToAPIFile(@"playpause\n");
			break;
		case 4:
			printToAPIFile(@"shuffle\n");
			break;
		case 5:
			printToAPIFile(@"favorite\n");
			break;
		case 6:
			printToAPIFile(@"showsongtoast\n");
			break;
		default:
			NSLog(@"%@", @"Key registered, no action defined");
			break;
	}
	return noErr;
}

+ (void)initialize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *file = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:file];
	[defaults registerDefaults:appDefaults];
}

- (BOOL)isSetForLogin:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	BOOL exists = NO;
	UInt32 seedValue;
	CFURLRef thePath;
	
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:path]) {
				exists = YES;
				break;
			}
		}
	}
//	CFRelease(thePath);
	CFRelease(loginItemsArray);
	return exists;
}

- (void)enableLoginItem:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	if (item) {
		CFRelease(item);
	}
}

- (void)disableLoginItem:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	UInt32 seedValue;
	CFURLRef thePath;
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:path]) {
				LSSharedFileListItemRemove(loginItems, itemRef);
			}
			CFRelease(thePath);
		}
	}
	CFRelease(loginItemsArray);
}

- (void)registerHotKeys:(BOOL)registerKeys {
	static EventHotKeyRef eventHotKeyRef[6];
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
	if (registerKeys == YES) {
		if (hotKeyRegistered == NO) {
			EventHotKeyID previousSong = {'gsur', 1};
			EventHotKeyID nextSong = {'gsur', 2};
			EventHotKeyID playPause = {'gsur', 3};
			EventHotKeyID toggleShuffle = {'gsur', 4};
			EventHotKeyID favoriteSong = {'gsur', 5};
			EventHotKeyID songToast = {'gsur', 6};
			
			//InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PreviousKey"] objectForKey:@"Code"] intValue], [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PreviousKey"] objectForKey:@"Modifier"] intValue], previousSong, GetApplicationEventTarget(), 0, &eventHotKeyRef[0]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"NextKey"] objectForKey:@"Code"] intValue], [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"NextKey"] objectForKey:@"Modifier"] intValue], nextSong, GetApplicationEventTarget(), 0, &eventHotKeyRef[1]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PlayPauseKey"] objectForKey:@"Code"] intValue], [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PlayPauseKey"] objectForKey:@"Modifier"] intValue], playPause, GetApplicationEventTarget(), 0, &eventHotKeyRef[2]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ShuffleKey"] objectForKey:@"Code"] intValue], [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ShuffleKey"] objectForKey:@"Modifier"] intValue], toggleShuffle, GetApplicationEventTarget(), 0, &eventHotKeyRef[3]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"FavoriteKey"] objectForKey:@"Code"] intValue], [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"FavoriteKey"] objectForKey:@"Modifier"] intValue], favoriteSong, GetApplicationEventTarget(), 0, &eventHotKeyRef[4]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SongToastKey"] objectForKey:@"Code"] intValue], [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SongToastKey"] objectForKey:@"Modifier"] intValue], songToast, GetApplicationEventTarget(), 0, &eventHotKeyRef[5]);
			hotKeyRegistered = YES;
			[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"EnableGlobalKeys"];
			[mi_globalKeys setState:NSOnState];
		}
	} else if (registerKeys == NO) {
		if (hotKeyRegistered == YES) {
			for (int i = 0; i < 8; i++) {
				UnregisterEventHotKey(eventHotKeyRef[i]);
			}
			[mi_globalKeys setState:NSOffState];
			[[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"EnableGlobalKeys"];
			hotKeyRegistered = NO;
		}
	}
}

- (void)registerMediaKeys:(BOOL)registerKeys {
	if (registerKeys == YES) {
		if (mediaKeyRegistered == NO) {
			mediaKeyRegistered = YES;
			[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"EnableMediaKeys"];
			[mi_mediaKeys setState:NSOnState];
		}
	} else if (registerKeys == NO) {
		if (mediaKeyRegistered == YES) {
			mediaKeyRegistered = NO;
			[[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"EnableMediaKeys"];
			[mi_mediaKeys setState:NSOffState];
		}
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	bundlePath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if ([self isSetForLogin:loginItems ForPath:bundlePath]) {
		loadAtLogin = YES;
		[mi_startAtLogin setState:NSOnState];
	}
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	NSImage *statusImage = [NSImage imageNamed:@"gs16.png"];
	[statusItem setImage:statusImage];
	[statusItem setHighlightMode:YES];
	
	[statusItem setMenu:statusMenu];
	hotKeyRegistered = NO;
	[self registerHotKeys:[[NSUserDefaults standardUserDefaults] boolForKey:@"EnableGlobalKeys"]];
	[self registerMediaKeys:[[NSUserDefaults standardUserDefaults] boolForKey:@"EnableMediaKeys"]];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
		[mi_firstLaunch makeKeyAndOrderFront:self];
		[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"HasLaunchedOnce"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction)showGrooveshark:(id)sender {
	NSTask *gsdesktop = [[NSTask alloc] init];
	[gsdesktop setLaunchPath:@"/usr/bin/open"];
	[gsdesktop setArguments:[NSArray arrayWithObjects:@"-b",@"GroovesharkDesktop.7F9BF17D6D9CB2159C78A6A6AB076EA0B1E0497C.1", nil]];
	[gsdesktop launch];
	[gsdesktop release];
}

- (IBAction)startAtLogin:(id)sender {
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		if ([sender state] == NSOnState) {
			[self disableLoginItem:loginItems ForPath:bundlePath];
			[sender setState:NSOffState];
		} else {
			[self enableLoginItem:loginItems ForPath:bundlePath];
			[sender setState:NSOnState];
		}
	}
	CFRelease(loginItems);
}

- (IBAction)mediaKeys:(id)sender {
	if ([mi_mediaKeys state] == NSOffState) {
		[self registerMediaKeys:YES];
	} else {
		[self registerMediaKeys:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] synchronize]) {
	}
}

- (IBAction)globalKeys:(id)sender {
	if ([mi_globalKeys state] == NSOffState) {
		[self registerHotKeys:YES];
	} else {
		[self registerHotKeys:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] synchronize]) {
	}
}

- (IBAction)appleRemote:(id)sender {
	//Not Yet Created
	//But probably simple to support.
	//TODO: Terin Stock
}

- (void)printToAPIFile:(NSString *)withAction {
	printToAPIFile(withAction);
}

- (IBAction)openLink:(id)sender {
	NSURL *moreInfoURL = [[NSURL alloc] initWithString:@"http://threestrangedays.net/gsdesktophelper"];
	[[NSWorkspace sharedWorkspace] openURL:[moreInfoURL absoluteURL]];
	[moreInfoURL release];
}

@end
