//
//  BSDiscoveredDevice.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSDiscoveredDevice {
    let id: String
    private(set) var name: String
    private(set) var deviceType: BSDeviceType?
    private(set) var rssi: Int?

    // MARK: - init

    init(scanner: BSScanner, id: String, name: String, deviceType: BSDeviceType? = nil, rssi: Int? = nil) {
        self.scanner = scanner
        self.id = id
        self.name = name
        self.deviceType = deviceType
        self.rssi = rssi

        self.lastTimeUpdated = .now
    }

    convenience init(scanner: BSScanner, discoveredDeviceJson: BSDiscoveredDeviceJson) {
        self.init(scanner: scanner, id: discoveredDeviceJson.bluetoothId, name: discoveredDeviceJson.name, deviceType: discoveredDeviceJson.deviceType, rssi: discoveredDeviceJson.rssi)
    }

    // MARK: - update

    private var lastTimeUpdated: Date
    var timeSinceLastUpdate: TimeInterval {
        return Date().timeIntervalSince(lastTimeUpdated)
    }

    func update(name: String?, deviceType: BSDeviceType?, rssi: Int?) {
        if let name {
            self.name = name
        }
        if let deviceType {
            self.deviceType = deviceType
        }
        if let rssi {
            self.rssi = rssi
        }
        lastTimeUpdated = .now
        logger.debug("updated \(self.name)")
    }

    func update(discoveredDeivceJson: BSDiscoveredDeviceJson) {
        update(name: discoveredDeivceJson.name, deviceType: discoveredDeivceJson.deviceType, rssi: discoveredDeivceJson.rssi)
    }

    // MARK: - scanner

    private(set) var scanner: BSScanner

    // MARK: - device

    func connect() -> BSDevice { scanner.connect(to: self) }
    func disconnect() -> BSDevice? { scanner.disconnect(from: self) }
    func toggleConnection() -> BSDevice { scanner.toggleConnection(to: self) }

    var device: BSDevice? { scanner.devices[id] }
}
