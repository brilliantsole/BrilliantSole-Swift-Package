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
    private static let availableDevicesSubject: CurrentValueSubject<[BSDevice], Never> = .init([])
    public static var availableDevicesPublisher: AnyPublisher<[BSDevice], Never> {
        availableDevicesSubject.eraseToAnyPublisher()
    }

    private static let availableDeviceSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var availableDevicePublisher: AnyPublisher<BSDevice, Never> {
        availableDeviceSubject.eraseToAnyPublisher()
    }

    private static let unavailableDeviceSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var unavailableDevicePublisher: AnyPublisher<BSDevice, Never> {
        unavailableDeviceSubject.eraseToAnyPublisher()
    }

    // MARK: - connectedDevices

    public private(set) nonisolated(unsafe) static var connectedDevices: [BSDevice] = .init()
    private static let connectedDevicesSubject: CurrentValueSubject<[BSDevice], Never> = .init([])
    public static var connectedDevicesPublisher: AnyPublisher<[BSDevice], Never> {
        connectedDevicesSubject.eraseToAnyPublisher()
    }

    private static let connectedDeviceSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var connectedDevicePublisher: AnyPublisher<BSDevice, Never> {
        connectedDeviceSubject.eraseToAnyPublisher()
    }

    private static let disconnectedDeviceSubject: PassthroughSubject<BSDevice, Never> = .init()
    public static var disconnectedDevicePublisher: AnyPublisher<BSDevice, Never> {
        disconnectedDeviceSubject.eraseToAnyPublisher()
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
        isDeviceConnectedSubject.send((device, device.isConnected))

        var updatedConnectedDevices = false
        var updatedAvailableDevices = false

        if device.isConnected {
            if let similarConnectedDevice = connectedDevices.first(where: { $0 == device && $0 !== device }) {
                logger?.debug("removing similarConnectedDevice")
                connectedDevices.removeAll(where: { $0 === similarConnectedDevice })
            }
            if !connectedDevices.contains(device) {
                logger?.debug("adding \(device.name) to connectedDevices")
                connectedDevices.append(device)
                updatedConnectedDevices = true
            }
            connectedDeviceSubject.send(device)

            if let similarAvailableDevice = availableDevices.first(where: { $0 == device && $0 !== device }) {
                logger?.debug("removing similarAvailableDevice")
                availableDevices.removeAll(where: { $0 === similarAvailableDevice })
            }
            if !availableDevices.contains(device) {
                logger?.debug("adding \(device.name) to availableDevices")
                availableDevices.append(device)
                availableDeviceSubject.send(device)
                BSDevicePair.shared.add(device: device)
                updatedAvailableDevices = true
            }
        }
        else {
            disconnectedDeviceSubject.send(device)

            if availableDevices.contains(device), !device.isAvailable {
                logger?.debug("removing \(device.name) from availableDevices")
                availableDevices.removeAll(where: { $0 === device })
                unavailableDeviceSubject.send(device)
                updatedAvailableDevices = true
            }

            if connectedDevices.contains(device) {
                logger?.debug("removing \(device.name) from connectedDevices")
                connectedDevices.removeAll(where: { $0 === device })
                updatedConnectedDevices = true
            }
        }

        if updatedConnectedDevices {
            connectedDevicesSubject.value = connectedDevices
        }
        if updatedAvailableDevices {
            availableDevicesSubject.value = availableDevices
        }
    }
}
