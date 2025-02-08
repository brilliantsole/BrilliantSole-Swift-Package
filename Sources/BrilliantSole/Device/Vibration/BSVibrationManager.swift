//
//  BSVibrationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
final class BSVibrationManager: BSBaseManager<BSVibrationMessageType> {
    override class var requiredMessageTypes: [BSVibrationMessageType]? {
        nil
    }

    override func onRxMessage(_ messageType: BSVibrationMessageType, data: Data) {}

    func triggerVibration(_ vibrationConfigurations: BSVibrationConfigurations, sendImmediately: Bool = true) {
        var data: Data = .init()
        for vibrationConfiguration in vibrationConfigurations {
            if let vibrationData = vibrationConfiguration.getData() {
                data += vibrationData
            }
        }
        guard !data.isEmpty else {
            logger?.debug("empty data - nothing to send")
            return
        }
        logger?.debug("vibrationData: \(data.count) bytes - \(data.bytes)")
        createAndSendMessage(.triggerVibration, data: data, sendImmediately: sendImmediately)
    }
}
