//
//  BSBleConnectionManager+CBPeripheralDelegate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/28/25.
//

import CoreBluetooth

extension BSBleConnectionManager: CBPeripheralDelegate {
    // MARK: - name

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        logger.debug("peripheral updated name \(peripheral.name ?? "unknown")")
        discoveredDevice.update(name: peripheral.name)
    }

    // MARK: - rssi

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?) {
        if let error {
            logger.error("error reading rssi services for \(peripheral): \(error)")
            return
        }
        logger.debug("read RSSI \(RSSI) for peripheral \(peripheral.name ?? "unknown")")
    }

    // MARK: - ready

    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        logger.debug("peripheral \(peripheral) is ready to send write without response")
    }

    // MARK: - services

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.debug("services \(invalidatedServices) invalidated for peripheral \(peripheral.name ?? "unknown")")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error {
            logger.error("error discovering services for \(peripheral): \(error)")
            return
        }
        logger.debug("discovered services for peripheral \(peripheral.name ?? "unknown")")
        peripheral.services?.forEach { service in
            guard let serviceEnum = BSBleServiceUUID(service: service) else {
                return
            }
            services[serviceEnum] = service
            logger.debug("discovering characteristics for \(serviceEnum.name)")
            peripheral.discoverCharacteristics(serviceEnum.characteristicUUIDs, for: service)
        }
    }

    // MARK: - characteristics

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error {
            logger.error("error discovering characteristics for \(service.uuid): \(error)")
            return
        }
        guard let serviceEnum = BSBleServiceUUID(service: service) else {
            return
        }
        logger.debug("discovered characteristics for \(serviceEnum.name)")
        service.characteristics?.forEach { characteristic in
            guard let characteristicEnum = BSBleCharacteristicUUID(characteristic: characteristic) else {
                return
            }
            logger.debug("discovered characteristic \(characteristicEnum.name)")
            characteristics[characteristicEnum] = characteristic
            if characteristic.properties.contains(.notify), characteristicEnum.notifyOnConnection {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.read), characteristicEnum.readOnConnection {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let characteristicEnum = BSBleCharacteristicUUID(characteristic: characteristic) else {
            return
        }
        if let error {
            logger.error("error updating notificationState for \(characteristicEnum.name): \(error)")
            return
        }
        logger.debug("notification state updated for \(characteristicEnum.name): \(characteristic.isNotifying)")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let characteristicEnum = BSBleCharacteristicUUID(characteristic: characteristic) else {
            return
        }
        if let error {
            logger.error("error writing value for \(characteristicEnum.name): \(error)")
            return
        }
        logger.debug("wrote characteristic \(characteristicEnum.name)")
        if characteristicEnum == .tx {
            sendTxDataSubject.send()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let characteristicEnum = BSBleCharacteristicUUID(characteristic: characteristic) else {
            return
        }
        if let error {
            logger.error("error updating value for \(characteristicEnum.name): \(error)")
            return
        }
        if let data = characteristic.value {
            logger.debug("value updated for characteristic \(characteristicEnum.name) (\(data.count) bytes)")
            switch characteristicEnum {
            case .batteryLevel:
                if let batteryLevel = BSBatteryLevel.parse(data) {
                    logger.debug("batteryLevel: \(batteryLevel)")
                    batteryLevelSubject.send(batteryLevel)
                }
            case let c where c.isDeviceInformation:
                if let deviceInformationType = c.deviceInformationType {
                    let string = String.parse(data)
                    logger.debug("\(deviceInformationType.name): \(string)")
                    deviceInformationSubject.send((deviceInformationType, string))
                }
            case .rx:
                parseRxData(data)
            default:
                logger.error("uncaught characteristic \(characteristicEnum.name)")
            }
        }
        else {
            logger.error("unable to read data from characteristic \(characteristicEnum.name)")
        }
    }
}
