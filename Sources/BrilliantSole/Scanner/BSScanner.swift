//
//  BSScanner.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import Combine

private let logger = getLogger(category: "BSScanner")

public protocol BSScanner {
    static var connectionType: BSConnectionType { get }

    // MARK: - isScanningAvailable

    var isScanningAvailablePublisher: AnyPublisher<Bool, Never> { get }
    var isScanningAvailable: Bool { get }

    var scanningIsAvailablePublisher: AnyPublisher<Void, Never> { get }
    var scanningIsUnavailablePublisher: AnyPublisher<Void, Never> { get }

    // MARK: - isScanning

    var isScanningPublisher: AnyPublisher<Bool, Never> { get }
    var isScanning: Bool { get }
    var scanStartPublisher: AnyPublisher<Void, Never> { get }
    var scanStopPublisher: AnyPublisher<Void, Never> { get }

    // MARK: - scan

    func startScan(scanWhenAvailable: Bool)
    func startScan()
    func stopScan()
    func toggleScan(scanWhenAvailable: Bool)
    func toggleScan()

    // MARK: - discoveredDevices

    var discoveredDevices: [String: BSDiscoveredDevice] { get }
    var discoveredDevicePublisher: AnyPublisher<BSDiscoveredDevice, Never> { get }
    var expiredDevicePublisher: AnyPublisher<BSDiscoveredDevice, Never> { get }

    mutating func connect(to device: BSDiscoveredDevice) -> BSDevice
    func disconnect(from device: BSDiscoveredDevice) -> BSDevice?
    mutating func toggleConnection(to device: BSDiscoveredDevice) -> BSDevice

    // MARK: - devices

    var devices: [String: BSDevice] { get }
}

public extension BSScanner {
    func startScan() { startScan(scanWhenAvailable: true) }

    func toggleScan(scanWhenAvailable: Bool) {
        logger.debug("toggling scan")
        isScanning ? stopScan() : startScan()
    }

    func toggleScan() { toggleScan(scanWhenAvailable: true) }
}
