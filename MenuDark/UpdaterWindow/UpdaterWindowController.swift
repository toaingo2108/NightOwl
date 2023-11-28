//
//  UpdaterWindowController.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 06.09.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Cocoa

class UpdaterWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.styleMask.remove(.resizable)
        self.window?.title = "Update available"
    }

}
