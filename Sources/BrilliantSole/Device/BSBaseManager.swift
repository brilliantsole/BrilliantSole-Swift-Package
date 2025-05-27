//
//  BSBaseManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import OSLog

private let logger = getLogger(category: "BSBaseManager", disabled: true)

typealias BSEnumToTxRx<MessageType: Hashable> = [MessageType: UInt8]
typealias BSTxRxToEnum<MessageType: Hashable> = [UInt8: MessageType]

private nonisolated(unsafe) var allEnumToTxRx: [String: [AnyHashable: UInt8]] = .init()
private nonisolated(unsafe) var allTxRxToEnum: [String: [UInt8: AnyHashable]] = .init()

class BSBaseManager<MessageType>: BSManager where MessageType: BSEnum {
    typealias MessageType = MessageType

    class var key: String { .init(describing: self) }
    typealias EnumToTxRx = BSEnumToTxRx<MessageType>
    class var enumToTxRx: EnumToTxRx? { allEnumToTxRx[key] as? EnumToTxRx }

    typealias TxRxToEnum = BSTxRxToEnum<MessageType>
    class var txRxToEnum: TxRxToEnum? { allTxRxToEnum[key] as? TxRxToEnum }

    static func initTxRxEnum(at offset: inout UInt8, enumStrings: inout [String]) {
        guard enumToTxRx == nil else {
            fatalError(
                "enumToTxRx already initialized. Please call `BSBaseManager.initTxRxEnum` only once."
            )
        }
        guard txRxToEnum == nil else {
            fatalError(
                "txRxToEnum already initialized. Please call `BSBaseManager.initTxRxEnum` only once."
            )
        }

        var enumToTxRx: EnumToTxRx = .init()
        var txRxToEnum: TxRxToEnum = .init()

        for item in MessageType.allCases {
            enumToTxRx[item] = offset
            txRxToEnum[offset] = item
            enumStrings.append(item.name)
            offset += 1
        }

        allEnumToTxRx[key] = enumToTxRx
        allTxRxToEnum[key] = txRxToEnum
    }

    func assertValidMessageTypeEnum(_ messageTypeEnum: MessageType.RawValue) throws {
        if !canParseRxMessageEnum(messageTypeEnum) {
            fatalError("invalid \(Self.key) messageTypeEnum: \(messageTypeEnum)")
        }
    }

    func onRxMessageEnum(_ messageTypeEnum: MessageType.RawValue, data: Data) {
        do {
            try assertValidMessageTypeEnum(messageTypeEnum)
            let messageType = Self.txRxToEnum![messageTypeEnum]!
            onRxMessage(messageType, data: data)
        }
        catch {
            logger?.error("\(error)")
        }
    }

    func onRxMessage(_ messageType: MessageType, data: Data) {
        logger?.debug("received \(messageType.name) message (\(data.count) bytes)")
    }

    func reset() {}
    func onSendTxData() {}
    func canParseRxMessageEnum(_ messageTypeEnum: MessageType.RawValue) -> Bool {
        Self.txRxToEnum![messageTypeEnum] != nil
    }

    static func enumArrayToTxRxArray(_ enumArray: [MessageType]) -> [MessageType.RawValue] {
        enumArray.map {
            Self.enumToTxRx![$0]!
        }
    }

    private var _sendTxMessages: (([BSTxMessage], _ sendImmediately: Bool) -> Void)?
    func setSendTxMessages(_ callback: @escaping ([BSTxMessage], Bool) -> Void) {
        _sendTxMessages = callback
    }

    func sendTxMessages(_ messages: [BSTxMessage], sendImmediately: Bool = true) {
        _sendTxMessages!(messages, sendImmediately)
    }

    func createMessage(_ messageType: MessageType, data: Data? = nil) -> BSTxMessage {
        return .init(type: Self.enumToTxRx![messageType]!, data: data)
    }

    func createAndSendMessage(_ messageType: MessageType, data: Data? = nil, sendImmediately: Bool = true) {
        let message = createMessage(messageType, data: data)
        sendTxMessages([message], sendImmediately: sendImmediately)
    }

    class var requiredMessageTypes: [MessageType]? { nil }
    static var requiredTxRxMessageTypes: [UInt8] { requiredMessageTypes != nil ? enumArrayToTxRxArray(requiredMessageTypes!) : [] }

    class var requiredFollowUpMessageTypes: [MessageType]? { nil }
    static var requiredFollowUpTxRxMessageTypes: [UInt8] { requiredMessageTypes != nil ? enumArrayToTxRxArray(requiredFollowUpMessageTypes!) : [] }
    var requiredFollowUpTxRxMessageTypes: [UInt8] { Self.requiredFollowUpTxRxMessageTypes }
    static var requiredFollowUpTxRxMessages: [BSTxMessage] {
        var requiredFollowUpTxRxMessages: [BSTxMessage] = []
        for requiredFollowUpTxRxMessageType in requiredFollowUpTxRxMessageTypes {
            requiredFollowUpTxRxMessages.append(.init(type: requiredFollowUpTxRxMessageType))
        }
        return requiredFollowUpTxRxMessages
    }

    func sendRequiredFollowupMessages(sendImmediately: Bool = true) {
        sendTxMessages(Self.requiredFollowUpTxRxMessages, sendImmediately: sendImmediately)
    }
}
