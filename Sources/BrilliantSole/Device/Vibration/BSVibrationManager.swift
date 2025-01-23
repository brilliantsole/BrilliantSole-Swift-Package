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

    func triggerVibration(_ vibrationConfigurations: [BSVibrationConfiguration], sendImmediately: Bool = true) {
        var data: Data = .init()
        for vibrationConfiguration in vibrationConfigurations {
            data += vibrationConfiguration.getData()
        }
        guard data.count == 0 else {
            logger.debug("empty data - nothing to sen")
            return
        }
        let message = createMessage(.triggerVibration, data: data)
        sendTxMessages([message], sendImmediately: sendImmediately)
    }
}
