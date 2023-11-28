//
//  AppDelegate.swift
//  MenuDark
//
//  Created by Benjamin Kramser on 20.06.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    let switcher = Switcher()
    let location = Location()
    let timed = Time()
    let sound = Sound()
    let runner = RunOnStartup()
    let systemReport = SystemReport()
    let updater = Updater()
    var debouncer = false
    let excludeApp = ExcludeApp()
    let nc = NotificationCenter.default
    let indicator = NSProgressIndicator(frame: NSRect(x: 7, y: 3, width: 16, height: 16))
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.isEnabled = false
            indicator.style = .spinning
            indicator.startAnimation(nil)
            button.addSubview(indicator)
        }
        UserDefaults.standard.set(0, forKey: "newUpdate")
        GoogleReporter.shared.configure(withTrackerId: "UA-122035377-3")
        GoogleReporter.shared.session(start: true)
        popover.contentViewController = PopViewController.freshController()
        nc.addObserver(self, selector: #selector(finishedLaunching), name: Notification.Name("FinishedLaunching"), object: nil)

        listenToInterfaceChangesNotification()
        sunTimer()
        timeTimer()
        incompatibleTimer()
        firstStart()
        excludeApp.runningApps()
        excludeApp.doSpotlightQuery()
        excludeApp.firstStart = true
        eventListenerGlobalKey()
        updater.start()
        systemReport.reportSystem()
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    @objc func finishedLaunching() {
        if let button = statusItem.button {
            button.isEnabled = true
            for sub in button.subviews {
                sub.removeFromSuperview()
            }
        }
        toggleIcon(dark: !switcher.isThemeModeDark())
    }
    
    @objc func togglePopover(_ sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            closePopover(sender: sender)
            toggle(action: "Quick-Toggle")
            if !UserDefaults.standard.bool(forKey: "rightClickShown") {
                UserDefaults.standard.set(true, forKey: "rightClickShown")
            }
        } else {
            print("Left click")
            if popover.isShown {
                closePopover(sender: sender)
            } else {
                showPopover(sender: sender)
            }
        }
    }
    
    func toggle(action: String) {
        if switcher.isThemeModeDark() {
            sound.playSound(file: "owl2", ext: "aiff")
            switcher.enableLightMode()
            toggleIcon(dark: true)
        } else {
            sound.playSound(file: "owl", ext: "aiff")
            switcher.enableDarkMode()
            toggleIcon(dark: false)
        }
        GoogleReporter.shared.session(start: true)
        GoogleReporter.shared.event("Toggle", action: action, label: appVersion, parameters: [ : ])
        stopTimer()
        UserDefaults.standard.set(0, forKey: "trackSun")
        UserDefaults.standard.set(0, forKey: "trackTime")
        GoogleReporter.shared.session(start: false)
    }
    
    func stopTimer() {
        GlobalTimer.sharedInstance.timerTime?.invalidate()
        GlobalTimer.sharedInstance.timerTime? = Timer()
        GlobalTimer.sharedInstance.timerLocation?.invalidate()
        GlobalTimer.sharedInstance.timerLocation? = Timer()
        GlobalTimer.sharedInstance.timerDayTime?.invalidate()
        GlobalTimer.sharedInstance.timerDayTime? = Timer()
        GlobalTimer.sharedInstance.timerUpdate?.invalidate()
        GlobalTimer.sharedInstance.timerUpdate? = Timer()
        GlobalTimer.sharedInstance.incompatibleTimer?.invalidate()
        GlobalTimer.sharedInstance.incompatibleTimer? = Timer()
    }
    
    func firstStart() {
        if UserDefaults.standard.integer(forKey: "already started") != 1 {
            sound.playSound(file: "owl2", ext: "aiff")
            runner.runOnStartup()
            runner.checkRunState()
            UserDefaults.standard.set(1, forKey: "playSound")
            UserDefaults.standard.set(1, forKey: "already started")
            UserDefaults.standard.set(1, forKey: "checkUpdates")
            UserDefaults.standard.set(1, forKey: "hotkey")
            UserDefaults.standard.set(0, forKey: "hotkeySelected")
        }
    }
    
    func toggleIcon(dark: Bool) {
        if dark {
            if let button = statusItem.button {
                button.action = #selector(togglePopover(_:))
                let image = NSImage(named:NSImage.Name("NightOwl_sleepy"))
                if #available(OSX 11.0, *) {
                    image?.isTemplate = true
                }
                button.image = image
                button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            }
        } else {
            if let button = statusItem.button {
                button.action = #selector(togglePopover(_:))
                let image = NSImage(named:NSImage.Name("NightOwl_angry"))
                if #available(OSX 11.0, *) {
                    image?.isTemplate = true
                }
                button.image = image
                button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            }
        }
    }
    
    func sunTimer() {
        if UserDefaults.standard.integer(forKey: "trackSun") == 1 {
            location.startTimer()
        }
    }
    
    func timeTimer() {
        if UserDefaults.standard.integer(forKey: "trackTime") == 1 {
            timed.startTimer()
        }
    }
    
    func listenToInterfaceChangesNotification() {
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(interfaceModeChanged),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )
    }
    
    @objc func interfaceModeChanged() {
        print("changed listener")
        
        let switchesAutomatically: Bool = (UserDefaults.standard.object(forKey: "AppleInterfaceStyleSwitchesAutomatically") != nil)
        
        
        print("auto? \(switchesAutomatically)")
        if self.switcher.isThemeModeDark() && self.statusItem.button?.image == NSImage(named:NSImage.Name("NightOwl_sleepy")){
            self.toggleIcon(dark: false)
        } else if !self.switcher.isThemeModeDark() && self.statusItem.button?.image == NSImage(named:NSImage.Name("NightOwl_angry")) {
            self.toggleIcon(dark: true)
        }
    }
    
    func eventListenerGlobalKey() {
        NSEvent.addGlobalMonitorForEvents(matching: [ .flagsChanged]) {
//            print("Keys")
//            print($0.keyCode)
            if UserDefaults.standard.integer(forKey: "hotkey") == 1 {
                if  $0.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.control, .command] && UserDefaults.standard.integer(forKey: "hotkeySelected") == 0 || $0.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.shift, .control, .option] && UserDefaults.standard.integer(forKey: "hotkeySelected") == 1 || $0.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.control, .option, .command] && UserDefaults.standard.integer(forKey: "hotkeySelected") == 2 {
                    GoogleReporter.shared.session(start: true)
                    GoogleReporter.shared.event("Toggle", action: "Hotkey toggle", label: appVersion, parameters: [ : ])
                    if self.debouncer == false {
                        self.toggle(action: "GlobalShortKey")
                        self.debouncer = true
                    }
                    GoogleReporter.shared.session(start: false)
                } else {
                    self.debouncer = false
                }
            }
        }
    }
    
    func stopTimeTimer() {
        timed.stopTimer()
    }
    
    func stopSunTimer() {
        location.stopTimer()
    }
    
    func incompatibleTimer() {
        excludeApp.runIncompatibleTimer()
        excludeApp.getIncompatible()
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        location.stopTimer()
        timed.stopTimer()
        GoogleReporter.shared.session(start: false)
    }
}
