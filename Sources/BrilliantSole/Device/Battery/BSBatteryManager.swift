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
        isBatteryCharging = false
        batteryCurrent = 0
    }

    // MARK: - isBatteryCharging

    let isBatteryChargingSubject = CurrentValueSubject<Bool, Never>(false)
    var isBatteryCharging: Bool {
        get { isBatteryChargingSubject.value }
        set {
            logger.debug("updated isBatteryCharging to \(newValue)")
            isBatteryChargingSubject.value = newValue
        }
    }

    func getIsBatteryCharging(sendImmediately: Bool = true) {
        logger.debug("getting isBatteryCharging")
        createAndSendMessage(.getIsBatteryCharging, sendImmediately: sendImmediately)
    }

    func parseIsBatteryCharging(_ data: Data) {
        let newIsBatteryCharging: Bool = data[0] == 1
        logger.debug("parsed isBatteryCharging: \(newIsBatteryCharging)")
        isBatteryCharging = newIsBatteryCharging
    }

    // MARK: - batteryCurrent

    let batteryCurrentSubject = CurrentValueSubject<Float, Never>(0)
    private(set) var batteryCurrent: Float {
        get { batteryCurrentSubject.value }
        set {
            logger.debug("updated batteryCurrent to \(newValue)")
            batteryCurrentSubject.value = newValue
        }
    }

    func getBatteryCurrent(sendImmediately: Bool = true) {
        logger.debug("getting batteryCurrent")
        createAndSendMessage(.getBatteryCurrent, sendImmediately: sendImmediately)
    }

    func parseBatteryCurrent(_ data: Data) {
        let newBatteryCurrent: Float = .parse(data)
        logger.debug("parsed batteryCurrent: \(newBatteryCurrent)")
        batteryCurrent = newBatteryCurrent
    }
}
