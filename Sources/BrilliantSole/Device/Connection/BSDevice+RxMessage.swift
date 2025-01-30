//
//  BSDevice+RxMessage.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/29/25.
//

import Foundation

extension BSDevice {
    func onRxMessage(type: BSTxMessageType, data: Data) {
        logger.debug("received message: \(BSTxRxMessageUtils.enumStrings[Int(type)]) (\(data.count) bytes)")
        receivedTxRxMessages.insert(type)
        for manager in managers {
            if manager.canParseRxMessageEnum(type) {
                manager.onRxMessageEnum(type, data: data)
                break
            }
        }
    }

    func onRxMessages() {
        logger.debug("parsed rxMessages")
        sendPendingTxMessages()
        if connectionStatus == .connecting {
            checkIfFullyConnected()
        }
    }

    func checkIfFullyConnected() {
        logger.debug("checking if fully connected")
        guard didReceiveBatteryLevel else {
            logger.debug("didn't receive batteryLevel - notFullyConnected")
            return
        }
        guard deviceInformationManager.hasAllInformation else {
            logger.debug("deviceInformationManager doesn't hasAllInformation - notFullyConnected")
            return
        }
        guard connectionStatus == .connecting else {
            logger.debug("connectionStatus is not connecting (got \(self.connectionStatus.name) - notFullyConnected")
            return
        }
        guard informationManager.currentTime != 0 else {
            logger.debug("currentTime is 0 - notFullyConnected")
            return
        }
        let receivedAllRequiredTxRxMessages = checkIfReceivedAllRequiredTxRxMessages()
        logger.debug("receivedAllRequiredTxRxMessages \(receivedAllRequiredTxRxMessages)")
        guard receivedAllRequiredTxRxMessages else {
            return
        }
        connectionStatus = .connected
    }

    func checkIfReceivedAllRequiredTxRxMessages() -> Bool {
        var receivedAllRequiredTxRxMessages = true
        for messageType in BSTxRxMessageUtils.requiredTxRxMessageTypes {
            if !receivedTxRxMessages.contains(messageType) {
                logger.debug("didn't receive mesageType \(BSTxRxMessageUtils.enumStrings[Int(messageType)])")
                receivedAllRequiredTxRxMessages = false
                break
            }
        }
        return receivedAllRequiredTxRxMessages
    }

    func resetRxMessaging() {
        receivedTxRxMessages.removeAll(keepingCapacity: true)
    }
}
