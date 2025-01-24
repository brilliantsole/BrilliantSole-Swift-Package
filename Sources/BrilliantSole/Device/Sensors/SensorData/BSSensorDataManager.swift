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
    }

    // MARK: - pressurePositions

    func parsePressurePositions(_ data: Data) {}

    // MARK: - sensorScalars

    typealias BSSensorScalars = [BSSensorType: Float]
    var sensorScalarsSubject = CurrentValueSubject<BSSensorScalars, Never>(.init())
    private(set) var sensorScalars: BSSensorScalars {
        get { sensorScalarsSubject.value }
        set {
            sensorScalarsSubject.value = newValue
            logger.debug("updated sensorScalars to \(newValue)")
        }
    }

    func parseSensorScalars(_ data: Data) {
        var newSensorScalars: BSSensorScalars = .init()
        for index in stride(from: 0, to: data.count, by: 5) {
            let rawSensorType: UInt8 = data[index]
            guard let sensorType: BSSensorType = .init(rawValue: rawSensorType) else {
                logger.error("invalid rawSensorType \(rawSensorType)")
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

    func parseSensorData(_ data: Data) {
        var offset: Data.Index = 0
        let timestamp = parseTimestamp(data, at: &offset)
        logger.debug("timestamp: \(timestamp)ms")
        parseMessages(data, messageCallback: { [self] (sensorType: BSSensorType, data: Data) in
            onSensorDataMessage(sensorType: sensorType, data: data, timestamp: timestamp)
        }, at: offset)
    }

    func onSensorDataMessage(sensorType: BSSensorType, data: Data, timestamp: UInt64) {
        // FILL
    }
}
