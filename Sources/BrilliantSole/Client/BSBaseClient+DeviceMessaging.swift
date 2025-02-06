//
//  BSBaseClient+DeviceMessaging.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation

extension BSBaseClient {
    func parseDeviceMessage(_ data: Data) {
        logger.debug("parsing deviceMessage (\(data.count) bytes)")

        var offset: Data.Index = 0
        guard let id = BSStringUtils.getString(from: data, includesLength: true) else {
            return
        }
        offset += id.count + 1

        logger.debug("received deviceMessage from \(id)")
        guard let device = allDevices[id] else {
            logger.debug("no device found for id \(id)")
            return
        }

        let messageData = data[(data.startIndex + offset)...]
        logger.debug("parsing \(messageData.count) bytes for device \(id)")
        guard let connectionManager = device.connectionManager as? BSClientConnectionManager else {
            logger.debug("failed to cast connectionManager to BSClientConnectionManager")
            return
        }
        parseMessages(data) { type, data in
            connectionManager.onDeviceEvent(type: type, data: data)
        }
    }
}
