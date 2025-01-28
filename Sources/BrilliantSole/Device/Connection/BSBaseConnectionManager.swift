//
//  BSBaseConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import OSLog

private let logger = getLogger(category: "BSBaseConnectionManager")

class BSBaseConnectionManager: NSObject, BSConnectionManager {
    class var connectionType: BSConnectionType { fatalError("Must override") }

    // MARK: - device information

    var name: String?
    var deviceType: BSDeviceType?

    private let batteryLevelSubject: PassthroughSubject<BSBatteryLevel, Never> = .init()
    var batteryLevelPublisher: AnyPublisher<BSBatteryLevel, Never> {
        batteryLevelSubject.eraseToAnyPublisher()
    }

    private let deviceInformationSubject: PassthroughSubject<(BSDeviceInformationType, BSDeviceInformationValue), Never> = .init()
    var deviceInformationPublisher: AnyPublisher<(BSDeviceInformationType, BSDeviceInformationValue), Never> {
        deviceInformationSubject.eraseToAnyPublisher()
    }

    // MARK: - connection

    private let connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(.notConnected)
    var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    private(set) var connectionStatus: BSConnectionStatus {
        get { connectionStatusSubject.value }
        set {
            logger.debug("updated connectionStatus to \(newValue.name)")
            connectionStatusSubject.value = newValue
        }
    }

    private(set) var isConnected: Bool = false

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

    private let rxMessageSubject: PassthroughSubject<(UInt8, Data), Never> = .init()
    var rxMessagePublisher: AnyPublisher<(UInt8, Data), Never> {
        rxMessageSubject.eraseToAnyPublisher()
    }

    private let rxMessagesSubject: PassthroughSubject<Void, Never> = .init()
    var rxMessagesPublisher: AnyPublisher<Void, Never> {
        rxMessagesSubject.eraseToAnyPublisher()
    }

    private let sendTxDataSubject: PassthroughSubject<Void, Never> = .init()
    var sendTxDataPublisher: AnyPublisher<Void, Never> {
        sendTxDataSubject.eraseToAnyPublisher()
    }

    func parseRxData(_ data: Data) {
        logger.debug("parsing \(data.count) bytes")
        parseMessages(data, messageCallback: { (messageType: UInt8, data: Data) in
            self.parseRxMessage(messageType: messageType, data: data)
        })
    }

    func parseRxMessage(messageType: UInt8, data: Data) {
        logger.debug("parsing rxMessage \(messageType) \(data)")
        rxMessageSubject.send((messageType, data))
    }
}
