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
    var canUpdateFirmware: Bool {
        isConnected && connectionType == .ble && (is_iOS || isMacOs)
    }

    func updateFirmware(fileName: String = "firmware", extension: String = "bin", bundle: Bundle = .main) {
        guard canUpdateFirmware else {
            logger?.error("cannot update firmware - can only update firmware on iOS/MacOS via bluetooth")
            return
        }
        logger?.debug("updating firmware...")

        guard let bleConnectionManager = connectionManager as? BSBleConnectionManager else {
            logger?.error("failed to cast connectionManager as BSBleConnectionManager")
            return
        }

        do {
            let bleTransport = McuMgrBleTransport(bleConnectionManager.peripheral)
            let dfuManager = FirmwareUpgradeManager(transport: bleTransport, delegate: self)
            guard let packageURL = bundle.url(forResource: fileName, withExtension: "bin") else {
                logger?.error("file \(fileName).bin not found")
                return
            }

            let package = try McuMgrPackage(from: packageURL)
            try dfuManager.start(package: package)
        } catch {
            logger?.error("error updating firmware: \(error.localizedDescription)")
        }
    }
}
