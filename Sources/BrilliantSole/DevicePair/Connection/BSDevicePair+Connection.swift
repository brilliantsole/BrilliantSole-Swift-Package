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
                logger?.debug("redundant isFullyConnected update \(newValue)")
                return
            }
            isFullyConnectedSubject.value = newValue
        }
    }

    func checkIsHalfConnected() {
        let newIsHalfConnected = connectedDeviceCount == 1
        logger?.debug("newIsHalfConnected: \(newIsHalfConnected)")
        isHalfConnected = newIsHalfConnected
    }

    // MARK: - isFullyConnected

    private(set) var isHalfConnected: Bool {
        get { isHalfConnectedSubject.value }
        set {
            guard newValue != isHalfConnected else {
                logger?.debug("redundant isHalfConnected update \(newValue)")
                return
            }
            isHalfConnectedSubject.value = newValue
        }
    }

    func checkIsFullyConnected() {
        let newIsFullyConnected = connectedDeviceCount == 2
        logger?.debug("newIsFullyConnected: \(newIsFullyConnected)")
        isFullyConnected = newIsFullyConnected

        checkIsHalfConnected()
    }

    // MARK: - deviceConnectionListeners

    func addDeviceConnectionListeners(device: BSDevice) {
        device.connectionStatusPublisher.sink { device, connectionStatus in
            self.onDeviceConnectionStatus(device: device, connectionStatus: connectionStatus)
        }.store(in: &deviceCancellables[device]!)

        device.isConnectedPublisher.sink { device, isConnected in
            self.onDeviceIsConnected(device: device, isConnected: isConnected)
        }.store(in: &deviceCancellables[device]!)
    }

    func onDeviceConnectionStatus(device: BSDevice, connectionStatus: BSConnectionStatus) {
        guard let insoleSide = device.insoleSide else {
            logger?.error("device.insoleSide not found")
            return
        }
        deviceConnectionStatusSubject.send((self, insoleSide, device, connectionStatus))
    }

    func onDeviceIsConnected(device: BSDevice, isConnected: Bool) {
        guard let insoleSide = device.insoleSide else {
            logger?.error("device.insoleSide not found")
            return
        }
        deviceIsConnectedSubject.send((self, insoleSide, device, isConnected))
    }
}
