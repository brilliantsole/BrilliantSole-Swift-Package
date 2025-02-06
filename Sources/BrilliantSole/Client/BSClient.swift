//
//  BSClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import Foundation

private let logger = getLogger(category: "BSClient")

protocol BSClient {
    func sendConnectToDeviceMessage(bluetoothId: String, sendImmediately: Bool)
    func sendDisconnectFromDeviceMessage(bluetoothId: String, sendImmediately: Bool)
    func sendDeviceMessages(_ messages: [BSConnectionMessage], bluetoothId: String, sendImmediately: Bool)

    func sendMessages(_ serverMessages: [BSServerMessage], sendImmediately: Bool)
    func sendMessageData(_ data: Data, sendImmediately: Bool)
}

extension BSClient {
    func sendConnectToDeviceMessage(bluetoothId: String) {
        sendConnectToDeviceMessage(bluetoothId: bluetoothId, sendImmediately: true)
    }

    func sendDisconnectFromDeviceMessage(bluetoothId: String) {
        sendDisconnectFromDeviceMessage(bluetoothId: bluetoothId, sendImmediately: true)
    }

    func sendDeviceMessages(_ messages: [BSConnectionMessage], bluetoothId: String) {
        sendDeviceMessages(messages, bluetoothId: bluetoothId, sendImmediately: true)
    }

    func sendMessages(_ serverMessages: [BSServerMessage]) {
        sendMessages(serverMessages, sendImmediately: true)
    }

    func sendMessageData(_ data: Data, sendImmediately: Bool) {
        sendMessageData(data, sendImmediately: true)
    }
}

extension BSClient {
    func sendConnectToDeviceMessage(bluetoothId: String, sendImmediately: Bool) {
        logger.debug("requesting connection to \(bluetoothId)")
        let serverMessage: BSServerMessage = .init(type: .connectToDevice, data: BSStringUtils.toBytes(bluetoothId, includeLength: true))
        sendMessages([serverMessage], sendImmediately: sendImmediately)
    }

    func sendDisconnectFromDeviceMessage(bluetoothId: String, sendImmediately: Bool) {
        logger.debug("requesting disconnection from \(bluetoothId)")
        let serverMessage: BSServerMessage = .init(type: .disconnectFromDevice, data: BSStringUtils.toBytes(bluetoothId, includeLength: true))
        sendMessages([serverMessage], sendImmediately: sendImmediately)
    }

    func sendDeviceMessages(_ messages: [BSConnectionMessage], bluetoothId: String, sendImmediately: Bool) {
        logger.debug("sending \(messages.count) to \(bluetoothId)")
        var data: Data = .init()
        data += BSStringUtils.toBytes(bluetoothId, includeLength: true)
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
