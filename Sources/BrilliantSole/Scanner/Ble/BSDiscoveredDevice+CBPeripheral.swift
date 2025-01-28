//
//  BSDiscoveredDevice+CBPeripheral.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/28/25.
//

import CoreBluetooth

extension BSDiscoveredDevice {
    convenience init(scanner: BSBleScanner, peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        self.init(scanner: scanner, id: peripheral.identifier.uuidString, name: peripheral.name ?? "unknown device", rssi: RSSI.intValue)
        let deviceType = parseAdvertisementData(advertisementData)
        self.update(deviceType: deviceType)
    }

    func update(peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceType = parseAdvertisementData(advertisementData)
        self.update(name: peripheral.name, deviceType: deviceType, rssi: RSSI.intValue)
    }

    private func parseAdvertisementData(_ advertisementData: [String: Any]) -> (BSDeviceType?) {
        var deviceType: BSDeviceType?
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (serviceUUID, data) in serviceData {
                logger.debug("Service UUID: \(serviceUUID)")
                logger.debug("Service Data: \(data)")
            }
        } else {
            logger.debug("no serviceData found in advertisementData")
        }
        return deviceType
    }
}
