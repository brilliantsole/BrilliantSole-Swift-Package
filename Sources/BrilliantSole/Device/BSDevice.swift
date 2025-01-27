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

    // MARK: - connection

    var connectionManager: BSConnectionManager? {
        didSet {
            // FILL
        }
    }

    let connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(.notConnected)
    private(set) var connectionStatus: BSConnectionStatus {
        get { connectionStatusSubject.value }
        set {
            connectionStatusSubject.value = newValue
            logger.debug("updated connectionStatus \(self.connectionStatus.name)")

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

    let notConnectedSubject: PassthroughSubject<Void, Never> = .init()
    let connectedSubject: PassthroughSubject<Void, Never> = .init()
    let connectingSubject: PassthroughSubject<Void, Never> = .init()
    let disconnectingSubject: PassthroughSubject<Void, Never> = .init()

    let isConnectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private(set) var isConnected: Bool {
        get { isConnectedSubject.value }
        set {
            isConnectedSubject.value = newValue
            logger.debug("updated isConnected \(self.isConnected)")
        }
    }
}
