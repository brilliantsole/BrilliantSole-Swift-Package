//
//  BSSensorConfigurationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSSensorConfigurationManager: BSBaseManager<BSSensorConfigurationMessageType> {
    override class var requiredMessageTypes: [BSSensorConfigurationMessageType]? {
        [.getSensorConfiguration]
    }

    override func onRxMessage(_ messageType: BSSensorConfigurationMessageType, data: Data) {
        switch messageType {
        case .getSensorConfiguration:
            print("FILL")
        case .setSensorConfiguration:
            print("FILL")
        }
    }
}
