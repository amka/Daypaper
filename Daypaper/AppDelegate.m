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
    // Insert code here to tear down your application
}

- (void)awakeFromNib {
    [self downloadWallpaper];
}

// Download from http://yandex.ru/images/today?size=widthxheight
- (void)downloadWallpaper {
    
    self.revealInFinderItem.enabled = NO;
    
    NSRect frame = [[NSScreen mainScreen] frame];
    
    NSURL *downloadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://yandex.ru/images/today?%dx%d", (int)frame.size.width, (int)frame.size.height]];
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:downloadUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];
    
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingString:[downloadUrl lastPathComponent]];
    
    NSLog(@"Begin download to %@", fullPath);
    image_path = [NSString stringWithString:fullPath];
    
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
            
            self.revealInFinderItem.enabled = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error.description);
    }];
    
    [operation start];
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

- (void)revealInFinderClicked:(id)sender {
    [self revealInFinder:image_path];
}

@end
