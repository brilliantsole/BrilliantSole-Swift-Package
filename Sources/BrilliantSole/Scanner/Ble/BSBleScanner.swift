//
//  BSBleScanner.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/27/25.
//

import CoreBluetooth
import OSLog
import UkatonMacros

@StaticLogger
class BSBleScanner: BSBaseScanner {
    override private init() {
        super.init()
        isScanningAvailable = centralManager.state == .poweredOn
    }

    nonisolated(unsafe) static let shared = BSBleScanner()

    override static var connectionType: BSConnectionType { .ble }

    // MARK: - CBCentralManager

    lazy var centralManager: CBCentralManager = .init(delegate: self, queue: .main)

    // MARK: - scanning

    override func startScanning(_continue: inout Bool) {
        super.startScanning(_continue: &_continue)
        guard _continue else {
            return
        }
        centralManager.scanForPeripherals(withServices: [BSBleServiceUUID.main.uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        isScanning = centralManager.isScanning

        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [BSBleServiceUUID.main.uuid])
        peripherals.forEach { addPeripheral($0) }
    }

    override func stopScanning(_continue: inout Bool) {
        super.stopScanning(_continue: &_continue)
        guard _continue else {
            return
        }
        centralManager.stopScan()
        isScanning = centralManager.isScanning
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        logger.debug("discovered peripherial \(peripheral), advertisementData: \(advertisementData), rssi: \(RSSI)")
        // FILL - create discoveredDevice
    }

    // MARK: - peripherals

    private var peripheralDictionary: [CBPeripheral: BSDiscoveredDevice] = .init()
    private func add(peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !peripheralDictionary.keys.contains(peripheral) else {
            logger.debug("already added peripherial \(peripheral)")
            return
        }
    }

    private func remove(peripheral: CBPeripheral) {
        // FILL
    }
}
