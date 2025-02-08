//
//  BSDevicePairPressureSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
class BSDevicePairPressureSensorDataManager {
    private var devicePressureData: [BSInsoleSide: BSPressureData] = .init()
    private var hasAllData: Bool { devicePressureData.count == 2 }
    private var centerOfPressureRange: BSCenterOfPressureRange = .init()

    private let pressureDataSubject: PassthroughSubject<(BSDevicePairPressureData, BSTimestamp), Never> = .init()
    var pressureDataPublisher: AnyPublisher<(BSDevicePairPressureData, BSTimestamp), Never> {
        pressureDataSubject.eraseToAnyPublisher()
    }

    func onDevicePressureData(insoleSide: BSInsoleSide, pressureData: BSPressureData, timestamp: BSTimestamp) {
        logger?.debug("assigning \(insoleSide.name) pressure data")
        devicePressureData[insoleSide] = pressureData
        guard hasAllData else {
            logger?.debug("not all data received yet")
            return
        }
        logger?.debug("calculating devicePair pressure data")

        var rawSum: Float = 0
        var normalizedSum: Float = 0

        for insoleSide in devicePressureData.keys {
            rawSum += devicePressureData[insoleSide]!.scaledSum
            normalizedSum += devicePressureData[insoleSide]!.normalizedSum
        }
        logger?.debug("rawSum: \(rawSum), normalizedSum: \(normalizedSum)")

        var centerOfPressure: BSCenterOfPressure?
        var normalizedCenterOfPressure: BSCenterOfPressure?
        if normalizedSum > 0 {
            var centerOfPressureX: Float = 0
            var centerOfPressureY: Float = 0

            for insoleSide in devicePressureData.keys {
                let normalizedSumWeight: Float = devicePressureData[insoleSide]!.normalizedSum / normalizedSum
                if normalizedSumWeight > 0, devicePressureData[insoleSide]!.normalizedCenterOfPressure != nil {
                    centerOfPressureY += normalizedSumWeight * devicePressureData[insoleSide]!.normalizedCenterOfPressure!.y
                    if insoleSide == .right {
                        centerOfPressureX = normalizedSumWeight
                    }
                }
            }
            centerOfPressure = .init(x: Double(centerOfPressureX), y: Double(centerOfPressureY))
            normalizedCenterOfPressure = centerOfPressureRange.updateAndGetNormalization(for: centerOfPressure!)

            logger?.debug("centerOfPressure: \(centerOfPressure!), normalizedCenterOfPressure: \(normalizedCenterOfPressure!)")
        }

        let pressureData: BSDevicePairPressureData = .init(
            rawSum: rawSum,
            normalizedSum: normalizedSum,
            centerOfPressure: centerOfPressure,
            normalizedCenterOfPressure: normalizedCenterOfPressure)
        pressureDataSubject.send((pressureData, timestamp))
    }

    func reset() {
        centerOfPressureRange.reset()
    }
}
