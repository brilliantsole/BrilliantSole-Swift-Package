//
//  BSDevicePair.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public final class BSDevicePair {
    // MARK: - shared

    public nonisolated(unsafe) static let shared = BSDevicePair(isShared: true)

    private var isShared: Bool = false

    private convenience init(isShared: Bool) {
        self.init()
        self.isShared = isShared
        guard isShared else { return }
        Self.logger?.debug("initializing shared instance")
        // listenToDeviceManager()
    }

    public init() {
        setupSensorDataManager()
    }

    public func reset() {
        sensorDataManager.reset()
    }

    func listenToDeviceManager() {
        logger?.debug("listening to deviceManager for new devices...")
        BSDeviceManager.availableDevicePublisher.sink { [self] device in
            self.add(device: device)
        }.store(in: &cancellables)
    }

    // MARK: - cancellables

    var cancellables: Set<AnyCancellable> = .init()

    // MARK: - devices

    var devices: [BSInsoleSide: BSDevice] = .init()

    // MARK: - deviceListeners

    var deviceCancellables: [BSDevice: Set<AnyCancellable>] = .init()

    // MARK: - deviceConnection

    let deviceConnectionStatusSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSConnectionStatus), Never> = .init()
    public var deviceConnectionStatusPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSConnectionStatus), Never> {
        deviceConnectionStatusSubject.eraseToAnyPublisher()
    }

    let deviceIsConnectedSubject: PassthroughSubject<(BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceIsConnectedPublisher: AnyPublisher<(BSInsoleSide, BSDevice, Bool), Never> {
        deviceIsConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - connection

    let connectionStatusSubject: CurrentValueSubject<BSDevicePairConnectionStatus, Never> = .init(.notConnected)
    public var connectionStatusPublisher: AnyPublisher<BSDevicePairConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    // MARK: - isFullyConnected

    let isFullyConnectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isFullyConnectedPublisher: AnyPublisher<Bool, Never> {
        isFullyConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - isHalfConnected

    let isHalfConnectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isHalfConnectedPublisher: AnyPublisher<Bool, Never> {
        isHalfConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorConfiguration

    let deviceSensorConfigurationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSSensorConfiguration), Never> = .init()
    public var deviceSensorConfigurationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSSensorConfiguration), Never> {
        deviceSensorConfigurationSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorData

    let sensorDataManager: BSDevicePairSensorDataManager = .init()

    // MARK: - deviceSensorData

    // MARK: - devicePressureSensorData

    let devicePressureDataSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSPressureData, BSTimestamp), Never> = .init()
    public var devicePressureDataPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSPressureData, BSTimestamp), Never> {
        devicePressureDataSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceMotionSensorData

    let deviceAccelerationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceAccelerationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceAccelerationSubject.eraseToAnyPublisher()
    }

    let deviceLinearAccelerationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceLinearAccelerationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceLinearAccelerationSubject.eraseToAnyPublisher()
    }

    let deviceGravitySubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceGravityPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceGravitySubject.eraseToAnyPublisher()
    }

    let deviceGyroscopeSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSRotation3D, BSTimestamp), Never> = .init()
    public var deviceGyroscopePublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSRotation3D, BSTimestamp), Never> {
        deviceGyroscopeSubject.eraseToAnyPublisher()
    }

    let deviceMagnetometerSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceMagnetometerPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceMagnetometerSubject.eraseToAnyPublisher()
    }

    let deviceGameRotationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var deviceGameRotationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> {
        deviceGameRotationSubject.eraseToAnyPublisher()
    }

    let deviceRotationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var deviceRotationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> {
        deviceRotationSubject.eraseToAnyPublisher()
    }

    let deviceOrientationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSRotation3D, BSTimestamp), Never> = .init()
    public var deviceOrientationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSRotation3D, BSTimestamp), Never> {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    let deviceStepCountSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSStepCount, BSTimestamp), Never> = .init()
    public var deviceStepCountPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSStepCount, BSTimestamp), Never> {
        deviceStepCountSubject.eraseToAnyPublisher()
    }

    let deviceStepDetectionSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSTimestamp), Never> = .init()
    public var deviceStepDetectionPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSTimestamp), Never> {
        deviceStepDetectionSubject.eraseToAnyPublisher()
    }

    let deviceActivitySubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSActivityFlags, BSTimestamp), Never> = .init()
    public var deviceActivityPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSActivityFlags, BSTimestamp), Never> {
        deviceActivitySubject.eraseToAnyPublisher()
    }

    let deviceDeviceOrientationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSDeviceOrientation, BSTimestamp), Never> = .init()
    public var deviceDeviceOrientationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSDeviceOrientation, BSTimestamp), Never> {
        deviceDeviceOrientationSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceBarometerSensorData

    let deviceBarometerSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSBarometer, BSTimestamp), Never> = .init()
    public var deviceBarometerPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSBarometer, BSTimestamp), Never> {
        deviceBarometerSubject.eraseToAnyPublisher()
    }

    // MARK: - tflite

    let deviceIsTfliteReadySubject: PassthroughSubject<(BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceIsTfliteReadyPublisher: AnyPublisher<(BSInsoleSide, BSDevice, Bool), Never> {
        deviceIsTfliteReadySubject.eraseToAnyPublisher()
    }

    let deviceTfliteInferencingEnabledSubject: PassthroughSubject<(BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceTfliteInferencingEnabledPublisher: AnyPublisher<(BSInsoleSide, BSDevice, Bool), Never> {
        deviceTfliteInferencingEnabledSubject.eraseToAnyPublisher()
    }

    let deviceTfliteInferenceSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSTfliteInference), Never> = .init()
    public var deviceTfliteInferencePublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSTfliteInference), Never> {
        deviceTfliteInferenceSubject.eraseToAnyPublisher()
    }

    let deviceTfliteClassificationSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSTfliteClassification), Never> = .init()
    public var deviceTfliteClassificationPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSTfliteClassification), Never> {
        deviceTfliteClassificationSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransfer

    let deviceMaxFileLengthSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileLength), Never> = .init()
    public var deviceMaxFileLengthPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileLength), Never> {
        deviceMaxFileLengthSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferStatusSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileTransferStatus), Never> = .init()
    public var deviceFileTransferStatusPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileTransferStatus), Never> {
        deviceFileTransferStatusSubject.eraseToAnyPublisher()
    }

    let deviceFileChecksumSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileChecksum), Never> = .init()
    public var deviceFileChecksumPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileChecksum), Never> {
        deviceFileChecksumSubject.eraseToAnyPublisher()
    }

    let deviceFileLengthSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileLength), Never> = .init()
    public var deviceFileLengthPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileLength), Never> {
        deviceFileLengthSubject.eraseToAnyPublisher()
    }

    let deviceFileTypeSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileType), Never> = .init()
    public var deviceFileTypePublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileType), Never> {
        deviceFileTypeSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferProgressSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection, Float), Never> = .init()
    public var deviceFileTransferProgressPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection, Float), Never> {
        deviceFileTransferProgressSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferCompleteSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection), Never> = .init()
    public var devieceFileTransferCompletePublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection), Never> {
        deviceFileTransferCompleteSubject.eraseToAnyPublisher()
    }

    let deviceFileReceivedSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSFileType, Data), Never> = .init()
    public var deviceFileReceivedPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSFileType, Data), Never> {
        deviceFileReceivedSubject.eraseToAnyPublisher()
    }
}
