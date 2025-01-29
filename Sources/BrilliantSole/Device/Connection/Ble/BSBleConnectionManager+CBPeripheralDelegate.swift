//
//  BSBleConnectionManager+CBPeripheralDelegate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/28/25.
//

import CoreBluetooth

extension BSBleConnectionManager: CBPeripheralDelegate {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        logger.debug("peripheral updated name \(peripheral.name ?? "unknown")")
        discoveredDevice.update(name: peripheral.name)
    }    
}
