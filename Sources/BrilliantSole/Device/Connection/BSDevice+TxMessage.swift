//
//  BSDevice+TxMessage.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/29/25.
//

import Foundation

extension BSDevice {
    func onSendTxData() {
        logger.debug("sent txData")
        isSendingTxData = false
        managers.forEach { $0.onSendTxData() }
        sendPendingTxMessages()
    }
    
    func sendTxMessages(_ txMessages: [BSTxMessage], sendImmediately: Bool = true) {
        // FILL
    }
    
    func sendPendingTxMessages() {
        // FLL
    }
    
    func sendTxData(_ data: Data) {
        connectionManager?.sendTxData(data)
    }
        
    func resetTxMessaging() {
        isSendingTxData = false
        pendingTxMessages.removeAll(keepingCapacity: true)
    }
}
