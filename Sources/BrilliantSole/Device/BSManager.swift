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

    var sendTxMessages: ((_ txMessages: [BSTxMessage], _ sendImmediately: Bool) -> Void)? { get set }
}
