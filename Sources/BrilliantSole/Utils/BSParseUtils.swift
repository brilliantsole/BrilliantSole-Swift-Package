//
//  BSParseUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSParseUtils", disabled: true)

func parseMessages<MessageType: BSMessageType>(_ data: Data, messageCallback: @escaping (MessageType, Data) -> Void, at initialoffset: Data.Index = .zero, parseMessageLengthAs2Bytes: Bool = true) {
    logger?.debug("parsing \(data.count) bytes at \(initialoffset)")
    var offset = initialoffset
    while offset < data.count {
        logger?.debug("parsing message at \(offset)")

        guard let messageType = MessageType.parse(data, at: offset) else {
            return
        }
        offset += 1
        logger?.debug("messageType \(String(describing: messageType))")

        let messageDataLength: UInt16
        if parseMessageLengthAs2Bytes {
            guard let parsedMessageDataLength = UInt16.parse(data, at: offset) else {
                break
            }
            messageDataLength = parsedMessageDataLength
            offset += 2
        } else {
            messageDataLength = UInt16(data[data.startIndex + offset])
            offset += 1
        }
        logger?.debug("messageType: \(String(describing: messageType)), messageDataLength: \(messageDataLength)")

        let endIndex = Data.Index(offset) + Data.Index(messageDataLength)
        guard endIndex <= data.count else {
            logger?.error("message data length exceeds buffer size")
            return
        }
        let messageData = data[(data.startIndex + Data.Index(offset)) ..< (data.startIndex + endIndex)]
        messageCallback(messageType, messageData)
        offset += Data.Index(messageDataLength)
        logger?.debug("new offset: \(offset)")
    }
    logger?.debug("finished parsing")
}
