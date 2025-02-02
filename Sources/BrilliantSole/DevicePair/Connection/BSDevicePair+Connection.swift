//
//  BSDevicePair+Connection.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

import Combine

public extension BSDevicePair {
    // MARK: - isFullyConnected

    private(set) var isFullyConnected: Bool {
        get { isFullyConnectedSubject.value }
        set {
            guard newValue != isFullyConnected else {
                logger.debug("redundant isFullyConnected update \(newValue)")
                return
            }
            isFullyConnectedSubject.value = newValue
        }
    }

    func checkIsHalfConnected() {
        let newIsHalfConnected = connectedDeviceCount == 1
        logger.debug("newIsHalfConnected: \(newIsHalfConnected)")
        isHalfConnected = newIsHalfConnected
    }

    // MARK: - isFullyConnected

    private(set) var isHalfConnected: Bool {
        get { isHalfConnectedSubject.value }
        set {
            guard newValue != isHalfConnected else {
                logger.debug("redundant isHalfConnected update \(newValue)")
                return
            }
            isHalfConnectedSubject.value = newValue
        }
    }

    func checkIsFullyConnected() {
        let newIsFullyConnected = connectedDeviceCount == 2
        logger.debug("newIsFullyConnected: \(newIsFullyConnected)")
        isFullyConnected = newIsFullyConnected

        checkIsHalfConnected()
    }

    // MARK: - deviceConnectionListeners

    func addDeviceConnectionListeners(device: BSDevice) {
        if deviceConnectionCancellables[device] != nil {
            removeDeviceConnectionListeners(device: device)
        }
        deviceConnectionCancellables[device] = .init()

        let insoleSide = device.insoleSide!
        device.connectionStatusPublisher.sink { connectionStatus in
            self.onDeviceConnectionStatus(insoleSide: insoleSide, connectionStatus: connectionStatus)
        }.store(in: &deviceConnectionCancellables[device]!)

        device.isConnectedPublisher.sink { isConnected in
            self.onDeviceIsConnected(insoleSide: insoleSide, isConnected: isConnected)
        }.store(in: &deviceConnectionCancellables[device]!)
    }

    func removeDeviceConnectionListeners(device: BSDevice) {
        deviceConnectionCancellables[device] = nil
    }

    func onDeviceConnectionStatus(insoleSide: BSInsoleSide, connectionStatus: BSConnectionStatus) {
        guard let device = devices[insoleSide] else {
            logger.error("\(insoleSide.name) device not found")
            return
        }
        deviceConnectionStatusSubject.send((insoleSide, device, connectionStatus))
    }

    func onDeviceIsConnected(insoleSide: BSInsoleSide, isConnected: Bool) {
        guard let device = devices[insoleSide] else {
            logger.error("\(insoleSide.name) device not found")
            return
        }
        deviceIsConnectedSubject.send((insoleSide, device, isConnected))
    }
}
