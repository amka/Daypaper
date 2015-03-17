//
//  AppDelegate.m
//  Daypaper
//
//  Created by Andrey M on 17.03.15.
//  Copyright (c) 2015 Andrey M. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
//    self.statusItem.title = @"Daypaper";
    self.statusItem.image = [NSImage imageNamed:@"MenuItemIcon"];
    self.statusItem.highlightMode = YES;
    self.statusItem.menu = self.statusMenu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)awakeFromNib {
    NSRect frame = [[NSScreen mainScreen] frame];
    NSLog(@"Resolution %dx%d", (int)frame.size.width, (int)frame.size.height);
}

// Download from http://yandex.ru/images/today?size=widthxheight
- (void)downloadWallpaper {
    
}

//
- (void)setWallpaper:(NSString *)imagePath {
    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:imageUrl forScreen:[NSScreen mainScreen] options:nil error:nil];
}

//
- (void)revealInFinder:(NSString *)imagePath {
    [[NSWorkspace sharedWorkspace] openFile:imagePath withApplication:@"Finder"];
}

@end
