//
//  PopViewController.swift
//  MenuDark
//
//  Created by Benjamin Kramser on 20.06.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Cocoa
import AVFoundation

class PopViewController: NSViewController {
    
    let switcher = Switcher()
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    let runOnStartup = RunOnStartup()
    var player:AVAudioPlayer = AVAudioPlayer()
    let location = Location()
    let timed = Time()
    let alert = Alert()
    let updater = Updater()
    var selectedApp = String()
    let excludeApp = ExcludeApp()
    let shell = Shell()
    let updaterWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "UpdaterWindow") as! UpdaterWindowController

    @IBOutlet weak var boxOutlet: NSBox!
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var quitButtonOutlet: NSButton!
    @IBOutlet weak var sunSwitchOutlet: NSButton!
    @IBOutlet weak var timeSwitchOutlet: NSButton!
    @IBOutlet weak var lightTimeOutlet: NSDatePicker!
    @IBOutlet weak var darkTimeOutlet: NSDatePicker!
    @IBOutlet weak var playSoundOutlet: NSButton!
    @IBOutlet weak var openStartupOutlet: NSButton!
    @IBOutlet weak var lightButtonOutlet: NSButton!
    @IBOutlet weak var darkButtonOutlet: NSButton!
    @IBOutlet weak var settingsView: NSView!
    @IBOutlet weak var sendStatisticsOutlet: NSButton!
    @IBOutlet weak var settingsOpenButtonOutlet: NSButton!
    @IBOutlet weak var checkUpdatesSwitch: NSButton!
    @IBOutlet weak var hotkeyOutlet: NSButton!
    @IBOutlet weak var hotkeySelectOutlet: NSPopUpButton!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var upperBoxView: NSBox!
    @IBOutlet weak var effectView: NSVisualEffectView!
    @IBOutlet weak var settingsEffectView: NSVisualEffectView!
    
    @IBAction func hotkeySelectAction(_ sender: Any) {
        UserDefaults.standard.set(Int(hotkeySelectOutlet.indexOfSelectedItem), forKey: "hotkeySelected")
        print("hotkey selected: \(hotkeySelectOutlet.indexOfSelectedItem) ")
        GoogleReporter.shared.event("Settings", action: "Select Hotkey \(hotkeySelectOutlet.indexOfSelectedItem)", label: appVersion, parameters: [ : ])
    }
    
    @IBAction func hotkeyAction(_ sender: Any) {
        if hotkeyOutlet.state == NSControl.StateValue.on {
            UserDefaults.standard.set(1, forKey: "hotkey")
            GoogleReporter.shared.event("Settings", action: "Enabled Hotkey", label: appVersion, parameters: [ : ])
        } else {
            UserDefaults.standard.set(0, forKey: "hotkey")
            GoogleReporter.shared.event("Settings", action: "Disabled Hotkey", label: appVersion, parameters: [ : ])
        }
    }
    
    
    
    @IBAction func checkUpdatesSwitchAction(_ sender: Any) {
        updater.toggleChecking(state: checkUpdatesSwitch.state == NSControl.StateValue.on)
    }
    
    @IBAction func playSound(_ sender: Any) {
        if playSoundOutlet.state == NSControl.StateValue.on {
            UserDefaults.standard.set(1, forKey: "playSound")
            GoogleReporter.shared.event("Settings", action: "Enabled PlaySound", label: appVersion, parameters: [ : ])
        } else {
            UserDefaults.standard.set(0, forKey: "playSound")
            GoogleReporter.shared.event("Settings", action: "Disabled PlaySound", label: appVersion, parameters: [ : ])
        }
        setSound()
    }
    
    @IBAction func statisticsButton(_ sender: Any) {
        if sendStatisticsOutlet.state == NSControl.StateValue.on {
            GoogleReporter.shared.event("Settings", action: "Disabled Statistics", label: appVersion, parameters: [ : ])
            UserDefaults.standard.set(0, forKey: "Disabled Stats")
        } else {
            UserDefaults.standard.set(1, forKey: "Disabled Stats")
            GoogleReporter.shared.event("Settings", action: "Enabled Statistics", label: appVersion, parameters: [ : ])
        }
    }
    
    @IBAction func quitButton(_ sender: Any) {
        GoogleReporter.shared.event("Settings", action: "Quit", label: appVersion, parameters: [ : ])
        NSApplication.shared.terminate(self)
    }
    
//    working on
    @IBAction func timeSwitch(_ sender: Any) {
        if timeSwitchOutlet.state == NSControl.StateValue.on {
           activateTime()
        } else {
            UserDefaults.standard.set(0, forKey: "trackTime")
        }
        toggleTime()
    }
    
    @IBAction func lightTime(_ sender: Any) {
        activateTime()
        timeSwitchOutlet.state = NSControl.StateValue.on
    }
    
    @IBAction func darkTime(_ sender: Any) {
        activateTime()
        timeSwitchOutlet.state = NSControl.StateValue.on
    }
    
    func activateTime() {
        UserDefaults.standard.set(1, forKey: "trackTime")
        UserDefaults.standard.set(0, forKey: "trackSun")
        sunSwitchOutlet.state = NSControl.StateValue.off
        toggleTime()
    }
    
    @IBAction func sunSwitch(_ sender: Any) {
        if sunSwitchOutlet.state == NSControl.StateValue.on {
            if location.requestLocation() {
                UserDefaults.standard.set(1, forKey: "trackSun")
                UserDefaults.standard.set(0, forKey: "trackTime")
                timeSwitchOutlet.state = NSControl.StateValue.off
            } else {
                sunSwitchOutlet.state = NSControl.StateValue.off
            }
        } else {
            UserDefaults.standard.set(0, forKey: "trackSun")
        }
        toggleSun()
    }
    
    @IBAction func closeSettings(_ sender: Any) {
        settingsView.alphaValue = 0
        settingsView.isHidden = true
        GoogleReporter.shared.event("UI", action: "Closed Settings", label: appVersion, parameters: [ : ])
    }
    @IBAction func openSettings(_ sender: Any) {
        settingsView.isHidden = false
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.5
            settingsView.animator().alphaValue = 1
        })
        setSettingToggles()
        GoogleReporter.shared.event("UI", action: "Opened Settings", label: appVersion, parameters: [ : ])
        GoogleReporter.shared.screenView("Settings")
    }
    @IBAction func openStartup(_ sender: Any) {
        runOnStartup.runOnStartup()
        if runOnStartup.checkRunState() {
            openStartupOutlet.state = NSControl.StateValue.on
            GoogleReporter.shared.event("Settings", action: "Enable RunOnStartup", label: appVersion, parameters: [ : ])
        } else {
            openStartupOutlet.state = NSControl.StateValue.off
            GoogleReporter.shared.event("Settings", action: "Disable RunOnStartup", label: appVersion, parameters: [ : ])
        }
    }
    
    @IBAction func lightButton(_ sender: Any) {
        appDelegate.closePopover(sender: Any?.self)
        appDelegate.toggleIcon(dark: true)
        toggle()
        switcher.enableLightMode()
        GoogleReporter.shared.event("Toggle", action: "Toggle-Light", label: appVersion, parameters: [ : ])
        checkRightHint()
    }
    
    @IBAction func darkButton(_ sender: Any) {
        toggle()
        appDelegate.closePopover(sender: Any?.self)
        appDelegate.toggleIcon(dark: false)
        switcher.enableDarkMode()
        GoogleReporter.shared.event("Toggle", action: "Toggle-Dark", label: appVersion, parameters: [ : ])
        checkRightHint()
    }
    
    
    @IBAction func donateButton(_ sender: Any) {
        openDonation()
    }
    
    @IBAction func bugButton(_ sender: Any) {
        let os = ProcessInfo().operatingSystemVersion
        let email = "dev@kramser.xyz"
        let subject = "Bug%20Report:%20NightOwl%20" + appVersion + "%20on%20macOS%20" + String(os.majorVersion) + "." + String(os.minorVersion)
        let bodyInfo = "System%20Information%20%28Please%20don't%20change%29:%0A"
        let body = "%2AOS:" + String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion) + "%2AApp:" + appVersion + "%2ATime:" + String(Date().timeIntervalSince1970) + "%2ARunBoot:" + String(runOnStartup.checkRunState()) + "%2ASound:" + String(UserDefaults.standard.integer(forKey: "playSound")) + "%2ADisabledStatistics:" + String(UserDefaults.standard.integer(forKey: "Disabled Stats")) + "%2ASun:" + String(UserDefaults.standard.integer(forKey: "trackSun")) + "%2ATimed:" + String(UserDefaults.standard.integer(forKey: "trackTime")) + "%2A"
        let bodyMessage = "%0A%0ABug%20Description:%0A%5BPlease%20describe%20your%20Bug%20here%5d"
        if let url = URL(string: "mailto:\(email)?subject=\(subject)&body=\(bodyInfo)\(body)\(bodyMessage)"),
            NSWorkspace.shared.open(url) {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerTime()
        settingsView.wantsLayer = true
        settingsView.isHidden = true
        settingsView.alphaValue = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
       
        scrollView.contentView.postsBoundsChangedNotifications = true
        if UserDefaults.standard.integer(forKey: "trackSun") == 1 {
            location.stopTimer()
            location.startTimer()
        }
        if UserDefaults.standard.integer(forKey: "trackTime") == 1 {
            timed.stopTimer()
            timed.startTimer()
        }
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name("AppAdded"), object: nil)
        nc.addObserver(self, selector: #selector(scrollViewDidScroll), name: NSScrollView.didLiveScrollNotification, object: nil)

    }
    
    override func viewDidAppear() {
        print("appear")
        GoogleReporter.shared.screenView("PopView")
        GoogleReporter.shared.event("UI", action: "Opened PopView", label: appVersion, parameters: [ : ])
        NSApp.activate(ignoringOtherApps: true)
        checkUpdate()

        setSound()
        versionLabel.stringValue = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) + "(" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String) + ")"
    }
    
    @objc func scrollViewDidScroll() {
        let scrollspeed = CGFloat(0.9)
        let tableViewMeasure = (tableView.enclosingScrollView?.contentView.bounds.minY)! * 0.7
        print(tableViewMeasure)
        var scrollPosition = (tableViewMeasure * scrollspeed) + 95
        if tableViewMeasure < 0 {
            upperBoxView.frame = NSRect(x: -7, y: 95, width: 234, height: 209)
            return
        }
        
//        if tableViewMeasure < 260 {
//            scrollPosition = (tableViewMeasure) + 240
//        }
        if tableViewMeasure > CGFloat(185) {
            upperBoxView.frame = NSRect(x: -7, y: 263, width: 234, height: 209)
            return
        }
        
        upperBoxView.frame = NSRect(x: -7, y: Int(scrollPosition), width: 234, height: 209)
        

    }
    
    
    func startTimeTracking() {
        UserDefaults.standard.set(getTimeInterval(date: darkTimeOutlet.dateValue), forKey: "darkTime")
        UserDefaults.standard.set(getTimeInterval(date: lightTimeOutlet.dateValue), forKey: "lightTime")
        timed.startTimer()
    }
    
    func checkRightHint() {
        if !UserDefaults.standard.bool(forKey: "rightClickShown") {
            let currentCount = UserDefaults.standard.integer(forKey: "rightClickCount")
            if currentCount < 10 {
                UserDefaults.standard.set(currentCount + 1, forKey: "rightClickCount")
            } else {
                alert.dialogHint()
                GoogleReporter.shared.event("UI", action: "RightClick hint Shown", label: appVersion, parameters: [ : ])
                UserDefaults.standard.set(true, forKey: "rightClickShown")
            }
        }
    }
    
    func setPickerTime() {
        let lightDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lightTime"))
        lightTimeOutlet.dateValue = lightDate
        let darkDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "darkTime"))
        darkTimeOutlet.dateValue = darkDate
    }
    
    func getTimeInterval(date: Date) -> TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour!
        let minute = components.minute!
        let newdate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        let timeInterval = newdate.timeIntervalSince1970
        return timeInterval
    }
    
    override func viewWillAppear() {
        toggle()
        setToggles()
        setStatsToggle()
    }
    override func viewDidDisappear() {
        GoogleReporter.shared.event("UI", action: "Closed PopView", label: appVersion, parameters: [ : ])
        settingsView.isHidden = true
        settingsView.alphaValue = 0
    }
    
    func openDonation() {
                let donationWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DonationWindow") as! DonateWindowController
                donationWindowController.showWindow(self)
    }
    
    func checkUpdate() {
        print("Called checkUpdate")
        if UserDefaults.standard.integer(forKey: "newUpdate") == 1 && UserDefaults.standard.integer(forKey: "checkUpdates") == 1 {
                updaterWindowController.showWindow(self)
        }
    }
    
    func toggleSun() {
        if UserDefaults.standard.integer(forKey: "trackSun") == 1 {
            print("SunDetection: on")
            if location.requestLocation() {
                location.checkDaytime()
                location.stopTimer()
                location.startTimer()
                lightButtonOutlet.isEnabled = false
                darkButtonOutlet.isEnabled = false
                GoogleReporter.shared.event("Toggle", action: "Start Autoswitch", label: appVersion, parameters: [ : ])
            }
        } else {
            print("SunDetection: off")
            stopTimers()
            toggle()
            GoogleReporter.shared.event("Toggle", action: "Stop Autoswitch", label: appVersion, parameters: [ : ])
        }
    }
    
    func toggleTime() {
        if UserDefaults.standard.integer(forKey: "trackTime") == 1 {
            print("Time tracking: on")
            timed.stopTimer()
            startTimeTracking()
            lightButtonOutlet.isEnabled = false
            darkButtonOutlet.isEnabled = false
            GoogleReporter.shared.event("Toggle", action: "Start Timeswitch", label: appVersion, parameters: [ : ])
        } else {
            print("Time tracking: off")
            stopTimers()
            toggle()
            GoogleReporter.shared.event("Toggle", action: "Stop Timeswitch", label: appVersion, parameters: [ : ])
        }
    }
    
    func stopTimers() {
        location.stopTimer()
        timed.stopTimer()
        appDelegate.stopSunTimer()
    }
    
    func setStatsToggle() {
        DispatchQueue.main.async {
            if UserDefaults.standard.integer(forKey: "Disabled Stats") == 1 {
                self.sendStatisticsOutlet.state = NSControl.StateValue.off
            } else {
                self.sendStatisticsOutlet.state = NSControl.StateValue.on
            }
        }
    }
    
    func setToggles() {
        if UserDefaults.standard.integer(forKey: "trackSun") == 1 {
            sunSwitchOutlet.state = NSControl.StateValue.on
            darkButtonOutlet.isEnabled = false
            lightButtonOutlet.isEnabled = false
            
        } else {
            sunSwitchOutlet.state = NSControl.StateValue.off
        }
        if UserDefaults.standard.integer(forKey: "trackTime") == 1 {
            timeSwitchOutlet.state = NSControl.StateValue.on
            darkButtonOutlet.isEnabled = false
            lightButtonOutlet.isEnabled = false
            
        } else {
            timeSwitchOutlet.state = NSControl.StateValue.off
        }
    }
    
    func setSettingToggles() {
        if runOnStartup.checkRunState() {
            openStartupOutlet.state = NSControl.StateValue.on
        } else {
            openStartupOutlet.state = NSControl.StateValue.off
        }
        if UserDefaults.standard.integer(forKey: "checkUpdates") == 1 {
            checkUpdatesSwitch.state = NSControl.StateValue.on
        } else {
            checkUpdatesSwitch.state = NSControl.StateValue.off
        }
        if UserDefaults.standard.integer(forKey: "hotkey") == 1 {
            hotkeyOutlet.state = NSControl.StateValue.on
        } else {
            hotkeyOutlet.state = NSControl.StateValue.off
        }
        hotkeySelectOutlet.selectItem(at: UserDefaults.standard.integer(forKey: "hotkeySelected"))
    }
    
    func toggle() {
        if switcher.isThemeModeDark() {
            darkButtonOutlet.isEnabled = false
            lightButtonOutlet.isEnabled = true
            effectView.material = .dark
            settingsEffectView.material = .dark
        } else {
            lightButtonOutlet.isEnabled = false
            darkButtonOutlet.isEnabled = true
            effectView.material = .mediumLight
            settingsEffectView.material = .mediumLight
        }
    }
    
    func setSound() {
        if UserDefaults.standard.integer(forKey: "playSound") == 0 {
            lightButtonOutlet.sound = nil
            darkButtonOutlet.sound = nil
            playSoundOutlet.state = NSControl.StateValue.off
        } else {
            lightButtonOutlet.sound = NSSound(named: "owl2")
            darkButtonOutlet.sound = NSSound(named: "owl")
            playSoundOutlet.state = NSControl.StateValue.on
        }
    }
    
    @objc func refreshTableView() {
        tableView.reloadData()
    }
    
    func logoutAlert() {
        if !UserDefaults.standard.bool(forKey: "disableLogoutAlert") {
            let myAlert: NSAlert = NSAlert()
            var message = "Disable forced Light Mode for all Apps"
            if UserDefaults.standard.integer(forKey: "-g") == 0 {
                message = "Enable forced Light Mode for all Apps"
            }
            myAlert.messageText = message
            myAlert.informativeText = "Changes will take effect after log out"
            myAlert.showsSuppressionButton = true
            myAlert.addButton(withTitle: "Log out")
            myAlert.addButton(withTitle: "Later")
            let choice = myAlert.runModal()
            switch choice {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                    NSAppleScript.execute("""
                tell app "System Events" to log out
        """)
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                print ("Later")
            default: break
            }
            if myAlert.suppressionButton!.state.rawValue == 1 {
                UserDefaults.standard.set(true, forKey: "disableLogoutAlert")
            } else {
                print ("Not checked")
            }
        }
    }
    
    func appAlert(bundle: String, name: String) {
        if !UserDefaults.standard.bool(forKey: "disableAppAlert") {
            let myAlert: NSAlert = NSAlert()
            var message = "Restart: '" + name + "' to disable forced Light Mode"
            if UserDefaults.standard.integer(forKey: bundle) == 0 {
                message = "Restart: '" + name + "' to enable forced Light Mode"
            }
            myAlert.messageText = message
            myAlert.informativeText = "Changes will take effect after restarting the App"
            myAlert.showsSuppressionButton = true
            myAlert.addButton(withTitle: "Ok")
            myAlert.runModal()
            if myAlert.suppressionButton!.state.rawValue == 1 {
                UserDefaults.standard.set(true, forKey: "disableAppAlert")
            } else {
                print ("Not checked")
            }
        }
    }
    
    @objc func setExclude(sender:NSButton) {
        let row = sender.tag
        let systemApp = App(name: "All Apps", bundle: "-g", image: Data())
        var displayArray = [systemApp]
        displayArray = displayArray + runningAppsArray
        let bundle = displayArray[row].bundle
        let loadingIndicator = NSProgressIndicator(frame: NSRect(x: 30, y: 30, width: 16, height: 16))
        loadingIndicator.style = .spinning
        loadingIndicator.controlSize = .regular
        loadingIndicator.controlTint = .blueControlTint
        loadingIndicator.startAnimation(nil)
        excludeApp.setStatus(bundle: bundle)
        if bundle == "-g" {
            logoutAlert()
        } else {
            appAlert(bundle: bundle, name: displayArray[row].name)
        }
    }
}

extension PopViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return runningAppsArray.count + 3
    }
    
}

extension PopViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView {
            
            let image = NSImage(named: "apps")
            let cgImage = image!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let pngData = bitmapRep.representation(using: .png, properties: [:])!
            
            let systemApp = App(name: "All Apps", bundle: "-g", image: pngData)
            var displayArray = [systemApp]
            displayArray = displayArray + runningAppsArray
            
            if row > displayArray.count {
                let textField = cell.textField
                for view in cell.subviews{
                    view.isHidden = true
                }
                textField!.stringValue = "Apps appear after first start"
                textField?.font = NSFont(name: (textField?.font?.fontName)!, size: 9)
                cell.imageView?.isHidden = true
                cell.textField?.isHidden = false
            } else if row == 0 {
                for view in cell.subviews{
                    view.isHidden = true
                }
                cell.textField?.isHidden = true
                cell.imageView?.isHidden = true
                let textField = cell.textField
                textField?.font = NSFont(name: (textField?.font?.fontName)!, size: 13)
                
            } else {
                
                let rowApp = displayArray[row - 1]
                selectedApp = rowApp.bundle
                var disabled = false
                cell.textField?.textColor = NSColor.textColor
                if UserDefaults.standard.integer(forKey: "-g") == 1 && rowApp.bundle != "-g" {
                    disabled = true
                    cell.textField?.textColor = NSColor.disabledControlTextColor
                }
                let textField = cell.textField
                textField?.stringValue = rowApp.name
                textField?.font = NSFont(name: (textField?.font?.fontName)!, size: 13)
                let imageData = rowApp.image
                cell.imageView?.image = NSImage(data: imageData)
                cell.imageView?.isHidden = false
                let buttonView = NSButton(checkboxWithTitle: "", target: self, action: #selector(setExclude))
                buttonView.frame = NSRect(x: 175, y: 4, width: 18, height: 18)
                buttonView.tag = row - 1
                buttonView.isEnabled = !disabled
                cell.textField?.isHidden = false
                cell.imageView?.isHidden = false
                cell.addSubview(buttonView)
                if let incompatibleBundles = UserDefaults.standard.array(forKey: "incompatibleBundles") as? [String] {
                    if incompatibleBundles.contains(rowApp.bundle) {
                        let indicatorView = NSImageView(image: NSImage(named: "error")!)
                        indicatorView.frame = NSRect(x: 6, y: 6, width: 13, height: 13)
                        indicatorView.toolTip = "May not work properly due to restrictions by Apple"
                        indicatorView.contentTintColor = NSColor.controlAccentColor
                        indicatorView.tag = 12
                        cell.addSubview(indicatorView)
                        buttonView.isEnabled = false
                        textField?.stringValue = rowApp.name + " (Unsupported)"
                    } else {
                        for subview in cell.subviews {
                            if (subview.tag == 12) {
                                subview.removeFromSuperview()
                            }
                        }
                    }
                } else {
                    for subview in cell.subviews {
                        if (subview.tag == 12) {
                            subview.removeFromSuperview()
                        }
                    }
                }
                if UserDefaults.standard.integer(forKey: selectedApp) == 1 {
                    buttonView.state = NSControl.StateValue(1)
                } else {
                    buttonView.state = NSControl.StateValue(0)
                }
            }
            return cell
        }
        return nil
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 {
            return 205
        }
        return 25
    }
}
