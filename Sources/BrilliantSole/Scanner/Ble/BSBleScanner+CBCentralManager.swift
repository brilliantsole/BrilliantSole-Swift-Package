//
//  BSBleScanner+CBCentralManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/27/25.
//

import CoreBluetooth

extension BSBleScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("centralManager state: \(String(describing: central.state))")
        isScanningAvailable = centralManager.state == .poweredOn
        if isScanningAvailable {
            if scanForDevicesWhenPoweredOn {
                startScanning()
                scanForDevicesWhenPoweredOn = false
            }
        }
    }
}
