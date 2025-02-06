//
//  BSBaseClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSBaseClient: BSBaseScanner, BSDeviceClient, BSClient {
    override init() {
        super.init()

        self.isScanningAvailablePublisher.sink { isScanningAvailable in
            if isScanningAvailable {
                self.checkIfScanning()
            }
        }.store(in: &cancellables)
    }

    private var cancellables: Set<AnyCancellable> = []

    func reset() {
        logger.debug("resetting")

        isScanning = false
        isScanningAvailable = false

        discoveredDevices.removeAll()
        // devices.removeAll()

        for (_, device) in devices {
            guard let connectionManager = device.connectionManager as? BSClientConnectionManager else {
                logger.debug("failed to cast connectionManager to BSClientConnectionManager")
                continue
            }
            connectionManager.isConnected = false
        }
    }

    // MARK: - requiredMessages

    static let requiredMessageTypes: [BSServerMessageType] = [.isScanningAvailable, .discoveredDevices, .connectedDevices]
    static let requiredMessages: [BSServerMessage] = requiredMessageTypes.compactMap { .init(type: $0) }

    // MARK: - scanning

    override public func startScan(scanWhenAvailable: Bool, _continue: inout Bool) {
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

    lazy var connectionStatusSubject: CurrentValueSubject<(BSClient, BSConnectionStatus), Never> = .init((self, self.connectionStatus))
    var connectionStatusPublisher: AnyPublisher<(BSClient, BSConnectionStatus), Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    public internal(set) var connectionStatus: BSConnectionStatus = .notConnected {
        didSet {
            logger.debug("updated connectionStatus \(self.connectionStatus.name)")

            connectionStatusSubject.send((self, connectionStatus))

            switch connectionStatus {
            case .notConnected:
                notConnectedSubject.send(self)
            case .connecting:
                connectingSubject.send(self)
            case .connected:
                connectedSubject.send(self)
            case .disconnecting:
                disconnectingSubject.send(self)
            }

            switch connectionStatus {
            case .connected, .notConnected:
                isConnectedSubject.send((self, isConnected))
            default:
                break
            }

            switch connectionStatus {
            case .connected:
                sendRequiredMessages()
            case .notConnected:
                reset()
                if disconnectedUnintentionally && reconnectOnDisconnection {
                    logger.debug("attempting reconnection")
                    connect()
                    disconnectedUnintentionally = false
                }
            default:
                break
            }
        }
    }

    private let notConnectedSubject: PassthroughSubject<BSDeviceClient, Never> = .init()
    var notConnectedPublisher: AnyPublisher<BSDeviceClient, Never> {
        notConnectedSubject.eraseToAnyPublisher()
    }

    private let connectedSubject: PassthroughSubject<BSDeviceClient, Never> = .init()
    var connectedPublisher: AnyPublisher<BSDeviceClient, Never> {
        connectedSubject.eraseToAnyPublisher()
    }

    private let connectingSubject: PassthroughSubject<BSDeviceClient, Never> = .init()
    var connectingPublisher: AnyPublisher<BSDeviceClient, Never> {
        connectingSubject.eraseToAnyPublisher()
    }

    private let disconnectingSubject: PassthroughSubject<BSDeviceClient, Never> = .init()
    var disconnectingPublisher: AnyPublisher<BSDeviceClient, Never> {
        disconnectingSubject.eraseToAnyPublisher()
    }

    // MARK: - isConnected

    lazy var isConnectedSubject: CurrentValueSubject<(BSClient, Bool), Never> = .init((self, self.isConnected))
    var isConnectedPublisher: AnyPublisher<(BSClient, Bool), Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    var isConnected: Bool { connectionStatus == .connected }

    // MARK: - connection

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

    func toggleConnection() {
        switch connectionStatus {
        case .connected, .connecting:
            disconnect()
        default:
            connect()
        }
    }

    public var reconnectOnDisconnection: Bool = true
    var disconnectedUnintentionally: Bool = false
}
