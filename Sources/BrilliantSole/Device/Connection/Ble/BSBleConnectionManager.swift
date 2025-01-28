//
//  BSBleConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import CoreBluetooth
import OSLog
import UkatonMacros

@StaticLogger
class BSBleConnectionManager: BSBaseConnectionManager {
    override class var connectionType: BSConnectionType { .ble }

    let peripheral: CBPeripheral

    init(discoveredDevice: BSDiscoveredDevice, peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init(discoveredDevice: discoveredDevice)
    }
}
