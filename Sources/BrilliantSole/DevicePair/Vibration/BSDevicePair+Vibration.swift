//
//  BSDevicePair+Vibration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

public extension BSDevicePair {
    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations, sendImmediately: Bool = true) {
        devices.forEach { $0.value.triggerVibration(vibrationConfigurations, sendImmediately: sendImmediately) }
    }
}

extension BSDevicePair: BSVibratable {}
