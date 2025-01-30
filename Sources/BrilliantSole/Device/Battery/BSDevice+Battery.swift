//
//  BSDevice+Battery.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    // MARK: - batteryCurrent

    var batteryCurrentPublisher: AnyPublisher<Float, Never> {
        batteryManager.batteryCurrentPublisher
    }

    var batteryCurrent: Float { batteryManager.batteryCurrent }

    // MARK: - isBatteryCharging

    var isBatteryChargingPublisher: AnyPublisher<Bool, Never> {
        batteryManager.isBatteryChargingPublisher
    }

    var isBatteryCharging: Bool { batteryManager.isBatteryCharging }
}
