//
//  BSDevicePairSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSDevicePairSensorDataManager {
    let pressureSensorDataManager: BSDevicePairPressureSensorDataManager = .init()
    let motionSensorDataManager: BSDevicePairMotionSensorDataManager = .init()
    let barometerSensorDataManager: BSDevicePairBarometerSensorDataManager = .init()

    func reset() {
        pressureSensorDataManager.reset()
    }
}
