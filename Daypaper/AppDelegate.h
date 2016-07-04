//
//  AppDelegate.h
//  Daypaper
//
//  Created by Andrey M on 17.03.15.
//  Copyright (c) 2015 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <DevMateKit/DevMateKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    NSString *image_path;
    NSTimer *wpTimer;
}

@property NSString *wpTitle;
@property NSString *wpDescription;

@property (strong) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;

@property (weak) IBOutlet NSMenuItem *revealInFinderItem;
@property (weak) IBOutlet NSMenuItem *toggleDownloadOnly;
@property (weak) IBOutlet NSMenuItem *toggleLoginItem;
@property (weak) IBOutlet NSMenuItem *wallpaperTitle;
@property (weak) IBOutlet NSMenuItem *imageTitle;

- (void)downloadWallpaper;
- (void)setWallpaper:(NSString *)imagePath;
- (void)revealInFinder:(NSString *)imagePath;

- (IBAction)downloadClicked:(id)sender;
- (IBAction)revealInFinderClicked:(id)sender;
- (IBAction)toggleDownloadOnly:(id)sender;
- (IBAction)toggleLoginItem:(id)sender;
- (IBAction)viewOnYandex:(id)sender;


@end

