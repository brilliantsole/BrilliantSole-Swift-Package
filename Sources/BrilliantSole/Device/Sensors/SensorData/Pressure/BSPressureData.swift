//
//  BSPressureData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog
import UkatonMacros

@StaticLogger
public struct BSPressureData {
    public let sensors: [BSPressureSensorData]
    public let scaledSum: Float
    public let normalizedSum: Float

    public let centerOfPressure: BSCenterOfPressure?
    public let normalizedCenterOfPressure: BSCenterOfPressure?

    init(sensors: [BSPressureSensorData], scaledSum: Float, normalizedSum: Float, centerOfPressure: BSCenterOfPressure?, normalizedCenterOfPressure: BSCenterOfPressure?) {
        self.sensors = sensors
        self.scaledSum = scaledSum
        self.normalizedSum = normalizedSum
        self.centerOfPressure = centerOfPressure
        self.normalizedCenterOfPressure = normalizedCenterOfPressure
    }

    static func parse(_ data: Data, scalar: Float, positions: [BSPressureSensorPosition], ranges: inout [BSRange], centerOfPressureRange: inout BSCenterOfPressureRange) -> Self? {
        guard data.count == ranges.count * 2 else {
            let rangesCount = ranges.count * 2
            logger.error("data count mismatch (expected \(rangesCount), got \(data.count)")
            return nil
        }
        var sensors: [BSPressureSensorData] = .init()
        var scaledSum: Float = 0
        var normalizedSum: Float = 0

        for index in ranges.indices {
            guard let rawValue = UInt16.parse(data, at: index * 2) else {
                break
            }
            logger.debug("#\(index) rawValue: \(rawValue)")

            let scaledValue = Float(rawValue) * scalar
            logger.debug("#\(index) scaledValue: \(scaledValue)")

            let normalizedValue = ranges[index].updateAndGetNormalization(for: scaledValue, weightBySpan: true)
            logger.debug("#\(index) normalizedValue: \(normalizedValue)")

            let sensor: BSPressureSensorData = .init(
                position: positions[index],
                rawValue: rawValue,
                scaledValue: scaledValue,
                normalizedValue: normalizedValue
            )
            logger.debug("#\(index) sensor: \(String(describing: sensor))")
            sensors.append(sensor)

            scaledSum += scaledValue
            normalizedSum += normalizedValue
            logger.debug("partial (#\(index) scaledSum: \(scaledSum), normalizedValue: \(normalizedValue)")
        }

        logger.debug("final scaledSum: \(scaledSum), normalizedSum: \(normalizedSum)")

        var centerOfPressure: BSCenterOfPressure?
        var normalizedCenterOfPressure: BSCenterOfPressure?

        if scaledSum > 0 {
            centerOfPressure = .init()
            for index in sensors.indices {
                sensors[index].updateWeightedValue(scaledSum: scaledSum)
                centerOfPressure! += sensors[index].position * Double(sensors[index].weightedValue)
            }
            logger.debug("centerOfPressure: \(String(describing: centerOfPressure))")

            normalizedCenterOfPressure = centerOfPressureRange.updateAndGetNormalization(for: centerOfPressure!)
            logger.debug("normalizedCenterOfPressure: \(String(describing: normalizedCenterOfPressure))")
        }
        else {
            logger.debug("scaledSum is 0 - skipping centerOfPressure calculation")
        }

        let pressureData: BSPressureData = .init(
            sensors: sensors,
            scaledSum: scaledSum,
            normalizedSum: normalizedSum,
            centerOfPressure: centerOfPressure,
            normalizedCenterOfPressure: normalizedCenterOfPressure
        )
        return pressureData
    }
}
