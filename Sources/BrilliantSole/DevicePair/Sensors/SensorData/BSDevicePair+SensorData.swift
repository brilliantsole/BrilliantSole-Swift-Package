//
//  BSDevicePair+SensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import Combine

public extension BSDevicePair {
    internal func setupSensorDataManager() {}

    var pressureDataPublisher: BSDevicePairPressurePublisher {
        sensorDataManager.pressureSensorDataManager.pressureDataPublisher
    }

    var centerOfPressurePublisher: BSCenterOfPressurePublisher {
        sensorDataManager.pressureSensorDataManager.centerOfPressurePublisher
    }

    func resetPressure() {
        devices.forEach { $0.value.resetPressure() }
        sensorDataManager.pressureSensorDataManager.reset()
    }
}

extension BSDevicePair: BSCenterOfPressureProvider {}
