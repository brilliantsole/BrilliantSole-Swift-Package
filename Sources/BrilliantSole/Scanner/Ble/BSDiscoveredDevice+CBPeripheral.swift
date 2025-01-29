//
//  BSDiscoveredDevice+CBPeripheral.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/28/25.
//

import CoreBluetooth

extension BSDiscoveredDevice {
    convenience init(scanner: BSBleScanner, peripheral: CBPeripheral) {
        self.init(scanner: scanner, id: peripheral.identifier.uuidString, name: peripheral.name ?? "unknown device")
    }

    convenience init(scanner: BSBleScanner, peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        self.init(scanner: scanner, peripheral: peripheral)
        let deviceType = parseAdvertisementData(advertisementData)
        self.update(deviceType: deviceType, rssi: RSSI.intValue)
    }

    func update(peripheral: CBPeripheral) {
        self.update(name: peripheral.name)
    }

    func update(peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        self.update(peripheral: peripheral)
        let deviceType = parseAdvertisementData(advertisementData)
        self.update(deviceType: deviceType, rssi: RSSI.intValue)
    }

    private func parseAdvertisementData(_ advertisementData: [String: Any]) -> (BSDeviceType?) {
        var deviceType: BSDeviceType?
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, !manufacturerData.isEmpty {
            logger.debug("manufacturerData \(manufacturerData)")
            if manufacturerData.count >= 5 {
                logger.debug("deviceType byte: \(manufacturerData[4])")
                deviceType = .parse(manufacturerData, at: 4)
            }
        } else {
            logger.debug("no serviceData found in advertisementData")
        }
        return deviceType
    }
}
