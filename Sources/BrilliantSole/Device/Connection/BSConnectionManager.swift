//
//  BSConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import Foundation

private let logger = getLogger(category: "BSConnectionManager", disabled: true)

public typealias BSBatteryLevel = UInt8

protocol BSConnectionManager: Identifiable & Hashable {
    static var connectionType: BSConnectionType { get }
    var connectionType: BSConnectionType { get }

    // MARK: - device information

    var name: String? { get }
    var deviceType: BSDeviceType? { get }

    var batteryLevelPublisher: AnyPublisher<BSBatteryLevel, Never> { get }
    var deviceInformationPublisher: AnyPublisher<(BSDeviceInformationType, BSDeviceInformationValue), Never> { get }

    // MARK: - connection

    var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> { get }
    var connectionStatus: BSConnectionStatus { get }

    var isConnected: Bool { get }
    func connect()
    func disconnect()
    func toggleConnection()

    // MARK: - messaging

    var rxMessagePublisher: AnyPublisher<(UInt8, Data), Never> { get }
    var rxMessagesPublisher: AnyPublisher<Void, Never> { get }

    func sendTxData(_ data: Data)
    var sendTxDataPublisher: AnyPublisher<Void, Never> { get }
}

extension BSConnectionManager {
    var connectionType: BSConnectionType { Self.connectionType }
    var isConnected: Bool { connectionStatus == .connected }

    func toggleConnection() {
        switch connectionStatus {
        case .connected, .connecting:
            disconnect()
        default:
            connect()
        }
    }
}
