//
//  BSDevice+Wifi.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/26/25.
//

import Combine

public extension BSDevice {
    internal func setupWifiManager() {
        wifiManager.isWifiAvailablePublisher.sink { _ in
            // TODO: - request followup data
        }.store(in: &managerCancellables)
    }

    // MARK: - isWifiAvailable

    var isWifiAvailable: Bool { wifiManager.isWifiAvailable }
    var isWifiAvailablePublisher: AnyPublisher<Bool, Never> { wifiManager.isWifiAvailablePublisher }

    // MARK: - wifiSSID

    var wifiSSID: String { wifiManager.wifiSSID }
    var wifiSSIDPublisher: AnyPublisher<String, Never> { wifiManager.wifiSSIDPublisher }

    func setWifiSSID(_ newWifiSSID: String, sendImmediately: Bool = true) {
        wifiManager.setWifiSSID(newWifiSSID, sendImmediately: sendImmediately)
    }

    // MARK: - wifiPassword

    var wifiPassword: String { wifiManager.wifiPassword }
    var wifiPasswordPublisher: AnyPublisher<String, Never> { wifiManager.wifiPasswordPublisher }

    func setWifiPassword(_ newWifiPassword: String, sendImmediately: Bool = true) {
        wifiManager.setWifiPassword(newWifiPassword, sendImmediately: sendImmediately)
    }

    // MARK: - wifiConnectionEnabled

    var wifiConnectionEnabled: Bool { wifiManager.wifiConnectionEnabled }
    var wifiConnectionEnabledPublisher: AnyPublisher<Bool, Never> { wifiManager.wifiConnectionEnabledPublisher }

    func setWifiConnectionEnabled(_ newWifiConnectionEnabled: Bool, sendImmediately: Bool = true) {
        wifiManager.setWifiConnectionEnabled(newWifiConnectionEnabled, sendImmediately: sendImmediately)
    }

    func enableWifiConnection(sendImmediately: Bool = true) {
        wifiManager.enableWifiConnection(sendImmediately: sendImmediately)
    }

    func disableWifiConnection(sendImmediately: Bool = true) {
        wifiManager.disableWifiConnection(sendImmediately: sendImmediately)
    }

    func toggleWifiConnection(sendImmediately: Bool = true) {
        wifiManager.toggleWifiConnection(sendImmediately: sendImmediately)
    }

    // MARK: - isWifiConnected

    var isWifiConnected: Bool { wifiManager.isWifiConnected }
    var isWifiConnectedPublisher: AnyPublisher<Bool, Never> { wifiManager.isWifiConnectedPublisher }

    // MARK: - ipAddress

    var ipAddress: String? { wifiManager.ipAddress }
    var ipAddressPublisher: AnyPublisher<String?, Never> { wifiManager.ipAddressPublisher }

    // MARK: - isWifiSecure

    var isWifiSecure: Bool { wifiManager.isWifiSecure }
    var isWifiSecurePublisher: AnyPublisher<Bool, Never> { wifiManager.isWifiSecurePublisher }
}
