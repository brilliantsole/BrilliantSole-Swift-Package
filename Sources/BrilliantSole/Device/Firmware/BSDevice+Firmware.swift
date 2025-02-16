//
//  BSDevice+Firmware.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/8/25.
//

import CoreBluetooth
import Foundation

public extension BSDevice {
    internal func setupFirmwareManager() {
        firmwareManager.firmwareUpgradeDidStartPublisher.sink { _ in
            self.firmwareUpgradeDidStartSubject.send()
        }.store(in: &managerCancellables)
        firmwareManager.firmwareUpgradeDidFailPublisher.sink { state, error in
            self.firmwareUpgradeDidFailSubject.send((state, error))
        }.store(in: &managerCancellables)
        firmwareManager.firmwareUpgradeDidCancelPublisher.sink { state in
            self.firmwareUpgradeDidCancelSubject.send(state)
        }.store(in: &managerCancellables)
        firmwareManager.firmwareUpgradeDidCompletePublisher.sink { _ in
            self.firmwareUpgradeDidCompleteSubject.send()
        }.store(in: &managerCancellables)
        firmwareManager.firmwareUpgradeStateDidChangePublisher.sink { previousState, newState in
            self.firmwareUpgradeStateDidChangeSubject.send((previousState, newState))
        }.store(in: &managerCancellables)
        firmwareManager.firmwareUploadProgressDidChangePublisher.sink { bytesSent, imageSize, progress, timestamp in
            self.firmwareUploadProgressDidChangeSubject.send((bytesSent, imageSize, progress, timestamp))
        }.store(in: &managerCancellables)
    }

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
}
