//
//  Sound.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 16.07.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation
import AVFoundation

class Sound {
    var player = AVAudioPlayer()
    func playSound(file:String, ext:String) -> Void {
        let url = Bundle.main.url(forResource: file, withExtension: ext)!
        if UserDefaults.standard.integer(forKey: "playSound") == 1 {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error.localizedDescription)
                GoogleReporter.shared.event("debug", action: "Cant Play Sound")
            }
        }
    }
}
