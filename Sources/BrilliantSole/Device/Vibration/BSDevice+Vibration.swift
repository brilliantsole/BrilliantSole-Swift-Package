//
//  BSDevice+Vibration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    internal func setupVibrationManager() {}

    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations, sendImmediately: Bool = true) {
        vibrationManager.triggerVibration(vibrationConfigurations, sendImmediately: sendImmediately)
    }
}
