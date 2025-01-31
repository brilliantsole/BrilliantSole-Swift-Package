//
//  BSBleConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Combine
import CoreBluetooth
import OSLog
import UkatonMacros

@StaticLogger
class BSBleConnectionManager: BSBaseConnectionManager {
    override class var connectionType: BSConnectionType { .ble }

    let peripheral: CBPeripheral
    let centralManager: CBCentralManager
    private var cancellables: Set<AnyCancellable> = []

    var services: [BSBleServiceUUID: CBService] = .init()
    var characteristics: [BSBleCharacteristicUUID: CBCharacteristic] = .init()

    init(discoveredDevice: BSDiscoveredDevice, peripheral: CBPeripheral, centralManager: CBCentralManager) {
        self.peripheral = peripheral
        self.centralManager = centralManager
        super.init(discoveredDevice: discoveredDevice)
        self.peripheral.delegate = self

        connectedPublisher.sink { [weak self] _ in
            self?.peripheral.discoverServices(BSBleServiceUUID.allUuids)
        }.store(in: &cancellables)

        notConnectedPublisher.sink { [weak self] _ in
            self?.services.removeAll()
            self?.characteristics.removeAll()
        }.store(in: &cancellables)
    }

    // MARK: - connection

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

    // MARK: - messaging

    override func sendTxData(_ data: Data) {
        super.sendTxData(data)
        guard let characteristic = characteristics[BSBleCharacteristicUUID.tx] else {
            fatalError("tx characteristic not found")
        }
        logger.debug("writing \(data.count) bytes to \(BSBleCharacteristicUUID.tx.name)")
        peripheral.writeValue(data, for: characteristic, type: BSBleCharacteristicUUID.tx.writeType)
    }
}
