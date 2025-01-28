//
//  BSDevice.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSDevice {
    // MARK: - init

    init() {
        // FILL
    }

    convenience init(name: String, deviceType: BSDeviceType?) {
        // FILL
        self.init()
    }

    convenience init(discoveredDevice: BSDiscoveredDevice) {
        self.init(name: discoveredDevice.name, deviceType: discoveredDevice.deviceType)
    }

    // MARK: - connectionManager

    var connectionManager: BSConnectionManager? {
        didSet {
            // FILL
        }
    }

    // MARK: - connectionStatus

    private let connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(.notConnected)
    var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    private(set) var connectionStatus: BSConnectionStatus {
        get { connectionStatusSubject.value }
        set {
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

    // MARK: - isConnected

    private let isConnectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    private(set) var isConnected: Bool {
        get { isConnectedSubject.value }
        set {
            logger.debug("updated isConnected \(newValue)")
            isConnectedSubject.value = newValue
        }
    }
}
