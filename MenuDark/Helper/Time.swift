//
//  time.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 01.09.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

class Time {
    
    let switcher = Switcher()
    let sound = Sound()
    
    func startTimer() {
        checktime()
        GlobalTimer.sharedInstance.timerTime?.invalidate()
        GlobalTimer.sharedInstance.timerLocation?.invalidate()
        GlobalTimer.sharedInstance.timerDayTime?.invalidate()
        GlobalTimer.sharedInstance.timerDayTime = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { (timer) in
            print("timerDayTime")
            self.checktime()
        }
        RunLoop.current.add(GlobalTimer.sharedInstance.timerDayTime!, forMode: .common)
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
    
    func checktime() {
        let darkTime = TimeInterval(UserDefaults.standard.double(forKey: "darkTime"))
        let lightTime = TimeInterval(UserDefaults.standard.double(forKey: "lightTime"))
        let now = NSDate().timeIntervalSince1970
        let modDarkTime = Int(darkTime) % (24 * 60 * 60)
        let modLightTime = Int(lightTime) % (24 * 60 * 60)
        let modNow = Int(now) % (24 * 60 * 60)
        
        if modLightTime < modDarkTime {
            if (modLightTime ... modDarkTime).contains(modNow) {
                setLight()
            } else {
                setDark()
            }
        } else if modDarkTime < modLightTime {
            if (modDarkTime ... modLightTime).contains(modNow) {
                setDark()
            } else {
                setLight()
            }
        }
    }
    
    func setLight() {
        if switcher.isThemeModeDark() {
            print("toggle Daytime")
            sound.playSound(file: "owl2", ext: "aiff")
            switcher.enableLightMode()
        }
    }
    
    func setDark() {
        if !switcher.isThemeModeDark(){
            print("toggle Nighttime")
            sound.playSound(file: "owl", ext: "aiff")
            switcher.enableDarkMode()
        }
    }
    
}
