//
//  BSBaseSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSBaseSensorDataManager", disabled: true)

class BSBaseSensorDataManager {
    class var sensorTypes: Set<BSSensorType> { [] }
    func canParseSensorData(_ sensorType: BSSensorType) -> Bool { Self.sensorTypes.contains(sensorType) }
    func parseSensorData(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard canParseSensorData(sensorType) else {
            fatalError("unable to parse \(sensorType.name) sensor data")
        }
        logger?.debug("parsing \(sensorType.name) sensor data (\(data.count) bytes)")
    }

    func reset() {
        logger?.debug("resetting sensorDataManager \(String(describing: Self.self))")
    }
}
