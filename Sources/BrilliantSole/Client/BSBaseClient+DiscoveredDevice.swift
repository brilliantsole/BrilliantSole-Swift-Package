//
//  BSBaseClient+DiscoveredDevice.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation

extension BSBaseClient {
    func parseDiscoveredDevice(_ data: Data) {
        logger?.debug("parsing discoveredDevice \(data.count) bytes")
        guard let discoveredDeviceJson = BSDiscoveredDeviceJson(data: data) else {
            return
        }

//        guard discoveredDeviceJson.deviceType != nil else {
//            logger?.debug("discoveredDeviceJson has no deviceType - waiting until it does")
//            return
//        }

        var discoveredDevice = allDiscoveredDevices[discoveredDeviceJson.id]
        if let discoveredDevice {
            discoveredDevice.update(discoveredDeivceJson: discoveredDeviceJson)
        }
        else {
            discoveredDevice = BSDiscoveredDevice(scanner: self, discoveredDeviceJson: discoveredDeviceJson)
        }
        add(discoveredDevice: discoveredDevice!)
    }

    func parseExpiredDiscoveredDevice(_ data: Data) {
        logger?.debug("parsing expiredDiscoveredDevice \(data.count) bytes")

        guard let id = BSStringUtils.getString(from: data, includesLength: true) else {
            return
        }
        logger?.debug("expired id: \(id)")

        var discoveredDevice = allDiscoveredDevices[id]
        if let discoveredDevice {
            remove(discoveredDevice: discoveredDevice)
        }
        else {
            logger?.debug("couldn't find discoveredDevice with id \(id)")
        }
    }
}
