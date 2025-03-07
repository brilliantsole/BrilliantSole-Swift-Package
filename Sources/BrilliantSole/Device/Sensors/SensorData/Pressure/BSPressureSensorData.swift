//
//  BSPressureSensorData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog
import simd
import UkatonMacros

public typealias BSPressureSensorPosition = simd_double2

@StaticLogger(disabled: true)
public struct BSPressureSensorData {
    public private(set) var position: BSPressureSensorPosition
    public let rawValue: UInt16
    public let scaledValue: Float
    public let normalizedValue: Float
    public private(set) var weightedValue: Float

    init(position: BSPressureSensorPosition, rawValue: UInt16, scaledValue: Float, normalizedValue: Float, weightedValue: Float = 0.0) {
        self.position = position
        self.rawValue = rawValue
        self.scaledValue = scaledValue
        self.normalizedValue = normalizedValue
        self.weightedValue = weightedValue
    }

    mutating func updateWeightedValue(scaledSum: Float) {
        weightedValue = scaledValue / scaledSum
    }

    mutating func updateDevicePairPosition(insoleSide: BSInsoleSide) {
        self.position.x *= 0.5
        if insoleSide == .right {
            self.position.x += 0.5
        }
    }
}
