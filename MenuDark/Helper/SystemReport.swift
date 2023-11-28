//
//  SystemReport.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 08.01.19.
//  Copyright © 2019 Benjamin Kramser. All rights reserved.
//

import Foundation
import Cocoa

class SystemReport {
    let processInfo = ProcessInfo()
    let osFull = ProcessInfo().operatingSystemVersionString
    
    func reportSystem() {
        DispatchQueue.main.async {
            if UserDefaults.standard.integer(forKey: "Disabled Stats") != 1 {
                let osFull = ProcessInfo().operatingSystemVersionString
                let processorCount = String(self.processInfo.processorCount)
                let memory = String((Double(self.processInfo.physicalMemory) / 1000.0 / 1000.0).rounded() / 1000.0)
                let versionCode = self.getVersionCode()
                let arch = self.getArch()
                let screenSize = self.getScreenSize()
                let infoString = versionCode + " os" + osFull + ", " + processorCount + "cores, " + memory + "GB, " + screenSize + ", " + arch
                GoogleReporter.shared.event("SystemReport", action: infoString, label: appVersion, parameters: [ : ])
                }
            }
    }
    
    func getVersionCode() -> String {
        var size : Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String.init(validatingUTF8: model) ?? ""
    }
    
    func getArch() -> String {
        var size : Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &model, &size, nil, 0)
        return String.init(validatingUTF8: model) ?? ""
    }
    
    func getScreenSize() -> String {
        if let screen = NSScreen.main {
            let rect = screen.frame
            let height = rect.size.height
            let width = rect.size.width
            let sizes = height.description + "x" + width.description
            
            return sizes
        }
        return "No Screen"
    }
}
