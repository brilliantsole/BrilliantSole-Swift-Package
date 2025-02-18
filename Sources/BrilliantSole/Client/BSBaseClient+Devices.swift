//
//  BSBaseClient+Devices.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation

extension BSBaseClient {
    func parseConnectedDevices(_ data: Data) {
        logger?.debug("parsing connected devices (\(data.count) bytes)")
        guard let connectedDevicesJson = BSConnectedDevicesJson(data: data) else {
            return
        }

        for id in connectedDevicesJson.connectedDeviceIds {
            logger?.debug("connectedDevice id \(id)")
            let discoveredDevice = discoveredDevicesMap[id] ?? .init(scanner: self.asScanner, id: id)
            let device = allDevices[discoveredDevice.id] ?? createDevice(discoveredDevice: discoveredDevice)
            guard let connectionManager = device.connectionManager as? BSClientConnectionManager else {
                logger?.error("failed to cast connectionManager to BSClientConnectionManager")
                continue
            }
            device.connectionStatus = .connecting
            connectionManager.isConnected = true
        }
    }
}
