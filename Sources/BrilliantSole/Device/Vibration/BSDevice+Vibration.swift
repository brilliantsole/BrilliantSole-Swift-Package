//
//  BSDevice+Vibration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    func triggerVibration(_ vibrationConfigurations: [BSVibrationConfiguration], sendImmediately: Bool = true) {
        vibrationManager.triggerVibration(vibrationConfigurations, sendImmediately: sendImmediately)
    }
}
