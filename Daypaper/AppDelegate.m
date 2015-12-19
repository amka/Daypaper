//
//  AppDelegate.m
//  Daypaper
//
//  Created by Andrey M on 17.03.15.
//  Copyright (c) 2015 Andrey M. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+BetweenTags.h"
#import <AFHTTPRequestOperation.h>
#import <NSBundle+LoginItem.h>


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
//    self.statusItem.title = @"Daypaper";
    self.statusItem.image = [NSImage imageNamed:@"StatusIcon"];
    self.statusItem.alternateImage = [NSImage imageNamed:@"StatusIconInv"];
    self.statusItem.highlightMode = YES;
    self.statusItem.menu = self.statusMenu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [self deleteWpTimer];
}

- (void)awakeFromNib {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DownloadOnly"] != 1) {
        [self initWpTimer];
    }
    
    self.toggleLoginItem.state = [[NSBundle mainBundle] isLoginItemEnabled] ? NSOnState : NSOffState;
    self.toggleDownloadOnly.state = [[NSUserDefaults standardUserDefaults] integerForKey:@"DownloadOnly"];
//    [self downloadWallpaper];
    
    self.wlprTitle = @"…";
    self.wlprDescription = @"…";
    self.wlprPreviewURL = @"https://yandex.ru/images/today?size=480x480";
    [self getWallpaperInfo];
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
        
        [self getWallpaperInfo];
        // If it's not then download new one
        [self downloadWallpaper];
    } else {
        NSLog(@"Wallpaper already exists at %@", wpPath);
    }
}

- (void)deleteWpTimer {
    // Destroing wpTimer
    if (wpTimer) {
        [wpTimer invalidate];
        wpTimer = nil;
    }
}

// Download from http://yandex.ru/images/today?size=widthxheight
- (void)downloadWallpaper {
    
    self.revealInFinderItem.enabled = NO;
    
    NSRect frame = [[NSScreen mainScreen] frame];
    
    NSURL *downloadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://yandex.ru/images/today?size=%dx%d", (int)frame.size.width, (int)frame.size.height]];
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
        NSString *errorString = [NSString stringWithFormat:@"%@: %@",
                                 NSLocalizedString(@"Can not download wallpaper", nil),
                                 error.localizedDescription];
        [self sendUserNotification:errorString];
        NSLog(@"ERROR: %@", errorString);
    }];
    
    [operation start];
}

//
- (void)setWallpaper:(NSString *)imagePath {
    NSURL *imageUrl = [NSURL fileURLWithPath: imagePath];
    NSError *error = nil;
    if(![[NSWorkspace sharedWorkspace] setDesktopImageURL:imageUrl forScreen:[NSScreen mainScreen] options:@{} error:&error]) {
        NSString *errorString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Error set Wallpaper", "error setWallpaper"), error.description];
        [self sendUserNotification:errorString];
        NSLog(@"%@", errorString);
        return;
    }
    
    [self sendUserNotification:NSLocalizedString(@"Wallpaper successfully changed", @"wallpaper changed")];
}

//
- (void)revealInFinder:(NSString *)imagePath {
    NSURL *fileURL = [NSURL fileURLWithPath:imagePath];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

- (IBAction)revealInFinderClicked:(id)sender {
    [self revealInFinder:[self makeWpFilepath]];
}

// Create full path with current date as filename
- (NSString *)makeWpFilepath {
    NSString *fullPath;
    
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *filename = [NSString stringWithFormat:@"%@-%dx%d.jpg", [dateFormatter stringFromDate:[NSDate date]], (int)screenFrame.size.width, (int)screenFrame.size.height];
    
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

// User notification 'bout smth
- (void)sendUserNotification:(NSString *)message {
    
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = NSLocalizedString(@"Fresh Look!", @"fresh look");
    notification.informativeText = message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (IBAction)toggleLoginItem:(id)sender {
    NSBundle *mainBundle = [NSBundle mainBundle];
    if ([mainBundle isLoginItemEnabled]) {
        [mainBundle disableLoginItem];
    } else {
        [mainBundle enableLoginItem];
    }
    
    self.toggleLoginItem.state = [mainBundle isLoginItemEnabled] ? NSOnState : NSOffState;
}

//- (IBAction)showPreview:(NSMenuItem *)sender {
//    NSLog(@"Clicked");
//    [self.previewPopover showRelativeToRect:[[sender view] frame] ofView:[sender view] preferredEdge:NSMinXEdge];
//}

- (void)toggleDownloadOnly:(id)sender {
    if (self.toggleDownloadOnly.state == NSOnState) {
        [self initWpTimer];
    } else {
        [self deleteWpTimer];
    }
    
    self.toggleDownloadOnly.state = !self.toggleDownloadOnly.state;
    [[NSUserDefaults standardUserDefaults] setInteger:self.toggleDownloadOnly.state forKey:@"DownloadOnly"];
}


- (void)getWallpaperInfo {
    
    NSURL *downloadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://yandex.ru/images/"]];
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:downloadUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *title = [self extractWallpaperTitleFrom:responseHTML];
        NSString *description = [self extractWallpaperDescriptionFrom:responseHTML];
        
        NSLog(@"Got image: %@. %@", title, description);
        
        self.wlprTitle= title;
        self.wlprDescription = description;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [operation start];
}

- (NSString *)extractWallpaperTitleFrom:(NSString *)html {
    NSString *title = nil;
    title = [html stringBetweenString:@"<span class=\"b-501px__name\">" andString:@"</span>"];
    if (!title) {
        title = [html stringBetweenString:@"<span class=\"b-500px__name\">" andString:@"</span>"];
    }
    return title;
}

- (NSString *)extractWallpaperDescriptionFrom:(NSString *)html {
    NSString *description = nil;
    description = [html stringBetweenString:@"<p class=\"b-501px__description\">" andString:@"</p>"];
    if (!description) {
        description = [html stringBetweenString:@"<p class=\"b-500px__description\">" andString:@"</p>"];
    }
    return description;
}

 

@end
