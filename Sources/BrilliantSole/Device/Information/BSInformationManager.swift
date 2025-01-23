//
//  BSInformationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSInformationManager: BSBaseManager<BSInformationMessageType> {
    override class var requiredMessageTypes: [BSInformationMessageType]? {
        [
            .getMtu,
            .getId,
            .getName,
            .getDeviceType,
            .getCurrentTime
        ]
    }

    override func onRxMessage(_ messageType: BSInformationMessageType, data: Data) {
        switch messageType {
        case .getMtu:
            print("FILL")
        case .getId:
            print("FILL")
        case .getName:
            print("FILL")
        case .setName:
            print("FILL")
        case .getDeviceType:
            print("FILL")
        case .setDeviceType:
            print("FILL")
        case .getCurrentTime:
            print("FILL")
        case .setCurrentTime:
            print("FILL")
        }
    }
}
