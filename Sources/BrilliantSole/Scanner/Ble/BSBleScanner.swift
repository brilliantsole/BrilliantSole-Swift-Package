//
//  BSBleScanner.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/27/25.
//

import CoreBluetooth
import OSLog
import UkatonMacros

@StaticLogger(disabled: false)
public class BSBleScanner: BSBaseScanner {
    override private init() {
        super.init()
        isScanningAvailable = centralManager.state == .poweredOn
    }

    public nonisolated(unsafe) static let shared = BSBleScanner()

    override public static var connectionType: BSConnectionType { .ble }

    // MARK: - CBCentralManager

    lazy var centralManager: CBCentralManager = .init(delegate: self, queue: .main)

    // MARK: - scanning

    override func startScan(scanWhenAvailable: Bool, _continue: inout Bool) {
        super.startScan(scanWhenAvailable: scanWhenAvailable, _continue: &_continue)
        guard _continue else {
            return
        }
        centralManager.scanForPeripherals(withServices: [BSBleServiceUUID.main.uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        isScanning = centralManager.isScanning

        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [BSBleServiceUUID.main.uuid])
        peripherals.forEach { onPeripheral($0) }
    }

    override public func stopScan(_continue: inout Bool) {
        super.stopScan(_continue: &_continue)
        guard _continue else {
            return
        }
        centralManager.stopScan()
        isScanning = centralManager.isScanning
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        logger?.debug("discovered peripherial \(peripheral), advertisementData: \(advertisementData), rssi: \(RSSI)")
        onDiscoveredPeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }

    // MARK: - peripherals

    private var peripherals: [String: CBPeripheral] = .init()

    private func onPeripheral(_ peripheral: CBPeripheral) {
        if peripherals[peripheral.id] == nil {
            peripherals[peripheral.id] = peripheral
        }

        var discoveredDevice = allDiscoveredDevices[peripheral.id]
        if let discoveredDevice {
            discoveredDevice.update(peripheral: peripheral)
        }
        else {
            discoveredDevice = .init(scanner: self, peripheral: peripheral)
        }
        add(discoveredDevice: discoveredDevice!)
    }

    private func onDiscoveredPeripheral(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripherals[peripheral.id] == nil {
            peripherals[peripheral.id] = peripheral
        }

        var discoveredDevice = allDiscoveredDevices[peripheral.id]
        if let discoveredDevice {
            discoveredDevice.update(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        }
        else {
            discoveredDevice = .init(scanner: self, peripheral: peripheral)
        }
        add(discoveredDevice: discoveredDevice!)
    }

    // MARK: - device

    private var connectionManagers: [String: BSBleConnectionManager] = .init()
    func getConnectionManager(for peripheral: CBPeripheral) -> BSBleConnectionManager? {
        guard let connectionManager = connectionManagers[peripheral.id] else {
            logger?.error("connectionManager not found for peripheral \(peripheral)")
            return nil
        }
        return connectionManager
    }

    override func createDevice(discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        guard let peripheral = peripherals[discoveredDevice.id] else {
            fatalError("no peripheral found for discoveredDevice \(discoveredDevice)")
        }
        let device = super.createDevice(discoveredDevice: discoveredDevice)
        let connectionManager: BSBleConnectionManager = .init(discoveredDevice: discoveredDevice, peripheral: peripheral, centralManager: centralManager)
        connectionManagers[discoveredDevice.id] = connectionManager
        device.connectionManager = connectionManager
        return device
    }

    // MARK: - connection

    override public func connect(to discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        let device = super.connect(to: discoveredDevice)
        device.connectionManager!.connect()
        return device
    }

    override public func disconnect(from discoveredDevice: BSDiscoveredDevice) -> BSDevice? {
        let device = super.disconnect(from: discoveredDevice)
        device?.connectionManager?.disconnect()
        return device
    }
}
