//
//  BSClientConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//
import OSLog
import UkatonMacros

// https://github.com/brilliantsole/BrilliantSole-Unity-Example/blob/31fb24b7152a8d60763fb645f0cc98e84bc0e811/Assets/BrilliantSole/Device/Connection/Client/BS_ClientConnectionManager.cs#L12

@StaticLogger
class BSClientConnectionManager: BSBaseConnectionManager {
    override class var connectionType: BSConnectionType { .udp }

    // MARK: - client

    var client: BSClient
    var bluetoothId: String

    init(discoveredDevice: BSDiscoveredDevice, client: BSClient, bluetoothId: String) {
        self.client = client
        self.bluetoothId = bluetoothId
        super.init(discoveredDevice: discoveredDevice)
    }

    // MARK: - connection

    override func connect(_continue: inout Bool) {
        super.connect(_continue: &_continue)
        guard _continue else { return }
        // FILL
        discoveredDevice.connect()
    }

    override func disconnect(_continue: inout Bool) {
        super.disconnect(_continue: &_continue)
        guard _continue else { return }
        // FILL
    }
}
