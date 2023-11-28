//
//  Sheduler.swift
//  MenuDark
//
//  Created by Benjamin Kramser on 21.06.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation

class Scheduler {
    
    
    func setlightScheduler() {
        print("sheduling")
        let scheduler = NSBackgroundActivityScheduler()
        scheduler.interval = 12
        scheduler.repeats = false
        scheduler.schedule { completion in
            if scheduler.shouldDefer {
                completion(.deferred)
                print("will return")
                return
            }
            self.turnLight(completion)
            print("set")
        }
        
    }
    
    func turnLight(_ completion: NSBackgroundActivityScheduler.CompletionHandler) {
        
        print("Badummmsss")
        completion(.finished)
        
    }
    
}
