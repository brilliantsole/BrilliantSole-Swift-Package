//
//  BSDevicePair+DeviceListeners.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

extension BSDevicePair {
    func addListeners(device: BSDevice) {
        if deviceCancellables[device] != nil {
            removeListeners(device: device)
        }
        deviceCancellables[device] = .init()

        addDeviceConnectionListeners(device: device)
        addDeviceSensorConfigurationListeners(device: device)
        addDeviceSensorDataListeners(device: device)
        addDeviceFileTransferListeners(device: device)
        addDeviceTfliteListeners(device: device)
    }

    func removeListeners(device: BSDevice) {
        deviceCancellables[device] = nil
    }
}
