//
//  Location.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 10.07.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

class Location: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
//    var timerTime = Timer()
//    var timerLocation = Timer()
    
    let switcher = Switcher()
    let alert = Alert()
    let sound = Sound()
    
    func requestLocation() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy =  kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
            print("is enabled")
            GoogleReporter.shared.event("debug", action: "Request Location - Location enabled", label: appVersion, parameters: [ : ])
            return true
        } else {
            print("failed")
//            self.locationManager.requestLocation()
            alert.dialogOKCancel(question: " Location Services are disabled.", text: "In order to use automatic Toggeling on Sunrise/Sunset activate the Location Services in the System Preferences.\n\n -> System Preferences -> Security & Privacy -> Privacy -> Location Services", critical: false)
            GoogleReporter.shared.event("debug", action: "Request Location - Location disabled", label: appVersion, parameters: [ : ])
            return false
        }
    }
    
    func startTimer() {
        GlobalTimer.sharedInstance.timerTime?.invalidate()
        GlobalTimer.sharedInstance.timerTime = Timer.scheduledTimer(withTimeInterval: 19.0, repeats: true) { (timer) in
            self.checkDaytime()
            print("timerTime")
        }
        GlobalTimer.sharedInstance.timerLocation?.invalidate()
        GlobalTimer.sharedInstance.timerLocation = Timer.scheduledTimer(withTimeInterval: 30 * 60.0, repeats: true) { (timer) in
            self.locationManager.startUpdatingLocation()
            print("timerLocation")
        }
        RunLoop.current.add(GlobalTimer.sharedInstance.timerTime!, forMode: .common)
        RunLoop.current.add(GlobalTimer.sharedInstance.timerLocation!, forMode: .common)
        print("timer started")
    }
    
    func stopTimer() {
        GlobalTimer.sharedInstance.timerTime?.invalidate()
        GlobalTimer.sharedInstance.timerTime? = Timer()
        GlobalTimer.sharedInstance.timerLocation?.invalidate()
        GlobalTimer.sharedInstance.timerLocation? = Timer()
        GlobalTimer.sharedInstance.timerDayTime?.invalidate()
        GlobalTimer.sharedInstance.timerDayTime? = Timer()
        print("timer killed")
    }
    
    func checkDaytime(){
        let location = UserDefaults.standard.location(forKey: "coordinate")
        if location != nil {
            let solar = Solar(for: Date(), coordinate: (location?.coordinate)!)
            if (solar?.isDaytime)! {
                print("isDaytime")
                if switcher.isThemeModeDark() {
                    print("toggle Daytime")
                    sound.playSound(file: "owl2", ext: "aiff")
                    switcher.enableLightMode()
                }
            } else {
                print("isNighttime")
                if !switcher.isThemeModeDark(){
                    print("toggle Nighttime")
                    sound.playSound(file: "owl", ext: "aiff")
                    switcher.enableDarkMode()
                }
            }
        } else {
            print("key doesnt exist")
            GoogleReporter.shared.event("debug", action: "Missing Location Key")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let currentLocation:CLLocation = locations[0] as CLLocation
        UserDefaults.standard.set(location: currentLocation, forKey: "coordinate")
        print("location updated")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: " + error.localizedDescription)
        if error.localizedDescription.contains("kCLErrorDomain error 1") {
            alert.dialogOKCancel(question: " Location Services are disabled.", text: "In order to use automatic Toggeling on Sunrise/Sunset activate the Location Services in the System Preferences.\n\n -> System Preferences -> Security & Privacy -> Privacy -> Location Services -> Enable NightOwl", critical: false)
        }
        GoogleReporter.shared.event("debug", action: "Cant get Location from Manager", label: appVersion, parameters: [ : ])
    }
}
