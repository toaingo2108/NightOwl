//
//  Extensions.swift
//  MenuDark
//
//  Created by Benjamin Kramser on 21.06.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import Cocoa
import CoreLocation

extension PopViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> PopViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("PopViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PopViewController else {
            fatalError("Cant find ViewController - Check Main.storyboard")
        }
        return viewcontroller
    }
}

extension NSAppleScript {
    @discardableResult
    static func execute(_ source: String) -> Bool {
        guard let script = NSAppleScript(source: source) else { return false }
        var error: NSDictionary? = nil
        script.executeAndReturnError(&error)
        if(error !== nil) {
            //            sendNotif(title: "Changing Mode", subtitle: "Operation Failed!", informativeText: nil)
            return false
        }
        //        sendNotif(title: "Changing Mode", subtitle: "Operation Success!", informativeText: nil)
        return true
    }

    @discardableResult static func executeBash(_ command: String) -> (String, Bool) {
        let cmd = "do shell script \"\(command)\""
        let script = NSAppleScript(source: cmd)

        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error).stringValue

        if result == nil {
            return ("", false)
        } else {
            return (result!, true)
        }
    }
}

extension NSImage {
    func resize(withSize targetSize: NSSize) -> NSImage? {
        let frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        guard let representation = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: targetSize, flipped: false, drawingHandler: { (_) -> Bool in
            return representation.draw(in: frame)
        })
        
        return image
    }

}

extension UserDefaults {
    
    func set(location:CLLocation, forKey key: String){
        let locationLat = NSNumber(value:location.coordinate.latitude)
        let locationLon = NSNumber(value:location.coordinate.longitude)
        self.set(["lat": locationLat, "lon": locationLon], forKey:key)
    }
    
    func location(forKey key: String) -> CLLocation?
    {
        if let locationDictionary = self.object(forKey: key) as? Dictionary<String,NSNumber> {
            let locationLat = locationDictionary["lat"]!.doubleValue
            let locationLon = locationDictionary["lon"]!.doubleValue
            return CLLocation(latitude: locationLat, longitude: locationLon)
        }
        return nil
    }
}


extension Notification.Name {
    static let AppleInterfaceThemeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")
}
