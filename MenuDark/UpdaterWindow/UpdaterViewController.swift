//
//  UpdaterViewController.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 06.09.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Cocoa

class UpdaterViewController: NSViewController, NSWindowDelegate {
    
    let updater = Updater()

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var searchSwitch: NSButton!
    @IBOutlet weak var skipButton: NSButton!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet var changelogTextView: NSTextView!

    @IBAction func skipButtonAction(_ sender: Any) {
        print("called skip")
        UserDefaults.standard.set(globalVersion, forKey: "seenUpdate")
        UserDefaults.standard.set(0, forKey: "newUpdate")
        GoogleReporter.shared.event("Updater", action: "Skip Update", label: appVersion, parameters: [ : ])
        view.window?.close()
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        if let url = URL(string: globalUrl),
            NSWorkspace.shared.open(url) {
            UserDefaults.standard.set(globalVersion, forKey: "seenUpdate")
            UserDefaults.standard.set(0, forKey: "newUpdate")
            GoogleReporter.shared.event("Updater", action: "Download Update", label: appVersion, parameters: [ : ])
            view.window?.close()
        }
    }
    
    @IBAction func searchSwitchAction(_ sender: Any) {
        updater.toggleChecking(state: searchSwitch.state == NSControl.StateValue.on)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.window?.delegate = self
        changelogTextView.isEditable = false
        changelogTextView.isSelectable = false
    }
    
    override func viewWillAppear() {
        changelogTextView.textStorage?.append(NSAttributedString(string: globalChangelog))
        let nsText = globalChangelog as NSString
        let textRange = NSMakeRange(0, nsText.length)
        changelogTextView.setTextColor(NSColor.textColor, range: textRange)
        titleLabel.stringValue = globalTitle + " - " + globalVersion
        if UserDefaults.standard.integer(forKey: "checkUpdates") == 1 {
            searchSwitch.state = NSControl.StateValue.on
        } else {
            searchSwitch.state = NSControl.StateValue.off
        }
        GoogleReporter.shared.event("Updater", action: "Update Window shown", label: appVersion, parameters: [ : ])
    }
}
