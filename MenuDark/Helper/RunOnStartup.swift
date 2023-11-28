//
//  RunOnStartup.swift
//  MenuDark
//
//  Created by Benjamin Kramser on 21.06.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation

class RunOnStartup {
    
    let alert = Alert()

    func doScriptScript(source: String) {
        if let appleScript = NSAppleScript(source: source) {
            var errorDict: NSDictionary? = nil
            var _ = appleScript.executeAndReturnError(&errorDict)
        } }

    func doShellScript() -> String {
        let theLP = "/usr/bin/osascript"
        let theParms = ["-e", "tell application \"System Events\" to get the name of every login item"]
        let task = Process()
        task.launchPath = theLP
        task.arguments = theParms
        let outPipe = Pipe()
        task.standardOutput = outPipe
        task.launch()
        let fileHandle = outPipe.fileHandleForReading
        let data = fileHandle.readDataToEndOfFile()
        task.waitUntilExit()
        let status = task.terminationStatus
        if (status != 0) {
            GoogleReporter.shared.event("debug", action: "System Events disabled")
            alert.dialogOKCancel(question: " System Events are disabled.", text: "In order to use NightOwl you need to activate the System Events in the System Preferences.\n\n -> System Preferences -> Security & Privacy -> Privacy -> Automation -> Enable NightOwl", critical: false)
            return "Failed, error = " + String(status)
        }
        else {
            return (NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
        }
    }

    func runOnStartup() {
        let thestr = doShellScript()
        if thestr.contains("NightOwl") {
            let theCmd4 = "tell application \"System Events\" to delete login item \"NightOwl\""
            doScriptScript(source: theCmd4)
        } else { let theCmd1 = "tell application \"System Events\" to make login item at end with properties {path:\""
            let theCmd2 = "\", hidden:false}"
            let thePath = Bundle.main.bundlePath
            doScriptScript(source: (theCmd1 + thePath + theCmd2))
        }
        let theStr2 = doShellScript()
        if theStr2.contains("NightOwl") {
    //        runonStartupCommand.state = NSControl.StateValue.on
            print("on")
        } else {
            print("off")
    //        runonStartupCommand.state = NSControl.StateValue.off
        }
    }

    func checkRunState() -> Bool {
        let theStr2 = doShellScript()
        print("String: " + theStr2)
        if theStr2.contains("NightOwl") {
            return true
        } else {
            return false
        }
    }
}
