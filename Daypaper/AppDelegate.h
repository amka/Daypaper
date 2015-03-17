//
//  AppDelegate.h
//  Daypaper
//
//  Created by Andrey M on 17.03.15.
//  Copyright (c) 2015 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;

@property (weak) IBOutlet NSTextField *wpNameLabel;
@property (weak) IBOutlet NSProgressIndicator *wpSpinner;

-(void)downloadWallpaper;
-(void)setWallpaper:(NSString *)imagePath;
-(void)revealInFinder:(NSString *)imagePath;

@end

