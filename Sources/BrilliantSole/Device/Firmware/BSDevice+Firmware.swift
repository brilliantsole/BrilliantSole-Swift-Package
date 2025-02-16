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

    var isUpgradingFirmware: Bool {
        firmwareManager.isInProgress
    }

    var isFirmwareUpgradePaused: Bool {
        firmwareManager.isPaused
    }

    // MARK: - commands

    func upgradeFirmware(fileName: String = "firmware", fileExtension: String = "bin", bundle: Bundle = .main) {
        guard canUpgradeFirmware else {
            return
        }
        logger?.debug("updating firmware to \(fileName).\(fileExtension)")

        guard let bleConnectionManager = connectionManager as? BSBleConnectionManager else {
            logger?.error("failed to cast connectionManager as BSBleConnectionManager")
            return
        }

        firmwareManager.upgradeFirmware(fileName: fileName, fileExtension: fileExtension, bundle: bundle, peripheral: bleConnectionManager.peripheral)
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

    var firmwareUpgradeDidStartPublisher: AnyPublisher<Void, Never> {
        firmwareManager.firmwareUpgradeDidStartPublisher
    }

    var firmwareUpgradeStateDidChangePublisher: AnyPublisher<(FirmwareUpgradeState, FirmwareUpgradeState), Never> {
        firmwareManager.firmwareUpgradeStateDidChangePublisher
    }

    var firmwareUpgradeDidCompletePublisher: AnyPublisher<Void, Never> {
        firmwareManager.firmwareUpgradeDidCompletePublisher
    }

    var firmwareUpgradeDidFailPublisher: AnyPublisher<(FirmwareUpgradeState, any Error), Never> {
        firmwareManager.firmwareUpgradeDidFailPublisher
    }

    var firmwareUpgradeDidCancelPublisher: AnyPublisher<FirmwareUpgradeState, Never> {
        firmwareManager.firmwareUpgradeDidCancelPublisher
    }

    var firmwareUploadProgressDidChangePublisher: AnyPublisher<(Int, Int, Float, Date), Never> {
        firmwareManager.firmwareUploadProgressDidChangePublisher
    }
}
