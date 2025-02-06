//
//  BSBaseClient+Messaging.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation

extension BSBaseClient {
    func onData(_ data: Data) {
        logger.debug("received \(data.count) bytes")
        parseServerData(data)
    }

    func parseServerData(_ data: Data) {
        logger.debug("parsing \(data.count) bytes")
        parseMessages(data) { messageType, data in
            self.parseServerMessage(type: messageType, data: data)
        }
    }

    func parseServerMessage(type serverMessageType: BSServerMessageType, data: Data) {
        switch serverMessageType {
        case .isScanningAvailable:
            parseIsScanningAvailable(data)
        case .isScanning:
            parseIsScanning(data)
        case .discoveredDevice:
            parseDiscoveredDevice(data)
        case .expiredDiscoveredDevice:
            parseExpiredDiscoveredDevice(data)
        case .connectedDevices:
            parseConnectedDevices(data)
        case .deviceMessage:
            parseDeviceMessage(data)
        default:
            logger.error("uncaught serverMessageType \(serverMessageType.name)")
        }

        func sendRequiredMessages() {
            sendMessages(Self.requiredMessages)
        }
    }
}
