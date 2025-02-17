//
//  BSDeviceManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/31/25.
//

@preconcurrency import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public final class BSDeviceManager {
    // MARK: - availableDevices

    public private(set) nonisolated(unsafe) static var availableDevices: [BSDevice] = .init()
    private static let availableDevicesSubject: PassthroughSubject<[BSDevice], Never> = .init()
    public static var availableDevicesPublisher: AnyPublisher<[BSDevice], Never> {
        availableDevicesSubject.eraseToAnyPublisher()
    }

    private static let availableDeviceSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var availableDevicePublisher: AnyPublisher<BSDevice, Never> {
        availableDeviceSubject.eraseToAnyPublisher()
    }

    // MARK: - connectedDevices

    public private(set) nonisolated(unsafe) static var connectedDevices: [BSDevice] = .init()
    private static let connectedDevicesSubject: PassthroughSubject<[BSDevice], Never> = .init()
    public static var connectedDevicesPublisher: AnyPublisher<[BSDevice], Never> {
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

    private nonisolated(unsafe) static var cancellables: Set<AnyCancellable> = .init()
    static func onDeviceCreated(_ device: BSDevice) {
        logger?.debug("adding device")
        device.isConnectedPublisher.sink { _ in
            logger?.debug("device \(device.name) isConnected? \(device.isConnected)")
            onDeviceIsConnected(device)
        }.store(in: &cancellables)
    }

    static func onDeviceIsConnected(_ device: BSDevice) {
        if device.isConnected {
            logger?.debug("adding \(device.name) to connectedDevices")
            connectedDevices.append(device)
            deviceConnectedSubject.send(device)
            if !availableDevices.contains(device) {
                logger?.debug("adding \(device.name) to availableDevices")
                availableDevices.append(device)
                availableDevicesSubject.send(availableDevices)
                availableDeviceSubject.send(device)
                BSDevicePair.shared.add(device: device)
            }
        }
        else if connectedDevices.contains(device) {
            logger?.debug("removing \(device.name) from connectedDevices")
            connectedDevices.removeAll(where: { $0 == device })
            deviceDisconnectedSubject.send(device)
        }
        if availableDevices.contains(device) {
            logger?.debug("updating connectedDevicesSubject and isDeviceConnectedSubject for \(device.name)")
            connectedDevicesSubject.send(connectedDevices)
            isDeviceConnectedSubject.send((device, device.isConnected))
        }
    }
}
