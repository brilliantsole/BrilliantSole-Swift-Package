//
//  BSDevice+Connection.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

public extension BSDevice {
    internal func onConnectionManagerChanged() {
        logger.debug("assigning connectionManager cancellables")

        connectionManagerCancellables.removeAll(keepingCapacity: true)

        connectionManager?.connectionStatusPublisher.sink { [weak self] connectionStatus in
            self?.onConnectionManagerStatusChanged(connectionStatus)
        }.store(in: &connectionManagerCancellables)

        connectionManager?.batteryLevelPublisher.sink { [weak self] batteryLevel in
            self?.batteryLevel = batteryLevel
        }.store(in: &connectionManagerCancellables)

        connectionManager?.deviceInformationPublisher.sink { [weak self] type, value in
            self?.deviceInformationManager[type] = value
        }.store(in: &connectionManagerCancellables)

        connectionManager?.rxMessagePublisher.sink { [weak self] messageType, messageData in
            self?.onRxMessage(type: messageType, data: messageData)
        }.store(in: &connectionManagerCancellables)

        connectionManager?.rxMessagesPublisher.sink { [weak self] in
            self?.onRxMessages()
        }.store(in: &connectionManagerCancellables)

        connectionManager?.sendTxDataPublisher.sink { [weak self] in
            self?.onSendTxData()
        }.store(in: &connectionManagerCancellables)

        if let name = connectionManager?.name {
            informationManager.initName(name)
        }
        if let deviceType = connectionManager?.deviceType {
            informationManager.initDeviceType(deviceType)
        }
    }

    var connectionType: BSConnectionType? { connectionManager?.connectionType }
    var connectionManagerStatus: BSConnectionStatus? { connectionManager?.connectionStatus }

    private func onConnectionManagerStatusChanged(_ connectionManagerStatus: BSConnectionStatus) {
        logger.debug("connectionManagerStatus updated to \(connectionManagerStatus.name)")
        switch connectionManagerStatus {
        case .connected:
            sendRequiredTxRxMessages()
        case .notConnected:
            reset()
        default:
            break
        }
        if connectionManagerStatus != .connected {
            connectionStatus = connectionManagerStatus
        }
    }

    func connect() { connectionManager?.connect() }
    func disconnect() { connectionManager?.disconnect() }
    func toggleConnection() { connectionManager?.toggleConnection() }

    private func sendRequiredTxRxMessages() {
        logger.debug("sending required txRxMessages")
        sendTxMessages(BSTxRxMessageUtils.requiredTxRxMessages)
    }
}
