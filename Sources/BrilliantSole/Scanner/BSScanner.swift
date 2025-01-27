//
//  BSScanner.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import Combine

private let logger = getLogger(category: "BSScanner")

protocol BSScanner {
    // MARK: - isScanningAvailable

    var isScanningAvailableSubject: CurrentValueSubject<Bool, Never> { get }
    var isScanningAvailable: Bool { get }

    var scanningIsAvailableSubject: PassthroughSubject<Void, Never> { get }
    var scanningIsUnavailableSubject: PassthroughSubject<Void, Never> { get }

    // MARK: - isScanning

    var isScanningSubject: CurrentValueSubject<Bool, Never> { get }
    var isScanning: Bool { get }
    var scanStartSubject: PassthroughSubject<Void, Never> { get }
    var scanStopSubject: PassthroughSubject<Void, Never> { get }

    // MARK: - scan

    func startScanning()
    func stopScanning()
    func toggleScan()

    // MARK: - discoveredDevices

    var discoveredDevices: [String: BSDiscoveredDevice] { get }
    var discoveredDeviceSubject: PassthroughSubject<BSDiscoveredDevice, Never> { get }
    var expiredDeviceSubject: PassthroughSubject<BSDiscoveredDevice, Never> { get }

    mutating func connect(to device: BSDiscoveredDevice) -> BSDevice
    func disconnect(from device: BSDiscoveredDevice) -> BSDevice?
    mutating func toggleConnection(to device: BSDiscoveredDevice) -> BSDevice

    // MARK: - devices

    var devices: [String: BSDevice] { get }
}

extension BSScanner {
    var isScanningAvailable: Bool { isScanningAvailableSubject.value }
    var isScanning: Bool { isScanningSubject.value }

    func toggleScan() {
        logger.debug("toggling scan")
        isScanning ? stopScanning() : startScanning()
    }
}
