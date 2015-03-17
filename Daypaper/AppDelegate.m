//
//  AppDelegate.m
//  Daypaper
//
//  Created by Andrey M on 17.03.15.
//  Copyright (c) 2015 Andrey M. All rights reserved.
//

#import "AppDelegate.h"
#import <AFHTTPRequestOperation.h>


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
    
    // Destroing wpTimer
    if (wpTimer) {
        [wpTimer invalidate];
        wpTimer = nil;
    }
}

- (void)awakeFromNib {
    [self initWpTimer];
//    [self downloadWallpaper];
}

- (void)initWpTimer {
    if(!wpTimer) {
        wpTimer = [NSTimer scheduledTimerWithTimeInterval:3600
                                                   target:self
                                                 selector:@selector(wpTimerFire)
                                                 userInfo:nil
                                                  repeats:YES];
        
        NSLog(@"Timer initialized");
        [wpTimer fire];
    };
}

// Fires by wpTimer
- (void)wpTimerFire {
    
    // Check if wp already downloaded
    NSString *wpPath = [self makeWpFilepath];
    if (![self isWpExists:wpPath]) {
        
        // If it's not then download new one
        [self downloadWallpaper];
    } else {
        NSLog(@"Wallpaper already exists at %@", wpPath);
    }
}

// Download from http://yandex.ru/images/today?size=widthxheight
- (void)downloadWallpaper {
    
    self.revealInFinderItem.enabled = NO;
    
    NSRect frame = [[NSScreen mainScreen] frame];
    
    NSURL *downloadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://yandex.ru/images/today?%dx%d", (int)frame.size.width, (int)frame.size.height]];
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:downloadUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];

    NSString *fullPath = [self makeDownloadPath];
    
    NSLog(@"Begin download to %@", fullPath);
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %lu, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            NSLog(@"SUCCESS: %lld", fileSize);
//            [[_downloadFile titleLabel] setText:[NSString stringWithFormat:@"%lld", fileSize]];
            
        }
        
        self.revealInFinderItem.enabled = YES;
        
        NSLog(@"Setting wallpaper with %@", fullPath);
        [self setWallpaper:fullPath];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error.description);
    }];
    
    [operation start];
}

//
- (void)setWallpaper:(NSString *)imagePath {
    NSURL *imageUrl = [NSURL fileURLWithPath: imagePath];
    NSError *error = nil;
    if(![[NSWorkspace sharedWorkspace] setDesktopImageURL:imageUrl forScreen:[NSScreen mainScreen] options:@{} error:&error]) {
        NSLog(@"Error setWallpaper: %@", error.description);
    }
}

//
- (void)revealInFinder:(NSString *)imagePath {
    [[NSWorkspace sharedWorkspace] openFile:imagePath withApplication:@"Finder"];
}

- (void)revealInFinderClicked:(id)sender {
    [self revealInFinder:[self makeWpFilepath]];
}

// Create full path with current date as filename
- (NSString *)makeWpFilepath {
    NSString *fullPath;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    NSString *filename = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:[NSDate date]]];
    
    NSString *picturesPath = [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadDirectory = [picturesPath stringByAppendingPathComponent:@"Daypaper"];
    
    fullPath = [downloadDirectory stringByAppendingPathComponent:filename];
    return fullPath;
}

- (BOOL)isWpExists:(NSString *)filepath {
    return [[NSFileManager new] fileExistsAtPath:filepath];
}

// Create download path if it's not exist
- (NSString *)makeDownloadPath {
    
    NSString *wpPath = [self makeWpFilepath];
    
    NSFileManager *fileManager = [NSFileManager new];
    if (![fileManager fileExistsAtPath:[wpPath stringByDeletingLastPathComponent]]) {
        [fileManager createDirectoryAtPath:[wpPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return  wpPath;
}

- (void)downloadClicked:(id)sender {
    [self downloadWallpaper];
}

@end
