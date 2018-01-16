//
//  AppDelegate.swift
//  Daypaper
//
//  Created by Maksimov Andrey Aleksandrovich on 1/15/18.
//  Copyright © 2018 Maksimov Andrey Aleksandrovich. All rights reserved.
//

import Cocoa

import Fabric
import Crashlytics

import Fuzi
import Nuke
import SwiftDate
import SwiftHTTP

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, NSOpenSavePanelDelegate {

    @IBOutlet var StatusMenu: NSMenu!
    @IBOutlet weak var captionLabel: NSMenuItem!
    @IBOutlet weak var descriptionLabel: NSMenuItem!
    @IBOutlet weak var previewView: NSImageView!
    
    let BASE_URL: String = "https://yandex.com/images/"
    
    var statusItem : NSStatusItem!
    var prefs : UserDefaults!
    var wpTimer : Timer!
    
    var captionText = ""
    var descriptionText = ""

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // First of all we should define defaults values
        initDefaults()
        
        Fabric.with([Crashlytics.self, Answers.self])
        loadUserDefaults()
        
        // After that we may create UI and initialilze application
        initStatusMenu()
        
        initDownloadFolder()
        
        // Finally we should init timer
        initWpTimer()

//        getPreview()
//        getWallpaperMeta()
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
        initialDefaults["NSApplicationCrashOnExceptions"] = true
 
        NSUserDefaultsController.shared.defaults.register(defaults: initialDefaults)
    }
    
    func loadUserDefaults() {
        prefs = NSUserDefaultsController.shared.defaults
    }
    
    func initWpTimer() {
        let interval = prefs.double(forKey: "check_interval")
        wpTimer = Timer.scheduledTimer(timeInterval: interval,
                                       target: self,
                                       selector: (#selector(beginUpdateWallpaper)),
                                       userInfo: nil,
                                       repeats: true)
        print("WPTimer initialized with interval \(interval)")
        wpTimer.fire()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if (wpTimer != nil) {
            wpTimer.invalidate()
        }
    }
    
    @IBAction func downloadTodayClicked(_ sender: Any) {
        downloadImage(force: true)
    }
    
    func initDownloadFolder() {
        let defaultPath = makeDefaultPath()
        print("Prefs download_folder -> \(defaultPath)")
//        if (prefs.string(forKey: "download_folder") == nil)
//        {
//            print("Should create or select download folder")
//
//            let notification = NSUserNotification.init()
//            notification.title = "Daypaper"
//            notification.informativeText = "Download folder not set"
//            notification.actionButtonTitle = "Use Default"
//            notification.otherButtonTitle = "Select"
//            notification.hasActionButton = true
//            notification.hasReplyButton = true
//            notification.userInfo = ["action": "download_folder"]
//            NSUserNotificationCenter.default.delegate = self
//            NSUserNotificationCenter.default.deliver(notification)
//
//        } else {
//            if (FileManager.default.isWritableFile(atPath: prefs.string(forKey: "download_folder")!)) {
//                initWpTimer()
//            } else {
//                let notification = NSUserNotification.init()
//                notification.title = "Daypaper"
//                notification.informativeText = "Download folder are not writable"
//                notification.actionButtonTitle = "Use Default"
//                notification.otherButtonTitle = "Select another"
//                notification.hasActionButton = true
////                notification.hasReplyButton = true
////                notification.soundName = "Glass"
//                notification.userInfo = ["action": "download_folder"]
//                NSUserNotificationCenter.default.delegate = self
//                NSUserNotificationCenter.default.deliver(notification)
//            }
//        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
            case .replied:
                guard let res = notification.response else { return }
                print("User replied: \(res.string)")
            default:
                selectDownloadFolder()
                print("didActivate userInfo -> \(notification.userInfo!)")
                break;
        }
    }
    
//    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
//        print("didDeliver userInfo -> \(notification.userInfo!)")
//        if (notification.userInfo != nil) {
//            switch notification.userInfo!["action"] as! String {
//                case "download_folder":
//                    print("download_folder")
//                    selectDownloadFolder()
//                    break
//                default:
//                    let path = makeDefaultPath()
//                    makeWallpaperFolder(path)
//                    break;
//            }
//        }
//    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return prefs.bool(forKey: "show_notifications") != false
    }
    
    func makeDefaultPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.picturesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        path.append("/Daypaper")
        prefs.set(path, forKey: "download_folder")
        return path
    }
    
    func makeWallpaperFolder(_ path: String) {
        if (!FileManager.default.fileExists(atPath: path)) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
                let note = NSUserNotification()
                note.title = "Daypaper"
                note.subtitle = NSLocalizedString("create_folder_error", comment: "")
                note.informativeText = error.localizedDescription
                NSUserNotificationCenter.default.deliver(note)
            }
        }
    }
    
    func selectDownloadFolder() {
        
        let panel = NSOpenPanel.init()
        panel.title = "Select Wallpaper's folder"
        panel.titleVisibility = .visible
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.delegate = self
        panel.begin(completionHandler: { (result) in
            if (result == NSApplication.ModalResponse.OK) {
                let path = panel.url!.path
                self.prefs.set(path, forKey: "download_folder")
//                self.prefs.synchronize()
                print(self.prefs.string(forKey: "download_folder")!)
            }
        })
    }
    
    @objc func beginUpdateWallpaper() {
        getWallpaperMeta()
        downloadImage(force: false)
    }
    
    func needDownload(localFilename: String) -> Bool {
        print("Checking wallpaper…")
        if (FileManager.default.fileExists(atPath: localFilename)) {
            print("File \(localFilename) already exists.")
            return false
        }
        return true
    }
    
    func downloadImage(force: Bool?) {
        let (sWidth, sHeight) = getScreenSize()
        let downloadURL = URL.init(string: "\(BASE_URL)today?size=\(sWidth)x\(sHeight)")
        let localURL = URL.init(fileURLWithPath: makeLocalFilename(width: sWidth, height: sHeight))
        
        if (!needDownload(localFilename: localURL.relativePath)) {
            return
        }
        
        Manager.shared.loadImage(with: downloadURL!, completion: { (result) in
            if(result.error != nil) {
                print(result.error!)
            } else {
                let wp = result.value!
                do {
                    if let bits = wp.representations.first as? NSBitmapImageRep {
                        let data = bits.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])
                        try data?.write(to: localURL)
                        print("Saved to \(localURL.absoluteString)")
                    }

                    if (self.prefs.bool(forKey: "download_only") != true) {
                        self.applyWallpaper(wallpaperURL: localURL)
                    }

                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        })
    }
    
    /**
     Apply Wallpaper to every screen
    */
    func applyWallpaper(wallpaperURL: URL) {
        NSScreen.screens.forEach { (screen) in
            print("Applying wallpaper to \(getScreenSize())")
            
            do {
                try NSWorkspace.shared.setDesktopImageURL(wallpaperURL, for: screen, options: [:])
                Answers.logCustomEvent(withName: "WallpaperApplied", customAttributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    /**
     Detect given screen width & height in pixels.
     
     - returns:
     Tuple of Width and Height represented as Ints
     
     - parameters:
        - screen: NSScreen object to detect attributes
    */
    func getScreenSize() -> (Int, Int) {
        var maxWidth = 0
        var maxHeight = 0
        NSScreen.screens.forEach { (screen) in
            let frameWidth = Int(screen.frame.width)
            let frameHeight = Int(screen.frame.height)
            
            if (frameWidth > maxWidth) {
                maxWidth = frameWidth
                maxHeight = frameHeight
            }
        }
        return (maxWidth, maxHeight)
    }
    
    @IBAction func viewOnYandexClicked(_ sender: Any) {
        let url = URL.init(string: BASE_URL)!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func revealInFinder(_ sender: Any) {
        let (width, height) = getScreenSize()
        let wpURL = URL.init(fileURLWithPath: makeLocalFilename(width: width, height: height))
        NSWorkspace.shared.activateFileViewerSelecting([wpURL])
    }
    
    func makeLocalFilename(width: Int, height: Int) -> String {
        let download_folder = prefs.string(forKey: "download_folder") ?? ""
        let date = DateInRegion()
        let dateString = date.string(format: .iso8601(options: .withFullDate))
        return "\(download_folder)/\(dateString).jpg"
    }
    
    func getPreview() {
        let url = URL.init(string: "\(BASE_URL)today?size=640x640")
        Manager.shared.loadImage(with: url!, into: previewView)
    }
    
    func getWallpaperMeta() {
        var req = URLRequest(urlString: BASE_URL)!
        req.timeoutInterval = 10.0
        let task = HTTP(req)
        task.onFinish = { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            do {
                let doc = try HTMLDocument(data: response.data)
                
                // CSS queries
                if let elCaption = doc.firstChild(css: ".b-501px__name") {
                    print("Caption: \(elCaption.stringValue)")
                    self.captionText = elCaption.stringValue
                }
                
                if let elDescription = doc.firstChild(css: ".b-501px__description") {
                    print("Description: \(elDescription.stringValue)")
                    self.descriptionText = elDescription.stringValue
                }
                
                DispatchQueue.main.async {
                    self.captionLabel.title = self.captionText
                    self.descriptionLabel.title = self.descriptionText
                }
                
            } catch let error {
                print("Parse error -> \(error.localizedDescription)")
            }
        }
        
        task.run()
    }
}

