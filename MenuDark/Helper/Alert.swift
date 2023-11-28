//
//  alert.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 15.07.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import Cocoa

class Alert {
    func dialogOKCancel(question: String, text: String, critical: Bool) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        if critical {
            alert.alertStyle = .critical
        } else {
            alert.alertStyle = .warning
        }
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func dialogHint() {
        let alert = NSAlert()
        alert.addButton(withTitle: "Ahh, thanks.")
        alert.icon = #imageLiteral(resourceName: "rightClick")
        alert.messageText = "NightOwl: Quick Tip! Right-Click to toggle."
        alert.informativeText = "You can toggle the modes by right-clicking on the NightOwl Menu Bar Icon. No need to open the App at all!"
        alert.runModal()
    }
}
