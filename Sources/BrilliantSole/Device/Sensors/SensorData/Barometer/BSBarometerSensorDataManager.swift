//
//  BSBarometerSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Combine
import Foundation
import OSLog
import UkatonMacros

@StaticLogger
class BSBarometerSensorDataManager: BSBaseSensorDataManager {
    override class var sensorTypes: Set<BSSensorType> { [.barometer] }

    override func parseSensorData(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        super.parseSensorData(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        switch sensorType {
        case .barometer:
            parseBarometer(data, timestamp: timestamp, scalar: scalar)
        default:
            break
        }
    }

    // MARK: - barometer

    let barometerSubject = PassthroughSubject<(BSBarometer, BSTimestamp), Never>()

    func parseBarometer(_ data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let barometer: BSBarometer = .parse(data, scalar: scalar) else { return }
        logger.debug("barometer: \(barometer) \(timestamp)ms")
        barometerSubject.send((barometer, timestamp))
    }
}
