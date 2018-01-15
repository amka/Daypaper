//
//  AppDelegate.swift
//  Daypaper
//
//  Created by Maksimov Andrey Aleksandrovich on 1/15/18.
//  Copyright © 2018 Maksimov Andrey Aleksandrovich. All rights reserved.
//

import Cocoa

let BASE_URL: String = "https://yandex.com/images/";

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet var StatusMenu: NSMenu!
    @IBOutlet weak var photoLabel: NSMenuItem!
    
    var statusItem : NSStatusItem!
    var prefs : UserDefaults!
    var wpTimer : Timer!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initStatusMenu()
        loadUserDefaults()
        initDownloadFolder()
        initWpTimer()
    }
    
    func initStatusMenu() {
        // Init application
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        statusItem.menu = StatusMenu
        statusItem.image = NSImage.init(imageLiteralResourceName: "StatusIcon")
        statusItem.alternateImage = NSImage.init(imageLiteralResourceName: "StatusIconInv")
        statusItem.highlightMode = true
    }
    
    func loadUserDefaults() {
        prefs = NSUserDefaultsController.shared.defaults
    }
    
    func initWpTimer() {
        wpTimer = Timer.scheduledTimer(timeInterval: 10,
                                       target: self,
                                       selector: (#selector(checkWallpaper)),
                                       userInfo: nil,
                                       repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if (wpTimer != nil) {
            wpTimer.invalidate()
        }
    }
    
    @IBAction func downloadTodayClicked(_ sender: Any) {
        downloadImage()
    }
    
    func initDownloadFolder() {
        if (prefs.string(forKey: "download_folder") == nil)
        {
            print("Should create or select download folder")
            let notification = NSUserNotification.init()
            notification.title = "Daypaper"
            notification.informativeText = "Download folder not set"
            notification.actionButtonTitle = "Use Default"
            notification.otherButtonTitle = "Select"
            notification.hasActionButton = true
            notification.hasReplyButton = true
            notification.soundName = "Glass"
            notification.userInfo = ["action": "download_folder"]
            NSUserNotificationCenter.default.delegate = self
            NSUserNotificationCenter.default.deliver(notification)
            
        } else {
            FileManager.default.isWritableFile(atPath: prefs.string(forKey: "download_folder")!)
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
            case .replied:
                guard let res = notification.response else { return }
                print("User replied: \(res.string)")
            default:
                print("userInfo -> \(notification.userInfo!)")
                break;
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("userInfo -> \(notification.userInfo!)")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return prefs.bool(forKey: "showNotifications") != false
    }
    
    @objc func checkWallpaper() {
        print("Checking wallpaper…")
    }
    
    func downloadImage() {
       print("Begin download wallpaper…")
    }
    
    func applyWallpaper() {
        
    }
}

