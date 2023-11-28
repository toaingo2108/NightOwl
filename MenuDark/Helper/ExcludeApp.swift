//
//  ExcludeApp.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 29.11.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import AppKit

struct App:Codable {
    let name: String
    let bundle: String
    let image: Data
}

var runningAppsArray = [App]()

class ExcludeApp {
    
    let shell = Shell()
    let nc = NotificationCenter.default
    var checkAppsArray = [App]()
    var firstStart = false
    
    // TODO: Cleanup
    func setList() {
        if let objects = UserDefaults.standard.value(forKey: "runningApps") as? Data {
            let decoder = JSONDecoder()
            if let myArray = try? decoder.decode(Array.self, from: objects) as [App] {
                for app in myArray {
                    for item in self.checkAppsArray {
                        if item.bundle == app.bundle {
                            let imageData = app.image
                            let myApp = App(name: app.name, bundle: app.bundle, image: imageData)
                            runningAppsArray.append(myApp)
                            runningAppsArray = sortAndClean(apps: runningAppsArray)
                            self.nc.post(name: Notification.Name("AppAdded"), object: nil)
                        }
                    }
                }
                runningAppsArray = sortAndClean(apps: runningAppsArray)
                print("Status: Started")
                self.nc.post(name: Notification.Name("FinishedLaunching"), object: nil)
            } else {
                print("error:")
                self.nc.post(name: Notification.Name("FinishedLaunching"), object: nil)
            }
        } else {
            self.nc.post(name: Notification.Name("FinishedLaunching"), object: nil)
        }
    }
    
    func runningApps() {
        print("running")
        print(NSWorkspace.shared.runningApplications)
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.didLaunchApplicationNotification,
                           object: nil,
        queue: OperationQueue.main) { (notification: Notification) in
            print("Status: runing apps: start")
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName != nil && app.bundleIdentifier != nil && app.icon != nil {
                    for item in self.checkAppsArray {
                        if item.bundle == app.bundleIdentifier {
                            print("Status: runing apps: start inner")
                            let imageData = self.pngDataFrom(image: app.icon!)
                            let myApp = App(name: app.localizedName!, bundle: app.bundleIdentifier!, image: imageData)
                            print("Status: runing apps: middle inner")
                            runningAppsArray.append(myApp)
                            runningAppsArray = self.sortAndClean(apps: runningAppsArray)
                            self.nc.post(name: Notification.Name("AppAdded"), object: nil)
                            }
                        }
                    
                    let cleanApps = self.sortAndClean(apps: runningAppsArray)
                    print("runningApps")
                    print(runningAppsArray)
                    
                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(cleanApps){
                            UserDefaults.standard.set(encoded, forKey: "runningApps")
                        }
                }
            }
        }
    }
    
    func sortAndClean(apps: [App]) -> [App] {
        print("sorting")
        var arrayCleaned = apps.uniqueValues(value: {$0.name})
        arrayCleaned.sort { $0.name.lowercased() < $1.name.lowercased() }
        return arrayCleaned
    }
    
    func runIncompatibleTimer() {
        let timerUpdate = Timer.scheduledTimer(withTimeInterval: 60 * 120, repeats: true) { (timer) in
            self.getIncompatible()
        }
        RunLoop.current.add(timerUpdate, forMode: .common)
    }
    
    func getIncompatible() {
        guard let jsonUrl = URL(string: "https://nightowl.kramser.xyz/api/incompatible_bundles") else {
            GoogleReporter.shared.event("Exclude", action: "Error GetJSON URL", label: appVersion, parameters: [ : ])
            return
        }
        
        URLSession.shared.dataTask(with: jsonUrl, completionHandler: {(data, response, error) -> Void in
            
            if data == nil {
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String:Any]] {
                var incompatibleBundles = [String]()
                for bundles in jsonObj! {
                    print(bundles)
                    if let value = bundles["bundle"] as? String {
                        incompatibleBundles.append(value)
                    }
                }
                
                UserDefaults.standard.set(incompatibleBundles, forKey: "incompatibleBundles")
                GoogleReporter.shared.event("Exclude", action: "GetJSON successful", label: appVersion, parameters: [ : ])
            } else {
                GoogleReporter.shared.event("Exclude", action: "Error GetJSON Serialization", label: appVersion, parameters: [ : ])
            }
        }).resume()
    }
    
    func pngDataFrom(image:NSImage) -> Data {
        let resized = image.resize(withSize: NSSize(width: 16, height: 16))
        let cgImage = resized!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let pngData = bitmapRep.representation(using: .png, properties: [:])!
        return pngData
    }
    
    
    func setStatus(bundle: String) {
        var script = "defaults write " + bundle + " NSRequiresAquaSystemAppearance -bool yes"
        
        let checkScript = "defaults read " + bundle + " NSRequiresAquaSystemAppearance"
        DispatchQueue.main.async {
            if self.shell.execute(command: checkScript) == "1" {
                script = "defaults delete " + bundle + " NSRequiresAquaSystemAppearance"
                UserDefaults.standard.set(0, forKey: bundle)
                GoogleReporter.shared.event("Exclude", action: "Disable " + bundle, label: appVersion, parameters: [ : ])
            } else {
                UserDefaults.standard.set(1, forKey: bundle)
                GoogleReporter.shared.event("Exclude", action: "Enable " + bundle, label: appVersion, parameters: [ : ])
            }
            self.shell.execute(command: script)
            print("Status: executed")
            runningAppsArray = self.sortAndClean(apps: runningAppsArray)
            self.nc.post(name: Notification.Name("AppAdded"), object: nil)
        }
    }
    
    var query: NSMetadataQuery? {
        willSet {
            if let query = self.query {
                query.stop()
            }
        }
    }
    
    public func doSpotlightQuery() {
        query = NSMetadataQuery()
        let predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        NotificationCenter.default.addObserver(self, selector: #selector(queryDidFinish(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        query?.predicate = predicate
        query?.start()
    }
    
    @objc public func queryDidFinish(_ notification: NSNotification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }
        for result in query.results {
            guard let item = result as? NSMetadataItem else {
                print("Result was not an NSMetadataItem, \(result)")
                continue
            }
            let name = item.value(forAttribute: kMDItemDisplayName as String) ?? ""
            let bundle = item.value(forAttribute: kMDItemCFBundleIdentifier as String) ?? ""
            print("url:")
            print(item.value(forAttribute: kMDItemPath as String) ?? "")
            let myApp = App(name: name as! String, bundle: bundle as! String, image: Data())
            
            checkAppsArray.append(myApp)
            
            
        }
        
        print("checkapps")
        print(checkAppsArray)
        if firstStart {
            setList()
            firstStart = false
        }
    }
}

extension Array
{
    func uniqueValues<V:Equatable>( value:(Element)->V) -> [Element]
    {
        var result:[Element] = []
        for element in self
        {
            if !result.contains(where: { value($0) == value(element) })
            { result.append(element) }
        }
        return result
    }
}
