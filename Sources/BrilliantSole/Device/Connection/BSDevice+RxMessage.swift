//
//  BSDevice+RxMessage.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/29/25.
//

import Foundation
import OSLog

extension BSDevice {
    func onRxMessage(type: BSTxMessageType, data: Data) {
        logger?.debug("received message: \"\(BSTxRxMessageUtils.enumStrings[Int(type)])\" (\(data.count) bytes)")
        receivedTxRxMessages.insert(type)
        for manager in managers {
            if manager.canParseRxMessageEnum(type) {
                manager.onRxMessageEnum(type, data: data)
                break
            }
        }
    }

    func onRxMessages() {
        logger?.debug("parsed rxMessages")
        if connectionStatus == .connecting {
            checkIfFullyConnected()
        }
        sendPendingTxMessages()
    }

    func checkIfFullyConnected() {
        logger?.debug("checking if fully connected")
        guard didReceiveBatteryLevel else {
            logger?.debug("didn't receive batteryLevel - notFullyConnected")
            return
        }
        guard deviceInformationManager.hasAllInformation else {
            logger?.debug("deviceInformationManager doesn't hasAllInformation - notFullyConnected")
            return
        }
        guard connectionStatus == .connecting else {
            logger?.debug("connectionStatus is not connecting (got \(self.connectionStatus.name) - notFullyConnected")
            return
        }
        guard informationManager.currentTime != 0 else {
            logger?.debug("currentTime is 0 - notFullyConnected")
            return
        }
        let receivedAllRequiredTxRxMessages = checkIfReceivedAllRequiredTxRxMessages()
        logger?.debug("receivedAllRequiredTxRxMessages \(receivedAllRequiredTxRxMessages)")
        guard receivedAllRequiredTxRxMessages else {
            return
        }
        var receivedFollowUpMessages = true
        if sensorTypes.contains(.pressure) {
            if !sensorDataManager.didReceivePressurePositions {
                receivedFollowUpMessages = false
                logger?.debug("getting followUp pressure messages...")
                sensorDataManager.getPressurePositions(sendImmediately: false)
            }
        }
        if isWifiAvailable {
            if !checkIfReceivedTxRxMessages(wifiManager.requiredFollowUpTxRxMessageTypes) {
                receivedFollowUpMessages = false
                logger?.debug("getting followUp wifi messages...")
                wifiManager.sendRequiredFollowupMessages(sendImmediately: false)
            }
        }
        if !fileTypes.isEmpty {
            if !checkIfReceivedTxRxMessages(fileTransferManager.requiredFollowUpTxRxMessageTypes) {
                receivedFollowUpMessages = false
                logger?.debug("getting followUp fileTransfer messages...")
                fileTransferManager.sendRequiredFollowupMessages(sendImmediately: false)
            }
        }
        if isTfliteAvailable {
            if !checkIfReceivedTxRxMessages(tfliteManager.requiredFollowUpTxRxMessageTypes) {
                receivedFollowUpMessages = false
                logger?.debug("getting followUp tflite messages...")
                tfliteManager.sendRequiredFollowupMessages(sendImmediately: false)
            }
        }
        if isCameraAvailable {
            if !checkIfReceivedTxRxMessages(cameraManager.requiredFollowUpTxRxMessageTypes) {
                receivedFollowUpMessages = false
                logger?.debug("getting followUp camera messages...")
                cameraManager.sendRequiredFollowupMessages(sendImmediately: false)
            }
        }
        // TODO: - check microphone/display
        guard receivedFollowUpMessages else { return }
        connectionStatus = .connected
    }

    func checkIfReceivedTxRxMessages(_ messageTypes: [UInt8]) -> Bool {
        var receivedAllRequiredTxRxMessages = true
        for messageType in messageTypes {
            if !receivedTxRxMessages.contains(messageType) {
                logger?.debug("didn't receive mesageType \(BSTxRxMessageUtils.enumStrings[Int(messageType)])")
                receivedAllRequiredTxRxMessages = false
                break
            }
        }
        return receivedAllRequiredTxRxMessages
    }

    func checkIfReceivedAllRequiredTxRxMessages() -> Bool {
        checkIfReceivedTxRxMessages(BSTxRxMessageUtils.requiredTxRxMessageTypes)
    }

    func resetRxMessaging() {
        receivedTxRxMessages.removeAll(keepingCapacity: true)
    }
}
