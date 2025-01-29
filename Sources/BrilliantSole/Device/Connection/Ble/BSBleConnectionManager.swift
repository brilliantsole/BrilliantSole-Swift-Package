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

    var peripheral: CBPeripheral {
        didSet {
            oldValue.delegate = nil
            peripheral.delegate = self
        }
    }

    let centralManager: CBCentralManager

    init(discoveredDevice: BSDiscoveredDevice, peripheral: CBPeripheral, centralManager: CBCentralManager) {
        self.peripheral = peripheral
        self.centralManager = centralManager
        super.init(discoveredDevice: discoveredDevice)

        // FILL - listen for connection
    }

    override func connect(_continue: inout Bool) {
        super.connect(_continue: &_continue)
        guard _continue else { return }
        centralManager.connect(peripheral, options: [CBConnectPeripheralOptionEnableAutoReconnect: true])
    }

    override func disconnect(_continue: inout Bool) {
        super.disconnect(_continue: &_continue)
        guard _continue else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
