//
//  BSSensorConfigurable.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/19/25.
//

public protocol BSSensorConfigurable {
    func setSensorConfiguration(_ newSensorConfiguration: BSSensorConfiguration, clearRest: Bool, sendImmediately: Bool)
    func setSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate, sendImmediately: Bool)
    func toggleSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate, sendImmediately: Bool)
    func clearSensorRate(sensorType: BSSensorType, sendImmediately: Bool)
    func clearSensorConfiguration(sendImmediately: Bool)
}

public extension BSSensorConfigurable {
    func setSensorConfiguration(_ newSensorConfiguration: BSSensorConfiguration, clearRest: Bool) {
        setSensorConfiguration(newSensorConfiguration, clearRest: clearRest, sendImmediately: true)
    }

    func setSensorConfiguration(_ newSensorConfiguration: BSSensorConfiguration) {
        setSensorConfiguration(newSensorConfiguration, clearRest: false, sendImmediately: true)
    }

    func setSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate) {
        setSensorRate(sensorType: sensorType, sensorRate: sensorRate, sendImmediately: true)
    }

    func toggleSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate) {
        toggleSensorRate(sensorType: sensorType, sensorRate: sensorRate, sendImmediately: true)
    }

    func clearSensorRate(sensorType: BSSensorType) {
        clearSensorRate(sensorType: sensorType, sendImmediately: true)
    }

    func clearSensorConfiguration() {
        clearSensorConfiguration(sendImmediately: true)
    }
}
