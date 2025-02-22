//
//  BSVibratable.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/21/25.
//

public protocol BSVibratable {
    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations, sendImmediately: Bool)
    func triggerVibration(_ vibrationConfiguration: BSVibrationConfiguration, sendImmediately: Bool)
}

public extension BSVibratable {
    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations) {
        triggerVibration(vibrationConfigurations, sendImmediately: true)
    }

    func triggerVibration(_ vibrationConfiguration: BSVibrationConfiguration, sendImmediately: Bool) {
        triggerVibration([vibrationConfiguration], sendImmediately: sendImmediately)
    }

    func triggerVibration(_ vibrationConfiguration: BSVibrationConfiguration) {
        triggerVibration([vibrationConfiguration], sendImmediately: true)
    }
}
