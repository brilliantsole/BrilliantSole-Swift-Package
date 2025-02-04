//
//  BSDevicePairPressureData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import OSLog
import UkatonMacros

@StaticLogger
public struct BSDevicePairPressureData {
    public let rawSum: Float
    public let normalizedSum: Float

    public let centerOfPressure: BSCenterOfPressure?
    public let normalizedCenterOfPressure: BSCenterOfPressure?

    init(rawSum: Float, normalizedSum: Float, centerOfPressure: BSCenterOfPressure?, normalizedCenterOfPressure: BSCenterOfPressure?) {
        self.rawSum = rawSum
        self.normalizedSum = normalizedSum

        self.centerOfPressure = centerOfPressure
        self.normalizedCenterOfPressure = normalizedCenterOfPressure
    }
}
