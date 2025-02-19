//
//  BSClientConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
class BSClientConnectionManager: BSBaseConnectionManager {
    override class var connectionType: BSConnectionType { .udpClient }

    // MARK: - client

    var client: BSDeviceClient

    init(discoveredDevice: BSDiscoveredDevice, client: BSDeviceClient) {
        self.client = client
        super.init(discoveredDevice: discoveredDevice)
    }

    // MARK: - connection

    override func connect(_continue: inout Bool) {
        super.connect(_continue: &_continue)
        guard _continue else { return }
        client.sendConnectToDeviceMessage(id: id)
    }

    override func disconnect(_continue: inout Bool) {
        super.disconnect(_continue: &_continue)
        guard _continue else { return }
        client.sendDisconnectFromDeviceMessage(id: id)
    }

    // MARK: - isConnected

    public internal(set) var isConnected: Bool = false {
        didSet {
            logger?.debug("updated isConnected \(self.isConnected)")
            connectionStatus = isConnected ? .connected : .notConnected

            if isConnected {
                requestDeviceInformation()
            }
        }
    }

    // MARK: - messaging

    override func sendTxData(_ data: Data) {
        super.sendTxData(data)
        guard let message = BSConnectionMessageUtils.createMessage(enumString: BSMetaConnectionMessageType.tx.name, data: data) else {
            return
        }
        client.sendDeviceMessages([message], id: id)
        sendTxDataSubject.send()
    }

    func onDeviceEvent(type: UInt8, data: Data) {
        guard type < BSDeviceEventMessageUtils.enumStrings.count else {
            logger?.debug("invalid deviceEventType \(type)")
            return
        }

        let typeString = BSDeviceEventMessageUtils.enumStrings[Int(type)]
        logger?.debug("deviceEventString \(typeString) (\(data.count) bytes)")

        switch typeString {
        case BSConnectionEventType.isConnected.name:
            guard let isConnected = Bool.parse(data) else {
                return
            }
            self.isConnected = isConnected
        case BSMetaConnectionMessageType.rx.name:
            parseRxData(data)
        case BSBatteryLevelMessageType.batteryLevel.name:
            guard let batteryLevel = BSBatteryLevel.parse(data) else {
                return
            }
            self.batteryLevelSubject.send(batteryLevel)
        case let deviceInformationTypeName where BSDeviceInformationType.allCases.contains(where: { $0.name == deviceInformationTypeName }):
            guard let deviceInformationType = BSDeviceInformationType(name: deviceInformationTypeName) else {
                logger?.error("failed to parse deviceInformationTypeName \(deviceInformationTypeName)")
                return
            }
            let string = String.parse(data)
            logger?.debug("\(deviceInformationType.name): \(string)")
            deviceInformationSubject.send((deviceInformationType, string))
        default:
            logger?.debug("miscellaneous deviceEvent \"\(typeString)\" (\(data.count) bytes)")
            guard let txRxMessageType = BSTxRxMessageUtils.enumStringMap[typeString] else {
                logger?.error("failed to get txRxMessageType for \"\(typeString)\"")
                return
            }
            rxMessageSubject.send((txRxMessageType, data))
            rxMessagesSubject.send()
        }
    }

    // MARK: - requiredMessages

    static let requiredDeviceInformationMessageTypes: [String] = [
        BSBatteryLevelMessageType.batteryLevel.name,

        BSDeviceInformationType.manufacturerNameString.name,
        BSDeviceInformationType.modelNumberString.name,
        BSDeviceInformationType.serialNumberString.name,
        BSDeviceInformationType.softwareRevisionString.name,
        BSDeviceInformationType.hardwareRevisionString.name,
        BSDeviceInformationType.firmwareRevisionString.name,
    ]
    static let requiredDeviceInformationMessages: [BSConnectionMessage] = requiredDeviceInformationMessageTypes.compactMap(BSConnectionMessageUtils.createMessage)
    private func requestDeviceInformation() {
        logger?.debug("requesting deviceInformation")
        client.sendDeviceMessages(Self.requiredDeviceInformationMessages, id: id)
    }

    // MARK: - isAvailable

    override var isAvailable: Bool { client.isConnected }
}
