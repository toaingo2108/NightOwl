//
//  Updater.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 05.09.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import WebKit

var globalTitle = String()
var globalVersion = String()
var globalUrl = String()
var globalChangelog = String()

class Updater {
    
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    struct Update: Codable {
        let title: String?
        let version: String?
        let build: String?
        let url: String?
        let changelog: String?
    }
    
    func start() {
        check()
        runUpdaterTimer()
    }
    
    func toggleChecking(state: Bool) {
        if state == true {
            UserDefaults.standard.set(1, forKey: "checkUpdates")
            GoogleReporter.shared.event("Updater", action: "Toggle Updater ON", label: appVersion, parameters: [ : ])
        } else {
            UserDefaults.standard.set(0, forKey: "checkUpdates")
            GoogleReporter.shared.event("Updater", action: "Toggle Updater OFF", label: appVersion, parameters: [ : ])
        }
    }
    
    func check() {
        
        if UserDefaults.standard.integer(forKey: "checkUpdates") == 1 {
        
        guard let jsonUrl = URL(string: "https://nightowl.kramser.xyz/api/public_update") else { return }
        URLSession.shared.dataTask(with: jsonUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let versionData = try decoder.decode(Update.self, from: data)
                print(versionData.version ?? "Empty Name")
                print(self.appVersion)
                globalTitle = versionData.title!
                globalVersion = versionData.version!
                globalUrl = versionData.url!
                globalChangelog = versionData.changelog!
                self.compare(version: versionData.version!)
            } catch let err {
                print("Err", err)
                GoogleReporter.shared.event("Updater", action: "Updater ERROR", label: self.appVersion, parameters: [ : ])
            }
            }.resume()
        }
    }
    
    func compare(version: String) {
        if version.compare(appVersion, options: .numeric) == .orderedDescending && UserDefaults.standard.string(forKey: "seenUpdate") != version {
//            print("Online Version is newer")
//            print("Version: " + globalVersion)
//            print("Changelog: " + globalChangelog)
//            print("Title: " + globalTitle)
//            print("Version: " + globalVersion)
//            print("seen: " + UserDefaults.standard.string(forKey: "seenUpdate")!)
            UserDefaults.standard.set(1, forKey: "newUpdate")
            GoogleReporter.shared.event("Updater", action: "Update available", label: appVersion, parameters: [ : ])
        }
    }
    
    func runUpdaterTimer() {
        let timerUpdate = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { (timer) in
            print("Updater Timer")
            self.check()
        }
        RunLoop.current.add(timerUpdate, forMode: .common)
    
    }
}
