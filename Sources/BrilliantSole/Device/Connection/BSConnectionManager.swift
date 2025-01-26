//
//  BSConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import Foundation

private let logger = getLogger(category: "BSConnectionManager")

typealias BSBatteryLevel = UInt8

protocol BSConnectionManager {
    static var connectionType: BSConnectionType { get }

    // MARK: - device information

    var name: String? { get }
    var deviceType: BSDeviceType? { get }

    var batteryLevelSubject: PassthroughSubject<BSBatteryLevel, Never> { get }
    var deviceInformationSubject: PassthroughSubject<(BSDeviceInformationType, BSDeviceInformationValue), Never> { get }

    // MARK: - connection

    var connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> { get }
    var connectionStatus: BSConnectionStatus { get }

    var isConnected: Bool { get }
    func connect()
    func disconnect()

    // MARK: - messaging

    var rxMessageSubject: PassthroughSubject<(UInt8, Data), Never> { get }
    var rxMessagesSubject: PassthroughSubject<Void, Never> { get }

    func sendTxData(_ data: Data)
    var sendTxDataSubject: PassthroughSubject<Void, Never> { get }
}

extension BSConnectionManager {
    func sendTxData(_ data: Data) {
        logger.log("sending \(data.count) bytes")
    }

    var isConnected: Bool { connectionStatus == .connected }
    var connectionStatus: BSConnectionStatus { connectionStatusSubject.value }
}
