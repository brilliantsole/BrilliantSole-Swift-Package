//
//  BSDevice.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import iOSMcuManagerLibrary
import OSLog
import UkatonMacros

@StaticLogger(disabled: false)
public final class BSDevice: BSConnectable, BSMetaDevice {
    public nonisolated(unsafe) static let mock = BSDevice(isMock: true)
    public let isMock: Bool

    // MARK: - init

    init(isMock: Bool = false) {
        self.isMock = isMock
        if self.isMock {
            informationManager.initName("mock device")
            deviceInformationManager.deviceInformation = mockDeviceInformation
            _ = BSTxRxMessageUtils.enumStrings
        }
        setupManagers()

        if !isMock {
            BSDeviceManager.onDeviceCreated(self)
        }
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
        discoveredDevice.device = self
    }

    func reset() {
        batteryLevel = 0
        didReceiveBatteryLevel = false
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

    lazy var connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(self.connectionStatus)
    public var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    public internal(set) var connectionStatus: BSConnectionStatus = .notConnected {
        didSet {
            guard connectionStatus != oldValue else { return }
            logger?.debug("updated connectionStatus \(self.connectionStatus.name)")

            updateCanUpgradeFirmware()

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

    // MARK: - batteryLevel

    lazy var batteryLevelSubject: CurrentValueSubject<BSBatteryLevel, Never> = .init(self.batteryLevel)
    public var batteryLevelPublisher: AnyPublisher<BSBatteryLevel, Never> {
        batteryLevelSubject.eraseToAnyPublisher()
    }

    var didReceiveBatteryLevel: Bool = false

    public internal(set) var batteryLevel: BSBatteryLevel = 0 {
        didSet {
            guard batteryLevel != oldValue else { return }
            didReceiveBatteryLevel = true
            batteryLevelSubject.send(batteryLevel)
        }
    }

    // MARK: - batteryManager

    // MARK: - deviceInformation

    let deviceInformationManager: BSDeviceInformationManager = .init()

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

    // MARK: - isTfliteReady

    lazy var isTfliteReadySubject: CurrentValueSubject<Bool, Never> = .init(self.isTfliteReady)
    public var isTfliteReadyPublisher: AnyPublisher<Bool, Never> {
        isTfliteReadySubject.eraseToAnyPublisher()
    }

    public internal(set) var isTfliteReady: Bool = false {
        didSet {
            logger?.debug("updated isTfliteReady \(self.isTfliteReady)")
            isTfliteReadySubject.send(isTfliteReady)
        }
    }

    // MARK: - firmware

    let firmwareManager: BSFirmwareManager = .init()

    let canUpgradeFirmwareSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var canUpgradeFirmwarePublisher: AnyPublisher<Bool, Never> {
        canUpgradeFirmwareSubject.eraseToAnyPublisher()
    }

    public internal(set) var canUpgradeFirmware: Bool = false {
        didSet {
            guard canUpgradeFirmware != oldValue else { return }
            canUpgradeFirmwareSubject.send(canUpgradeFirmware)
        }
    }

    // MARK: - availability

    public var isAvailable: Bool { connectionManager?.isAvailable ?? false }
}

extension BSDevice: Identifiable {}

extension BSDevice: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public static func == (lhs: BSDevice, rhs: BSDevice) -> Bool {
        guard let lhsType = lhs.connectionType, let rhsType = lhs.connectionType, lhsType == rhsType else {
            return false
        }

        return !lhs.id.isEmpty && lhs.id == rhs.id
    }
}
