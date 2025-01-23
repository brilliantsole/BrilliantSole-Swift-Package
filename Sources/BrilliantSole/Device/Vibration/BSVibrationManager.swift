//
//  BSVibrationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//
import OSLog
import UkatonMacros

@StaticLogger
class BSVibrationManager: BSBaseManager<BSVibrationMessageType> {
    override class var requiredMessageTypes: [BSVibrationMessageType]? {
        nil
    }

    override func onRxMessage(_ messageType: BSVibrationMessageType, data: Data) {}
}
