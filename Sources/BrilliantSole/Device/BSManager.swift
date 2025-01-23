//
//  BSManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSManager")

protocol BSManager {
    associatedtype MessageType: RawRepresentable & CaseIterable where MessageType.RawValue == UInt8

    func reset()
    func onSendTxData()
    func canParseRxMessageEnum(_ messageTypeEnum: MessageType.RawValue) -> Bool
    func onRxMessageEnum(_ messageTypeEnum: MessageType.RawValue, data: Data)
    func onRxMessage(_ messageType: MessageType, data: Data)

    func sendTxMessages(_ txMessages: [BSTxMessage], sendImmediately: Bool)
    func setSendTxMessages(_ callback: @escaping (_ txMessages: [BSTxMessage], _ sendImmediately: Bool) -> Void)

    static func initTxRxEnum(offset: inout UInt8, enumStrings: inout [String])
    static var requiredTxRxMessageTypes: [UInt8] { get }
}
