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
@MainActor
public final class BSDeviceManager: ObservableObject {
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

    public typealias isDeviceConnectedSubjectType = (device: BSDevice, isConnected: Bool)
    private static let isDeviceConnectedSubject: PassthroughSubject<isDeviceConnectedSubjectType, Never> = .init()
    public static var isDeviceConnectedPublisher: AnyPublisher<isDeviceConnectedSubjectType, Never> {
        isDeviceConnectedSubject.eraseToAnyPublisher()
    }

    // MARK: - deviceCreation

    static var cancellables: Set<AnyCancellable> = .init()
    static func onDeviceCreated(_ device: BSDevice) {
        logger.debug("adding device \(device.name)...")
        device.isConnectedPublisher.sink { _ in
            onDeviceIsConnected(device)
        }.store(in: &cancellables)
    }

    static func onDeviceIsConnected(_ device: BSDevice) {
        logger.debug("\(device.name) isConnected? \(device.isConnected)")
        if device.isConnected {
            connectedDevices.insert(device)
            deviceConnectedSubject.send(device)
            if !availableDevices.contains(device) {
                availableDevices.insert(device)
                availableDevicesSubject.send(availableDevices)
                availableDeviceSubject.send(device)
            }
            // FILL - devicePair
        }
        else {
            connectedDevices.remove(device)
            deviceDisconnectedSubject.send(device)
        }
        connectedDevicesSubject.send(connectedDevices)
        isDeviceConnectedSubject.send((device, device.isConnected))
    }
}
