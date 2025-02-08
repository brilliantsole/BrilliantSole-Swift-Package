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
public class BSDiscoveredDevice {
    let id: String

    private let nameSubject: CurrentValueSubject<String, Never> = .init("")
    public var namePublisher: AnyPublisher<String, Never> {
        nameSubject.eraseToAnyPublisher()
    }

    private(set) var name: String {
        get { nameSubject.value }
        set {
            guard name != newValue else {
                logger?.debug("redundant name assignment \(newValue)")
                return
            }
            logger?.debug("updated name \(newValue)")
            nameSubject.value = newValue
        }
    }

    private let deviceTypeSubject: CurrentValueSubject<BSDeviceType?, Never> = .init(nil)
    public var deviceTypePublisher: AnyPublisher<BSDeviceType?, Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    private(set) var deviceType: BSDeviceType? {
        get { deviceTypeSubject.value }
        set {
            guard newValue != nil else { return }
            guard deviceType != newValue else {
                logger?.debug("redundant deviceType assignment \(newValue?.name ?? "nil")")
                return
            }
            logger?.debug("updated deviceType \(newValue?.name ?? "nil")")
            deviceTypeSubject.value = newValue
        }
    }

    private let rssiSubject: CurrentValueSubject<Int?, Never> = .init(nil)
    public var rssiaPublisher: AnyPublisher<Int?, Never> {
        rssiSubject.eraseToAnyPublisher()
    }

    private(set) var rssi: Int? {
        get { rssiSubject.value }
        set {
            guard newValue != nil else { return }
//            guard rssi != newValue else {
//                logger?.debug("redundant rssi assignment \(newValue ?? 0)")
//                return
//            }
            logger?.debug("updated rssi \(newValue ?? 0)")
            rssiSubject.value = newValue
        }
    }

    // MARK: - init

    init(scanner: BSScanner, id: String, name: String = "", deviceType: BSDeviceType? = nil, rssi: Int? = nil) {
        self.scanner = scanner
        self.id = id
        self.lastTimeUpdated = .now
        self.name = name
        self.deviceType = deviceType
        self.rssi = rssi
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

    // MARK: - device

    func connect() -> BSDevice { scanner.connect(to: self) }
    func disconnect() -> BSDevice? { scanner.disconnect(from: self) }
    func toggleConnection() -> BSDevice { scanner.toggleConnection(to: self) }

    var device: BSDevice? { scanner.devices[id] }
}
