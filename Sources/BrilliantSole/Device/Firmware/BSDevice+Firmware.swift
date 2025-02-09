//
//  BSDevice+Firmware.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/8/25.
//

import CoreBluetooth
import Foundation
import iOSMcuManagerLibrary

public extension BSDevice {
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

    func upgradeFirmware(fileName: String = "firmware", fileExtension: String = "bin", bundle: Bundle = .main) {
        guard canUpgradeFirmware else {
            return
        }
        logger?.debug("updating firmware to \(fileName).\(fileExtension)")

        guard let bleConnectionManager = connectionManager as? BSBleConnectionManager else {
            logger?.error("failed to cast connectionManager as BSBleConnectionManager")
            return
        }

        do {
            let bleTransport = McuMgrBleTransport(bleConnectionManager.peripheral)
            firmwareUpgradeManager = FirmwareUpgradeManager(transport: bleTransport, delegate: self)
            guard let packageURL = bundle.url(forResource: fileName, withExtension: fileExtension) else {
                logger?.error("file \(fileName).\(fileExtension) not found")
                return
            }
            let package = try McuMgrPackage(from: packageURL)
            let configuration: FirmwareUpgradeConfiguration = .init(estimatedSwapTime: 10.0, pipelineDepth: 2, upgradeMode: .confirmOnly)
            try firmwareUpgradeManager?.start(package: package, using: configuration)
        } catch {
            logger?.error("error updating firmware: \(error.localizedDescription)")
        }
    }
}
