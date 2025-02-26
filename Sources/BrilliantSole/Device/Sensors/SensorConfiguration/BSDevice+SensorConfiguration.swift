//
//  BSDevice+SensorConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    internal func setupSensorConfiguration() {}

    var sensorConfiguration: BSSensorConfiguration { sensorConfigurationManager.sensorConfiguration }
    func containsSensorType(_ sensorType: BSSensorType) -> Bool {
        isMock || sensorConfiguration.contains(sensorType)
    }

    var sensorConfigurationPublisher: AnyPublisher<BSSensorConfiguration, Never> { sensorConfigurationManager.sensorConfigurationPublisher }

    // MARK: - modify sensorConfiguration

    func setSensorConfiguration(_ newSensorConfiguration: BSSensorConfiguration, clearRest: Bool = false, sendImmediately: Bool = true) {
        sensorConfigurationManager.setSensorConfiguration(newSensorConfiguration, clearRest: clearRest, sendImmediately: sendImmediately)
    }

    func setSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate, sendImmediately: Bool = true) {
        sensorConfigurationManager.setSensorRate(sensorType: sensorType, sensorRate: sensorRate, sendImmediately: sendImmediately)
    }

    func toggleSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate, sendImmediately: Bool = true) {
        sensorConfigurationManager.toggleSensorRate(sensorType: sensorType, sensorRate: sensorRate, sendImmediately: sendImmediately)
    }

    func clearSensorRate(sensorType: BSSensorType, sendImmediately: Bool = true) {
        sensorConfigurationManager.clearSensorRate(sensorType: sensorType, sendImmediately: sendImmediately)
    }

    func clearSensorConfiguration(sendImmediately: Bool = true) {
        sensorConfigurationManager.clearSensorConfiguration(sendImmediately: sendImmediately)
    }
}
