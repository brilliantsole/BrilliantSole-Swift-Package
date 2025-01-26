//
//  BSBaseConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import OSLog

private let logger = getLogger(category: "BSBaseConnectionManager")

class BSBaseConnectionManager: BSConnectionManager {
    class var connectionType: BSConnectionType { fatalError("Must override") }

    // MARK: - device information

    var name: String?
    var deviceType: BSDeviceType?

    let batteryLevelSubject: PassthroughSubject<BSBatteryLevel, Never> = .init()
    let deviceInformationSubject: PassthroughSubject<(BSDeviceInformationType, BSDeviceInformationValue), Never> = .init()

    // MARK: - connection

    var connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(.notConnected)
    var connectionStatus: BSConnectionStatus {
        get { connectionStatusSubject.value }
        set {
            connectionStatusSubject.value = newValue
            logger.debug("updated connectionStatus to \(newValue.name)")
        }
    }

    var isConnected: Bool = false
    func connect() {
        var _continue = true
        connect(_continue: &_continue)
    }

    private func connect(_continue: inout Bool) {
        guard !isConnected else {
            logger.debug("already connected")
            _continue = false
            return
        }
        connectionStatus = .connecting
        _continue = true
    }

    func disconnect() {
        var _continue = true
        disconnect(_continue: &_continue)
    }

    private func disconnect(_continue: inout Bool) {
        guard connectionStatus != .notConnected else {
            logger.debug("already disconnected")
            _continue = false
            return
        }
        guard connectionStatus != .disconnecting else {
            logger.debug("already disconnecting")
            _continue = false
            return
        }
        connectionStatus = .disconnecting
        _continue = true
    }

    // MARK: - messaging

    let rxMessageSubject: PassthroughSubject<(UInt8, Data), Never> = .init()
    let rxMessagesSubject: PassthroughSubject<Void, Never> = .init()
    let sendTxDataSubject: PassthroughSubject<Void, Never> = .init()

    func parseRxData(_ data: Data) {
        logger.debug("parsing \(data.count) bytes")
        parseMessages(data, messageCallback: { [self] (messageType: UInt8, data: Data) in
            parseRxMessage(messageType: messageType, data: data)
        })
    }

    func parseRxMessage(messageType: UInt8, data: Data) {
        logger.debug("parsing rxMessage \(messageType) \(data)")
        rxMessageSubject.send((messageType, data))
    }
}
