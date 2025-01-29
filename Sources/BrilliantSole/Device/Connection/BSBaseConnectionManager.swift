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

    // MARK: - discoveredDevice

    let discoveredDevice: BSDiscoveredDevice
    init(discoveredDevice: BSDiscoveredDevice) {
        self.discoveredDevice = discoveredDevice
        self.name = discoveredDevice.name
        self.deviceType = discoveredDevice.deviceType
    }

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

    var connectionStatus: BSConnectionStatus {
        get { connectionStatusSubject.value }
        set {
            guard newValue != connectionStatus else {
                logger.debug("redundant update to connectionStatus \(newValue.name)")
                return
            }
            logger.debug("updated connectionStatus \(newValue.name)")
            connectionStatusSubject.value = newValue

            switch connectionStatus {
            case .notConnected:
                notConnectedSubject.send()
            case .connecting:
                connectingSubject.send()
            case .connected:
                connectedSubject.send()
            case .disconnecting:
                disconnectingSubject.send()
            }
        }
    }

    var isConnected: Bool { connectionStatus == .connected }

    private let notConnectedSubject: PassthroughSubject<Void, Never> = .init()
    var notConnectedPublisher: AnyPublisher<Void, Never> {
        notConnectedSubject.eraseToAnyPublisher()
    }

    private let connectedSubject: PassthroughSubject<Void, Never> = .init()
    var connectedPublisher: AnyPublisher<Void, Never> {
        connectedSubject.eraseToAnyPublisher()
    }

    private let connectingSubject: PassthroughSubject<Void, Never> = .init()
    var connectingPublisher: AnyPublisher<Void, Never> {
        connectingSubject.eraseToAnyPublisher()
    }

    private let disconnectingSubject: PassthroughSubject<Void, Never> = .init()
    var disconnectingPublisher: AnyPublisher<Void, Never> {
        disconnectingSubject.eraseToAnyPublisher()
    }

    func connect() {
        var _continue = true
        connect(_continue: &_continue)
    }

    func connect(_continue: inout Bool) {
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

    func disconnect(_continue: inout Bool) {
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
