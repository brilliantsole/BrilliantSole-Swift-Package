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
public actor BSDeviceManager {
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
        logger.debug("adding device")
        device.isConnectedPublisher.sink { _ in
            logger.debug("device \(device.name) isConnected? \(device.isConnected)")
            onDeviceIsConnected(device)
        }.store(in: &cancellables)
    }

    static func onDeviceIsConnected(_ device: BSDevice) {
        if device.isConnected {
            logger.debug("adding \(device.name) to connectedDevices")
            connectedDevices.insert(device)
            deviceConnectedSubject.send(device)
            if !availableDevices.contains(device) {
                logger.debug("adding \(device.name) to availableDevices")
                availableDevices.insert(device)
                availableDevicesSubject.send(availableDevices)
                availableDeviceSubject.send(device)
            }
        }
        else if connectedDevices.contains(device) {
            logger.debug("removing \(device.name) from connectedDevices")
            connectedDevices.remove(device)
            deviceDisconnectedSubject.send(device)
        }
        if availableDevices.contains(device) {
            logger.debug("updating connectedDevicesSubject and isDeviceConnectedSubject for \(device.name)")
            connectedDevicesSubject.send(connectedDevices)
            isDeviceConnectedSubject.send((device, device.isConnected))
        }
    }
}
