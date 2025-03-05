//
//  BSDevicePairPressureSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import Combine
import OSLog
import UkatonMacros

public typealias BSDevicePairPressureDataTuple = (pressure: BSDevicePairPressureData, timestamp: BSTimestamp)
typealias BSDevicePairPressureSubject = PassthroughSubject<BSDevicePairPressureDataTuple, Never>
public typealias BSDevicePairPressurePublisher = AnyPublisher<BSDevicePairPressureDataTuple, Never>

@StaticLogger(disabled: true)
class BSDevicePairPressureSensorDataManager {
    private var devicePressureData: [BSInsoleSide: BSPressureData] = .init()
    private var hasAllData: Bool { devicePressureData.count == 2 }
    private var centerOfPressureRange: BSCenterOfPressureRange = .init()
    private var normalizedSumRange: BSRange = .init()

    private let pressureDataSubject: BSDevicePairPressureSubject = .init()
    var pressureDataPublisher: BSDevicePairPressurePublisher {
        pressureDataSubject.eraseToAnyPublisher()
    }

    private let centerOfPressureSubject: BSCenterOfPressureSubject = .init()
    var centerOfPressurePublisher: BSCenterOfPressurePublisher {
        centerOfPressureSubject.eraseToAnyPublisher()
    }

    func onDevicePressureData(insoleSide: BSInsoleSide, pressureData: BSPressureData, timestamp: BSTimestamp) {
        logger?.debug("assigning \(insoleSide.name) pressure data")
        devicePressureData[insoleSide] = pressureData
        guard hasAllData else {
            logger?.debug("not all data received yet")
            return
        }
        logger?.debug("calculating devicePair pressure data")

        var scaledSum: Float = 0
        var normalizedSum: Float = 0

        for insoleSide in devicePressureData.keys {
            scaledSum += devicePressureData[insoleSide]!.scaledSum
            // normalizedSum += devicePressureData[insoleSide]!.normalizedSum
        }
        normalizedSum = normalizedSumRange.updateAndGetNormalization(for: scaledSum)
        logger?.debug("rawSum: \(scaledSum), normalizedSum: \(normalizedSum)")

        var centerOfPressure: BSCenterOfPressure?
        var normalizedCenterOfPressure: BSCenterOfPressure?
        var sensors: [BSInsoleSide: [BSPressureSensorData]] = .init()
        if normalizedSum > 0 {
            var centerOfPressureX: Float = 0
            var centerOfPressureY: Float = 0

            for insoleSide in devicePressureData.keys {
                if true {
                    sensors[insoleSide] = .init()
                    devicePressureData[insoleSide]!.sensors.forEach { _sensor in
                        var sensor = _sensor
                        sensor.updateWeightedValue(scaledSum: scaledSum)
                        sensor.updateDevicePairPosition(insoleSide: insoleSide)
                        sensors[insoleSide]?.append(sensor)

                        centerOfPressureX += sensor.weightedValue * sensor.position.x
                        centerOfPressureY += sensor.weightedValue * sensor.position.y
                    }
                }
                else {
                    let normalizedSumWeight: Float = devicePressureData[insoleSide]!.normalizedSum / normalizedSum
                    if normalizedSumWeight > 0, devicePressureData[insoleSide]!.normalizedCenterOfPressure != nil {
                        centerOfPressureY += normalizedSumWeight * devicePressureData[insoleSide]!.normalizedCenterOfPressure!.y
                        if insoleSide == .right {
                            centerOfPressureX = normalizedSumWeight
                        }
                    }
                }
            }

            centerOfPressure = .init(x: Double(centerOfPressureX), y: Double(centerOfPressureY))
            normalizedCenterOfPressure = centerOfPressureRange.updateAndGetNormalization(for: centerOfPressure!)

            logger?.debug("centerOfPressure: \(centerOfPressure!), normalizedCenterOfPressure: \(normalizedCenterOfPressure!)")
        }

        let pressureData: BSDevicePairPressureData = .init(
            sensors: sensors,
            scaledSum: scaledSum,
            normalizedSum: normalizedSum,
            centerOfPressure: centerOfPressure,
            normalizedCenterOfPressure: normalizedCenterOfPressure)
        pressureDataSubject.send((pressureData, timestamp))

        if let centerOfPressure, let normalizedCenterOfPressure {
            centerOfPressureSubject.send((centerOfPressure, normalizedCenterOfPressure, timestamp))
        }
    }

    func reset() {
        centerOfPressureRange.reset()
        normalizedSumRange.reset()
    }
}
