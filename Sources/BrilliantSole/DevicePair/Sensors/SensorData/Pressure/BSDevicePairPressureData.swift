//
//  BSDevicePairPressureData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public struct BSDevicePairPressureData: BSCenterOfPressureData {
    public let sensors: [BSSide: [BSPressureSensorData]]
    public let scaledSum: Float
    public let normalizedSum: Float

    public let centerOfPressure: BSCenterOfPressure?
    public let normalizedCenterOfPressure: BSCenterOfPressure?

    init(sensors: [BSSide: [BSPressureSensorData]], scaledSum: Float, normalizedSum: Float, centerOfPressure: BSCenterOfPressure?, normalizedCenterOfPressure: BSCenterOfPressure?) {
        self.sensors = sensors

        self.scaledSum = scaledSum
        self.normalizedSum = normalizedSum

        self.centerOfPressure = centerOfPressure
        self.normalizedCenterOfPressure = normalizedCenterOfPressure
    }
}
