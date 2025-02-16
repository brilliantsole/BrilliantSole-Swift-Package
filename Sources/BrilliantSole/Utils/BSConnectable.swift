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

    var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }

    var notConnectedPublisher: AnyPublisher<Void, Never> { get }
    var connectedPublisher: AnyPublisher<Void, Never> { get }
    var connectingPublisher: AnyPublisher<Void, Never> { get }
    var disconnectingPublisher: AnyPublisher<Void, Never> { get }
}
