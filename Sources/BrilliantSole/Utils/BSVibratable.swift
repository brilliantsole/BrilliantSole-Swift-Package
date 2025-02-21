//
//  BSVibratable.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/21/25.
//

public protocol BSVibratable {
    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations, sendImmediately: Bool)
}

extension BSVibratable {
    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations) {
        triggerVibration(vibrationConfigurations, sendImmediately: true)
    }
}
