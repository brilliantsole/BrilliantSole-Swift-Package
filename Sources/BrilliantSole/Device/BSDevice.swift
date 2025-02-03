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

    // MARK: - batteryManager

    // MARK: - batteryCurrent

    let batteryCurrentSubject: PassthroughSubject<(BSDevice, Float), Never> = .init()
    var batteryCurrentPublisher: AnyPublisher<(BSDevice, Float), Never> {
        batteryCurrentSubject.eraseToAnyPublisher()
    }

    // MARK: - isBatteryCharging

    let isBatteryChargingSubject: PassthroughSubject<(BSDevice, Bool), Never> = .init()
    var isBatteryChargingPublisher: AnyPublisher<(BSDevice, Bool), Never> {
        isBatteryChargingSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceInformation

    let deviceInformationSubject: PassthroughSubject<(BSDevice, BSDeviceInformation), Never> = .init()
    public var deviceInformationPublisher: AnyPublisher<(BSDevice, BSDeviceInformation), Never> {
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

    let idSubject: PassthroughSubject<(BSDevice, String), Never> = .init()
    public var idPublisher: AnyPublisher<(BSDevice, String), Never> {
        idSubject.eraseToAnyPublisher()
    }

    // MARK: - mtu

    let mtuSubject: PassthroughSubject<(BSDevice, BSMtu), Never> = .init()
    public var mtuPublisher: AnyPublisher<(BSDevice, BSMtu), Never> {
        mtuSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceType

    let deviceTypeSubject: PassthroughSubject<(BSDevice, BSDeviceType), Never> = .init()
    public var deviceTypePublisher: AnyPublisher<(BSDevice, BSDeviceType), Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    // MARK: - name

    let nameSubject: PassthroughSubject<(BSDevice, String), Never> = .init()
    public var namePublisher: AnyPublisher<(BSDevice, String), Never> {
        nameSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorConfigurationManager

    let sensorConfigurationSubject: PassthroughSubject<(BSDevice, BSSensorConfiguration), Never> = .init()
    public var sensorConfigurationPublisher: AnyPublisher<(BSDevice, BSSensorConfiguration), Never> {
        sensorConfigurationSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorDataManager

    // MARK: - pressure

    let pressureDataSubject: PassthroughSubject<(BSDevice, BSPressureData, BSTimestamp), Never> = .init()
    public var pressureDataPublisher: AnyPublisher<(BSDevice, BSPressureData, BSTimestamp), Never> {
        pressureDataSubject.eraseToAnyPublisher()
    }

    // MARK: - motion

    let accelerationSubject: PassthroughSubject<(BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var accelerationPublisher: AnyPublisher<(BSDevice, BSVector3D, BSTimestamp), Never> {
        accelerationSubject.eraseToAnyPublisher()
    }

    let linearAccelerationSubject: PassthroughSubject<(BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var linearAccelerationPublisher: AnyPublisher<(BSDevice, BSVector3D, BSTimestamp), Never> {
        linearAccelerationSubject.eraseToAnyPublisher()
    }

    let gravitySubject: PassthroughSubject<(BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var gravityPublisher: AnyPublisher<(BSDevice, BSVector3D, BSTimestamp), Never> {
        gravitySubject.eraseToAnyPublisher()
    }

    let gyroscopeSubject: PassthroughSubject<(BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var gyroscopePublisher: AnyPublisher<(BSDevice, BSVector3D, BSTimestamp), Never> {
        gyroscopeSubject.eraseToAnyPublisher()
    }

    let magnetometerSubject: PassthroughSubject<(BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var magnetometerPublisher: AnyPublisher<(BSDevice, BSVector3D, BSTimestamp), Never> {
        magnetometerSubject.eraseToAnyPublisher()
    }

    let gameRotationSubject: PassthroughSubject<(BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var gameRotationPublisher: AnyPublisher<(BSDevice, BSQuaternion, BSTimestamp), Never> {
        gameRotationSubject.eraseToAnyPublisher()
    }

    let rotationSubject: PassthroughSubject<(BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var rotationPublisher: AnyPublisher<(BSDevice, BSQuaternion, BSTimestamp), Never> {
        rotationSubject.eraseToAnyPublisher()
    }

    let orientationSubject: PassthroughSubject<(BSDevice, BSRotation3D, BSTimestamp), Never> = .init()
    public var orientationPublisher: AnyPublisher<(BSDevice, BSRotation3D, BSTimestamp), Never> {
        orientationSubject.eraseToAnyPublisher()
    }

    let stepCountSubject: PassthroughSubject<(BSDevice, BSStepCount, BSTimestamp), Never> = .init()
    public var stepCountPublisher: AnyPublisher<(BSDevice, BSStepCount, BSTimestamp), Never> {
        stepCountSubject.eraseToAnyPublisher()
    }

    let stepDetectionSubject: PassthroughSubject<(BSDevice, BSTimestamp), Never> = .init()
    public var stepDetectionPublisher: AnyPublisher<(BSDevice, BSTimestamp), Never> {
        stepDetectionSubject.eraseToAnyPublisher()
    }

    let activitySubject: PassthroughSubject<(BSDevice, BSActivityFlags, BSTimestamp), Never> = .init()
    public var activityPublisher: AnyPublisher<(BSDevice, BSActivityFlags, BSTimestamp), Never> {
        activitySubject.eraseToAnyPublisher()
    }

    let deviceOrientationSubject: PassthroughSubject<(BSDevice, BSDeviceOrientation, BSTimestamp), Never> = .init()
    public var deviceOrientationPublisher: AnyPublisher<(BSDevice, BSDeviceOrientation, BSTimestamp), Never> {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    // MARK: - barometer

    let barometerSubject: PassthroughSubject<(BSDevice, BSBarometer, BSTimestamp), Never> = .init()
    public var barometerPublisher: AnyPublisher<(BSDevice, BSBarometer, BSTimestamp), Never> {
        barometerSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferManager

    // MARK: - maxFileLength

    let maxFileLengthSubject: PassthroughSubject<(BSDevice, BSFileLength), Never> = .init()
    public var maxFileLengthPublisher: AnyPublisher<(BSDevice, BSFileLength), Never> {
        maxFileLengthSubject.eraseToAnyPublisher()
    }

    // MARK: - fileType

    let fileTypeSubject: PassthroughSubject<(BSDevice, BSFileType), Never> = .init()
    public var fileTypePublisher: AnyPublisher<(BSDevice, BSFileType), Never> {
        fileTypeSubject.eraseToAnyPublisher()
    }

    // MARK: - fileLength

    let fileLengthSubject: PassthroughSubject<(BSDevice, BSFileLength), Never> = .init()
    public var fileLengthPublisher: AnyPublisher<(BSDevice, BSFileLength), Never> {
        fileLengthSubject.eraseToAnyPublisher()
    }

    // MARK: - fileChecksum

    let fileChecksumSubject: PassthroughSubject<(BSDevice, BSFileChecksum), Never> = .init()
    public var fileChecksumPublisher: AnyPublisher<(BSDevice, BSFileChecksum), Never> {
        fileChecksumSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferStatus

    let fileTransferStatusSubject: PassthroughSubject<(BSDevice, BSFileTransferStatus), Never> = .init()
    public var fileTransferStatusPublisher: AnyPublisher<(BSDevice, BSFileTransferStatus), Never> {
        fileTransferStatusSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferProgress

    let fileTransferProgressSubject: PassthroughSubject<(BSDevice, BSFileType, BSFileTransferDirection, Float), Never> = .init()
    public var fileTransferProgressPublisher: AnyPublisher<(BSDevice, BSFileType, BSFileTransferDirection, Float), Never> {
        fileTransferProgressSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransferComplete

    let fileReceivedSubject: PassthroughSubject<(BSDevice, BSFileType, Data), Never> = .init()
    public var fileReceivedPublisher: AnyPublisher<(BSDevice, BSFileType, Data), Never> {
        fileReceivedSubject.eraseToAnyPublisher()
    }

    // MARK: - fileReceived

    let fileTransferCompleteSubject: PassthroughSubject<(BSDevice, BSFileType, BSFileTransferDirection), Never> = .init()
    public var fileTransferCompletePublisher: AnyPublisher<(BSDevice, BSFileType, BSFileTransferDirection), Never> {
        fileTransferCompleteSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteManager

    // MARK: - tfliteName

    let tfliteNameSubject: PassthroughSubject<(BSDevice, String), Never> = .init()
    public var tfliteNamePublisher: AnyPublisher<(BSDevice, String), Never> {
        tfliteNameSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteTask

    let tfliteTaskSubject: PassthroughSubject<(BSDevice, BSTfliteTask), Never> = .init()
    public var tfliteTaskPublisher: AnyPublisher<(BSDevice, BSTfliteTask), Never> {
        tfliteTaskSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteSensorRate

    let tfliteSensorRateSubject: PassthroughSubject<(BSDevice, BSSensorRate), Never> = .init()
    public var tfliteSensorRatePublisher: AnyPublisher<(BSDevice, BSSensorRate), Never> {
        tfliteSensorRateSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteSensorTypes

    let tfliteSensorTypesSubject: PassthroughSubject<(BSDevice, BSTfliteSensorTypes), Never> = .init()
    public var tfliteSensorTypesPublisher: AnyPublisher<(BSDevice, BSTfliteSensorTypes), Never> {
        tfliteSensorTypesSubject.eraseToAnyPublisher()
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

    // MARK: - tfliteThreshold

    let tfliteThresholdSubject: PassthroughSubject<(BSDevice, BSTfliteThreshold), Never> = .init()
    public var tfliteThresholdPublisher: AnyPublisher<(BSDevice, BSTfliteThreshold), Never> {
        tfliteThresholdSubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteCaptureDelay

    let tfliteCaptureDelaySubject: PassthroughSubject<(BSDevice, BSTfliteCaptureDelay), Never> = .init()
    public var tfliteCaptureDelayPublisher: AnyPublisher<(BSDevice, BSTfliteCaptureDelay), Never> {
        tfliteCaptureDelaySubject.eraseToAnyPublisher()
    }

    // MARK: - tfliteInferencingEnabled

    let tfliteInferencingEnabledSubject: PassthroughSubject<(BSDevice, Bool), Never> = .init()
    public var tfliteInferencingEnabledPublisher: AnyPublisher<(BSDevice, Bool), Never> {
        tfliteInferencingEnabledSubject.eraseToAnyPublisher()
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
