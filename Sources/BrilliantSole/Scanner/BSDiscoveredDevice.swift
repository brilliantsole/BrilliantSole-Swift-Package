//
//  BSDiscoveredDevice.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public final class BSDiscoveredDevice {
    public nonisolated(unsafe) static let none = BSDiscoveredDevice(scanner: BSBleScanner.shared, id: "none", name: "BS Placeholder", deviceType: .leftInsole, rssi: -20)

    public let id: String

    private lazy var nameSubject: CurrentValueSubject<(BSDiscoveredDevice, String), Never> = .init((self, self.name))
    public var namePublisher: AnyPublisher<(BSDiscoveredDevice, String), Never> {
        nameSubject.eraseToAnyPublisher()
    }

    public private(set) var name: String = "" {
        didSet {
            logger?.debug("updated name \(self.name)")
            nameSubject.send((self, name))
        }
    }

    private lazy var deviceTypeSubject: CurrentValueSubject<(BSDiscoveredDevice, BSDeviceType?), Never> = .init((self, self.deviceType))
    public var deviceTypePublisher: AnyPublisher<(BSDiscoveredDevice, BSDeviceType?), Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    public private(set) var deviceType: BSDeviceType? {
        didSet {
            logger?.debug("updated deviceType \(self.deviceType?.name ?? "nil")")
            deviceTypeSubject.send((self, deviceType))
        }
    }

    private lazy var rssiSubject: CurrentValueSubject<(BSDiscoveredDevice, Int?), Never> = .init((self, self.rssi))
    public var rssiPublisher: AnyPublisher<(BSDiscoveredDevice, Int?), Never> {
        rssiSubject.eraseToAnyPublisher()
    }

    public private(set) var rssi: Int? {
        didSet {
            logger?.debug("updated rssi \(self.rssi ?? 0)")
            rssiSubject.send((self, rssi))
        }
    }

    // MARK: - init

    init(scanner: BSScanner, id: String, name: String = "", deviceType: BSDeviceType? = nil, rssi: Int? = nil) {
        self.scanner = scanner
        self.id = id
        self.lastTimeUpdated = .now
        self.name = name
        if let deviceType {
            self.deviceType = deviceType
        }
        if let rssi {
            self.rssi = rssi
        }
    }

    convenience init(scanner: BSScanner, discoveredDeviceJson: BSDiscoveredDeviceJson) {
        self.init(scanner: scanner, id: discoveredDeviceJson.id, name: discoveredDeviceJson.name, deviceType: discoveredDeviceJson.deviceType, rssi: discoveredDeviceJson.rssi)
    }

    // MARK: - lastTimeUpdated

    public private(set) var lastTimeUpdated: Date {
        didSet {
            lastTimeUpdatedSubject.send((self, lastTimeUpdated))
            timeSinceLastUpdate = lastTimeUpdated.timeIntervalSince(oldValue)
        }
    }

    private lazy var lastTimeUpdatedSubject: CurrentValueSubject<(BSDiscoveredDevice, Date), Never> = .init((self, self.lastTimeUpdated))
    public var lastTimeUpdatedPublisher: AnyPublisher<(BSDiscoveredDevice, Date), Never> {
        lastTimeUpdatedSubject.eraseToAnyPublisher()
    }

    // MARK: - timeSinceLastUpdate

    public private(set) var timeSinceLastUpdate: BSTimeInterval? {
        didSet {
            timeSinceLastUpdateSubject.send((self, timeSinceLastUpdate))
        }
    }

    public var timeSinceLastUpdateString: String? {
        guard let timeSinceLastUpdate else {
            return nil
        }
        return timeIntervalString(interval: timeSinceLastUpdate)
    }

    private lazy var timeSinceLastUpdateSubject: CurrentValueSubject<(BSDiscoveredDevice, BSTimeInterval?), Never> = .init((self, self.timeSinceLastUpdate))
    public var timeSinceLastUpdatePublisher: AnyPublisher<(BSDiscoveredDevice, BSTimeInterval?), Never> {
        timeSinceLastUpdateSubject.eraseToAnyPublisher()
    }

    // MARK: - update

    func update(name: String? = nil, deviceType: BSDeviceType? = nil, rssi: Int? = nil) {
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
        logger?.debug("updated \(self.id)")
    }

    func update(discoveredDeivceJson: BSDiscoveredDeviceJson) {
        update(name: discoveredDeivceJson.name, deviceType: discoveredDeivceJson.deviceType, rssi: discoveredDeivceJson.rssi)
    }

    // MARK: - scanner

    public private(set) var scanner: BSScanner

    // MARK: - connection

    public func connect() -> BSDevice { scanner.connect(to: self) }
    public func disconnect() -> BSDevice? { scanner.disconnect(from: self) }
    public func toggleConnection() -> BSDevice { scanner.toggleConnection(to: self) }

    // MARK: - device

    private lazy var deviceSubject: CurrentValueSubject<(BSDiscoveredDevice, BSDevice?), Never> = .init((self, nil))
    public var devicePublisher: AnyPublisher<(BSDiscoveredDevice, BSDevice?), Never> {
        deviceSubject.eraseToAnyPublisher()
    }

    public var device: BSDevice? {
        didSet {
            deviceSubject.send((self, device))
        }
    }
}

extension BSDiscoveredDevice: Identifiable {}
