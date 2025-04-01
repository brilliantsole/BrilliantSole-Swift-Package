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

    internal func checkIsHalfConnected() {
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

    var connectedSide: BSSide? {
        guard isHalfConnected else { return nil }
        return devices[.left]?.isConnected == true ? .left : .right
    }

    var unconnectedSide: BSSide? {
        connectedSide?.otherSide
    }

    internal func checkIsFullyConnected() {
        let newIsFullyConnected = connectedDeviceCount == 2
        logger?.debug("newIsFullyConnected: \(newIsFullyConnected)")
        isFullyConnected = newIsFullyConnected

        checkIsHalfConnected()
        checkConnectionStatus()
    }

    // MARK: - connectionStatus

    private(set) var connectionStatus: BSDevicePairConnectionStatus {
        get { connectionStatusSubject.value }
        set {
            guard newValue != connectionStatus else {
                logger?.debug("redundant connectionStatus update \(newValue.name)")
                return
            }
            connectionStatusSubject.value = newValue
        }
    }

    private func checkConnectionStatus() {
        let newConnectionStatus: BSDevicePairConnectionStatus
        if isFullyConnected {
            newConnectionStatus = .fullyConnected
        } else if isHalfConnected {
            newConnectionStatus = .halfConnected
        } else {
            newConnectionStatus = .notConnected
        }
        connectionStatus = newConnectionStatus
    }

    // MARK: - deviceConnectionListeners

    internal func addDeviceConnectionListeners(device: BSDevice) {
        device.connectionStatusPublisher.sink { connectionStatus in
            self.onDeviceConnectionStatus(device: device, connectionStatus: connectionStatus)
        }.store(in: &deviceCancellables[device]!)

        device.isConnectedPublisher.sink { isConnected in
            self.onDeviceIsConnected(device: device, isConnected: isConnected)
        }.store(in: &deviceCancellables[device]!)
    }

    internal func onDeviceConnectionStatus(device: BSDevice, connectionStatus: BSConnectionStatus) {
        guard let side = device.side else {
            logger?.error("device.side not found")
            return
        }
        deviceConnectionStatusSubject.send((side, device, connectionStatus))
    }

    internal func onDeviceIsConnected(device: BSDevice, isConnected: Bool) {
        guard let side = device.side else {
            logger?.error("device.side not found")
            return
        }
        checkIsFullyConnected()
        deviceIsConnectedSubject.send((side, device, isConnected))
    }
}
