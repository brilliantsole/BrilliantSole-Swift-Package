//
//  BSDevice+Firmware.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/8/25.
//

import Combine
import CoreBluetooth
import Foundation
import iOSMcuManagerLibrary

public extension BSDevice {
    internal func setupFirmwareManager() {}

    // MARK: - canUpgradeFirmware

    private func checkCanUpgradeFirmware() -> Bool {
        guard is_iOS || isMacOs else {
            logger?.debug("firmware upgrades only work on iOS and macOS")
            return false
        }
        guard isConnected else {
            logger?.debug("firmware upgrade requires connection")
            return false
        }
        guard connectionType == .ble else {
            logger?.debug("firmware upgrade bluetooth connection")
            return false
        }
        guard let bleConnectionManager = connectionManager as? BSBleConnectionManager else {
            logger?.error("failed to cast connectionManager as BSBleConnectionManager")
            return false
        }
        guard bleConnectionManager.characteristics[.smp] != nil else {
            logger?.debug("firmware upgrade requires smp characteristic")
            return false
        }
        return true
    }

    internal func updateCanUpgradeFirmware() {
        let newCanUpgradeFirmware = checkCanUpgradeFirmware()
        logger?.debug("newCanUpgradeFirmware: \(newCanUpgradeFirmware)")
        canUpgradeFirmware = newCanUpgradeFirmware
    }

    // MARK: - state

    var firmwareUpgradeState: BSFirmwareUpgradeState {
        firmwareManager.firmwareUpgradeState
    }

    var isFirmwareInProgress: Bool {
        firmwareManager.isInProgress
    }

    var isFirmwarePaused: Bool {
        firmwareManager.isPaused
    }

    // MARK: - commands

    func upgradeFirmware(fileName: String = "firmware", fileExtension: String = "bin", bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            logger?.error("file \(fileName).\(fileExtension) not found")
            return
        }
        upgradeFirmware(url: url)
    }

    func upgradeFirmware(url: URL) {
        guard canUpgradeFirmware else {
            return
        }
        logger?.debug("updating firmware to \(url.lastPathComponent)")

        guard let bleConnectionManager = connectionManager as? BSBleConnectionManager else {
            logger?.error("failed to cast connectionManager as BSBleConnectionManager")
            return
        }

        firmwareManager.upgradeFirmware(url: url, peripheral: bleConnectionManager.peripheral)
    }

    func cancelFirmwareUpgrade() {
        firmwareManager.cancel()
    }

    func resumeFirmwareUpgrade() {
        firmwareManager.resume()
    }

    func pauseFirmwareUpgrade() {
        firmwareManager.pause()
    }

    // MARK: - publishers

    var isFirmwareInProgressPublisher: AnyPublisher<Bool, Never> {
        firmwareManager.isFirmwareInProgressPublisher
    }

    var isFirmwarePausedPublisher: AnyPublisher<Bool, Never> {
        firmwareManager.isFirmwarePausedPublisher
    }

    var firmwareUpgradeDidStartPublisher: AnyPublisher<Void, Never> {
        firmwareManager.firmwareUpgradeDidStartPublisher
    }

    var firmwareUpgradeStateDidChangePublisher: BSFirmwareUpgradeStateDidChangePublisher {
        firmwareManager.firmwareUpgradeStateDidChangePublisher
    }
    
    var firmwareUpgradeStatePublisher: AnyPublisher<BSFirmwareUpgradeState, Never> {
        firmwareManager.firmwareUpgradeStatePublisher
    }

    var firmwareUpgradeDidCompletePublisher: AnyPublisher<Void, Never> {
        firmwareManager.firmwareUpgradeDidCompletePublisher
    }

    var firmwareUpgradeDidFailPublisher: BSFirmwareUpgradeDidFailPublisher {
        firmwareManager.firmwareUpgradeDidFailPublisher
    }

    var firmwareUpgradeDidCancelPublisher: AnyPublisher<FirmwareUpgradeState, Never> {
        firmwareManager.firmwareUpgradeDidCancelPublisher
    }

    var firmwareUploadProgressDidChangePublisher: BSFirmwareUploadProgressDidChangePublisher {
        firmwareManager.firmwareUploadProgressDidChangePublisher
    }
}
