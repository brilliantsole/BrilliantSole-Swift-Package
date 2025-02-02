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
public final class BSDevice {
    // MARK: - init

    init() {
        setupManagers()
        BSDeviceManager.onDeviceCreated(self)
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

    private let connectionStatusSubject: PassthroughSubject<(BSDevice, BSConnectionStatus), Never> = .init()
    var connectionStatusPublisher: AnyPublisher<(BSDevice, BSConnectionStatus), Never> {
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
        }
    }

    private let notConnectedSubject: PassthroughSubject<BSDevice, Never> = .init()
    var notConnectedPublisher: AnyPublisher<BSDevice, Never> {
        notConnectedSubject.eraseToAnyPublisher()
    }

    private let connectedSubject: PassthroughSubject<BSDevice, Never> = .init()
    var connectedPublisher: AnyPublisher<BSDevice, Never> {
        connectedSubject.eraseToAnyPublisher()
    }

    private let connectingSubject: PassthroughSubject<BSDevice, Never> = .init()
    var connectingPublisher: AnyPublisher<BSDevice, Never> {
        connectingSubject.eraseToAnyPublisher()
    }

    private let disconnectingSubject: PassthroughSubject<BSDevice, Never> = .init()
    var disconnectingPublisher: AnyPublisher<BSDevice, Never> {
        disconnectingSubject.eraseToAnyPublisher()
    }

    // MARK: - isConnected

    private let isConnectedSubject: PassthroughSubject<(BSDevice, Bool), Never> = .init()
    var isConnectedPublisher: AnyPublisher<(BSDevice, Bool), Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    var isConnected: Bool { connectionStatus == .connected }

    // MARK: - batteryLevel

    private let batteryLevelSubject: PassthroughSubject<(BSDevice, BSBatteryLevel), Never> = .init()
    var batteryLevelPublisher: AnyPublisher<(BSDevice, BSBatteryLevel), Never> {
        batteryLevelSubject.eraseToAnyPublisher()
    }

    var didReceiveBatteryLevel: Bool = false

    public internal(set) var batteryLevel: BSBatteryLevel = 0 {
        didSet {
            logger.debug("updated batteryLevel \(self.batteryLevel)")
            didReceiveBatteryLevel = true
            batteryLevelSubject.send((self, batteryLevel))
        }
    }

    // MARK: - deviceInformation

    let deviceInformationSubject: PassthroughSubject<(BSDevice, BSDeviceInformation), Never> = .init()
    public var deviceInformationPublisher: AnyPublisher<(BSDevice, BSDeviceInformation), Never> {
        deviceInformationSubject.eraseToAnyPublisher()
    }

    let deviceInformationManager: BSDeviceInformationManager = .init()
    public internal(set) var deviceInformation: BSDeviceInformation = .init() {
        didSet {
            logger.debug("updated deviceInformation \(self.deviceInformation)")
            deviceInformationSubject.send((self, deviceInformation))
        }
    }

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

    // MARK: - tfliteInferencingEnabled

    private let tfliteInferencingEnabledSubject: PassthroughSubject<(BSDevice, Bool), Never> = .init()
    public var tfliteInferencingEnabledPublisher: AnyPublisher<(BSDevice, Bool), Never> {
        tfliteInferencingEnabledSubject.eraseToAnyPublisher()
    }

    // MARK: - isTfliteReady

    let isTfliteReadySubject: PassthroughSubject<(BSDevice, Bool), Never> = .init()
    public var isTfliteReadyPublisher: AnyPublisher<(BSDevice, Bool), Never> {
        isTfliteReadySubject.eraseToAnyPublisher()
    }

    public internal(set) var isTfliteReady: Bool = false {
        didSet {
            logger.debug("updated isTfliteReady \(self.isTfliteReady)")
            isTfliteReadySubject.send((self, isTfliteReady))
        }
    }

    // MARK: - tfliteInference

    let tfliteInferenceSubject: PassthroughSubject<(BSDevice, BSInference), Never> = .init()
    public var tfliteInferencePublisher: AnyPublisher<(BSDevice, BSInference), Never> {
        tfliteInferenceSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteClassification

    let tfliteClassificationSubject: PassthroughSubject<(BSDevice, BSClassification), Never> = .init()
    var tfliteClassificationPublisher: AnyPublisher<(BSDevice, BSClassification), Never> {
        tfliteClassificationSubject.eraseToAnyPublisher()
    }
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
