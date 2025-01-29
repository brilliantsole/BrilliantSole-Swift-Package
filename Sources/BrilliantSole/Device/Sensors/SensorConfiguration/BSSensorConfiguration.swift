//
//  BSSensorConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSSensorConfiguration")

typealias BSSensorConfiguration = [BSSensorType: BSSensorRate]

extension BSSensorConfiguration {
    // MARK: - SensorTypes

    var sensorTypes: [BSSensorType] { keys.map { $0 } }

    // MARK: - Parsing

    static func parse(_ data: Data) -> Self? {
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

            guard let sensorRate = BSSensorRate.parse(data, at: index + 1) else {
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
            data += sensorType.data
            data += sensorRate.rawValue.getData(littleEndian: true)
        }
        return data
    }

    // MARK: - Zero

    var isZero: Bool {
        !contains(where: { $1 != ._0ms })
    }

    static var zero: Self {
        var zero: Self = .init()
        Key.allCases.forEach { zero[$0] = ._0ms }
        return zero
    }

    mutating func clear() {
        self.keys.forEach { self[$0] = ._0ms }
    }

    // MARK: - Toggling

    func isEnabled(_ key: Key) -> Bool {
        self[key] != ._0ms
    }

    func contains(_ key: Key) -> Bool {
        keys.contains(key)
    }

    mutating func toggle(_ key: Key, sensorRate: Value) {
        if isEnabled(key) {
            self[key] = ._0ms
        } else {
            self[key] = sensorRate
        }
    }

    // MARK: - equality

    func isASubsetOf(_ other: Self) -> Bool {
        other.count >= count && other.keys.allSatisfy { self[$0] == other[$0] }
    }

    func isSimilarTo(_ other: Self) -> Bool {
        count > other.count ? other.isASubsetOf(self) : self.isASubsetOf(other)
    }
}
