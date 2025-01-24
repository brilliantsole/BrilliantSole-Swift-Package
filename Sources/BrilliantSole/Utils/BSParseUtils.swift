//
//  BSParseUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSParseUtils")

func parseMessages<MessageType: BSEnum>(_ data: Data, messageCallback: @escaping (MessageType, Data) -> Void, at initialoffset: Data.Index, parseMessageLengthAs2Bytes: Bool = false) {
    logger.debug("parsing \(data.count) bytes at \(initialoffset)...")
    var offset = initialoffset
    while offset < data.count {
        logger.debug("parsing message at \(offset)...")

        let rawMessageType = data[offset]
        guard let messageType = MessageType(rawValue: rawMessageType) else {
            logger.error("invalid rawMessageType \(rawMessageType)")
            return
        }
        offset += 1
        logger.debug("messageType \(messageType.name)")

        let messageDataLength: UInt16
        if parseMessageLengthAs2Bytes {
            messageDataLength = .parse(data, at: offset)
            offset += 2
        } else {
            messageDataLength = UInt16(data[offset])
            offset += 1
        }
        logger.debug("messageType: \(messageType.name), messageDataLength: \(messageDataLength)")

        let endIndex = Data.Index(offset) + Data.Index(messageDataLength)
        guard endIndex <= data.count else {
            logger.error("message data length exceeds buffer size")
            return
        }
        let messageData = data[Data.Index(offset) ..< endIndex]
        messageCallback(messageType, messageData)

        offset += Data.Index(messageDataLength)
        logger.debug("new offset: \(offset)")
    }
}
