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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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
