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
public final class BSDiscoveredDevice: BSConnectable, BSDeviceMetadata {
    public nonisolated(unsafe) static let none = BSDiscoveredDevice(scanner: BSBleScanner.shared, id: "none", name: "BS Placeholder", deviceType: .leftInsole, rssi: -20)

    public let id: String

    private lazy var nameSubject: CurrentValueSubject<String, Never> = .init(self.name)
    public var namePublisher: AnyPublisher<String, Never> {
        nameSubject.eraseToAnyPublisher()
    }

    public private(set) var name: String = "" {
        didSet {
            logger?.debug("updated name \(self.name)")
            nameSubject.send(name)
        }
    }

    private lazy var deviceTypeSubject: CurrentValueSubject<BSDeviceType, Never> = .init(self.deviceType)
    public var deviceTypePublisher: AnyPublisher<BSDeviceType, Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    public private(set) var deviceType: BSDeviceType = .leftInsole {
        didSet {
            logger?.debug("updated deviceType \(self.deviceType.name)")
            deviceTypeSubject.send(deviceType)
        }
    }

    private lazy var rssiSubject: CurrentValueSubject<Int?, Never> = .init(self.rssi)
    public var rssiPublisher: AnyPublisher<Int?, Never> {
        rssiSubject.eraseToAnyPublisher()
    }

    public private(set) var rssi: Int? {
        didSet {
            logger?.debug("updated rssi \(self.rssi ?? 0)")
            rssiSubject.send(rssi)
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
            lastTimeUpdatedSubject.send(lastTimeUpdated)
            timeSinceLastUpdate = lastTimeUpdated.timeIntervalSince(oldValue)
        }
    }

    private lazy var lastTimeUpdatedSubject: CurrentValueSubject<Date, Never> = .init(self.lastTimeUpdated)
    public var lastTimeUpdatedPublisher: AnyPublisher<Date, Never> {
        lastTimeUpdatedSubject.eraseToAnyPublisher()
    }

    // MARK: - timeSinceLastUpdate

    public private(set) var timeSinceLastUpdate: BSTimeInterval? {
        didSet {
            timeSinceLastUpdateSubject.send(timeSinceLastUpdate)
        }
    }

    public var timeSinceLastUpdateString: String? {
        guard let timeSinceLastUpdate else {
            return nil
        }
        return timeIntervalString(interval: timeSinceLastUpdate)
    }

    private lazy var timeSinceLastUpdateSubject: CurrentValueSubject<BSTimeInterval?, Never> = .init(self.timeSinceLastUpdate)
    public var timeSinceLastUpdatePublisher: AnyPublisher<BSTimeInterval?, Never> {
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

    public var connectionType: BSConnectionType? { scanner.connectionType }

    public func connect() { _ = scanner.connect(to: self) }
    public func disconnect() { _ = scanner.disconnect(from: self) }
    public func toggleConnection() { _ = scanner.toggleConnection(to: self) }

    // MARK: - connectionStatus

    public var connectionStatus: BSConnectionStatus { device?.connectionStatus ?? .notConnected }

    lazy var connectionStatusSubject: CurrentValueSubject<BSConnectionStatus, Never> = .init(self.connectionStatus)
    public var connectionStatusPublisher: AnyPublisher<BSConnectionStatus, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    private let notConnectedSubject: PassthroughSubject<Void, Never> = .init()
    public var notConnectedPublisher: AnyPublisher<Void, Never> {
        notConnectedSubject.eraseToAnyPublisher()
    }

    private let connectedSubject: PassthroughSubject<Void, Never> = .init()
    public var connectedPublisher: AnyPublisher<Void, Never> {
        connectedSubject.eraseToAnyPublisher()
    }

    private let connectingSubject: PassthroughSubject<Void, Never> = .init()
    public var connectingPublisher: AnyPublisher<Void, Never> {
        connectingSubject.eraseToAnyPublisher()
    }

    private let disconnectingSubject: PassthroughSubject<Void, Never> = .init()
    public var disconnectingPublisher: AnyPublisher<Void, Never> {
        disconnectingSubject.eraseToAnyPublisher()
    }

    // MARK: - isConnected

    lazy var isConnectedSubject: CurrentValueSubject<Bool, Never> = .init(self.isConnected)
    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    public var isConnected: Bool { device?.isConnected ?? false }

    // MARK: - device

    private lazy var deviceSubject: CurrentValueSubject<BSDevice?, Never> = .init(nil)
    public var devicePublisher: AnyPublisher<BSDevice?, Never> {
        deviceSubject.eraseToAnyPublisher()
    }

    private var deviceCancellables: Set<AnyCancellable> = []

    public var device: BSDevice? {
        didSet {
            deviceCancellables.removeAll()

            device?.connectionStatusPublisher.sink { [self] connectionStatus in
                connectionStatusSubject.send(connectionStatus)
            }.store(in: &deviceCancellables)
            device?.isConnectedPublisher.sink { [self] isConnected in
                isConnectedSubject.send(isConnected)
            }.store(in: &deviceCancellables)

            device?.connectedPublisher.sink { [self] _ in
                connectedSubject.send()
            }.store(in: &deviceCancellables)
            device?.connectingPublisher.sink { [self] _ in
                connectingSubject.send()
            }.store(in: &deviceCancellables)
            device?.disconnectingPublisher.sink { [self] _ in
                disconnectingSubject.send()
            }.store(in: &deviceCancellables)
            device?.notConnectedPublisher.sink { [self] _ in
                notConnectedSubject.send()
            }.store(in: &deviceCancellables)

            deviceSubject.send(device)
        }
    }
}

extension BSDiscoveredDevice: Identifiable {}
