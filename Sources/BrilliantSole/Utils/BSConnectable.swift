//
//  BSConnectable.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

public protocol BSConnectable {
    var connectionStatus: BSConnectionStatus { get }
    var isConnected: Bool { get }

    func connect()
    func disconnect()
    func toggleConnection()
}
