//
//  BSDevicePair+Device.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

public extension BSDevicePair {
    subscript(insoleSide: BSInsoleSide) -> BSDevice? {
        get {
            devices[insoleSide]
        }
        set(newValue) {
            if let device = newValue {
                add(device: device)
            }
            else {
                if let device = devices[insoleSide] {
                    remove(device: device)
                }
                else {
                    logger.error("no \(insoleSide.name) device to remove")
                }
            }
        }
    }

    func add(device: BSDevice) {
        guard device.isInsole else {
            logger.debug("device is not insole")
            return
        }
        let insoleSide = device.insoleSide!

        if devices[insoleSide] != nil {
            guard device != devices[insoleSide] else {
                logger.debug("already added device")
                return
            }
            remove(device: device)
        }

        logger.debug("adding device \"\(device.name)\"")

        devices[insoleSide] = device
        addListeners(device: device)
        checkIsFullyConnected()
    }

    func remove(device: BSDevice) {
        guard device.isInsole else {
            logger.debug("device is not insole")
            return
        }

        if devices.contains(where: { $0.value === device }) {
            let insoleSide = devices.keys.first(where: { devices[$0] === device })!
            remove(insoleSide: insoleSide)
        }
        else {
            logger.debug("devicePair doesn't contain \(device.name)")
        }
    }

    func remove(insoleSide: BSInsoleSide) {
        guard let device = devices[insoleSide] else {
            logger.debug("no \(insoleSide.name) device")
            return
        }
        removeListeners(device: device)
        devices[insoleSide] = nil
        checkIsFullyConnected()
    }

    var hasAllDevices: Bool { devices.count == 2 }
    var connectedDeviceCount: UInt8 {
        devices.reduce(into: 0) { result, device
            in result += device.value.isConnected ? 1 : 0
        }
    }
}
