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
    public private(set) var type: BSDevicePairType

    // MARK: - shared

    public nonisolated(unsafe) static let insoles = BSDevicePair(type: .insoles, isStatic: true)
    public nonisolated(unsafe) static let gloves = BSDevicePair(type: .gloves, isStatic: true)

    private convenience init(type: BSDevicePairType, isStatic: Bool = false) {
        self.init(type: type)
        listenToDeviceManager()
    }

    public init(type: BSDevicePairType) {
        self.type = type
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

    var devices: [BSSide: BSDevice] = .init()

    // MARK: - deviceListeners

    var deviceCancellables: [BSDevice: Set<AnyCancellable>] = .init()

    // MARK: - deviceConnection

    let deviceConnectionStatusSubject: PassthroughSubject<(BSSide, BSDevice, BSConnectionStatus), Never> = .init()
    public var deviceConnectionStatusPublisher: AnyPublisher<(BSSide, BSDevice, BSConnectionStatus), Never> {
        deviceConnectionStatusSubject.eraseToAnyPublisher()
    }

    let deviceIsConnectedSubject: PassthroughSubject<(BSSide, BSDevice, Bool), Never> = .init()
    public var deviceIsConnectedPublisher: AnyPublisher<(BSSide, BSDevice, Bool), Never> {
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

    let deviceSensorConfigurationSubject: PassthroughSubject<(BSSide, BSDevice, BSSensorConfiguration), Never> = .init()
    public var deviceSensorConfigurationPublisher: AnyPublisher<(BSSide, BSDevice, BSSensorConfiguration), Never> {
        deviceSensorConfigurationSubject.eraseToAnyPublisher()
    }

    // MARK: - sensorData

    let sensorDataManager: BSDevicePairSensorDataManager = .init()

    // MARK: - deviceSensorData

    // MARK: - devicePressureSensorData

    let devicePressureDataSubject: PassthroughSubject<(BSSide, BSDevice, BSPressureData, BSTimestamp), Never> = .init()
    public var devicePressureDataPublisher: AnyPublisher<(BSSide, BSDevice, BSPressureData, BSTimestamp), Never> {
        devicePressureDataSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceMotionSensorData

    let deviceAccelerationSubject: PassthroughSubject<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceAccelerationPublisher: AnyPublisher<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceAccelerationSubject.eraseToAnyPublisher()
    }

    let deviceLinearAccelerationSubject: PassthroughSubject<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceLinearAccelerationPublisher: AnyPublisher<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceLinearAccelerationSubject.eraseToAnyPublisher()
    }

    let deviceGravitySubject: PassthroughSubject<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceGravityPublisher: AnyPublisher<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceGravitySubject.eraseToAnyPublisher()
    }

    let deviceGyroscopeSubject: PassthroughSubject<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceGyroscopePublisher: AnyPublisher<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceGyroscopeSubject.eraseToAnyPublisher()
    }

    let deviceMagnetometerSubject: PassthroughSubject<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> = .init()
    public var deviceMagnetometerPublisher: AnyPublisher<(BSSide, BSDevice, BSVector3D, BSTimestamp), Never> {
        deviceMagnetometerSubject.eraseToAnyPublisher()
    }

    let deviceGameRotationSubject: PassthroughSubject<(BSSide, BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var deviceGameRotationPublisher: AnyPublisher<(BSSide, BSDevice, BSQuaternion, BSTimestamp), Never> {
        deviceGameRotationSubject.eraseToAnyPublisher()
    }

    let deviceRotationSubject: PassthroughSubject<(BSSide, BSDevice, BSQuaternion, BSTimestamp), Never> = .init()
    public var deviceRotationPublisher: AnyPublisher<(BSSide, BSDevice, BSQuaternion, BSTimestamp), Never> {
        deviceRotationSubject.eraseToAnyPublisher()
    }

    let deviceOrientationSubject: PassthroughSubject<(BSSide, BSDevice, BSRotation3D, BSTimestamp), Never> = .init()
    public var deviceOrientationPublisher: AnyPublisher<(BSSide, BSDevice, BSRotation3D, BSTimestamp), Never> {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    let deviceStepCountSubject: PassthroughSubject<(BSSide, BSDevice, BSStepCount, BSTimestamp), Never> = .init()
    public var deviceStepCountPublisher: AnyPublisher<(BSSide, BSDevice, BSStepCount, BSTimestamp), Never> {
        deviceStepCountSubject.eraseToAnyPublisher()
    }

    let deviceStepDetectionSubject: PassthroughSubject<(BSSide, BSDevice, BSTimestamp), Never> = .init()
    public var deviceStepDetectionPublisher: AnyPublisher<(BSSide, BSDevice, BSTimestamp), Never> {
        deviceStepDetectionSubject.eraseToAnyPublisher()
    }

    let deviceActivitySubject: PassthroughSubject<(BSSide, BSDevice, BSActivityFlags, BSTimestamp), Never> = .init()
    public var deviceActivityPublisher: AnyPublisher<(BSSide, BSDevice, BSActivityFlags, BSTimestamp), Never> {
        deviceActivitySubject.eraseToAnyPublisher()
    }

    let deviceDeviceOrientationSubject: PassthroughSubject<(BSSide, BSDevice, BSDeviceOrientation, BSTimestamp), Never> = .init()
    public var deviceDeviceOrientationPublisher: AnyPublisher<(BSSide, BSDevice, BSDeviceOrientation, BSTimestamp), Never> {
        deviceDeviceOrientationSubject.eraseToAnyPublisher()
    }

    let deviceTapDetectionSubject: PassthroughSubject<(BSSide, BSDevice, BSTimestamp), Never> = .init()
    public var deviceTapDetectionPublisher: AnyPublisher<(BSSide, BSDevice, BSTimestamp), Never> {
        deviceTapDetectionSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceBarometerSensorData

    let deviceBarometerSubject: PassthroughSubject<(BSSide, BSDevice, BSBarometer, BSTimestamp), Never> = .init()
    public var deviceBarometerPublisher: AnyPublisher<(BSSide, BSDevice, BSBarometer, BSTimestamp), Never> {
        deviceBarometerSubject.eraseToAnyPublisher()
    }

    // MARK: - tflite

    let deviceIsTfliteReadySubject: PassthroughSubject<(BSSide, BSDevice, Bool), Never> = .init()
    public var deviceIsTfliteReadyPublisher: AnyPublisher<(BSSide, BSDevice, Bool), Never> {
        deviceIsTfliteReadySubject.eraseToAnyPublisher()
    }

    let deviceTfliteInferencingEnabledSubject: PassthroughSubject<(BSSide, BSDevice, Bool), Never> = .init()
    public var deviceTfliteInferencingEnabledPublisher: AnyPublisher<(BSSide, BSDevice, Bool), Never> {
        deviceTfliteInferencingEnabledSubject.eraseToAnyPublisher()
    }

    let deviceTfliteInferenceSubject: PassthroughSubject<(BSSide, BSDevice, BSTfliteInference), Never> = .init()
    public var deviceTfliteInferencePublisher: AnyPublisher<(BSSide, BSDevice, BSTfliteInference), Never> {
        deviceTfliteInferenceSubject.eraseToAnyPublisher()
    }

    let deviceTfliteClassificationSubject: PassthroughSubject<(BSSide, BSDevice, BSTfliteClassification), Never> = .init()
    public var deviceTfliteClassificationPublisher: AnyPublisher<(BSSide, BSDevice, BSTfliteClassification), Never> {
        deviceTfliteClassificationSubject.eraseToAnyPublisher()
    }

    // MARK: - fileTransfer

    let deviceMaxFileLengthSubject: PassthroughSubject<(BSSide, BSDevice, BSFileLength), Never> = .init()
    public var deviceMaxFileLengthPublisher: AnyPublisher<(BSSide, BSDevice, BSFileLength), Never> {
        deviceMaxFileLengthSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferStatusSubject: PassthroughSubject<(BSSide, BSDevice, BSFileTransferStatus), Never> = .init()
    public var deviceFileTransferStatusPublisher: AnyPublisher<(BSSide, BSDevice, BSFileTransferStatus), Never> {
        deviceFileTransferStatusSubject.eraseToAnyPublisher()
    }

    let deviceFileChecksumSubject: PassthroughSubject<(BSSide, BSDevice, BSFileChecksum), Never> = .init()
    public var deviceFileChecksumPublisher: AnyPublisher<(BSSide, BSDevice, BSFileChecksum), Never> {
        deviceFileChecksumSubject.eraseToAnyPublisher()
    }

    let deviceFileLengthSubject: PassthroughSubject<(BSSide, BSDevice, BSFileLength), Never> = .init()
    public var deviceFileLengthPublisher: AnyPublisher<(BSSide, BSDevice, BSFileLength), Never> {
        deviceFileLengthSubject.eraseToAnyPublisher()
    }

    let deviceFileTypeSubject: PassthroughSubject<(BSSide, BSDevice, BSFileType), Never> = .init()
    public var deviceFileTypePublisher: AnyPublisher<(BSSide, BSDevice, BSFileType), Never> {
        deviceFileTypeSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferProgressSubject: PassthroughSubject<(BSSide, BSDevice, BSFileType, BSFileTransferDirection, Float), Never> = .init()
    public var deviceFileTransferProgressPublisher: AnyPublisher<(BSSide, BSDevice, BSFileType, BSFileTransferDirection, Float), Never> {
        deviceFileTransferProgressSubject.eraseToAnyPublisher()
    }

    let deviceFileTransferCompleteSubject: PassthroughSubject<(BSSide, BSDevice, BSFileType, BSFileTransferDirection), Never> = .init()
    public var devieceFileTransferCompletePublisher: AnyPublisher<(BSSide, BSDevice, BSFileType, BSFileTransferDirection), Never> {
        deviceFileTransferCompleteSubject.eraseToAnyPublisher()
    }

    let deviceFileReceivedSubject: PassthroughSubject<(BSSide, BSDevice, BSFileType, Data), Never> = .init()
    public var deviceFileReceivedPublisher: AnyPublisher<(BSSide, BSDevice, BSFileType, Data), Never> {
        deviceFileReceivedSubject.eraseToAnyPublisher()
    }
}
