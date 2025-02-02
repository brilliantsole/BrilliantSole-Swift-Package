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

    // MARK: - deviceConnection

    let deviceConnectionStatusSubject: PassthroughSubject<(BSInsoleSide, BSDevice, BSConnectionStatus), Never> = .init()
    public var deviceConnectionStatusPublisher: AnyPublisher<(BSInsoleSide, BSDevice, BSConnectionStatus), Never> {
        deviceConnectionStatusSubject.eraseToAnyPublisher()
    }

    let deviceIsConnectedSubject: PassthroughSubject<(BSInsoleSide, BSDevice, Bool), Never> = .init()
    public var deviceIsConnectedPublisher: AnyPublisher<(BSInsoleSide, BSDevice, Bool), Never> {
        deviceIsConnectedSubject.eraseToAnyPublisher()
    }

    var deviceConnectionCancellables: [BSDevice: Set<AnyCancellable>] = .init()

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
}
