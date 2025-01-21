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

    static func parse(data: Data, numberOfPressureSensors: UInt8) -> Self? {
        // FILL
    }
}
