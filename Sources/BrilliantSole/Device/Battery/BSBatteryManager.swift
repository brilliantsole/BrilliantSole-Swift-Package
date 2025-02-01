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
final class BSBatteryManager: BSBaseManager<BSBatteryMessageType> {
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

    private let isBatteryChargingSubject = CurrentValueSubject<Bool, Never>(false)
    var isBatteryChargingPublisher: AnyPublisher<Bool, Never> {
        isBatteryChargingSubject.eraseToAnyPublisher()
    }

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

    private func parseIsBatteryCharging(_ data: Data) {
        guard let newIsBatteryCharging = Bool.parse(data) else { return }
        logger.debug("parsed isBatteryCharging: \(newIsBatteryCharging)")
        isBatteryCharging = newIsBatteryCharging
    }

    // MARK: - batteryCurrent

    private let batteryCurrentSubject = CurrentValueSubject<Float, Never>(0)
    var batteryCurrentPublisher: AnyPublisher<Float, Never> {
        batteryCurrentSubject.eraseToAnyPublisher()
    }

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

    private func parseBatteryCurrent(_ data: Data) {
        guard let newBatteryCurrent = Float.parse(data) else { return }
        logger.debug("parsed batteryCurrent: \(newBatteryCurrent)")
        batteryCurrent = newBatteryCurrent
    }
}
