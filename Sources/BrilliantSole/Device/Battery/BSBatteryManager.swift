//
//  BSBatteryManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSBatteryManager: BSBaseManager<BSBatteryMessageType> {
    override class var requiredMessageTypes: [BSBatteryMessageType]? {
        [.getIsBatteryCharging, .getBatteryCurrent]
    }

    override func onRxMessage(_ messageType: BSBatteryMessageType, data: Data) {
        switch messageType {
        case .getIsBatteryCharging:
            print("FILL")
        case .getBatteryCurrent:
            print("FILL")
        }
    }
}
