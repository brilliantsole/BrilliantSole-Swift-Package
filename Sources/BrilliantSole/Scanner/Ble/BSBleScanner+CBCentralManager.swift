//
//  BSBleScanner+CBCentralManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/27/25.
//

import CoreBluetooth

extension BSBleScanner: CBCentralManagerDelegate {
    // MARK: - state

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("centralManager state: \(String(describing: central.state))")
        isScanningAvailable = centralManager.state == .poweredOn
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        logger.debug("will restore centralManager state \(dict)")
    }

    // MARK: - peripherals

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.connectionStatus = .connected
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        logger.error("disconnected from peripheral \(peripheral) error: \(String(describing: error))")
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.connectionStatus = .notConnected
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
        logger.error("failed to connect to peripheral \(peripheral) at \(timestamp), isReconnecting: \(isReconnecting), error: \(String(describing: error))")
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.connectionStatus = .notConnected
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        logger.error("failed to connect to peripheral \(peripheral) error: \(String(describing: error))")
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.connectionStatus = .notConnected
    }
}
