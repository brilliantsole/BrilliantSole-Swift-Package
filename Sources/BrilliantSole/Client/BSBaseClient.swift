//
//  BSBaseClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSBaseClient: BSBaseScanner, BSClient {
    override init() {
        super.init()
        
        self.isScanningAvailablePublisher.sink { isScanningAvailable in
            if isScanningAvailable {
                self.checkIfScanning()
            }
        }.store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
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
    
    // MARK: - requiredMessages
    
    static let requiredMessageTypes: [BSServerMessageType] = [.isScanningAvailable, .discoveredDevices, .connectedDevices]
    static let requiredMessages: [BSServerMessage] = requiredMessageTypes.compactMap { .init(type: $0) }
    
    // MARK: - scanning
    
    override func startScan(scanWhenAvailable: Bool, _continue: inout Bool) {
        super.startScan(scanWhenAvailable: scanWhenAvailable, _continue: &_continue)
        guard _continue else {
            return
        }
        sendMessages([.init(type: .startScan)])
    }

    override func stopScan(_continue: inout Bool) {
        super.stopScan(_continue: &_continue)
        guard _continue else {
            return
        }
        sendMessages([.init(type: .stopScan)])
    }
}
