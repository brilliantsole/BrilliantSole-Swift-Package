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
        let (deviceType, ipAddress) = parseAdvertisementData(advertisementData)
        self.update(deviceType: deviceType, rssi: RSSI.intValue, ipAddress: ipAddress)
    }

    func update(peripheral: CBPeripheral) {
        self.update(name: peripheral.name)
    }

    func update(peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        self.update(peripheral: peripheral)
        let (deviceType, ipAddress) = parseAdvertisementData(advertisementData)
        self.update(deviceType: deviceType, rssi: RSSI.intValue, ipAddress: ipAddress)
    }

    private func parseAdvertisementData(_ advertisementData: [String: Any]) -> (deviceType: BSDeviceType?, ipAddress: String?) {
        var deviceType: BSDeviceType?
        var ipAddress: String?
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, !manufacturerData.isEmpty {
            logger?.debug("manufacturerData \(manufacturerData)")
            if manufacturerData.count >= 3 {
                logger?.debug("deviceType byte: \(manufacturerData[2])")
                deviceType = .parse(manufacturerData, at: 2)
            }
            if manufacturerData.count >= 7 {
                let ipAddressBytes = manufacturerData.bytes[3 ..< 7]
                logger?.debug("ipAddressBytes: \(ipAddressBytes)")
                ipAddress = ipAddressBytes.map { String($0) }.joined(separator: ".")
            }
        } else {
            logger?.debug("no serviceData found in advertisementData")
        }
        return (deviceType, ipAddress)
    }
}
