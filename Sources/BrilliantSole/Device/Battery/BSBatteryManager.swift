//
//  BSBatteryManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
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
            parseIsBatteryCharging(data)
        case .getBatteryCurrent:
            parseBatteryCurrent(data)
        }
    }

    override func reset() {
        super.reset()
        isBatteryChargingSubject.value = false
        batteryCurrentSubject.value = 0
    }

    // MARK: - isBatteryCharging

    var isBatteryChargingSubject = CurrentValueSubject<Bool, Never>(false)
    var isBatteryCharging: Bool { isBatteryChargingSubject.value }

    func parseIsBatteryCharging(_ data: Data) {
        let newIsBatteryCharging: Bool = data[0] == 1
        logger.debug("parsed isBatteryCharging: \(newIsBatteryCharging)")
        isBatteryChargingSubject.value = newIsBatteryCharging
    }

    // MARK: - batteryCurrent

    var batteryCurrentSubject = CurrentValueSubject<Float, Never>(0)
    var batteryCurrent: Float { batteryCurrentSubject.value }

    func parseBatteryCurrent(_ data: Data) {
        let newBatteryCurrent: Float = .parse(data, at: 0)
        logger.debug("parsed batteryCurrent: \(newBatteryCurrent)")
        batteryCurrentSubject.value = newBatteryCurrent
    }
}
