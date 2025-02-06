//
//  BSBaseClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import OSLog
import UkatonMacros

// https://github.com/brilliantsole/BrilliantSole-Unity-Example/blob/31fb24b7152a8d60763fb645f0cc98e84bc0e811/Assets/BrilliantSole/Client/BS_BaseClient.cs

@StaticLogger
class BSBaseClient: BSBaseScanner {
    // FILL

    func reset() {
        logger.debug("resetting")

        isScanning = false
        isScanningAvailable = false

        discoveredDevices.removeAll()
        // devices.removeAll()

        for (_, device) in devices {
            guard let connectionManager = device.connectionManager as? BSClientConnectionManager else {
                logger.debug("failed to cast connectionManager to BSClientConnectionManager")
                continue
            }
            // FILL
        }
    }

    func update() {
        // FILL
    }
}
