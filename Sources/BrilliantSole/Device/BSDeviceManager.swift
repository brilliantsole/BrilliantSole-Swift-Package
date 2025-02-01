//
//  BSDeviceManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/31/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
@Singleton
@MainActor
public class BSDeviceManager {
    // MARK: - availableDevices

    public private(set) static var availableDevices: Set<BSDevice> = .init()
    private static let availableDevicesSubject: PassthroughSubject<Set<BSDevice>, Never> = .init()
    public static var availableDevicesPublisher: AnyPublisher<Set<BSDevice>, Never> {
        availableDevicesSubject.eraseToAnyPublisher()
    }

    private static let availableDeviceSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var availableDevicePublisher: AnyPublisher<BSDevice, Never> {
        availableDeviceSubject.eraseToAnyPublisher()
    }

    // MARK: - connectedDevices

    public private(set) static var connectedDevices: Set<BSDevice> = .init()
    private static let connectedDevicesSubject: PassthroughSubject<Set<BSDevice>, Never> = .init()
    public static var connectedDevicesPublisher: AnyPublisher<Set<BSDevice>, Never> {
        connectedDevicesSubject.eraseToAnyPublisher()
    }

    private static let deviceConnectedSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var deviceConnectedPublisher: AnyPublisher<BSDevice, Never> {
        deviceConnectedSubject.eraseToAnyPublisher()
    }

    private static let deviceDisconnectedSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var deviceDisconnectedPublisher: AnyPublisher<BSDevice, Never> {
        deviceDisconnectedSubject.eraseToAnyPublisher()
    }

    private static let isDeviceConnectedSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var isDeviceConnectedPublisher: AnyPublisher<BSDevice, Never> {
        isDeviceConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceCreation
}
