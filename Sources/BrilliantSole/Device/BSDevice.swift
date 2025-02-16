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

@StaticLogger(disabled: true)
public final class BSDevice: ObservableObject, BSConnectable, BSDeviceMetadata {
    public nonisolated(unsafe) static let none = BSDevice(isNone: true)
    private let isNone: Bool

    // MARK: - init

    init(isNone: Bool = false) {
        self.isNone = isNone
        setupManagers()

        if !isNone {
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

    // MARK: - batteryCurrent

    lazy var batteryCurrentSubject: CurrentValueSubject<Float, Never> = .init(self.batteryCurrent)
    public var batteryCurrentPublisher: AnyPublisher<Float, Never> {
        batteryCurrentSubject.eraseToAnyPublisher()
    }

    // MARK: - isBatteryCharging

    lazy var isBatteryChargingSubject: CurrentValueSubject<Bool, Never> = .init(self.isBatteryCharging)
    public var isBatteryChargingPublisher: AnyPublisher<Bool, Never> {
        isBatteryChargingSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceInformation

    lazy var deviceInformationSubject: CurrentValueSubject<BSDeviceInformation, Never> = .init(self.deviceInformation)
    public var deviceInformationPublisher: AnyPublisher<BSDeviceInformation, Never> {
        deviceInformationSubject.eraseToAnyPublisher()
    }

    let deviceInformationManager: BSDeviceInformationManager = .init()
    public var deviceInformation: BSDeviceInformation { deviceInformationManager.deviceInformation }

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

    // MARK: - informationManager

    // MARK: - id

    lazy var idSubject: CurrentValueSubject<String, Never> = .init(self.id)
    public var idPublisher: AnyPublisher<String, Never> {
        idSubject.eraseToAnyPublisher()
    }

    // MARK: - mtu

    lazy var mtuSubject: CurrentValueSubject<BSMtu, Never> = .init(self.mtu)
    public var mtuPublisher: AnyPublisher<BSMtu, Never> {
        mtuSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceType

    lazy var deviceTypeSubject: CurrentValueSubject<BSDeviceType, Never> = .init(self.deviceType)
    public var deviceTypePublisher: AnyPublisher<BSDeviceType, Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    // MARK: - name

    lazy var nameSubject: CurrentValueSubject<String, Never> = .init(self.name)
    public var namePublisher: AnyPublisher<String, Never> {
        nameSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorConfigurationManager

    lazy var sensorConfigurationSubject: CurrentValueSubject<BSSensorConfiguration, Never> = .init(self.sensorConfiguration)
    public var sensorConfigurationPublisher: AnyPublisher<BSSensorConfiguration, Never> {
        sensorConfigurationSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorDataManager

    // MARK: - pressure

    let pressureDataSubject: PassthroughSubject<(BSPressureData, BSTimestamp), Never> = .init()
    public var pressureDataPublisher: AnyPublisher<(BSPressureData, BSTimestamp), Never> {
        pressureDataSubject.eraseToAnyPublisher()
    }

    // MARK: - motion

    let accelerationSubject: PassthroughSubject<(BSVector3D, BSTimestamp), Never> = .init()
    public var accelerationPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        accelerationSubject.eraseToAnyPublisher()
    }

    let linearAccelerationSubject: PassthroughSubject<(BSVector3D, BSTimestamp), Never> = .init()
    public var linearAccelerationPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        linearAccelerationSubject.eraseToAnyPublisher()
    }

    let gravitySubject: PassthroughSubject<(BSVector3D, BSTimestamp), Never> = .init()
    public var gravityPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        gravitySubject.eraseToAnyPublisher()
    }

    let gyroscopeSubject: PassthroughSubject<(BSVector3D, BSTimestamp), Never> = .init()
    public var gyroscopePublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        gyroscopeSubject.eraseToAnyPublisher()
    }

    let magnetometerSubject: PassthroughSubject<(BSVector3D, BSTimestamp), Never> = .init()
    public var magnetometerPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        magnetometerSubject.eraseToAnyPublisher()
    }

    let gameRotationSubject: PassthroughSubject<(BSQuaternion, BSTimestamp), Never> = .init()
    public var gameRotationPublisher: AnyPublisher<(BSQuaternion, BSTimestamp), Never> {
        gameRotationSubject.eraseToAnyPublisher()
    }

    let rotationSubject: PassthroughSubject<(BSQuaternion, BSTimestamp), Never> = .init()
    public var rotationPublisher: AnyPublisher<(BSQuaternion, BSTimestamp), Never> {
        rotationSubject.eraseToAnyPublisher()
    }

    let orientationSubject: PassthroughSubject<(BSRotation3D, BSTimestamp), Never> = .init()
    public var orientationPublisher: AnyPublisher<(BSRotation3D, BSTimestamp), Never> {
        orientationSubject.eraseToAnyPublisher()
    }

    let stepCountSubject: PassthroughSubject<(BSStepCount, BSTimestamp), Never> = .init()
    public var stepCountPublisher: AnyPublisher<(BSStepCount, BSTimestamp), Never> {
        stepCountSubject.eraseToAnyPublisher()
    }

    let stepDetectionSubject: PassthroughSubject<BSTimestamp, Never> = .init()
    public var stepDetectionPublisher: AnyPublisher<BSTimestamp, Never> {
        stepDetectionSubject.eraseToAnyPublisher()
    }

    let activitySubject: PassthroughSubject<(BSActivityFlags, BSTimestamp), Never> = .init()
    public var activityPublisher: AnyPublisher<(BSActivityFlags, BSTimestamp), Never> {
        activitySubject.eraseToAnyPublisher()
    }

    let deviceOrientationSubject: PassthroughSubject<(BSDeviceOrientation, BSTimestamp), Never> = .init()
    public var deviceOrientationPublisher: AnyPublisher<(BSDeviceOrientation, BSTimestamp), Never> {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    // MARK: - barometer

    let barometerSubject: PassthroughSubject<(BSBarometer, BSTimestamp), Never> = .init()
    public var barometerPublisher: AnyPublisher<(BSBarometer, BSTimestamp), Never> {
        barometerSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferManager

    // MARK: - maxFileLength

    lazy var maxFileLengthSubject: CurrentValueSubject<BSFileLength, Never> = .init(self.maxFileLength)
    public var maxFileLengthPublisher: AnyPublisher<BSFileLength, Never> {
        maxFileLengthSubject.eraseToAnyPublisher()
    }

    // MARK: - fileType

    lazy var fileTypeSubject: CurrentValueSubject<BSFileType, Never> = .init(self.fileType)
    public var fileTypePublisher: AnyPublisher<BSFileType, Never> {
        fileTypeSubject.eraseToAnyPublisher()
    }

    // MARK: - fileLength

    lazy var fileLengthSubject: CurrentValueSubject<BSFileLength, Never> = .init(self.fileLength)
    public var fileLengthPublisher: AnyPublisher<BSFileLength, Never> {
        fileLengthSubject.eraseToAnyPublisher()
    }

    // MARK: - fileChecksum

    lazy var fileChecksumSubject: CurrentValueSubject<BSFileChecksum, Never> = .init(self.fileChecksum)
    public var fileChecksumPublisher: AnyPublisher<BSFileChecksum, Never> {
        fileChecksumSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferStatus

    lazy var fileTransferStatusSubject: CurrentValueSubject<BSFileTransferStatus, Never> = .init(self.fileTransferStatus)
    public var fileTransferStatusPublisher: AnyPublisher<BSFileTransferStatus, Never> {
        fileTransferStatusSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferProgress

    let fileTransferProgressSubject: PassthroughSubject<(BSFileType, BSFileTransferDirection, Float), Never> = .init()
    public var fileTransferProgressPublisher: AnyPublisher<(BSFileType, BSFileTransferDirection, Float), Never> {
        fileTransferProgressSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferComplete

    let fileReceivedSubject: PassthroughSubject<(BSFileType, Data), Never> = .init()
    public var fileReceivedPublisher: AnyPublisher<(BSFileType, Data), Never> {
        fileReceivedSubject.eraseToAnyPublisher()
    }

    // MARK: - fileReceived

    let fileTransferCompleteSubject: PassthroughSubject<(BSFileType, BSFileTransferDirection), Never> = .init()
    public var fileTransferCompletePublisher: AnyPublisher<(BSFileType, BSFileTransferDirection), Never> {
        fileTransferCompleteSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteManager

    // MARK: - tfliteName

    lazy var tfliteNameSubject: CurrentValueSubject<String, Never> = .init(self.tfliteName)
    public var tfliteNamePublisher: AnyPublisher<String, Never> {
        tfliteNameSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteTask

    lazy var tfliteTaskSubject: CurrentValueSubject<BSTfliteTask, Never> = .init(self.tfliteTask)
    public var tfliteTaskPublisher: AnyPublisher<BSTfliteTask, Never> {
        tfliteTaskSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteSensorRate

    lazy var tfliteSensorRateSubject: CurrentValueSubject<BSSensorRate, Never> = .init(self.tfliteSensorRate)
    public var tfliteSensorRatePublisher: AnyPublisher<BSSensorRate, Never> {
        tfliteSensorRateSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteSensorTypes

    lazy var tfliteSensorTypesSubject: CurrentValueSubject<BSTfliteSensorTypes, Never> = .init(self.tfliteSensorTypes)
    public var tfliteSensorTypesPublisher: AnyPublisher<BSTfliteSensorTypes, Never> {
        tfliteSensorTypesSubject.eraseToAnyPublisher()
    }

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

    // MARK: - tfliteThreshold

    lazy var tfliteThresholdSubject: CurrentValueSubject<BSTfliteThreshold, Never> = .init(self.tfliteThreshold)
    public var tfliteThresholdPublisher: AnyPublisher<BSTfliteThreshold, Never> {
        tfliteThresholdSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteCaptureDelay

    lazy var tfliteCaptureDelaySubject: CurrentValueSubject<BSTfliteCaptureDelay, Never> = .init(self.tfliteCaptureDelay)
    public var tfliteCaptureDelayPublisher: AnyPublisher<BSTfliteCaptureDelay, Never> {
        tfliteCaptureDelaySubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteInferencingEnabled

    lazy var tfliteInferencingEnabledSubject: CurrentValueSubject<Bool, Never> = .init(self.tfliteInferencingEnabled)
    public var tfliteInferencingEnabledPublisher: AnyPublisher<Bool, Never> {
        tfliteInferencingEnabledSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteInference

    let tfliteInferenceSubject: PassthroughSubject<BSTfliteInference, Never> = .init()
    public var tfliteInferencePublisher: AnyPublisher<BSTfliteInference, Never> {
        tfliteInferenceSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteClassification

    let tfliteClassificationSubject: PassthroughSubject<BSTfliteClassification, Never> = .init()
    public var tfliteClassificationPublisher: AnyPublisher<BSTfliteClassification, Never> {
        tfliteClassificationSubject.eraseToAnyPublisher()
    }

    // MARK: - firmware

    let firmwareManager: BSFirmwareManager = .init()

    public internal(set) var canUpgradeFirmware: Bool = false

    let firmwareUpgradeDidStartSubject: PassthroughSubject<Void, Never> = .init()
    public var firmwareUpgradeDidStartPublisher: AnyPublisher<Void, Never> {
        firmwareUpgradeDidStartSubject.eraseToAnyPublisher()
    }

    let firmwareUpgradeStateDidChangeSubject: PassthroughSubject<(FirmwareUpgradeState, FirmwareUpgradeState), Never> = .init()
    public var firmwareUpgradeStateDidChangePublisher: AnyPublisher<(FirmwareUpgradeState, FirmwareUpgradeState), Never> {
        firmwareUpgradeStateDidChangeSubject.eraseToAnyPublisher()
    }

    let firmwareUpgradeDidCompleteSubject: PassthroughSubject<Void, Never> = .init()
    public var firmwareUpgradeDidCompletePublisher: AnyPublisher<Void, Never> {
        firmwareUpgradeDidCompleteSubject.eraseToAnyPublisher()
    }

    let firmwareUpgradeDidFailSubject: PassthroughSubject<(FirmwareUpgradeState, any Error), Never> = .init()
    public var firmwareUpgradeDidFailPublisher: AnyPublisher<(FirmwareUpgradeState, any Error), Never> {
        firmwareUpgradeDidFailSubject.eraseToAnyPublisher()
    }

    let firmwareUpgradeDidCancelSubject: PassthroughSubject<FirmwareUpgradeState, Never> = .init()
    public var firmwareUpgradeDidCancelPublisher: AnyPublisher<FirmwareUpgradeState, Never> {
        firmwareUpgradeDidCancelSubject.eraseToAnyPublisher()
    }

    let firmwareUploadProgressDidChangeSubject: PassthroughSubject<(Int, Int, Float, Date), Never> = .init()
    public var firmwareUploadProgressDidChangePublisher: AnyPublisher<(Int, Int, Float, Date), Never> {
        firmwareUploadProgressDidChangeSubject.eraseToAnyPublisher()
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
