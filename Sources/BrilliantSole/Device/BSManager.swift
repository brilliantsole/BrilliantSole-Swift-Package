//
//  BSBaseManagerProtocol.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation

protocol BSManager {
    associatedtype MessageType: RawRepresentable & CaseIterable where MessageType.RawValue == UInt8

    func reset()
    func onSendTxData()
    func canParseRxMessage(messageTypeEnum: MessageType.RawValue) -> Bool
    func onRxMessage(messageTypeEnum: MessageType.RawValue, data: Data)

    var sendTxMessages: ((_ txMessages: [BSTxMessage], _ sendImmediately: Bool) -> Void)? { get set }
}

extension BSManager {
    func canParseRxMessage(messageTypeEnum: MessageType.RawValue) -> Bool { false }
}
