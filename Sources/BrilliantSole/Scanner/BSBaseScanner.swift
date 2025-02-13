//
//  BSBaseScanner.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import Combine
import Foundation

private let logger = getLogger(category: "BSBaseScanner", disabled: true)

public class BSBaseScanner: NSObject, BSScanner {
    public class var connectionType: BSConnectionType { fatalError("not implemented") }

    // MARK: - isScanningAvailable

    private let isScanningAvailableSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isScanningAvailablePublisher: AnyPublisher<Bool, Never> {
        isScanningAvailableSubject.eraseToAnyPublisher()
    }

    public var isScanningAvailable: Bool {
        get { isScanningAvailableSubject.value }
        set {
            logger?.debug("updated isScanningAvailable \(newValue)")
            isScanningAvailableSubject.value = newValue
            if isScanningAvailable {
                scanningIsAvailableSubject.send()
                if scanWhenAvailable {
                    logger?.debug("reattempting scan")
                    startScan(scanWhenAvailable: scanWhenAvailable)
                }
            }
            else {
                stopScan()
                scanningIsUnavailableSubject.send()
            }
        }
    }

    private let scanningIsAvailableSubject: PassthroughSubject<Void, Never> = .init()
    public var scanningIsAvailablePublisher: AnyPublisher<Void, Never> {
        scanningIsAvailableSubject.eraseToAnyPublisher()
    }

    private let scanningIsUnavailableSubject: PassthroughSubject<Void, Never> = .init()
    public var scanningIsUnavailablePublisher: AnyPublisher<Void, Never> {
        scanningIsUnavailableSubject.eraseToAnyPublisher()
    }

    // MARK: - isScanning

    private let isScanningSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isScanningPublisher: AnyPublisher<Bool, Never> {
        isScanningSubject.eraseToAnyPublisher()
    }

    public var isScanning: Bool {
        get { isScanningSubject.value }
        set {
            logger?.debug("updated isScannng \(newValue)")
            isScanningSubject.value = newValue
            if isScanning {
                scanStartSubject.send()
                startCheckingExpiredDiscoveredDevices()
                scanWhenAvailable = false
            }
            else {
                scanStopSubject.send()
                stopCheckingExpiredDiscoveredDevices()
            }
        }
    }

    private let scanStartSubject: PassthroughSubject<Void, Never> = .init()
    public var scanStartPublisher: AnyPublisher<Void, Never> {
        scanStartSubject.eraseToAnyPublisher()
    }

    private let scanStopSubject: PassthroughSubject<Void, Never> = .init()
    public var scanStopPublisher: AnyPublisher<Void, Never> {
        scanStopSubject.eraseToAnyPublisher()
    }

    // MARK: - scan

    private var scanWhenAvailable: Bool = false

    public func startScan(scanWhenAvailable: Bool) {
        var _continue = true
        startScan(scanWhenAvailable: scanWhenAvailable, _continue: &_continue)
    }

    func startScan(scanWhenAvailable: Bool, _continue: inout Bool) {
        guard !isScanning else {
            logger?.debug("already scanning")
            _continue = false
            return
        }
        guard isScanningAvailable else {
            logger?.warning("scanning is not available")
            _continue = false
            logger?.debug("waiting until scaning is available")
            self.scanWhenAvailable = scanWhenAvailable
            return
        }
        discoveredDevicesMap.removeAll()
        devices.removeAll()

        discoveredDevices.removeAll()
        discoveredDevicesSubject.value = discoveredDevices

        logger?.debug("starting scan")
        _continue = true
    }

    public func stopScan() {
        scanWhenAvailable = false

        var _continue = true
        stopScan(_continue: &_continue)
    }

    public func stopScan(_continue: inout Bool) {
        guard isScanning else {
            logger?.debug("already not scanning")
            _continue = false
            return
        }
        logger?.debug("stopping scan")
        _continue = true
    }

    // MARK: - discoveredDevices

    public var discoveredDevicesMap: [String: BSDiscoveredDevice] = .init()
    var allDiscoveredDevices: [String: BSDiscoveredDevice] = .init()

    private let discoveredDeviceSubject: PassthroughSubject<BSDiscoveredDevice, Never> = .init()
    public var discoveredDevicePublisher: AnyPublisher<BSDiscoveredDevice, Never> {
        discoveredDeviceSubject.eraseToAnyPublisher()
    }

    public private(set) var discoveredDevices: [BSDiscoveredDevice] = .init()
    private let discoveredDevicesSubject: CurrentValueSubject<[BSDiscoveredDevice], Never> = .init([])
    public var discoveredDevicesPublisher: AnyPublisher<[BSDiscoveredDevice], Never> {
        discoveredDevicesSubject.eraseToAnyPublisher()
    }

    private let expiredDeviceSubject: PassthroughSubject<BSDiscoveredDevice, Never> = .init()
    public var expiredDevicePublisher: AnyPublisher<BSDiscoveredDevice, Never> {
        expiredDeviceSubject.eraseToAnyPublisher()
    }

    func add(discoveredDevice: BSDiscoveredDevice) {
        logger?.debug("adding discoveredDevice \(discoveredDevice.name)")
        if allDiscoveredDevices[discoveredDevice.id] !== discoveredDevice {
            allDiscoveredDevices[discoveredDevice.id] = discoveredDevice
        }
        if discoveredDevicesMap[discoveredDevice.id] !== discoveredDevice {
            discoveredDevicesMap[discoveredDevice.id] = discoveredDevice
            discoveredDeviceSubject.send(discoveredDevice)

            discoveredDevices.append(discoveredDevice)
            discoveredDevicesSubject.value = discoveredDevices
        }
    }

    func remove(discoveredDevice: BSDiscoveredDevice) {
        logger?.debug("removing discoveredDevice \(discoveredDevice.name)")
        guard discoveredDevicesMap[discoveredDevice.id] != nil else {
            logger?.error("no discoveredDevice \(discoveredDevice.name) found")
            return
        }
        discoveredDevicesMap[discoveredDevice.id] = nil
        expiredDeviceSubject.send(discoveredDevice)

        discoveredDevices.removeAll { $0.id == discoveredDevice.id }
        discoveredDevicesSubject.value = discoveredDevices
    }

    public func connect(to discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        let device = getDevice(discoveredDevice: discoveredDevice, createIfNotFound: true)!
        device.connect()
        return device
    }

    public func disconnect(from discoveredDevice: BSDiscoveredDevice) -> BSDevice? {
        let device = getDevice(discoveredDevice: discoveredDevice)
        device?.disconnect()
        return device
    }

    public func toggleConnection(to discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        let device = getDevice(discoveredDevice: discoveredDevice, createIfNotFound: true)!
        device.toggleConnection()
        return device
    }

    // MARK: - expiration

    private static let discoveredDeviceExpirationInterval: TimeInterval = 5
    @objc func checkExpiredDiscoveredDevices() {
        var deviceIdsToRemove: [String] = .init()
        for (id, discoveredDevice) in discoveredDevicesMap {
            if discoveredDevice.timeSinceLastUpdate > Self.discoveredDeviceExpirationInterval {
                logger?.debug("discoveredDevice \(discoveredDevice.name) expired")
                deviceIdsToRemove.append(id)
            }
        }
        deviceIdsToRemove.forEach { remove(discoveredDevice: discoveredDevicesMap[$0]!) }
    }

    private static let checkExpiredDiscoveredDevicesInterval: TimeInterval = 1
    private var checkExpiredDiscoveredDevicesTimer: Timer?
    private func startCheckingExpiredDiscoveredDevices() {
        checkExpiredDiscoveredDevicesTimer?.invalidate()
        checkExpiredDiscoveredDevicesTimer = .scheduledTimer(timeInterval: Self.checkExpiredDiscoveredDevicesInterval, target: self, selector: #selector(checkExpiredDiscoveredDevices), userInfo: nil, repeats: true)
        checkExpiredDiscoveredDevicesTimer?.tolerance = 0.2
    }

    private func stopCheckingExpiredDiscoveredDevices() {
        checkExpiredDiscoveredDevicesTimer?.invalidate()
        checkExpiredDiscoveredDevicesTimer = nil
    }

    // MARK: - devices

    public var devices: [String: BSDevice] = .init()
    var allDevices: [String: BSDevice] = .init()

    private func getDevice(discoveredDevice: BSDiscoveredDevice, createIfNotFound: Bool = false) -> BSDevice? {
        guard discoveredDevicesMap[discoveredDevice.id] != nil else {
            fatalError("invalid discoveredDevice \(discoveredDevicesMap)")
        }
        if allDevices[discoveredDevice.id] == nil {
            logger?.debug("no device found for \(discoveredDevice.name)")
            if createIfNotFound {
                _ = createDevice(discoveredDevice: discoveredDevice)
            }
            else {
                return nil
            }
        }
        return allDevices[discoveredDevice.id]
    }

    private var deviceIsConnectedCancellables = Set<AnyCancellable>()
    func createDevice(discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        logger?.debug("creating device for \(discoveredDevice.name)")
        let device: BSDevice = .init(discoveredDevice: discoveredDevice)
        allDevices[discoveredDevice.id] = device
        device.isConnectedPublisher.sink { [weak self] device, isConnected in
            if isConnected {
                self?.devices[discoveredDevice.id] = device
            }
            else {
                self?.devices[discoveredDevice.id] = nil
            }
        }.store(in: &deviceIsConnectedCancellables)
        return device
    }
}
