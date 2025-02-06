//
//  BSBaseClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSBaseClient: BSBaseScanner {
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
            connectionManager.isConnected = false
        }
    }
}
