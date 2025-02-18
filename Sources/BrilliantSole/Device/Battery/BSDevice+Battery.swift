//
//  BSDevice+Battery.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    internal func setupBatteryManager() {}

    var batteryCurrent: Float { batteryManager.batteryCurrent }
    var batteryCurrentPublisher: AnyPublisher<Float, Never> { batteryManager.batteryCurrentPublisher }

    var isBatteryCharging: Bool { batteryManager.isBatteryCharging }
    var isBatteryChargingPublisher: AnyPublisher<Bool, Never> { batteryManager.isBatteryChargingPublisher }

    func getBatteryCurrent(sendImmediately: Bool = true) {
        batteryManager.getBatteryCurrent(sendImmediately: sendImmediately)
    }
}
