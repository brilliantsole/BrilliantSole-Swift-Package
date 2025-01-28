//
//  BSSensorConfigurationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSSensorConfigurationManager: BSBaseManager<BSSensorConfigurationMessageType> {
    override class var requiredMessageTypes: [BSSensorConfigurationMessageType]? {
        [.getSensorConfiguration]
    }

    override func onRxMessage(_ messageType: BSSensorConfigurationMessageType, data: Data) {
        switch messageType {
        case .getSensorConfiguration, .setSensorConfiguration:
            parseSensorConfiguration(data)
        }
    }

    override func reset() {
        var newSensorConfiguration = sensorConfiguration
        newSensorConfiguration.clear()
        sensorConfiguration = newSensorConfiguration
    }

    // MARK: sensorConfiguration

    private let sensorConfigurationSubject = CurrentValueSubject<BSSensorConfiguration, Never>(.zero)
    var sensorConfigurationPublisher: AnyPublisher<BSSensorConfiguration, Never> {
        sensorConfigurationSubject.eraseToAnyPublisher()
    }

    private(set) var sensorConfiguration: BSSensorConfiguration {
        get { sensorConfigurationSubject.value }
        set {
            logger.debug("updated sensorConfiguration to \(newValue)")
            sensorConfigurationSubject.value = newValue
        }
    }

    private func parseSensorConfiguration(_ data: Data) {
        guard let newSensorConfiguration: BSSensorConfiguration = .parse(data) else {
            logger.error("failed to parse sensorConfiguration")
            return
        }
        logger.debug("parsed sensorConfiguration: \(newSensorConfiguration)")
        sensorConfiguration = newSensorConfiguration
    }

    func getSensorConfiguration(sendImmediately: Bool = true) {
        logger.debug("getting sensorConfiguration")
        createAndSendMessage(.getSensorConfiguration, sendImmediately: sendImmediately)
    }

    func setSensorConfiguration(_ newSensorConfiguration: BSSensorConfiguration, clearRest: Bool = false, sendImmediately: Bool = true) {
        guard !newSensorConfiguration.isEmpty else {
            logger.warning("ignoring empty sensorConfiguration")
            return
        }
        guard !newSensorConfiguration.isASubsetOf(sensorConfiguration) else {
            logger.debug("newSensorConfiguration is a subset - not setting")
            return
        }
        var _newSensorConfiguration = newSensorConfiguration
        if clearRest {
            sensorConfiguration.sensorTypes.filter { _newSensorConfiguration.contains($0) }.forEach { _newSensorConfiguration[$0] = ._0ms }
        }
        logger.debug("sending setSensorConfiguration: \(_newSensorConfiguration)")
        createAndSendMessage(.setSensorConfiguration, data: _newSensorConfiguration.getData(), sendImmediately: sendImmediately)
    }

    func clearSensorConfiguration(sendImmediately: Bool = true) {
        var newSensorConfiguration = sensorConfiguration
        newSensorConfiguration.clear()
        setSensorConfiguration(newSensorConfiguration, sendImmediately: sendImmediately)
    }

    var sensorTypes: [BSSensorType] { sensorConfiguration.sensorTypes }
    func containsSensorType(_ sensorType: BSSensorType) -> Bool { sensorTypes.contains(sensorType) }
    func isSensorRateNonzero(_ sensorType: BSSensorType) -> Bool { containsSensorType(sensorType) && sensorConfiguration[sensorType] != ._0ms }
    func getSensorRate(_ sensorType: BSSensorType) -> BSSensorRate? { sensorConfiguration[sensorType] }
    func setSensorRate(_ sensorType: BSSensorType, _ sensorRate: BSSensorRate, sendImmediately: Bool = true) {
        guard containsSensorType(sensorType) else {
            logger.debug("sensorConfiguration does not contain \(sensorType.name)")
            return
        }
        guard let currentSensorRate = getSensorRate(sensorType), currentSensorRate != sensorRate else {
            logger.debug("sensorType \(sensorType.name) already has sensorRate \(sensorRate.name)")
            return
        }
        var newSensorConfiguration: BSSensorConfiguration = .init()
        newSensorConfiguration[sensorType] = sensorRate
        setSensorConfiguration(newSensorConfiguration, sendImmediately: sendImmediately)
    }
}
