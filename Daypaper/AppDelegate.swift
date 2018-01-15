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
        // First of all we should define defaults values
        initDefaults()
        loadUserDefaults()
        
        // After that we may create UI and initialilze application
        initStatusMenu()
        initDownloadFolder()
        
        // Finally we should init timer
    }
    
    func initStatusMenu() {
        // Init application
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        statusItem.menu = StatusMenu
        statusItem.image = NSImage.init(imageLiteralResourceName: "StatusIcon")
        statusItem.alternateImage = NSImage.init(imageLiteralResourceName: "StatusIconInv")
        statusItem.highlightMode = true
    }
    
    func initDefaults() {
        var initialDefaults = [String:Any]()
        initialDefaults["check_interval"] = 3600.0
        initialDefaults["show_notifications"] = true
        initialDefaults["start_at_login"] = false
        initialDefaults["download_only"] = false
 
        NSUserDefaultsController.shared.defaults.register(defaults: initialDefaults)
    }
    
    func loadUserDefaults() {
        prefs = NSUserDefaultsController.shared.defaults
    }
    
    func initWpTimer() {
        wpTimer = Timer.scheduledTimer(timeInterval: prefs.double(forKey: "check_interval"),
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
            if (FileManager.default.isWritableFile(atPath: prefs.string(forKey: "download_folder")!)) {
                initWpTimer()
            } else {
                let notification = NSUserNotification.init()
                notification.title = "Daypaper"
                notification.informativeText = "Download folder are not writable"
                notification.actionButtonTitle = "Use Default"
                notification.otherButtonTitle = "Select another"
                notification.hasActionButton = true
                notification.hasReplyButton = true
                notification.soundName = "Glass"
                notification.userInfo = ["action": "download_folder"]
                NSUserNotificationCenter.default.delegate = self
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
            case .replied:
                guard let res = notification.response else { return }
                print("User replied: \(res.string)")
            default:
                print("didActivate userInfo -> \(notification.userInfo!)")
                break;
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("didDeliver userInfo -> \(notification.userInfo!)")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return prefs.bool(forKey: "show_notifications") != false
    }
    
    @objc func checkWallpaper() {
        print("Checking wallpaper…")
    }
    
    func downloadImage() {
        NSScreen.screens.forEach { (screen) in
            print("Begin download wallpaper for \(getScreenSize(screen: screen))")
            applyWallpaper(screen: screen)
        }
    }
    
    func applyWallpaper(screen: NSScreen) {
        print("Applying wallpaper to \(getScreenSize(screen: screen))")
    }
    
    func getScreenSize(screen: NSScreen) -> (Int, Int) {
        return (Int(screen.frame.width), Int(screen.frame.height))
    }
}

