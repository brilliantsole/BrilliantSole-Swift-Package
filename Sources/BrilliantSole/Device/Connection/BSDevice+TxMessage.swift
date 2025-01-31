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
        logger.debug("requesting to send \(txMessages.count) txMessages")
        pendingTxMessages += txMessages
        guard sendImmediately else {
            logger.debug("not sending txMessages immediately")
            return
        }
        sendPendingTxMessages()
    }
    
    func sendPendingTxMessages() {
        guard !isSendingTxData else {
            logger.debug("already sending txData - will wait")
            return
        }
        guard !pendingTxMessages.isEmpty else {
            logger.debug("no pending messages")
            return
        }
        isSendingTxData = true
        txData.removeAll(keepingCapacity: true)
        
        let maxMessageLength = informationManager.maxMtuMessageLength
        
        var pendingTxMessageIndex: Data.Index = 0
        while pendingTxMessageIndex < pendingTxMessages.count {
            let pendingTxMessage = pendingTxMessages[pendingTxMessageIndex]
            let pendingTxMessageLength = pendingTxMessage.length()
            let shouldAppendTxMessage: Bool = maxMessageLength == 0 || UInt16(txData.count) + pendingTxMessageLength <= maxMessageLength
            if shouldAppendTxMessage {
                logger.debug("appending pendingTxMessage \"\(pendingTxMessage.typeString)\" (\(pendingTxMessageLength) bytes)")
                pendingTxMessage.appendTo(&txData)
                pendingTxMessages.remove(at: pendingTxMessageIndex)
            } else {
                logger.debug("skipping pendingTxMessage \"\(pendingTxMessage.typeString)\" (\(pendingTxMessageLength) bytes")
                pendingTxMessageIndex += 1
            }
        }
        logger.debug("there are still \(self.pendingTxMessages.count) pending messages")
        
        guard !txData.isEmpty else {
            logger.debug("txData is empty - nothing to send")
            isSendingTxData = false
            return
        }
        logger.debug("sending \(self.txData.count) bytes..")
        sendTxData(txData)
    }
    
    func sendTxData(_ data: Data) {
        connectionManager?.sendTxData(data)
    }
        
    func resetTxMessaging() {
        isSendingTxData = false
        pendingTxMessages.removeAll(keepingCapacity: true)
    }
}
