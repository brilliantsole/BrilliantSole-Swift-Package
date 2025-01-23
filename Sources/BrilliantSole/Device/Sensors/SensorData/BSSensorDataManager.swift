//
//  BSSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSSensorDataManager: BSBaseManager<BSSensorDataMessageType> {
    override class var requiredMessageTypes: [BSSensorDataMessageType]? {
        [
            .getPressurePositions,
            .getSensorScalars
        ]
    }

    override func onRxMessage(_ messageType: BSSensorDataMessageType, data: Data) {
        switch messageType {
        case .getPressurePositions:
            print("FILL")
        case .getSensorScalars:
            print("FILL")
        case .sensorData:
            print("FILL")
        }
    }
}
