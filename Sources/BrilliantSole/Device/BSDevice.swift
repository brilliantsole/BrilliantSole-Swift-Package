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
public class BSDevice {
    // MARK: - init

    init() {
        setupManagers()
        // BSDeviceManager.shared.add(device: self) FILL
    }

    convenience init(name: String, deviceType: BSDeviceType?) {
        self.init()
        informationManager.initName(name)
        if let deviceType {
            informationManager.initDeviceType(deviceType)
        }
    }

    convenience init(discoveredDevice: BSDiscoveredDevice) {
        self.init(name: discoveredDevice.name, deviceType: discoveredDevice.deviceType)
    }

    func reset() {
        batteryLevel = 0
        resetTxMessaging()
        resetRxMessaging()
        deviceInformationManager.reset()
        resetManagers()
        connectionStatus = .notConnected
    }

    // MARK: - connectionManager

    var connectionManagerCancellables: Set<AnyCancellable> = []
    var connectionManager: (any BSConnectionManager)? {
        didSet { onConnectionManagerChanged() }
    }

    // MARK: - connectionStatus

    private let connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(.notConnected)
    var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    public internal(set) var connectionStatus: BSConnectionStatus {
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

            switch connectionStatus {
            case .connected, .notConnected:
                isConnectedSubject.send(isConnected)
            default:
                break
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

    var isConnected: Bool { connectionStatus == .connected }

    // MARK: - batteryLevel

    private let batteryLevelSubject: CurrentValueSubject<BSBatteryLevel, Never> = .init(0)
    var batteryLevelPublisher: AnyPublisher<BSBatteryLevel, Never> {
        batteryLevelSubject.eraseToAnyPublisher()
    }

    public internal(set) var batteryLevel: BSBatteryLevel {
        get { batteryLevelSubject.value }
        set {
            guard newValue != batteryLevel else {
                logger.debug("redundant batteryLevel \(newValue)")
                return
            }
            batteryLevelSubject.value = newValue
        }
    }

    // MARK: - deviceInformation

    let deviceInformationManager: BSDeviceInformationManager = .init()
    public var deviceInformation: BSDeviceInformation { deviceInformationManager.deviceInformation }
    var deviceInformationPublisher: AnyPublisher<BSDeviceInformation, Never> { deviceInformationManager.deviceInformationPublisher }

    // MARK: - managers

    let batteryManager: BSBatteryManager = .init()
    let informationManager: BSInformationManager = .init()
    let sensorConfigurationManager: BSSensorConfigurationManager = .init()
    let sensorDataManager: BSSensorDataManager = .init()
    let vibrationManager: BSVibrationManager = .init()
    let fileTransferManager: BSFileTransferManager = .init()
    let tfliteManager: BSTfliteManager = .init()
    let smpManager: BSSmpManager = .init()

    var managerCancellables: Set<AnyCancellable> = []

    // MARK: - txMessage

    var pendingTxMessages: [BSTxMessage] = .init()
    var isSendingTxData: Bool = false

    var txData: Data = .init()

    // MARK: - rxMessage

    var receivedTxRxMessages: Set<BSTxMessageType> = .init()

    // MARK: - tfliteManager

    let isTfliteReadySubject: CurrentValueSubject<Bool, Never> = .init(false)
}
