//
//  BSClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import Foundation

private let logger = getLogger(category: "BSClient")

protocol BSDeviceClient {
    func sendConnectToDeviceMessage(id: String, sendImmediately: Bool)
    func sendDisconnectFromDeviceMessage(id: String, sendImmediately: Bool)
    func sendDeviceMessages(_ messages: [BSConnectionMessage], id: String, sendImmediately: Bool)

    func sendMessages(_ serverMessages: [BSServerMessage], sendImmediately: Bool)
    func sendMessageData(_ data: Data, sendImmediately: Bool)
}

extension BSDeviceClient {
    func sendConnectToDeviceMessage(id: String) {
        sendConnectToDeviceMessage(id: id, sendImmediately: true)
    }

    func sendDisconnectFromDeviceMessage(id: String) {
        sendDisconnectFromDeviceMessage(id: id, sendImmediately: true)
    }

    func sendDeviceMessages(_ messages: [BSConnectionMessage], id: String) {
        sendDeviceMessages(messages, id: id, sendImmediately: true)
    }

    func sendMessages(_ serverMessages: [BSServerMessage]) {
        sendMessages(serverMessages, sendImmediately: true)
    }

    func sendMessageData(_ data: Data) {
        sendMessageData(data, sendImmediately: true)
    }
}

extension BSDeviceClient {
    func sendConnectToDeviceMessage(id: String, sendImmediately: Bool) {
        logger.debug("requesting connection to \(id)")
        let serverMessage: BSServerMessage = .init(type: .connectToDevice, data: BSStringUtils.toBytes(id, includeLength: true))
        sendMessages([serverMessage], sendImmediately: sendImmediately)
    }

    func sendDisconnectFromDeviceMessage(id: String, sendImmediately: Bool) {
        logger.debug("requesting disconnection from \(id)")
        let serverMessage: BSServerMessage = .init(type: .disconnectFromDevice, data: BSStringUtils.toBytes(id, includeLength: true))
        sendMessages([serverMessage], sendImmediately: sendImmediately)
    }

    func sendDeviceMessages(_ messages: [BSConnectionMessage], id: String, sendImmediately: Bool) {
        logger.debug("sending \(messages.count) to \(id)")
        var data: Data = .init()
        data += BSStringUtils.toBytes(id, includeLength: true)
        for message in messages {
            logger.debug("appending \(message.typeString) message")
            message.appendTo(&data)
        }
        let serverMessage: BSServerMessage = .init(type: .deviceMessage, data: data)
        sendMessages([serverMessage], sendImmediately: sendImmediately)
    }

    func sendMessages(_ serverMessages: [BSServerMessage], sendImmediately: Bool) {
        var data: Data = .init()
        for message in serverMessages {
            logger.debug("appending \(message.type.name) message")
            message.appendTo(&data)
        }
        logger.debug("sending \(data.count) bytes...")
        sendMessageData(data, sendImmediately: sendImmediately)
    }
}
