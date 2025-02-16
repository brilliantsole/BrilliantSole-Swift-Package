//
//  BSConnectable.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Combine

public protocol BSConnectable {
    var connectionType: BSConnectionType? { get }

    var connectionStatus: BSConnectionStatus { get }
    var isConnected: Bool { get }

    func connect()
    func disconnect()
    func toggleConnection()

    associatedtype ConnectableType
    var connectionStatusPublisher: AnyPublisher<(ConnectableType, BSConnectionStatus), Never> { get }
    var isConnectedPublisher: AnyPublisher<(ConnectableType, Bool), Never> { get }

    var notConnectedPublisher: AnyPublisher<ConnectableType, Never> { get }
    var connectedPublisher: AnyPublisher<ConnectableType, Never> { get }
    var connectingPublisher: AnyPublisher<ConnectableType, Never> { get }
    var disconnectingPublisher: AnyPublisher<ConnectableType, Never> { get }
}
