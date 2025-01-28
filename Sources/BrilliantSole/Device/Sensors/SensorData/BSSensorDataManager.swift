//
//  BSSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSSensorDataManager: BSBaseManager<BSSensorDataMessageType> {
    override class var requiredMessageTypes: [BSSensorDataMessageType]? {
        [
            .getPressurePositions,
            .getSensorScalars
        ]
    }

    override func onRxMessage(_ messageType: BSSensorDataMessageType, data: Data) {
        switch messageType {
        case .getPressurePositions:
            parsePressurePositions(data)
        case .getSensorScalars:
            parseSensorScalars(data)
        case .sensorData:
            parseSensorData(data)
        }
    }

    override func reset() {
        super.reset()
        sensorScalars.removeAll()
        sensorDataManagers.forEach { $0.reset() }
    }

    // MARK: - pressurePositions

    func getPressurePositions(sendImmediately: Bool = true) {
        logger.debug("getting pressurePositions")
        createAndSendMessage(.getPressurePositions, sendImmediately: sendImmediately)
    }

    func parsePressurePositions(_ data: Data) {
        pressureSensorDataManager.parsePressurePositions(data)
    }

    // MARK: - sensorScalars

    typealias BSSensorScalars = [BSSensorType: Float]
    let sensorScalarsSubject = CurrentValueSubject<BSSensorScalars, Never>(.init())
    private(set) var sensorScalars: BSSensorScalars {
        get { sensorScalarsSubject.value }
        set {
            logger.debug("updated sensorScalars to \(newValue)")
            sensorScalarsSubject.value = newValue
        }
    }

    func getSensorScalars(sendImmediately: Bool = true) {
        logger.debug("getting sensorScalars")
        createAndSendMessage(.getSensorScalars, sendImmediately: sendImmediately)
    }

    func parseSensorScalars(_ data: Data) {
        var newSensorScalars: BSSensorScalars = .init()
        for index in stride(from: 0, to: data.count, by: 5) {
            guard let sensorType = BSSensorType.parse(data, at: index) else {
                return
            }
            let sensorScalar: Float = .parse(data, at: index + 1)
            logger.debug("\(sensorType.name) scalar: \(sensorScalar)")
            newSensorScalars[sensorType] = sensorScalar
        }
        logger.debug("parsed sensorScalars: \(newSensorScalars)")
        sensorScalars = newSensorScalars
    }

    // MARK: - sensorData

    let pressureSensorDataManager: BSPressureSensorDataManager = .init()
    let motionSensorDataManager: BSMotionSensorDataManager = .init()
    let barometerSensorDataManager: BSBarometerSensorDataManager = .init()
    var sensorDataManagers: [BSBaseSensorDataManager] { [pressureSensorDataManager, motionSensorDataManager, barometerSensorDataManager] }

    func parseSensorData(_ data: Data) {
        var offset: Data.Index = .zero
        let timestamp = parseTimestamp(data, at: &offset)
        logger.debug("timestamp: \(timestamp)ms")
        parseMessages(data, messageCallback: { (sensorType: BSSensorType, data: Data) in
            self.parseSensorDataMessage(sensorType: sensorType, data: data, timestamp: timestamp)
        }, at: offset)
    }

    func parseSensorDataMessage(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp) {
        let scalar = sensorScalars[sensorType] ?? 1
        for sensorDataManager in sensorDataManagers {
            if sensorDataManager.canParseSensorData(sensorType) {
                sensorDataManager.parseSensorData(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
                break
            }
        }
    }
}
