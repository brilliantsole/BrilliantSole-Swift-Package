//
//  BSDevicePair+Device.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

public extension BSDevicePair {
    subscript(side: BSSide) -> BSDevice? {
        get {
            devices[side]
        }
        set(newValue) {
            if let device = newValue {
                add(device: device)
            }
            else {
                if let device = devices[side] {
                    remove(device: device)
                }
                else {
                    logger?.error("no \(side.name) device to remove")
                }
            }
        }
    }

    func add(device: BSDevice) {
        if type == .insoles, !device.isInsole {
            logger?.debug("device is not insole")
            return
        }
        if type == .gloves, !device.isGlove {
            logger?.debug("device is not glove")
            return
        }
        let side = device.side!

        if devices[side] != nil {
            guard device != devices[side] else {
                logger?.debug("already added device")
                return
            }
            remove(device: device)
        }

        logger?.debug("adding device \"\(device.name)\"")

        devices[side] = device
        addListeners(device: device)
        checkIsFullyConnected()
    }

    func remove(device: BSDevice) {
        guard device.isInsole else {
            logger?.debug("device is not insole")
            return
        }

        if devices.contains(where: { $0.value === device }) {
            let side = devices.keys.first(where: { devices[$0] === device })!
            remove(side: side)
        }
        else {
            logger?.debug("devicePair doesn't contain \(device.name)")
        }
    }

    func remove(side: BSSide) {
        guard let device = devices[side] else {
            logger?.debug("no \(side.name) device")
            return
        }
        removeListeners(device: device)
        devices[side] = nil
        checkIsFullyConnected()
    }

    var hasAllDevices: Bool { devices.count == 2 }
    var connectedDeviceCount: UInt8 {
        devices.reduce(into: 0) { result, device
            in result += device.value.isConnected ? 1 : 0
        }
    }

    internal func getDeviceSide(_ device: BSDevice) -> BSSide? {
        guard let side = device.side
        else {
            self.logger?.error("device \(device.name) missing side")
            return nil
        }
        return side
    }
}
