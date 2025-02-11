//
//  BSBleScanner+CBCentralManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/27/25.
//

import CoreBluetooth

extension BSBleScanner: CBCentralManagerDelegate {
    // MARK: - state

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger?.debug("centralManager state: \(String(describing: central.state))")
        switch central.state {
        case .unknown:
            logger?.debug("centralManager state \"unknown\"")
        case .resetting:
            logger?.debug("centralManager state \"resetting\"")
        case .unsupported:
            logger?.debug("centralManager state \"unsupported\"")
        case .unauthorized:
            logger?.debug("centralManager state \"unauthorized\"")
        case .poweredOff:
            logger?.debug("centralManager state \"poweredOff\"")
        case .poweredOn:
            logger?.debug("centralManager state \"poweredOn\"")
        @unknown default:
            logger?.debug("centralManager state \"unknoen\"")
        }
        isScanningAvailable = centralManager.state == .poweredOn
    }

    // MARK: - peripherals

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.onPeripheralStateUpdate()
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            logger?.error("error disconnecting from peripheral \(peripheral): \(error)")
        }
        logger?.debug("disconnected from peripheral \(peripheral)")
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.onPeripheralStateUpdate()
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
        if let error {
            logger?.error("error disconnecting from peripheral \(peripheral): \(error)")
        }
        logger?.debug("disconnected from \(peripheral) at \(timestamp), isReconnecting: \(isReconnecting)")
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.onPeripheralStateUpdate()
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        logger?.debug("failed to connect to peripheral \(peripheral) error: \(String(describing: error))")
        let connectionManager = getConnectionManager(for: peripheral)
        connectionManager?.onPeripheralStateUpdate()
    }
}
