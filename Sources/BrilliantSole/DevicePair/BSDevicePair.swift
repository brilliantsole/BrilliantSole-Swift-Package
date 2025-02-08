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

    nonisolated(unsafe) static let shared = BSDevicePair(isShared: true)

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

    let deviceConnectionStatusSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSConnectionStatus), Never> = .init()
    public var deviceConnectionStatusPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSConnectionStatus), Never> {
        deviceConnectionStatusSubject.eraseToAnyPublisher()
    }

    let deviceIsConnectedSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceIsConnectedPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, Bool), Never> {
        deviceIsConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - connection

    // MARK: - isFullyConnected

    let isFullyConnectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isFullyConnectedPublisher: AnyPublisher<Bool, Never> {
        isFullyConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - isHalfConnected

    let isHalfConnectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isHalfConnectedPublisher: AnyPublisher<Bool, Never> {
        isHalfConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorConfiguration

    let deviceSensorConfigurationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSSensorConfiguration), Never> = .init()
    public var deviceSensorConfigurationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSSensorConfiguration), Never> {
        deviceSensorConfigurationSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorData

    let sensorDataManager: BSDevicePairSensorDataManager = .init()

    // MARK: - deviceSensorData

    // MARK: - devicePressureSensorData

    let devicePressureDataSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSPressureData, BSTimestamp), Never> = .init()
    public var devicePressureDataPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSPressureData, BSTimestamp), Never> {
        devicePressureDataSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceMotionSensorData

    let deviceAccelerationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceAccelerationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceAccelerationSubject.eraseToAnyPublisher()
    }

    let deviceLinearAccelerationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceLinearAccelerationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceLinearAccelerationSubject.eraseToAnyPublisher()
    }

    let deviceGravitySubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceGravityPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceGravitySubject.eraseToAnyPublisher()
    }

    let deviceGyroscopeSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceGyroscopePublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceGyroscopeSubject.eraseToAnyPublisher()
    }

    let deviceMagnetometerSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceMagnetometerPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceMagnetometerSubject.eraseToAnyPublisher()
    }

    let deviceGameRotationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var deviceGameRotationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> {
        deviceGameRotationSubject.eraseToAnyPublisher()
    }

    let deviceRotationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var deviceRotationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSQuaternion, BSTimestamp), Never> {
        deviceRotationSubject.eraseToAnyPublisher()
    }

    let deviceOrientationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSRotation3D, BSTimestamp), Never> = .init()
    public var deviceOrientationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSRotation3D, BSTimestamp), Never> {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    let deviceStepCountSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSStepCount, BSTimestamp), Never> = .init()
    public var deviceStepCountPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSStepCount, BSTimestamp), Never> {
        deviceStepCountSubject.eraseToAnyPublisher()
    }

    let deviceStepDetectionSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSTimestamp), Never> = .init()
    public var deviceStepDetectionPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSTimestamp), Never> {
        deviceStepDetectionSubject.eraseToAnyPublisher()
    }

    let deviceActivitySubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSActivityFlags, BSTimestamp), Never> = .init()
    public var deviceActivityPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSActivityFlags, BSTimestamp), Never> {
        deviceActivitySubject.eraseToAnyPublisher()
    }

    let deviceDeviceOrientationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSDeviceOrientation, BSTimestamp), Never> = .init()
    public var deviceDeviceOrientationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSDeviceOrientation, BSTimestamp), Never> {
        deviceDeviceOrientationSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceBarometerSensorData

    let deviceBarometerSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSBarometer, BSTimestamp), Never> = .init()
    public var deviceBarometerPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSBarometer, BSTimestamp), Never> {
        deviceBarometerSubject.eraseToAnyPublisher()
    }

    // MARK: - pressureSensorData

    let pressureDataSubject: PassthroughSubject<(BSDevicePair, BSDevicePairPressureData, BSTimestamp), Never> = .init()
    public var pressureDataPublisher: AnyPublisher<(BSDevicePair, BSDevicePairPressureData, BSTimestamp), Never> {
        pressureDataSubject.eraseToAnyPublisher()
    }

    // MARK: - tflite

    let deviceIsTfliteReadySubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceIsTfliteReadyPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, Bool), Never> {
        deviceIsTfliteReadySubject.eraseToAnyPublisher()
    }

    let deviceTfliteInferencingEnabledSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceTfliteInferencingEnabledPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, Bool), Never> {
        deviceTfliteInferencingEnabledSubject.eraseToAnyPublisher()
    }

    let deviceTfliteInferenceSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSTfliteInference), Never> = .init()
    public var deviceTfliteInferencePublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSTfliteInference), Never> {
        deviceTfliteInferenceSubject.eraseToAnyPublisher()
    }

    let deviceTfliteClassificationSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSTfliteClassification), Never> = .init()
    public var deviceTfliteClassificationPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSTfliteClassification), Never> {
        deviceTfliteClassificationSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransfer

    let deviceMaxFileLengthSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileLength), Never> = .init()
    public var deviceMaxFileLengthPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileLength), Never> {
        deviceMaxFileLengthSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferStatusSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileTransferStatus), Never> = .init()
    public var deviceFileTransferStatusPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileTransferStatus), Never> {
        deviceFileTransferStatusSubject.eraseToAnyPublisher()
    }

    let deviceFileChecksumSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileChecksum), Never> = .init()
    public var deviceFileChecksumPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileChecksum), Never> {
        deviceFileChecksumSubject.eraseToAnyPublisher()
    }

    let deviceFileLengthSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileLength), Never> = .init()
    public var deviceFileLengthPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileLength), Never> {
        deviceFileLengthSubject.eraseToAnyPublisher()
    }

    let deviceFileTypeSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType), Never> = .init()
    public var deviceFileTypePublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType), Never> {
        deviceFileTypeSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferProgressSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection, Float), Never> = .init()
    public var deviceFileTransferProgressPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection, Float), Never> {
        deviceFileTransferProgressSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferCompleteSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection), Never> = .init()
    public var devieceFileTransferCompletePublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType, BSFileTransferDirection), Never> {
        deviceFileTransferCompleteSubject.eraseToAnyPublisher()
    }

    let deviceFileReceivedSubject: PassthroughSubject<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType, Data), Never> = .init()
    public var deviceFileReceivedPublisher: AnyPublisher<(BSDevicePair, BSInsoleSide, BSDevice, BSFileType, Data), Never> {
        deviceFileReceivedSubject.eraseToAnyPublisher()
    }
}
