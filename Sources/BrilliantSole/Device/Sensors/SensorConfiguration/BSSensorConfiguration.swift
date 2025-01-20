//
//  BSSensorConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "BSSensorConfiguration")

typealias BSSensorConfiguration = [BSSensorType: BSSensorRate]

extension BSSensorConfiguration {
    static func parse(data: Data) -> Self? {
        guard data.count.isMultiple(of: 3) else {
            logger.error("Invalid data length (\(data.count)) - must be multiple of 3")
            return nil
        }

        var configuration: Self = .init()
        logger.debug("parsing sensor configuration (\(data.count) bytes)")
        for index in stride(from: 0, to: data.count, by: 3) {
            guard let sensorType = BSSensorType(rawValue: data[index]) else {
                logger.error("Invalid sensor type (\(data[index])) at index \(index)")
                continue
            }

            let rawSensorRate: UInt16 = data.parse(at: index + 1)
            guard let sensorRate = BSSensorRate(rawValue: rawSensorRate) else {
                logger.error("Invalid sensor rate \(rawSensorRate)")
                continue
            }

            logger.debug("\(sensorType.name): \(sensorRate.name)")
            configuration[sensorType] = sensorRate
        }
        return configuration
    }

    func getData() -> Data {
        var data: Data = .init()
        for (sensorType, sensorRate) in self {
            data += sensorType.rawValue.data
            data += sensorRate.rawValue.data(littleEndian: true)
        }
        return data
    }
}
