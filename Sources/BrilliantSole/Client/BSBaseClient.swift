//
//  BSBaseClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public class BSBaseClient: BSBaseScanner, BSDeviceClient, BSClient {
    public var connectionType: BSConnectionType? { nil }

    override init() {
        super.init()

        self.isScanningAvailablePublisher.sink { isScanningAvailable in
            if isScanningAvailable {
                self.checkIfScanning(sendImmediately: false)
            }
        }.store(in: &cancellables)
    }

    private var cancellables: Set<AnyCancellable> = []

    func reset() {
        logger?.debug("resetting")

        isScanning = false
        isScanningAvailable = false

        discoveredDevicesMap.removeAll()
        devices.removeAll()

        discoveredDevices.removeAll()
        discoveredDevicesSubject.value = discoveredDevices

        pendingMessages.removeAll()

        receivedMessageTypes.removeAll()

        for (_, device) in devices {
            guard let connectionManager = device.connectionManager as? BSClientConnectionManager else {
                logger?.debug("failed to cast connectionManager to BSClientConnectionManager")
                continue
            }
            // FILL
            connectionManager.isConnected = false
        }
    }

    // MARK: - requiredMessages

    static let requiredMessageTypes: [BSServerMessageType] = [.isScanningAvailable, .discoveredDevices, .connectedDevices]
    static let requiredMessages: [BSServerMessage] = requiredMessageTypes.compactMap { .init(type: $0) }

    // MARK: - scanning

    override func startScan(scanWhenAvailable: Bool, _continue: inout Bool) {
        super.startScan(scanWhenAvailable: scanWhenAvailable, _continue: &_continue)
        guard _continue else {
            return
        }
        sendMessages([.init(type: .startScan)])
    }

    override public func stopScan(_continue: inout Bool) {
        super.stopScan(_continue: &_continue)
        guard _continue else {
            return
        }
        sendMessages([.init(type: .stopScan)])
    }

    // MARK: - devices

    override func createDevice(discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        let device = super.createDevice(discoveredDevice: discoveredDevice)
        let connectionManager: BSClientConnectionManager = .init(discoveredDevice: discoveredDevice, client: self)
        device.connectionManager = connectionManager
        return device
    }

    // MARK: - connection

    lazy var connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(self.connectionStatus)
    public var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    public internal(set) var connectionStatus: BSConnectionStatus = .notConnected {
        didSet {
            logger?.debug("updated connectionStatus \(self.connectionStatus.name)")

            connectionStatusSubject.send(connectionStatus)

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

            switch connectionStatus {
            case .connected, .notConnected:
                isConnectedSubject.send(isConnected)
            default:
                break
            }

            switch connectionStatus {
            case .connected:
                // sendRequiredMessages(sendImmediately: false)
                break
            case .notConnected:
                reset()
                if disconnectedUnintentionally && reconnectOnDisconnection {
                    logger?.debug("attempting reconnection")
                    connect()
                    disconnectedUnintentionally = false
                }
            default:
                break
            }
        }
    }

    private let notConnectedSubject: PassthroughSubject<Void, Never> = .init()
    public var notConnectedPublisher: AnyPublisher<Void, Never> {
        notConnectedSubject.eraseToAnyPublisher()
    }

    private let connectedSubject: PassthroughSubject<Void, Never> = .init()
    public var connectedPublisher: AnyPublisher<Void, Never> {
        connectedSubject.eraseToAnyPublisher()
    }

    private let connectingSubject: PassthroughSubject<Void, Never> = .init()
    public var connectingPublisher: AnyPublisher<Void, Never> {
        connectingSubject.eraseToAnyPublisher()
    }

    private let disconnectingSubject: PassthroughSubject<Void, Never> = .init()
    public var disconnectingPublisher: AnyPublisher<Void, Never> {
        disconnectingSubject.eraseToAnyPublisher()
    }

    // MARK: - isConnected

    lazy var isConnectedSubject: CurrentValueSubject<Bool, Never> = .init(self.isConnected)
    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    public var isConnected: Bool { connectionStatus == .connected }

    // MARK: - connection

    public func connect() {
        var _continue = true
        connect(_continue: &_continue)
    }

    func connect(_continue: inout Bool) {
        guard !isConnected else {
            logger?.debug("already connected")
            _continue = false
            return
        }
        connectionStatus = .connecting
        _continue = true
    }

    public func disconnect() {
        var _continue = true
        disconnect(_continue: &_continue)
    }

    func disconnect(_continue: inout Bool) {
        guard connectionStatus != .notConnected else {
            logger?.debug("already disconnected")
            _continue = false
            return
        }
        guard connectionStatus != .disconnecting else {
            logger?.debug("already disconnecting")
            _continue = false
            return
        }
        connectionStatus = .disconnecting
        _continue = true
    }

    public func toggleConnection() {
        switch connectionStatus {
        case .connected, .connecting:
            disconnect()
        default:
            connect()
        }
    }

    public var reconnectOnDisconnection: Bool = true
    var disconnectedUnintentionally: Bool = false

    // MARK: - messaging

    private var pendingMessages: [BSServerMessage] = .init()
    func sendMessages(_ serverMessages: [BSServerMessage], sendImmediately: Bool = true) {
        logger?.debug("requesting to send \(serverMessages.count) messages")
        pendingMessages += serverMessages
        guard sendImmediately else {
            logger?.debug("not sending serverMessages immediately")
            return
        }
        sendPendingMessages()
    }

    func sendPendingMessages() {
        guard !pendingMessages.isEmpty else {
            logger?.debug("pendingMessages is empty, not sending")
            return
        }
        var data: Data = .init()
        for message in pendingMessages {
            logger?.debug("appending \(message.type.name) serverMessage")
            message.appendTo(&data)
        }
        pendingMessages.removeAll()

        guard !data.isEmpty else {
            logger?.debug("data is empty, not sending")
            return
        }
        logger?.debug("sending \(data.count) bytes...")
        sendMessageData(data)
    }

    func sendMessageData(_ data: Data) {
        logger?.debug("sending \(data.count) bytes...")
    }

    // MARK: - fullyConnected

    var receivedMessageTypes: Set<BSServerMessageType> = []
    func checkIfFullyConnected() {
        guard connectionStatus == .connecting else { return }

        logger?.debug("checking if fully connected...")

        guard receivedMessageTypes.contains(.isScanningAvailable) else {
            logger?.debug("didn't receive isScanningAvailable yet - not fully connected")
            return
        }
        if isScanningAvailable {
            guard receivedMessageTypes.contains(.isScanning) else {
                logger?.debug("didn't receive isScanning yet - not fully connected")
                return
            }
        }

        logger?.debug("fully connected")
        connectionStatus = .connected
    }
}
