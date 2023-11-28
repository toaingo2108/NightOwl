//
//  Switcher.swift
//  MenuDark
//
//  Created by Benjamin Kramser on 20.06.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation

class Switcher {
    
    func getDarkMode() -> Bool {
        let darkModeState = NSAppleScript.execute("""
            tell application "System Events"
                tell appearance preferences
                    get dark mode
                end tell
            end tell
    """)
        if(darkModeState) {
            return true
        }
        return false
    }
    
    func enableDarkMode() {
        NSAppleScript.execute("""
            tell application "System Events"
                tell appearance preferences to set dark mode to true
            end tell
    """)
    }
    
    func enableLightMode() {
        NSAppleScript.execute("""
            tell application "System Events"
                tell appearance preferences to set dark mode to false
            end tell
    """)
    }
    
    public func isThemeModeDark() -> Bool {
        let (output, _) = NSAppleScript.executeBash("defaults read -g AppleInterfaceStyle")
        if output.contains("Dark") {
            return true
        }
        return false
    }
}
