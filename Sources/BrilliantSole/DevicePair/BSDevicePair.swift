//
//  BSDevicePair.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
public actor BSDevicePair {
    // MARK: - shared

    static let shared = BSDevicePair(isShared: true)

    var isShared: Bool { self === Self.shared }

    private init(isShared: Bool) {
        self.init()
        guard isShared else { return }
        Self.logger.debug("initializing shared instance")
        // FILL
    }

    public init() {
        // FILL
    }

    public func reset() {
        // FILL
    }

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

    // FILL

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

    // FILL
}
