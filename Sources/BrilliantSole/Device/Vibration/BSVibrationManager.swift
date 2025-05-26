//
//  BSVibrationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: false)
final class BSVibrationManager: BSBaseManager<BSVibrationMessageType> {
    override class var requiredMessageTypes: [BSVibrationMessageType]? {
        [.getVibrationLocations]
    }

    override func onRxMessage(_ messageType: BSVibrationMessageType, data: Data) {
        switch messageType {
        case .getVibrationLocations:
            parseVibrationLocations(data)
        case .triggerVibration:
            // nothing to do
            break
        }
    }

    // MARK: - vibrationLocations

    private let vibrationLocationsSubject: CurrentValueSubject<BSVibrationLocationFlags, Never> = .init(.init())
    var vibrationLocationsPublisher: AnyPublisher<BSVibrationLocationFlags, Never> {
        vibrationLocationsSubject.eraseToAnyPublisher()
    }

    private(set) var vibrationLocations: BSVibrationLocationFlags {
        get { vibrationLocationsSubject.value }
        set {
            vibrationLocationsSubject.value = newValue
            logger?.debug("updated vibrationLocations to \(newValue)")
        }
    }

    func getVibrationLocations(sendImmediately: Bool = true) {
        logger?.debug("getting vibrationLocations")
        createAndSendMessage(.getVibrationLocations, sendImmediately: sendImmediately)
    }

    private func parseVibrationLocations(_ data: Data) {
        guard let newVibrationLocations = BSVibrationLocationFlags.parse(data) else { return }
        logger?.debug("parsed vibrationLocations \(newVibrationLocations)")
        vibrationLocations = newVibrationLocations
    }

    // MARK: - triggerVibration

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
