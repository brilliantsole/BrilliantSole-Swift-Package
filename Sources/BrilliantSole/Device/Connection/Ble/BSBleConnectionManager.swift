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

    // MARK: - peripheral

    func onPeripheralStateUpdate() {
        logger.debug("peripheral state update: \(self.peripheral.state.rawValue)")
        switch peripheral.state {
        case .connected:
            peripheral.discoverServices(BSBleServiceUUID.allUuids)
        case .disconnected:
            services.removeAll()
            characteristics.removeAll()
            connectionStatus = .notConnected
        default:
            break
        }
    }

    func checkIfFullyConnected() {
        logger.debug("checking if fully connected")
        guard connectionStatus == .connecting else {
            logger.debug("connectionStatus is not connecting (got \(self.connectionStatus.name) - notFullyConnected")
            return
        }
        if let missingServiceUuid = BSBleServiceUUID.allCases.first(where: { !services.keys.contains($0) }) {
            logger.debug("missingServiceUuid \(missingServiceUuid.name) - notFullyConnected")
            return
        }
        if let missingCharacteristicUuid = BSBleCharacteristicUUID.allCases.first(where: { !characteristics.keys.contains($0) }) {
            logger.debug("missingCharacteristicUuid \(missingCharacteristicUuid.name) - notFullyConnected")
            return
        }
        if let (characteristicNotRead, _) = characteristics.first(where: { $0.key.readOnConnection && $0.value.properties.contains(.read) && $0.value.value == nil }) {
            logger.debug("characteristicNotRead \(characteristicNotRead.name) - notFullyConnected")
            return
        }
        if let (characteristicNotNotifying, _) = characteristics.first(where: { $0.key.notifyOnConnection && $0.value.properties.contains(.notify) && !$0.value.isNotifying }) {
            logger.debug("characteristicNotNotifying \(characteristicNotNotifying.name) - notFullyConnected")
            return
        }
        logger.debug("fully connected")
        connectionStatus = .connected
    }
}
