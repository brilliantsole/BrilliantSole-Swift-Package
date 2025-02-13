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
    public nonisolated(unsafe) static let none = BSDiscoveredDevice(scanner: BSBleScanner.shared, id: "none", name: "none", deviceType: .leftInsole)

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

    private lazy var deviceTypeSubject: CurrentValueSubject<(BSDiscoveredDevice, BSDeviceType), Never> = .init((self, self.deviceType))
    public var deviceTypePublisher: AnyPublisher<(BSDiscoveredDevice, BSDeviceType), Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    public private(set) var deviceType: BSDeviceType = .leftInsole {
        didSet {
            logger?.debug("updated deviceType \(self.deviceType.name)")
            deviceTypeSubject.send((self, deviceType))
        }
    }

    private lazy var rssiSubject: CurrentValueSubject<(BSDiscoveredDevice, Int), Never> = .init((self, self.rssi))
    public var rssiPublisher: AnyPublisher<(BSDiscoveredDevice, Int), Never> {
        rssiSubject.eraseToAnyPublisher()
    }

    public private(set) var rssi: Int = 0 {
        didSet {
            logger?.debug("updated rssi \(self.rssi)")
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

    // MARK: - update

    private var lastTimeUpdated: Date
    var timeSinceLastUpdate: TimeInterval {
        return Date().timeIntervalSince(lastTimeUpdated)
    }

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

    private(set) var scanner: BSScanner

    // MARK: - connectionStatus

    private lazy var connectionStatusSubject: CurrentValueSubject<(BSDiscoveredDevice, BSConnectionStatus), Never> = .init((self, connectionStatus))
    public var connectionStatusPublisher: AnyPublisher<(BSDiscoveredDevice, BSConnectionStatus), Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    var connectionStatus: BSConnectionStatus { device?.connectionStatus ?? .notConnected }

    // MARK: - device

    func connect() -> BSDevice { scanner.connect(to: self) }
    func disconnect() -> BSDevice? { scanner.disconnect(from: self) }
    func toggleConnection() -> BSDevice { scanner.toggleConnection(to: self) }

    private var connectionStatusCancellables: Set<AnyCancellable> = []
    public var device: BSDevice? {
        didSet {
            connectionStatusCancellables.removeAll()
            device?.connectionStatusPublisher.sink { [self] _, connectionStatus in
                connectionStatusSubject.send((self, connectionStatus))
            }.store(in: &connectionStatusCancellables)
        }
    }
}

extension BSDiscoveredDevice: Identifiable {}

extension BSDiscoveredDevice: BSDeviceMetadata {}
