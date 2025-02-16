//
//  BSDevicePair+SensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import Combine

extension BSDevicePair {
    func setupSensorDataManager() {}

    public var pressureDataPublisher: AnyPublisher<(BSDevicePairPressureData, BSTimestamp), Never> {
        sensorDataManager.pressureSensorDataManager.pressureDataPublisher
    }
}
