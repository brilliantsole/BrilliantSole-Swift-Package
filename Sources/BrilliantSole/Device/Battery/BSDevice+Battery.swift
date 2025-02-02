//
//  BSDevice+Battery.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    internal func setupBatteryManager() {
        batteryManager.batteryCurrentPublisher.sink { [self] batteryCurrent in
            self.batteryCurrentSubject.send((self, batteryCurrent))
        }.store(in: &managerCancellables)

        batteryManager.isBatteryChargingPublisher.sink { [self] isBatteryCharging in
            self.isBatteryChargingSubject.send((self, isBatteryCharging))
        }.store(in: &managerCancellables)
    }

    var batteryCurrent: Float { batteryManager.batteryCurrent }
    var isBatteryCharging: Bool { batteryManager.isBatteryCharging }
}
