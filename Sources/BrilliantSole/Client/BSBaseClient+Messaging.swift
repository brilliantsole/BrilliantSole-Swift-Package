//
//  BSBaseClient+Messaging.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation

extension BSBaseClient {
    func parseServerData(_ data: Data) {
        logger?.debug("parsing serverData (\(data.count) bytes)")
        parseMessages(data) { messageType, data in
            self.parseServerMessage(type: messageType, data: data)
        }
        logger?.debug("sendPendingMessages")
        checkIfFullyConnected()
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
            logger?.error("uncaught serverMessageType \(serverMessageType.name)")
        }
        
        receivedMessageTypes.insert(serverMessageType)
    }

    func sendRequiredMessages(sendImmediately: Bool = true) {
        logger?.debug("sending required messages")
        sendMessages(Self.requiredMessages, sendImmediately: sendImmediately)
    }
}
