//
//  Timer.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 17.07.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Foundation

public class GlobalTimer {
    public static let sharedInstance = GlobalTimer()
    private init() { }
    public var timerTime: Timer?
    public var timerLocation: Timer?
    public var timerDayTime: Timer?
    public var timerUpdate: Timer?
    public var incompatibleTimer: Timer?
}

