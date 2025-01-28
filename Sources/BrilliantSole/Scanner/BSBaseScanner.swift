//
//  BSBaseScanner.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import Combine
import Foundation

private let logger = getLogger(category: "BSBaseScanner")

class BSBaseScanner: NSObject, BSScanner {
    class var connectionType: BSConnectionType { fatalError("not implemented") }

    // MARK: - isScanningAvailable

    let isScanningAvailableSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isScanningAvailable: Bool {
        get { isScanningAvailableSubject.value }
        set {
            isScanningAvailableSubject.value = newValue
            logger.debug("updated isScanningAvailable \(self.isScanningAvailable)")
            if isScanningAvailable {
                scanningIsAvailableSubject.send()
            }
            else {
                scanningIsUnavailableSubject.send()
            }
        }
    }

    let scanningIsAvailableSubject: PassthroughSubject<Void, Never> = .init()
    let scanningIsUnavailableSubject: PassthroughSubject<Void, Never> = .init()

    // MARK: - isScanning

    let isScanningSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isScanning: Bool {
        get { isScanningSubject.value }
        set {
            isScanningSubject.value = newValue
            logger.debug("updated isScannng \(self.isScanning)")
            if isScanning {
                scanStartSubject.send()
                startCheckingExpiredDiscoveredDevices()
            }
            else {
                scanStopSubject.send()
                stopCheckingExpiredDiscoveredDevices()
            }
        }
    }

    let scanStartSubject: PassthroughSubject<Void, Never> = .init()
    let scanStopSubject: PassthroughSubject<Void, Never> = .init()

    // MARK: - scan

    public func startScanning() {
        var _continue = true
        startScanning(_continue: &_continue)
    }

    func startScanning(_continue: inout Bool) {
        guard !isScanning else {
            logger.debug("already scanning")
            _continue = false
            return
        }
        guard isScanningAvailable else {
            logger.warning("scanning is not available")
            _continue = false
            return
        }
        discoveredDevices.removeAll()
        devices.removeAll()
        logger.debug("starting scan")
        _continue = true
    }

    public func stopScanning() {
        var _continue = true
        stopScanning(_continue: &_continue)
    }

    func stopScanning(_continue: inout Bool) {
        guard isScanning else {
            logger.debug("already not scanning")
            _continue = false
            return
        }
        logger.debug("stopping scan")
        _continue = true
    }

    // MARK: - discoveredDevices

    private(set) var discoveredDevices: [String: BSDiscoveredDevice] = .init()
    var allDiscoveredDevices: [String: BSDiscoveredDevice] = .init()
    let discoveredDeviceSubject: PassthroughSubject<BSDiscoveredDevice, Never> = .init()
    let expiredDeviceSubject: PassthroughSubject<BSDiscoveredDevice, Never> = .init()

    func add(discoveredDevice: BSDiscoveredDevice) {
        logger.debug("adding discoveredDevice \(discoveredDevice.name)")
        discoveredDevices[discoveredDevice.id] = discoveredDevice
        allDiscoveredDevices[discoveredDevice.id] = discoveredDevice
        discoveredDeviceSubject.send(discoveredDevice)
    }

    func remove(discoveredDevice: BSDiscoveredDevice) {
        logger.debug("removing discoveredDevice \(discoveredDevice.name)")
        guard discoveredDevices[discoveredDevice.id] != nil else {
            logger.error("no discoveredDevice \(discoveredDevice.name) found")
            return
        }
        discoveredDevices[discoveredDevice.id] = nil
        expiredDeviceSubject.send(discoveredDevice)
    }

    func connect(to discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        getDevice(discoveredDevice: discoveredDevice, createIfNotFound: true)!
    }

    func disconnect(from discoveredDevice: BSDiscoveredDevice) -> BSDevice? {
        let device = getDevice(discoveredDevice: discoveredDevice)
        device?.disconnect()
        return device
    }

    func toggleConnection(to discoveredDevice: BSDiscoveredDevice) -> BSDevice {
        let device = getDevice(discoveredDevice: discoveredDevice, createIfNotFound: true)!
        device.toggleConnection()
        return device
    }

    // MARK: - expiration

    private static let discoveredDeviceExpirationInterval: TimeInterval = 5
    @objc func checkExpiredDiscoveredDevices() {
        var deviceIdsToRemove: [String] = .init()
        for (id, discoveredDevice) in discoveredDevices {
            if discoveredDevice.timeSinceLastUpdate > Self.discoveredDeviceExpirationInterval {
                logger.debug("discoveredDevice \(discoveredDevice.name) expired")
                deviceIdsToRemove.append(id)
            }
        }
        deviceIdsToRemove.forEach { remove(discoveredDevice: discoveredDevices[$0]!) }
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

    private(set) var devices: [String: BSDevice] = .init()
    var allDevices: [String: BSDevice] = .init()

    private func getDevice(discoveredDevice: BSDiscoveredDevice, createIfNotFound: Bool = false) -> BSDevice? {
        guard discoveredDevices[discoveredDevice.id] != nil else {
            fatalError("invalid discoveredDevice \(discoveredDevices)")
        }
        if allDevices[discoveredDevice.id] == nil {
            logger.debug("no device found for \(discoveredDevice.name)")
            if createIfNotFound {
                createDevice(discoveredDevice: discoveredDevice)
            }
            else {
                return nil
            }
        }
        return allDevices[discoveredDevice.id]
    }

    private var deviceIsConnectedCancellables = Set<AnyCancellable>()
    private func createDevice(discoveredDevice: BSDiscoveredDevice) {
        logger.debug("creating device for \(discoveredDevice.name)")
        let device: BSDevice = .init(discoveredDevice: discoveredDevice)
        allDevices[discoveredDevice.id] = device
        device.isConnectedSubject.sink { [weak self] connected in
            if connected {
                self?.devices[discoveredDevice.id] = device
            }
            else {
                self?.devices[discoveredDevice.id] = nil
            }
        }.store(in: &deviceIsConnectedCancellables)
    }
}
